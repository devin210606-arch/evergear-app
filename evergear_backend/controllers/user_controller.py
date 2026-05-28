from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel, field_validator
from database import get_db
from services import user_service
from core import security
from core.dependencies import get_current_user
from core.security import get_password_hash
from models.user_model import User, PasswordReset
from models.listing_model import Listing
from models.wallet_model import Transaction
from fastapi.security import OAuth2PasswordRequestForm
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
import shutil
import os
import random
from datetime import datetime, timedelta
from schemas.engagement_schema import EcoStatsResponse
from models.order_model import Order

router = APIRouter()

# The exact JSON format expected from Flutter
class UserCreate(BaseModel):
    name: str
    email: str
    password: str
    # role is optional; if they don't send it, it defaults to 'user'
    @field_validator('email')
    @classmethod
    def validate_gmail(cls, v):
        # Check if the text ends with exactly "@gmail.com"
        if not v.lower().endswith('@gmail.com'):
            raise ValueError('Email must be a valid @gmail.com address')
        return v

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

class ForgotPasswordRequest(BaseModel):
    email: str

class VerifyOTPRequest(BaseModel):
    email: str
    otp_code: str

class ResetPasswordRequest(BaseModel):
    email: str
    otp_code: str
    new_password: str


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

    db.query(Listing).filter(Listing.seller_id == current_user.id).update(
            {"seller_name": user_update.name}
    )
    db.query(Order).filter(Order.seller_id == current_user.id).update(
        {"seller_name": user_update.name}
    )
    db.query(Order).filter(Order.buyer_id == current_user.id).update(
        {"buyer_name": user_update.name}
    )

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


# ==========================================
#  ECO STATS
# ==========================================

@router.get("/me/stats", response_model=EcoStatsResponse)
def get_user_eco_stats(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    
    # 1. Count parts sold (Listings created by user that are marked "sold")
    parts_sold = db.query(Listing).filter(
        Listing.seller_id == current_user.id, 
        Listing.status == "sold"
    ).count()

    # 2. Count parts bought (Using wallet purchase transactions as a proxy)
    parts_bought = db.query(Transaction).filter(
        Transaction.user_id == current_user.id,
        Transaction.type == "purchase"
    ).count()

    # 3. Calculate Eco Metrics
    saved_from_landfill = parts_sold + parts_bought
    
    # Arbitrary gamification formula for CO2 percentage (e.g., each part is a 2% boost, capped at 100%)
    co2_percent = min(saved_from_landfill * 2, 100) 

    return {
        "parts_sold": parts_sold,
        "parts_bought": parts_bought,
        "co2_reduced_percent": co2_percent,
        "parts_saved_from_landfill": saved_from_landfill
    }

# ==========================================
# FORGOT PASSWORD & OTP
# ==========================================

@router.post("/forgot-password")
def forgot_password(data: ForgotPasswordRequest, db: Session = Depends(get_db)):
    # 1. Check if user exists
    user = db.query(User).filter(User.email == data.email).first()
    if not user:
        # Security best practice: Don't reveal if an email is registered or not
        return {"message": "If an account exists, an OTP has been sent."}

    # 2. Generate a 6-digit OTP and set expiration (e.g., 15 minutes)
    otp_code = str(random.randint(100000, 999999))
    expiry = datetime.utcnow() + timedelta(minutes=15)

    # 3. Save to database
    reset_record = PasswordReset(email=data.email, otp=otp_code, expires_at=expiry)
    db.add(reset_record)
    db.commit()

    # 4. Simulate sending an email (Check your VS Code terminal for this print statement!)
    print(f"\n" + "="*40)
    print(f"📧 SIMULATED EMAIL TO: {data.email}")
    print(f"🔐 YOUR OTP CODE IS: {otp_code}")
    print("="*40 + "\n")

    return {"message": "If an account exists, an OTP has been sent."}


@router.post("/verify-otp")
def verify_otp(data: VerifyOTPRequest, db: Session = Depends(get_db)):
    # Look for a valid, unexpired OTP for this email
    record = db.query(PasswordReset).filter(
        PasswordReset.email == data.email,
        PasswordReset.otp == data.otp_code,
        PasswordReset.expires_at > datetime.utcnow()
    ).first()

    if not record:
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")

    return {"message": "OTP verified successfully. You can now reset your password."}


@router.post("/reset-password")
def reset_password(data: ResetPasswordRequest, db: Session = Depends(get_db)):
    # 1. Double-check the OTP is still valid just in case
    record = db.query(PasswordReset).filter(
        PasswordReset.email == data.email,
        PasswordReset.otp == data.otp_code,
        PasswordReset.expires_at > datetime.utcnow()
    ).first()

    if not record:
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")

    # 2. Find the actual user
    user = db.query(User).filter(User.email == data.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # 3. Hash the new password and update the user record
    user.hashed_password = get_password_hash(data.new_password)
    
    # 4. Delete the OTP record so it can't be reused
    db.delete(record)
    db.commit()

    return {"message": "Password has been successfully reset."}