package health

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHandler_Live(t *testing.T) {
	h := &Handler{}
	req := httptest.NewRequest(http.MethodGet, "/health/live", nil)
	rec := httptest.NewRecorder()

	h.Live(rec, req)

	if rec.Code != http.StatusOK {
		t.Errorf("got status %d, want 200", rec.Code)
	}
	if rec.Header().Get("Content-Type") != "application/json" {
		t.Errorf("got Content-Type %s", rec.Header().Get("Content-Type"))
	}
}

func TestHandler_Ready(t *testing.T) {
	h := &Handler{}
	req := httptest.NewRequest(http.MethodGet, "/health/ready", nil)
	rec := httptest.NewRecorder()

	h.Ready(rec, req)

	if rec.Code != http.StatusOK {
		t.Errorf("got status %d, want 200", rec.Code)
	}
}
