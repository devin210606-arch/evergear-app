from sqlalchemy import Column, Integer, String, ForeignKey
from database import Base

class Listing(Base):
    __tablename__ = "listings"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    price = Column(Integer, nullable=False)
    category = Column(String, nullable=False)
    condition = Column(String, nullable=False)
    description = Column(String, nullable=True)
    status = Column(String, default="available")
    seller_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    seller_name = Column(String, nullable=False)
    photo = Column(String, nullable=True)