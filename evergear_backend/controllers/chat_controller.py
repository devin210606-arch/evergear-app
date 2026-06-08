from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import or_
from typing import List
from database import get_db
from core.dependencies import get_current_user
from models.user_model import User
from models.chat_model import Conversation, Message
from models.listing_model import Listing # Ensure this matches your actual listing model filename
from schemas.chat_schema import ChatSummaryResponse, MessageResponse, SendMessageRequest
from datetime import timedelta

router = APIRouter()

# 1. GET All My Conversations (For the Inbox List)
@router.get("/", response_model=List[ChatSummaryResponse])
def get_my_chats(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    # Find all conversations where I am either the buyer or the seller
    conversations = db.query(Conversation).filter(
        or_(Conversation.buyer_id == current_user.id, Conversation.seller_id == current_user.id)
    ).all()

    chat_list = []
    for conv in conversations:
        # Determine who the "other user" is
        is_buyer = current_user.id == conv.buyer_id
        other_user = conv.seller if is_buyer else conv.buyer

        # Get the latest message
        last_msg = db.query(Message).filter(Message.conversation_id == conv.id).order_by(Message.created_at.desc()).first()
        
        # Count unread messages sent by the OTHER person
        unread_count = db.query(Message).filter(
            Message.conversation_id == conv.id,
            Message.sender_id != current_user.id,
            Message.is_read == False
        ).count()

        # Shift UTC to WIB (UTC+7) and format for the UI
        if last_msg:
            local_time = last_msg.created_at + timedelta(hours=7)
            time_str = local_time.strftime("%H:%M")
        else:
            time_str = ""

        chat_list.append({
            "id": conv.id,
            "otherUser": other_user.name if other_user else "Unknown User",
            "product": conv.listing.title if conv.listing else "Deleted Item",
            "lastMessage": last_msg.text if last_msg else "No messages yet",
            "time": time_str,
            "unread": unread_count
        })

    return chat_list


# 2. GET Messages for a Specific Chat
@router.get("/{conversation_id}/messages", response_model=List[MessageResponse])
def get_chat_messages(conversation_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    # Fetch messages in chronological order
    messages = db.query(Message).filter(Message.conversation_id == conversation_id).order_by(Message.created_at.asc()).all()
    
    # Mark incoming messages as read since the user just opened the chat
    for msg in messages:
        if msg.sender_id != current_user.id and not msg.is_read:
            msg.is_read = True
    db.commit()

    # Format for the UI
    return [{"text": m.text, "isMe": m.sender_id == current_user.id} for m in messages]


# 3. POST Send a New Message
@router.post("/{conversation_id}/messages", response_model=MessageResponse)
def send_message(conversation_id: int, data: SendMessageRequest, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    new_msg = Message(
        conversation_id=conversation_id,
        sender_id=current_user.id,
        text=data.text
    )
    db.add(new_msg)
    db.commit()
    
    return {"text": new_msg.text, "isMe": True}


# 4. POST Start a New Conversation from a Listing Page
@router.post("/start/{listing_id}")
def start_conversation(listing_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    listing = db.query(Listing).filter(Listing.id == listing_id).first()
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
        
    if listing.seller_id == current_user.id:
        raise HTTPException(status_code=400, detail="You cannot message yourself")

    # Check if conversation already exists
    existing_conv = db.query(Conversation).filter(
        Conversation.listing_id == listing_id,
        Conversation.buyer_id == current_user.id
    ).first()

    if existing_conv:
        return {"conversation_id": existing_conv.id}

    # Create new conversation
    new_conv = Conversation(
        listing_id=listing_id,
        buyer_id=current_user.id,
        seller_id=listing.seller_id
    )
    db.add(new_conv)
    db.commit()
    db.refresh(new_conv)

    return {"conversation_id": new_conv.id}

@router.get("/unread-count")
async def get_unread_count(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    try:
        # Menghitung pesan yang masuk ke user ini dan belum dibaca
        unread_count = db.query(Message).filter(
            Message.receiver_id == current_user.id,
            Message.is_read == False
        ).count()
        
        return {
            "success": True, 
            "data": {"count": unread_count}
        }
    except Exception as e:
        return {
            "success": False, 
            "message": str(e)
        }