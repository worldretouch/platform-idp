from app.main import build_request_log


def test_build_request_log_contains_trace_and_request_id():
    log = build_request_log("GET", "/health/live", 200, "req-123", "trace-456", 10)
    assert log["request_id"] == "req-123"
    assert log["trace_id"] == "trace-456"
