from sqlalchemy.orm import Session
from models.user_model import User

def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

def create_user(db: Session, name: str, email: str, hashed_password: str, role: str):
    new_user = User(
        name=name, 
        email=email, 
        hashed_password=hashed_password, 
        role=role
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user