"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const supertest_1 = __importDefault(require("supertest"));
const express_1 = __importDefault(require("express"));
const health_1 = require("./health");
describe("Health", () => {
    const app = (0, express_1.default)();
    app.use("/health", (0, health_1.createHealthRouter)());
    it("GET /health/live returns ok", async () => {
        const res = await (0, supertest_1.default)(app).get("/health/live");
        expect(res.status).toBe(200);
        expect(res.body.status).toBe("ok");
    });
    it("GET /health/ready returns ok", async () => {
        const res = await (0, supertest_1.default)(app).get("/health/ready");
        expect(res.status).toBe(200);
        expect(res.body).toHaveProperty("status");
        expect(res.body).toHaveProperty("checks");
    });
});
