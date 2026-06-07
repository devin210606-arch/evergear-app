from pydantic import BaseModel
from typing import Optional

# --- REVIEWS ---
class ReviewCreate(BaseModel):
    rating: float
    comment: Optional[str] = ""

class ReviewResponse(BaseModel):
    id: int
    listing_id: int
    reviewer_id: int
    reviewer_name: str
    rating: float
    comment: str
    created_at: str

    class Config:
        from_attributes = True

# --- ECO STATS ---
class EcoStatsResponse(BaseModel):
    parts_sold: int
    parts_bought: int
    co2_reduced_percent: float
    parts_saved_from_landfill: int