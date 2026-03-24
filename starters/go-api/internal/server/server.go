package server

import (
	"context"
	"log"
	"net/http"
	"time"
)

// Server wraps HTTP server with graceful shutdown
type Server struct {
	httpServer *http.Server
}

// New creates HTTP server
func New(addr string, mux http.Handler) *Server {
	return &Server{
		httpServer: &http.Server{
			Addr:         addr,
			Handler:      mux,
			ReadTimeout:  15 * time.Second,
			WriteTimeout: 15 * time.Second,
		},
	}
}

// Start starts the server
func (s *Server) Start() error {
	log.Printf("Listening on %s", s.httpServer.Addr)
	return s.httpServer.ListenAndServe()
}

// Shutdown gracefully shuts down the server
func (s *Server) Shutdown(ctx context.Context) error {
	return s.httpServer.Shutdown(ctx)
}
