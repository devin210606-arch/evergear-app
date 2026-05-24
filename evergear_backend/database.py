from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# Creates a local file named evergear.db
SQLALCHEMY_DATABASE_URL = "sqlite:///./evergear.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Dependency to open and close the database connection per request
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()