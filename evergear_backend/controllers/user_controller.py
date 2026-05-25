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
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
import shutil
import os

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
        "phone": current_user.phone,
        "avatar": current_user.avatar,
        "message": "You made it past the bouncer!"
    }
# Update profile
class UserUpdate(BaseModel):
    name: str
    email: str
    phone: str = None

@router.put("/me")
def update_profile(
    user_update: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    current_user.name = user_update.name
    current_user.email = user_update.email
    if user_update.phone:
        current_user.phone = user_update.phone
    db.commit()
    db.refresh(current_user)
    return {
        "message": "Profile updated successfully!",
        "name": current_user.name,
        "email": current_user.email,
    }

# Change password
class PasswordChange(BaseModel):
    current_password: str
    new_password: str

@router.put("/me/password")
def change_password(
    data: PasswordChange,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    from passlib.context import CryptContext
    pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
    
    if not pwd_context.verify(data.current_password, current_user.hashed_password):
        raise HTTPException(status_code=400, detail="Current password is incorrect")
    
    current_user.hashed_password = pwd_context.hash(data.new_password)
    db.commit()
    return {"message": "Password changed successfully!"}

# Upload avatar
@router.put("/me/avatar")
def upload_avatar(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Create uploads folder if it doesn't exist
    os.makedirs("uploads/avatars", exist_ok=True)
    
    # Save file
    file_path = f"uploads/avatars/{current_user.id}_{file.filename}"
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    # Save path to user
    current_user.avatar = file_path
    db.commit()
    
    return {
        "message": "Avatar uploaded successfully!",
        "avatar_url": file_path
    }

# Get avatar - serve the file
from fastapi.responses import FileResponse

@router.get("/me/avatar")
def get_avatar(current_user: User = Depends(get_current_user)):
    if not current_user.avatar or not os.path.exists(current_user.avatar):
        raise HTTPException(status_code=404, detail="No avatar found")
    return FileResponse(current_user.avatar)