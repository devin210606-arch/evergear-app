from fastapi import FastAPI
from database import engine, Base
from controllers import user_controller
from controllers import user_controller, gadget_controller
from models import gadget_model, service_model

# Automatically create the SQLite database tables on startup
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="EverGear API",
    description="Monolithic Backend for Gadget Owners & Technicians"
)

# Attach the user routes to the app
app.include_router(user_controller.router, prefix="/users", tags=["Users"])
app.include_router(gadget_controller.router, prefix="/gadgets", tags=["Gadgets"])

@app.get("/")
def read_root():
    return {"message": "EverGear Monolithic Backend is online and ready!"}

