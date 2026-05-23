from sqlalchemy import Column, Integer, String, Float, ForeignKey
from sqlalchemy.orm import relationship
from database import Base

class ServiceRequest(Base):
    __tablename__ = "service_requests"

    id = Column(Integer, primary_key=True, index=True)
    status = Column(String, default="pending") # Can be: pending, accepted, completed
    price = Column(Float, nullable=True) # Blank until a technician sets a price
    
    # Linking the items and the people
    gadget_id = Column(Integer, ForeignKey("gadgets.id"))
    technician_id = Column(Integer, ForeignKey("users.id"), nullable=True) # Blank until accepted

    gadget = relationship("Gadget")
    technician = relationship("User")