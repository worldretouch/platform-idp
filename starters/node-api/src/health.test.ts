import request from "supertest";
import express from "express";
import { createHealthRouter } from "./health";

describe("Health", () => {
  const app = express();
  app.use("/health", createHealthRouter());

  it("GET /health/live returns ok", async () => {
    const res = await request(app).get("/health/live");
    expect(res.status).toBe(200);
    expect(res.body.status).toBe("ok");
  });

  it("GET /health/ready returns ok", async () => {
    const res = await request(app).get("/health/ready");
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty("status");
    expect(res.body).toHaveProperty("checks");
  });
});
