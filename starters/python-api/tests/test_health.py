"""Health endpoint tests."""

import pytest
from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health_live():
    r = client.get("/health/live")
    assert r.status_code == 200
    data = r.json()
    assert data["status"] == "ok"
    assert "timestamp" in data


def test_health_ready():
    r = client.get("/health/ready")
    assert r.status_code == 200
    data = r.json()
    assert "status" in data
    assert "checks" in data
