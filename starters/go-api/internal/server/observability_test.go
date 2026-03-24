package server

import "testing"

func TestRequestLogFields_ContainsTraceAndRequestID(t *testing.T) {
	fields := RequestLogFields("GET", "/health/live", 200, "req-123", "trace-456")

	if fields["request_id"] != "req-123" {
		t.Fatalf("expected request_id, got %v", fields["request_id"])
	}
	if fields["trace_id"] != "trace-456" {
		t.Fatalf("expected trace_id, got %v", fields["trace_id"])
	}
}
