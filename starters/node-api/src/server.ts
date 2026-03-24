import express, { NextFunction, Request, Response } from "express";
import { createHealthRouter } from "./health";

type RequestLog = Record<string, string | number>;

export function buildRequestLog(
  method: string,
  path: string,
  statusCode: number,
  requestId: string,
  traceId: string
): RequestLog {
  return {
    level: "info",
    message: "request completed",
    request_id: requestId,
    trace_id: traceId,
    "http.method": method,
    "http.path": path,
    "http.status_code": statusCode,
  };
}

export function createApp(healthChecks?: Parameters<typeof createHealthRouter>[0]) {
  const app = express();
  app.use(express.json());

  app.use((req: Request, res: Response, next: NextFunction) => {
    const requestId =
      (req.header("x-request-id") || `req-${Date.now()}-${Math.random()}`.replace(/\./g, ""));
    const traceId = req.header("x-trace-id") || requestId;

    res.setHeader("x-request-id", requestId);
    res.setHeader("x-trace-id", traceId);

    res.on("finish", () => {
      const log = buildRequestLog(req.method, req.path, res.statusCode, requestId, traceId);
      console.log(JSON.stringify(log));
    });

    next();
  });

  app.use("/health", createHealthRouter(healthChecks));

  return app;
}
