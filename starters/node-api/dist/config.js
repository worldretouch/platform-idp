"use strict";
// Platform contract: PORT, APP_ENV, LOG_LEVEL, DATABASE_URL, REDIS_URL, RABBITMQ_URL
Object.defineProperty(exports, "__esModule", { value: true });
exports.loadConfig = loadConfig;
function loadConfig() {
    return {
        port: parseInt(process.env.PORT || "3000", 10),
        appEnv: process.env.APP_ENV || "development",
        logLevel: process.env.LOG_LEVEL || "info",
        databaseUrl: process.env.DATABASE_URL,
        redisUrl: process.env.REDIS_URL,
        rabbitmqUrl: process.env.RABBITMQ_URL,
    };
}
