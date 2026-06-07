from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional
from database import get_db
from core.dependencies import get_current_user
from models.user_model import User
from models.listing_model import Listing
import os
import shutil

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

# 🟢 HELPER FUNCTION: Calculates the real average rating safely before sending to Flutter
def get_seller_rating(db: Session, seller_id: int) -> float:
    seller = db.query(User).filter(User.id == seller_id).first()
    # Check if seller exists and has been rated at least once
    if seller and getattr(seller, 'rating_count', 0) > 0:
        return round(seller.total_rating_score / seller.rating_count, 1)
    return 0.0 # Default fallback if no ratings yet

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
            "seller_rating": get_seller_rating(db, l.seller_id) # 🟢 Attached rating here!
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
            "seller_rating": get_seller_rating(db, l.seller_id) # 🟢 Attached rating here!
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
    
    # Calculate current user's own rating to attach to their inventory
    my_rating = 0.0
    if getattr(current_user, 'rating_count', 0) > 0:
        my_rating = round(current_user.total_rating_score / current_user.rating_count, 1)

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
            "seller_rating": my_rating # 🟢 Attached rating here!
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
        "seller_rating": get_seller_rating(db, listing.seller_id) # 🟢 Attached rating here!
    }

# POST create listing
@router.post("")
def create_listing(
    title: str = Form(...),
    price: int = Form(...),
    category: str = Form(...),
    condition: str = Form(...),
    description: str = Form(None), 
    image: UploadFile = File(None), 
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    photo_url = None
    
    if image is not None:
        os.makedirs("uploads", exist_ok=True)
        file_location = f"uploads/{image.filename}"
        with open(file_location, "wb+") as file_object:
            shutil.copyfileobj(image.file, file_object)
        
        photo_url = f"http://10.0.2.2:8000/{file_location}"

    new_listing = Listing(
        title=title,
        price=price,
        category=category,
        condition=condition,
        description=description,
        seller_id=current_user.id,
        seller_name=current_user.name,
        status="available",
        photo=photo_url 
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
    title: str = Form(...),
    price: int = Form(...),
    category: str = Form(...),
    condition: str = Form(...),
    description: str = Form(None),
    image: UploadFile = File(None), 
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    listing = db.query(Listing).filter(Listing.id == listing_id).first()
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    if listing.seller_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not your listing")
    
    listing.title = title
    listing.price = price
    listing.category = category
    listing.condition = condition
    listing.description = description

    if image is not None:
        os.makedirs("uploads", exist_ok=True)
        file_location = f"uploads/{image.filename}"
        with open(file_location, "wb+") as file_object:
            shutil.copyfileobj(image.file, file_object)
        
        listing.photo = f"http://10.0.2.2:8000/{file_location}"

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