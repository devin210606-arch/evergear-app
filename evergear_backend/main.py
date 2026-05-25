from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import engine, Base
from controllers import user_controller, gadget_controller, listing_controller, order_controller
from models import gadget_model, service_model, listing_model, order_model


# Automatically create the SQLite database tables on startup
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="EverGear API",
    description="Monolithic Backend for Gadget Owners & Technicians"
)

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
app.include_router(gadget_controller.router, prefix="/gadgets", tags=["Gadgets"])
app.include_router(listing_controller.router, prefix="/listings", tags=["Listings"])
app.include_router(order_controller.router, prefix="/orders", tags=["Orders"])

@app.get("/")
def read_root():
    return {"message": "EverGear Monolithic Backend is online and ready!"}