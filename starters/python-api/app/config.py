"""Platform contract: PORT, APP_ENV, LOG_LEVEL, DATABASE_URL, REDIS_URL, RABBITMQ_URL."""

import os
from dataclasses import dataclass
from typing import Optional


@dataclass
class Config:
    port: int
    app_env: str
    log_level: str
    database_url: Optional[str] = None
    redis_url: Optional[str] = None
    rabbitmq_url: Optional[str] = None


def load_config() -> Config:
    return Config(
        port=int(os.getenv("PORT", "3000")),
        app_env=os.getenv("APP_ENV", "development"),
        log_level=os.getenv("LOG_LEVEL", "info"),
        database_url=os.getenv("DATABASE_URL"),
        redis_url=os.getenv("REDIS_URL"),
        rabbitmq_url=os.getenv("RABBITMQ_URL"),
    )
