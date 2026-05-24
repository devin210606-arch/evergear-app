from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from database import Base

class Gadget(Base):
    __tablename__ = "gadgets"

    id = Column(Integer, primary_key=True, index=True)
    item_name = Column(String, nullable=False)
    damage_description = Column(String, nullable=False)
    
    # The Foreign Key linking this gadget to the specific user who owns it
    user_id = Column(Integer, ForeignKey("users.id"))

    # This tells SQLAlchemy to build a two-way street between the tables
    owner = relationship("User")