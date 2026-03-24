package health

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"time"
)

// Handler implements platform health contract
type Handler struct {
	DB    *sql.DB
	Redis interface{ Ping() error } // optional
}

type healthResponse struct {
	Status    string            `json:"status"`
	Timestamp string            `json:"timestamp"`
	Checks    map[string]string `json:"checks"`
}

// Live — GET /health/live (liveness)
func (h *Handler) Live(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(healthResponse{
		Status:    "ok",
		Timestamp: time.Now().UTC().Format(time.RFC3339),
		Checks:    map[string]string{},
	})
}

// Ready — GET /health/ready (readiness, checks deps)
func (h *Handler) Ready(w http.ResponseWriter, r *http.Request) {
	checks := make(map[string]string)
	allOk := true

	if h.DB != nil {
		if err := h.DB.Ping(); err != nil {
			checks["database"] = "error"
			allOk = false
		} else {
			checks["database"] = "ok"
		}
	}

	if h.Redis != nil {
		if err := h.Redis.Ping(); err != nil {
			checks["redis"] = "error"
			allOk = false
		} else {
			checks["redis"] = "ok"
		}
	}

	status := "ok"
	code := http.StatusOK
	if !allOk {
		status = "degraded"
		code = http.StatusServiceUnavailable
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	json.NewEncoder(w).Encode(healthResponse{
		Status:    status,
		Timestamp: time.Now().UTC().Format(time.RFC3339),
		Checks:    checks,
	})
}
