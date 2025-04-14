app/core/engine.py
app/core/engine.py
app/core/engine.py
from fastapi import APIRouter
async def health_check():

async def health_check():
health_router = APIRouter()
@health_router.get("/health", include_in_schema=False)

@health_router.get("/health", include_in_schema=False)
async def health_check():
    return {"status": "healthy"}

async def health_check():
    return {"status": "healthy"}
@health_router.get("/health", include_in_schema=False)
@health_router.get("/health", include_in_schema=False)

    return {"status": "healthy"}
