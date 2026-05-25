from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional
from database import get_db
from core.dependencies import get_current_user
from models.user_model import User
from models.listing_model import Listing
from models.engagement_model import Favorite, Review
from models.wallet_model import Transaction

router = APIRouter()

# --- Schemas defined directly in the controller (matching your style) ---
class ReviewCreate(BaseModel):
    rating: float
    comment: Optional[str] = ""

# ==========================================
# FAVORITES
# ==========================================

@router.get("/favorites", tags=["Favorites"])
def get_my_favorites(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    favorites = db.query(Favorite).filter(Favorite.user_id == current_user.id).all()
    
    # Format the favorite listings exactly like your listing_controller
    return [
        {
            "id": fav.listing.id,
            "title": fav.listing.title,
            "price": fav.listing.price,
            "category": getattr(fav.listing, 'category', None),
            "condition": fav.listing.condition,
            "description": getattr(fav.listing, 'description', None),
            "status": fav.listing.status,
            "seller_id": fav.listing.seller_id,
            "seller_name": getattr(fav.listing, 'seller_name', None),
            "photo": getattr(fav.listing, 'photo', None),
        }
        for fav in favorites if fav.listing
    ]

@router.post("/favorites/{listing_id}", tags=["Favorites"])
def add_favorite(listing_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    existing_fav = db.query(Favorite).filter(Favorite.user_id == current_user.id, Favorite.listing_id == listing_id).first()
    if existing_fav:
        return {"message": "Listing already in favorites"}

    new_fav = Favorite(user_id=current_user.id, listing_id=listing_id)
    db.add(new_fav)
    db.commit()
    return {"message": "Added to favorites"}

@router.delete("/favorites/{listing_id}", tags=["Favorites"])
def remove_favorite(listing_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    fav = db.query(Favorite).filter(Favorite.user_id == current_user.id, Favorite.listing_id == listing_id).first()
    if fav:
        db.delete(fav)
        db.commit()
    return {"message": "Removed from favorites"}

# ==========================================
# REVIEWS
# ==========================================

@router.get("/reviews/{listing_id}", tags=["Reviews"])
def get_listing_reviews(listing_id: int, db: Session = Depends(get_db)):
    reviews = db.query(Review).filter(Review.listing_id == listing_id).all()
    
    return [
        {
            "id": r.id,
            "listing_id": r.listing_id,
            "reviewer_id": r.reviewer_id,
            "reviewer_name": r.reviewer.name if r.reviewer else "Unknown",
            "rating": r.rating,
            "comment": r.comment,
            "created_at": r.created_at.strftime("%Y-%m-%dT%H:%M:%S")
        }
        for r in reviews
    ]

@router.post("/reviews/{listing_id}", tags=["Reviews"])
def leave_review(listing_id: int, data: ReviewCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    new_review = Review(
        listing_id=listing_id,
        reviewer_id=current_user.id,
        rating=data.rating,
        comment=data.comment
    )
    db.add(new_review)
    db.commit()
    db.refresh(new_review)

    return {
        "id": new_review.id,
        "listing_id": new_review.listing_id,
        "reviewer_id": new_review.reviewer_id,
        "reviewer_name": current_user.name,
        "rating": new_review.rating,
        "comment": new_review.comment,
        "created_at": new_review.created_at.strftime("%Y-%m-%dT%H:%M:%S")
    }