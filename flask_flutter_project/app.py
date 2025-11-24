# app.py
# Point d'entrée principal de l'application Flask

from flask import Flask
from flask_cors import CORS
from config import Config
from models import db
from models.tasks import Task
from routes.task_routes import tasks_bp
from flask_jwt_extended import JWTManager
from routes.auth_routes import auth_bp

jwt = JWTManager()


def create_app():

    app = Flask(__name__)  # Crée l'application Flask
    app.config.from_object(Config)  # Charge la configuration depuis config.py

    db.init_app(app)  # Initialise SQLAlchemy avec cette application
    jwt.init_app(app)

    CORS(app, resources={r"/*": {"origins": "*"}})  # Active CORS pour toutes les routes

    # Crée les tables dans la base si elles n'existent pas
    with app.app_context():
        db.create_all()

    # Enregistre les routes des tâches
    app.register_blueprint(tasks_bp)
    app.register_blueprint(auth_bp)

    return app


# Exécution directe du fichier app.py
if __name__ == "__main__":
    app = create_app()
    app.run()  # Lance le serveur Flask
