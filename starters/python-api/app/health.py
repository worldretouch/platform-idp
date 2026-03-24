"""Platform health contract: GET /health/live, GET /health/ready."""

from datetime import datetime, timezone
from typing import Callable, Optional

from fastapi import APIRouter

router = APIRouter(prefix="/health", tags=["health"])

CheckFn = Callable[[], bool]


def create_health_checks(
    database: Optional[CheckFn] = None,
    redis: Optional[CheckFn] = None,
) -> dict:
    """Run optional dependency checks."""
    checks = {}
    if database:
        try:
            checks["database"] = "ok" if database() else "error"
        except Exception:
            checks["database"] = "error"
    if redis:
        try:
            checks["redis"] = "ok" if redis() else "error"
        except Exception:
            checks["redis"] = "error"
    return checks


@router.get("/live")
def live():
    """Liveness — process is running."""
    return {
        "status": "ok",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "checks": {},
    }


@router.get("/ready")
def ready():
    """Readiness — ready for traffic. Add DB/Redis checks when configured."""
    checks = {}
    all_ok = True
    return {
        "status": "ok" if all_ok else "degraded",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "checks": checks,
    }
