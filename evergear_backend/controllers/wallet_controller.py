from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from database import get_db
from core.dependencies import get_current_user
from models.user_model import User
from models.wallet_model import Transaction
from schemas.wallet_schema import WalletBalanceResponse, TopUpRequest, WithdrawRequest, TransactionResponse

router = APIRouter()

@router.get("/", response_model=WalletBalanceResponse)
def get_wallet_balance(current_user: User = Depends(get_current_user)):
    return {"balance": current_user.wallet_balance}

@router.post("/topup", response_model=WalletBalanceResponse)
def topup_wallet(data: TopUpRequest, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if data.amount <= 0:
        raise HTTPException(status_code=400, detail="Amount must be greater than zero")

    current_user.wallet_balance += data.amount

    new_tx = Transaction(
        user_id=current_user.id,
        type="topup",
        amount=data.amount,
        description="Top Up",
        status="success"
    )
    db.add(new_tx)
    db.commit()
    db.refresh(current_user)

    return {"balance": current_user.wallet_balance}

@router.post("/withdraw", response_model=WalletBalanceResponse)
def withdraw_wallet(data: WithdrawRequest, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if data.amount <= 0:
        raise HTTPException(status_code=400, detail="Amount must be greater than zero")
    if current_user.wallet_balance < data.amount:
        raise HTTPException(status_code=400, detail="Insufficient wallet balance")

    current_user.wallet_balance -= data.amount

    new_tx = Transaction(
        user_id=current_user.id,
        type="withdraw",
        amount=data.amount,
        description=f"Withdrawal to Bank Account: {data.bank_account}",
        status="success"
    )
    db.add(new_tx)
    db.commit()
    db.refresh(current_user)

    return {"balance": current_user.wallet_balance}

@router.get("/transactions", response_model=List[TransactionResponse])
def get_transaction_history(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    tx_records = db.query(Transaction).filter(Transaction.user_id == current_user.id).order_by(Transaction.date.desc()).all()
    
    formatted_tx = []
    for tx in tx_records:
        # Formats 200000 -> "+Rp. 200.000" or "-Rp. 200.000"
        formatted_amount = f"{'.' if tx.type in ['topup', 'sale'] else '-'}Rp. {tx.amount:,}".replace(',', '.')
        if tx.type in ['topup', 'sale']:
            formatted_amount = "+" + formatted_amount
            
        # Formats date to exactly "18 May 2025"
        ui_date = tx.date.strftime("%d %b %Y") 
        ui_title = tx.description if tx.type in ['purchase', 'sale'] else tx.type.replace('_', ' ').title()

        formatted_tx.append({
            "id": tx.id,
            "type": ui_title,
            "amount": formatted_amount,
            "description": tx.description,
            "date": ui_date
        })

    return formatted_tx