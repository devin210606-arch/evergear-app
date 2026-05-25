from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from database import get_db
from core.dependencies import get_current_user
from models.user_model import User
from models.order_model import Order
from models.listing_model import Listing
from models.wallet_model import Transaction

router = APIRouter()

class OrderCreate(BaseModel):
    listing_id: int
    payment_method: str

class StatusUpdate(BaseModel):
    status: str

# POST create order (Buy Now)
@router.post("")
def create_order(
    order_data: OrderCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    listing = db.query(Listing).filter(Listing.id == order_data.listing_id).first()
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    if listing.seller_id == current_user.id:
        raise HTTPException(status_code=400, detail="You cannot buy your own listing")
    if listing.status != "available":
        raise HTTPException(status_code=400, detail="Listing is not available")

    # 1. NEW: SECURITY CHECK
    if current_user.wallet_balance < listing.price:
        raise HTTPException(status_code=400, detail="Insufficient funds in wallet")

    # 2. NEW: DEDUCT THE MONEY
    current_user.wallet_balance -= listing.price

    new_order = Order(
        listing_id=listing.id,
        buyer_id=current_user.id,
        buyer_name=current_user.name,
        seller_id=listing.seller_id,
        seller_name=listing.seller_name,
        product_title=listing.title,
        price=listing.price,
        payment_method=order_data.payment_method,
        status="pending"
    )

    # Mark listing as in_progress
    listing.status = "in_progress"

    db.add(new_order)
   
    buyer_transaction = Transaction(
        user_id=current_user.id,
        type="purchase",         
        amount=-listing.price,   
        description=f"Bought {listing.title}",
        status="completed"
    )
    db.add(buyer_transaction)

    db.commit()
    db.refresh(new_order)

    return {
        "message": "Order created successfully!",
        "order_id": new_order.id,
        "product": new_order.product_title,
        "status": new_order.status
    }

# GET my orders as buyer
@router.get("")
def get_my_orders(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    orders = db.query(Order).filter(Order.buyer_id == current_user.id).all()
    return [
        {
            "id": o.id,
            "listing_id": o.listing_id,
            "product": o.product_title,
            "price": o.price,
            "payment_method": o.payment_method,
            "status": o.status,
            "seller_name": o.seller_name,
        }
        for o in orders
    ]

# GET my orders as seller
@router.get("/selling")
def get_selling_orders(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    orders = db.query(Order).filter(Order.seller_id == current_user.id).all()
    return [
        {
            "id": o.id,
            "listing_id": o.listing_id,
            "product": o.product_title,
            "price": o.price,
            "payment_method": o.payment_method,
            "status": o.status,
            "buyer_name": o.buyer_name,
        }
        for o in orders
    ]

# GET single order
@router.get("/{order_id}")
def get_order(
    order_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return {
        "id": order.id,
        "product": order.product_title,
        "price": order.price,
        "status": order.status,
        "buyer_name": order.buyer_name,
        "seller_name": order.seller_name,
        "payment_method": order.payment_method,
    }

# PUT buyer confirms received
@router.put("/{order_id}/confirm")
def confirm_received(
    order_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    if order.buyer_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not your order")
    
    order.status = "completed"
    
    # Mark listing as sold
    listing = db.query(Listing).filter(Listing.id == order.listing_id).first()
    if listing:
        listing.status = "sold"
    
    db.commit()
    return {"message": "Order confirmed!", "status": "completed"}

# PUT seller updates status
@router.put("/{order_id}/status")
def update_order_status(
    order_id: int,
    status_data: StatusUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    if order.seller_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not your order")
    
    order.status = status_data.status
    db.commit()
    return {"message": f"Order status updated to {status_data.status}"}