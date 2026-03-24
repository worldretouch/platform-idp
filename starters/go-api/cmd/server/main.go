package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"github.com/myorg/go-api/internal/config"
	"github.com/myorg/go-api/internal/health"
	"github.com/myorg/go-api/internal/server"
)

func main() {
	cfg := config.Load()

	mux := http.NewServeMux()
	healthHandler := &health.Handler{} // DB/Redis set when configured
	mux.HandleFunc("/health/live", healthHandler.Live)
	mux.HandleFunc("/health/ready", healthHandler.Ready)

	handler := server.ObservabilityMiddleware(mux)
	srv := server.New(":"+strconv.Itoa(cfg.Port), handler)
	// TODO: wire DB/Redis when DATABASE_URL/REDIS_URL set

	go func() {
		if err := srv.Start(); err != nil && err != http.ErrServerClosed {
			log.Fatal(err)
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		log.Fatal("Server shutdown:", err)
	}
	log.Println("Server stopped")
}
