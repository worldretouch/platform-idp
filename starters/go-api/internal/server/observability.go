package server

import (
	"encoding/json"
	"log"
	"net/http"
)

// RequestLogFields builds a JSON-safe request log payload.
func RequestLogFields(method, path string, statusCode int, requestID, traceID string) map[string]any {
	return map[string]any{
		"level":            "info",
		"message":          "request completed",
		"request_id":       requestID,
		"trace_id":         traceID,
		"http.method":      method,
		"http.path":        path,
		"http.status_code": statusCode,
	}
}

// ObservabilityMiddleware injects correlation IDs and logs one JSON line per request.
func ObservabilityMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		requestID := r.Header.Get("X-Request-Id")
		if requestID == "" {
			requestID = "req-" + r.Method
		}
		traceID := r.Header.Get("X-Trace-Id")
		if traceID == "" {
			traceID = requestID
		}

		w.Header().Set("X-Request-Id", requestID)
		w.Header().Set("X-Trace-Id", traceID)

		rec := &statusRecorder{ResponseWriter: w, statusCode: http.StatusOK}
		next.ServeHTTP(rec, r)

		payload, _ := json.Marshal(RequestLogFields(r.Method, r.URL.Path, rec.statusCode, requestID, traceID))
		log.Println(string(payload))
	})
}

type statusRecorder struct {
	http.ResponseWriter
	statusCode int
}

func (r *statusRecorder) WriteHeader(code int) {
	r.statusCode = code
	r.ResponseWriter.WriteHeader(code)
}
