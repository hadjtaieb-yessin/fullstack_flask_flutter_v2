from flask import Blueprint, request, jsonify
from models.user import User, db
from flask_jwt_extended import create_access_token, jwt_required, JWTManager

auth_bp = Blueprint("auth_bp", __name__)


# REGISTER
@auth_bp.route("/register", methods=["POST"])
def register():
    data = request.json
    if User.query.filter_by(username=data["username"]).first():
        return jsonify({"msg": "Username already exists"}), 400

    user = User(username=data["username"])
    user.set_password(data["password"])
    db.session.add(user)
    db.session.commit()
    return jsonify({"msg": "User created"}), 201


# LOGIN
@auth_bp.route("/login", methods=["POST"])
def login():
    data = request.json
    user = User.query.filter_by(username=data["username"]).first()
    if user and user.check_password(data["password"]):
        access_token = create_access_token(identity=str(user.id))
        print("TOKEN:", access_token)
        return jsonify({"access_token": access_token})
    return jsonify({"msg": "Bad username or password"}), 401
