from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
import jwt
from sqlalchemy.orm import Session
from database import get_db
from repositories import user_repository
from core.security import SECRET_KEY, ALGORITHM

# This tells FastAPI where the login door is, so it can show the "padlock" in the /docs
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="users/login")

# This is our Bouncer function
def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    try:
        # 1. Read the keycard (Decode the JWT)
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise HTTPException(status_code=401, detail="Invalid token")
            
    except jwt.PyJWTError:
        # If the token is fake or expired, kick them out
        raise HTTPException(status_code=401, detail="Invalid or expired token")
    
    # 2. Find the user in the database
    user = user_repository.get_user_by_email(db, email=email)
    if user is None:
        raise HTTPException(status_code=401, detail="User no longer exists")
        
    # 3. Let them through!
    return user