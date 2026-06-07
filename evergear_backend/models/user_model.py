from sqlalchemy import Column, Integer, String, DateTime, Float
from database import Base
from sqlalchemy.orm import relationship
from datetime import datetime, timedelta


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    role = Column(String, default="user", nullable=False)
    phone = Column(String, nullable=True)
    avatar = Column(String, nullable=True)
    wallet_balance = Column(Integer, default=0, nullable=False)
    total_rating_score = Column(Float, default=0.0) 
    rating_count = Column(Integer, default=0)
    transactions = relationship("Transaction", back_populates="user")
    

class PasswordReset(Base):
    __tablename__ = "password_resets"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, index=True, nullable=False)
    otp = Column(String, nullable=False)
    expires_at = Column(DateTime, nullable=False)