from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from database import get_db
from services import user_service
from core import security
from core.dependencies import get_current_user
from models.user_model import User
# Add this next to your other FastAPI imports
from fastapi.security import OAuth2PasswordRequestForm

router = APIRouter()

# The exact JSON format expected from Flutter
class UserCreate(BaseModel):
    name: str
    email: str
    password: str
    # role is optional; if they don't send it, it defaults to 'user'

# The endpoint will call: http://10.0.2.2:8000/users/register
@router.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):
    
    # Pass the validated data to the service layer
    new_user = user_service.register_new_user(
        db=db, 
        name=user.name, 
        email=user.email, 
        password=user.password
    )
    
    # The JSON data sent back to the Flutter app
    return {
        "message": "User registered successfully!", 
        "user_id": new_user.id,
        "email": new_user.email,
        "role": new_user.role
    }


# 1. The exact JSON format expected from Flutter for logging in
@router.post("/login")
# The ONE and ONLY Login Endpoint
@router.post("/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    
    # Swagger calls the box "username", but we will type our email into it!
    user = user_service.authenticate_user(db, form_data.username, form_data.password)
    
    if not user:
        raise HTTPException(status_code=401, detail="Incorrect email or password")

    access_token = security.create_access_token(
        data={"sub": user.email, "role": user.role}
    )

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_id": user.id,
        "role": user.role,
        "message": "Successfully logged in!"
    }

@router.get("/me")
def get_my_profile(current_user: User = Depends(get_current_user)):
    return {
        "name": current_user.name,
        "email": current_user.email,
        "role": current_user.role,
        "message": "You made it past the bouncer!"
    }