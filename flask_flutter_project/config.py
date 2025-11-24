# config.py
# Contient la configuration de l'application Flask et de la base de données


class Config:
    # URI de connexion SQLAlchemy pour SQL Server via pyodbc
    SQLALCHEMY_DATABASE_URI = (
        "mssql+pyodbc://localhost\\SQLEXPRESS/TasksDB?"
        "driver=ODBC+Driver+18+for+SQL+Server&"
        "Trusted_Connection=yes&"
        "TrustServerCertificate=yes"
    )

    # Désactive le suivi des modifications d'objet pour améliorer les performances
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # Active le mode debug pour le développement (rechargement automatique + messages d'erreur)
    DEBUG = True

    # JWT
    JWT_SECRET_KEY = "yessin_hadjtaieb"
