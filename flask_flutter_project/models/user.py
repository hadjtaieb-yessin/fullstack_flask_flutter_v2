from . import db
from werkzeug.security import generate_password_hash, check_password_hash


class User(db.Model):
    __tablename__ = "Users"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)

    # Créer le hash du mot de passe
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    # Vérifier le mot de passe
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

    # Convertir en dict (optionnel)
    def to_dict(self):
        return {"id": self.id, "username": self.username}
