# Contient le modèle Task et l'objet db pour SQLAlchemy

from flask_sqlalchemy import SQLAlchemy
from . import db


class Task(db.Model):
    # Nom de la table dans la base de données
    __tablename__ = "Tasks"

    # Colonnes de la table
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)  # ID unique
    title = db.Column(db.String(255), nullable=False)  # Titre de la tâche
    done = db.Column(db.Boolean, default=False)  # Statut terminé ou non

    # Convertit l'objet Task en dictionnaire Python pour retourner du JSON
    def to_dict(self):
        return {"id": self.id, "title": self.title, "done": self.done}
