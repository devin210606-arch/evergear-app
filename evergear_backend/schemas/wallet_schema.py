from pydantic import BaseModel, field_validator
from datetime import datetime
from typing import Any

class WalletBalanceResponse(BaseModel):
    balance: int

class TopUpRequest(BaseModel):
    amount: Any 

    @field_validator('amount', mode='before')
    @classmethod
    def clean_amount(cls, v: Any) -> int:
        if isinstance(v, str):
            cleaned = v.replace('.', '').strip()
            return int(cleaned)
        return int(v)

class WithdrawRequest(BaseModel):
    amount: Any
    bank_account: str 

    @field_validator('amount', mode='before')
    @classmethod
    def clean_amount(cls, v: Any) -> int:
        if isinstance(v, str):
            cleaned = v.replace('.', '').strip()
            return int(cleaned)
        return int(v)

class TransactionResponse(BaseModel):
    id: int
    type: str
    amount: str 
    description: str
    date: str 

    class Config:
        from_attributes = True