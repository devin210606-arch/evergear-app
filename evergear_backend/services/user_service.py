from sqlalchemy.orm import Session
from fastapi import HTTPException
from repositories import user_repository
from core import security
from models.user_model import User # <-- We added this import so it knows what 'User' is!

def register_new_user(db: Session, name: str, email: str, password: str, role: str = "user"):
    # 1. Check if user already exists
    existing_user = user_repository.get_user_by_email(db, email)
    if existing_user:
        raise HTTPException(status_code=400, detail="Email is already registered")

    # 2. Hash the password securely using bcrypt
    hashed_password = security.get_password_hash(password)

    # 3. Send to repository to save in database
    return user_repository.create_user(db, name, email, hashed_password, role)


def authenticate_user(db: Session, login_text: str, password: str):
    # 1. Check if the text looks like an email or a regular name
    if "@" in login_text:
        # It's an email! Search the database by email
        user = db.query(User).filter(User.email == login_text).first()
    else:
        # It's a username! Search the database by their name
        user = db.query(User).filter(User.name == login_text).first()

    # 2. If no user was found with that email OR name, kick them out
    if not user:
        return False
        
    # 3. Check if the password matches
    if not security.verify_password(password, user.hashed_password):
        return False
        
    return user