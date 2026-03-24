package config

import (
	"os"
	"strconv"
)

// Config holds platform-standard env vars
type Config struct {
	Port       int
	AppEnv     string
	LogLevel   string
	DatabaseURL string
	RedisURL   string
	RabbitMQURL string
}

// Load reads config from environment (platform contract)
func Load() *Config {
	port, _ := strconv.Atoi(getEnv("PORT", "3000"))
	return &Config{
		Port:        port,
		AppEnv:      getEnv("APP_ENV", "development"),
		LogLevel:    getEnv("LOG_LEVEL", "info"),
		DatabaseURL: os.Getenv("DATABASE_URL"),
		RedisURL:    os.Getenv("REDIS_URL"),
		RabbitMQURL: os.Getenv("RABBITMQ_URL"),
	}
}

func getEnv(key, defaultVal string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return defaultVal
}
