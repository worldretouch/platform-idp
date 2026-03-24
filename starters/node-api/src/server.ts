import express from "express";
import { createHealthRouter } from "./health";

export function createApp(healthChecks?: Parameters<typeof createHealthRouter>[0]) {
  const app = express();
  app.use(express.json());

  app.use("/health", createHealthRouter(healthChecks));

  return app;
}
