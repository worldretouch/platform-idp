import { Request, Response } from "express";
import express from "express";

export interface HealthCheck {
  database?: () => Promise<boolean>;
  redis?: () => Promise<boolean>;
}

export function createHealthRouter(checks: HealthCheck = {}) {
  const router = express.Router();

  // GET /health/live — liveness
  router.get("/live", (_req: Request, res: Response) => {
    res.json({
      status: "ok",
      timestamp: new Date().toISOString(),
      checks: {},
    });
  });

  // GET /health/ready — readiness
  router.get("/ready", async (_req: Request, res: Response) => {
    const results: Record<string, string> = {};
    let allOk = true;

    if (checks.database) {
      try {
        results.database = (await checks.database()) ? "ok" : "error";
        if (results.database === "error") allOk = false;
      } catch {
        results.database = "error";
        allOk = false;
      }
    }

    if (checks.redis) {
      try {
        results.redis = (await checks.redis()) ? "ok" : "error";
        if (results.redis === "error") allOk = false;
      } catch {
        results.redis = "error";
        allOk = false;
      }
    }

    const status = allOk ? "ok" : "degraded";
    const code = allOk ? 200 : 503;
    res.status(code).json({
      status,
      timestamp: new Date().toISOString(),
      checks: results,
    });
  });

  return router;
}
