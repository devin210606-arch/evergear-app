from sqlalchemy import Column, Integer, String, ForeignKey
from database import Base

class Order(Base):
    __tablename__ = "orders"
    id = Column(Integer, primary_key=True, index=True)
    listing_id = Column(Integer, ForeignKey("listings.id"), nullable=False)
    buyer_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    buyer_name = Column(String, nullable=False)
    seller_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    seller_name = Column(String, nullable=False)
    product_title = Column(String, nullable=False)
    price = Column(Integer, nullable=False)
    payment_method = Column(String, nullable=False)
    status = Column(String, default="pending")