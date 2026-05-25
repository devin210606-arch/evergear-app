from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional
from database import get_db
from core.dependencies import get_current_user
from models.user_model import User
from models.listing_model import Listing

router = APIRouter()

class ListingCreate(BaseModel):
    title: str
    price: int
    category: str
    condition: str
    description: Optional[str] = None

class ListingUpdate(BaseModel):
    title: str
    price: int
    category: str
    condition: str
    description: Optional[str] = None

# GET all listings (Buy page)
@router.get("")
def get_listings(
    category: Optional[str] = None,
    search: Optional[str] = None,
    db: Session = Depends(get_db)
):
    query = db.query(Listing).filter(Listing.status == "available")
    if category:
        query = query.filter(Listing.category.ilike(category))
    if search:
        query = query.filter(Listing.title.ilike(f"%{search}%"))
    listings = query.all()
    return [
        {
            "id": l.id,
            "title": l.title,
            "price": l.price,
            "category": l.category,
            "condition": l.condition,
            "description": l.description,
            "status": l.status,
            "seller_id": l.seller_id,
            "seller_name": l.seller_name,
            "photo": l.photo,
        }
        for l in listings
    ]

# GET popular listings (Home page)
@router.get("/popular")
def get_popular_listings(db: Session = Depends(get_db)):
    listings = db.query(Listing).filter(
        Listing.status == "available"
    ).limit(6).all()
    return [
        {
            "id": l.id,
            "title": l.title,
            "price": l.price,
            "category": l.category,
            "condition": l.condition,
            "status": l.status,
            "seller_name": l.seller_name,
            "photo": l.photo,
        }
        for l in listings
    ]

# GET my listings (Sell page inventory)
@router.get("/mine")
def get_my_listings(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    listings = db.query(Listing).filter(
        Listing.seller_id == current_user.id
    ).all()
    return [
        {
            "id": l.id,
            "title": l.title,
            "price": l.price,
            "category": l.category,
            "condition": l.condition,
            "description": l.description,
            "status": l.status,
            "photo": l.photo,
        }
        for l in listings
    ]

# GET single listing
@router.get("/{listing_id}")
def get_listing(listing_id: int, db: Session = Depends(get_db)):
    listing = db.query(Listing).filter(Listing.id == listing_id).first()
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    return {
        "id": listing.id,
        "title": listing.title,
        "price": listing.price,
        "category": listing.category,
        "condition": listing.condition,
        "description": listing.description,
        "status": listing.status,
        "seller_id": listing.seller_id,
        "seller_name": listing.seller_name,
        "photo": listing.photo,
    }

# POST create listing
@router.post("")
def create_listing(
    listing_data: ListingCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    new_listing = Listing(
        title=listing_data.title,
        price=listing_data.price,
        category=listing_data.category,
        condition=listing_data.condition,
        description=listing_data.description,
        seller_id=current_user.id,
        seller_name=current_user.name,
        status="available"
    )
    db.add(new_listing)
    db.commit()
    db.refresh(new_listing)
    return {
        "message": "Listing created successfully!",
        "id": new_listing.id,
        "title": new_listing.title,
    }

# PUT update listing
@router.put("/{listing_id}")
def update_listing(
    listing_id: int,
    listing_data: ListingUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    listing = db.query(Listing).filter(Listing.id == listing_id).first()
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    if listing.seller_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not your listing")
    listing.title = listing_data.title
    listing.price = listing_data.price
    listing.category = listing_data.category
    listing.condition = listing_data.condition
    listing.description = listing_data.description
    db.commit()
    db.refresh(listing)
    return {"message": "Listing updated!", "id": listing.id}

# DELETE listing
@router.delete("/{listing_id}")
def delete_listing(
    listing_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    listing = db.query(Listing).filter(Listing.id == listing_id).first()
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    if listing.seller_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not your listing")
    db.delete(listing)
    db.commit()
    return {"message": "Listing deleted!"}