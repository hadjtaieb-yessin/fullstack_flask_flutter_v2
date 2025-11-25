# routes/task_routes.py
# Contient toutes les routes pour gérer les tâches

from flask import Blueprint, jsonify, request
from models.tasks import Task, db
from flask_jwt_extended import jwt_required


# Crée un Blueprint pour regrouper toutes les routes liées aux tâches
tasks_bp = Blueprint("tasks_bp", __name__)


# GET /tasks : récupérer toutes les tâches AVEC pagination
@tasks_bp.route("/tasks", methods=["GET"])
@jwt_required()
def get_tasks():
    # lire ?page= & ?limit=
    page = request.args.get("page", 1, type=int)
    limit = request.args.get("limit", 20, type=int)

    # pagination SQLAlchemy
    pagination = Task.query.order_by(Task.id).paginate(
        page=page, per_page=limit, error_out=False
    )
    # données paginées
    tasks = [task.to_dict() for task in pagination.items]

    # réponse JSON
    return jsonify(
        {
            "tasks": tasks,  # liste des tâches pour cette page
            "total": pagination.total,  # nombre total d'entrées
            "page": page,  # page actuelle (demandée par le client)
            "limit": limit,
            "pages": pagination.pages,  # nombre total de pages
        }
    )


# POST /tasks : ajouter une nouvelle tâche
@tasks_bp.route("/tasks", methods=["POST"])
@jwt_required()
def add_task():
    data = request.json  # Récupère le JSON envoyé par le client
    task = Task(title=data["title"], done=data.get("done", False))
    db.session.add(task)  # Ajoute la tâche à la session
    db.session.commit()  # Valide la transaction
    return jsonify(task.to_dict()), 201  # Retourne la tâche créée avec le code HTTP 201


# GET /tasks/<id> : récupérer une tâche par ID
@tasks_bp.route("/tasks/<int:id>", methods=["GET"])
@jwt_required()
def get_task(id):
    task = Task.query.get(id)
    if task:
        return jsonify(task.to_dict())
    return jsonify({"error": "Task not found"}), 404


# PUT /tasks/<id> : mettre à jour une tâche
@tasks_bp.route("/tasks/<int:id>", methods=["PUT"])
@jwt_required()
def update_task(id):
    task = Task.query.get_or_404(id)
    data = request.json
    task.title = data.get("title", task.title)
    task.done = data.get("done", task.done)
    db.session.commit()
    return jsonify(task.to_dict())


# DELETE /tasks/<id> : supprimer une tâche
@tasks_bp.route("/tasks/<int:id>", methods=["DELETE"])
@jwt_required()
def delete_task(id):
    task = Task.query.get_or_404(id)
    db.session.delete(task)
    db.session.commit()
    return jsonify({"message": "Task deleted"})
