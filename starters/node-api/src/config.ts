// Platform contract: PORT, APP_ENV, LOG_LEVEL, DATABASE_URL, REDIS_URL, RABBITMQ_URL

export interface Config {
  port: number;
  appEnv: string;
  logLevel: string;
  databaseUrl?: string;
  redisUrl?: string;
  rabbitmqUrl?: string;
}

export function loadConfig(): Config {
  return {
    port: parseInt(process.env.PORT || "3000", 10),
    appEnv: process.env.APP_ENV || "development",
    logLevel: process.env.LOG_LEVEL || "info",
    databaseUrl: process.env.DATABASE_URL,
    redisUrl: process.env.REDIS_URL,
    rabbitmqUrl: process.env.RABBITMQ_URL,
  };
}
