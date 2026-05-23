from datetime import datetime, timedelta, timezone
import jwt
from passlib.context import CryptContext

# Secret key used to sign your JWTs (In a real app, this goes in a hidden .env file)
SECRET_KEY = "super_secret_evergear_key_change_this_later"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

# Tell Passlib to use the bcrypt algorithm for hashing passwords
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password, hashed_password):
    """Checks if a typed password matches the scrambled database password."""
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    """Scrambles a new password before saving it to the database."""
    return pwd_context.hash(password)

def create_access_token(data: dict):
    """Generates the secure digital keycard for the Flutter app."""
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt