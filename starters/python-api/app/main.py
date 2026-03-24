"""Platform Python API — FastAPI app."""

import json
import time

from fastapi import FastAPI
from fastapi import Request

from app.config import load_config
from app.health import router as health_router

config = load_config()
app = FastAPI(title="Platform API", version="1.0.0")

app.include_router(health_router)


def build_request_log(
    method: str,
    path: str,
    status_code: int,
    request_id: str,
    trace_id: str,
    duration_ms: int,
) -> dict:
    return {
        "level": "info",
        "message": "request completed",
        "request_id": request_id,
        "trace_id": trace_id,
        "http.method": method,
        "http.path": path,
        "http.status_code": status_code,
        "duration_ms": duration_ms,
    }


@app.middleware("http")
async def observability_middleware(request: Request, call_next):
    request_id = request.headers.get("x-request-id", f"req-{int(time.time() * 1000)}")
    trace_id = request.headers.get("x-trace-id", request_id)
    start = time.time()
    response = await call_next(request)
    duration_ms = int((time.time() - start) * 1000)
    response.headers["x-request-id"] = request_id
    response.headers["x-trace-id"] = trace_id
    print(
        json.dumps(
            build_request_log(
                request.method,
                request.url.path,
                response.status_code,
                request_id,
                trace_id,
                duration_ms,
            )
        )
    )
    return response


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=config.port,
        reload=config.app_env == "development",
    )
