from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel
from database import get_db
from core.dependencies import get_current_user
from models.user_model import User
from models.gadget_model import Gadget

router = APIRouter()

# 1. Yo\API Contract (What Flutter sends)
class GadgetCreate(BaseModel):
    item_name: str
    damage_description: str
    # NO user_id! The Bouncer handles that.

# 2. The API Endpoint (http://127.0.0.1:8000/gadgets/submit)
@router.post("/submit")
def submit_broken_gadget(
    gadget_data: GadgetCreate, 
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user) # <-- The Bouncer!
):
    
    # 3. Create the database record, combining the Flutter data with the Bouncer data
    new_gadget = Gadget(
        item_name=gadget_data.item_name,
        damage_description=gadget_data.damage_description,
        user_id=current_user.id  # Automatically pulled from the JWT keycard!
    )
    
    # 4. Save to the database
    db.add(new_gadget)
    db.commit()
    db.refresh(new_gadget)
    
    return {
        "message": "Gadget submitted successfully!",
        "gadget_id": new_gadget.id,
        "owner": current_user.name
    }