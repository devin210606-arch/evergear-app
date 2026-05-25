from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base 

class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    type = Column(String, nullable=False)  # "topup", "withdraw", "purchase", "sale"
    amount = Column(Integer, nullable=False)
    description = Column(String, nullable=False) 
    date = Column(DateTime, default=datetime.utcnow, nullable=False)
    status = Column(String, default="success", nullable=False)

    user = relationship("User", back_populates="transactions")