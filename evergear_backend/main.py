from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import engine, Base
from controllers import user_controller, listing_controller, order_controller, wallet_controller, chat_controller, engagement_controller
from models import listing_model, order_model
from fastapi.staticfiles import StaticFiles
import os

# Automatically create the SQLite database tables on startup
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="EverGear API",
    description="Monolithic Backend for Gadget Owners & Technicians"
)

os.makedirs("uploads", exist_ok=True)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# Allow Flutter to talk to this API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Attach the user routes to the app
app.include_router(user_controller.router, prefix="/users", tags=["Users"])
app.include_router(listing_controller.router, prefix="/listings", tags=["Listings"])
app.include_router(order_controller.router, prefix="/orders", tags=["Orders"])
app.include_router(wallet_controller.router, prefix="/wallet", tags=["Wallet"])
app.include_router(chat_controller.router, prefix="/chats", tags=["Chat"])
app.include_router(engagement_controller.router)

@app.get("/")
def read_root():
    return {"message": "EverGear Monolithic Backend is online and ready!"}
