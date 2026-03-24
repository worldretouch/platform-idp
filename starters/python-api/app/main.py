"""Platform Python API — FastAPI app."""

from fastapi import FastAPI

from app.config import load_config
from app.health import router as health_router

config = load_config()
app = FastAPI(title="Platform API", version="1.0.0")

app.include_router(health_router)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=config.port,
        reload=config.app_env == "development",
    )
