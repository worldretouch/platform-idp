"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.createHealthRouter = createHealthRouter;
const express_1 = __importDefault(require("express"));
function createHealthRouter(checks = {}) {
    const router = express_1.default.Router();
    // GET /health/live — liveness
    router.get("/live", (_req, res) => {
        res.json({
            status: "ok",
            timestamp: new Date().toISOString(),
            checks: {},
        });
    });
    // GET /health/ready — readiness
    router.get("/ready", async (_req, res) => {
        const results = {};
        let allOk = true;
        if (checks.database) {
            try {
                results.database = (await checks.database()) ? "ok" : "error";
                if (results.database === "error")
                    allOk = false;
            }
            catch {
                results.database = "error";
                allOk = false;
            }
        }
        if (checks.redis) {
            try {
                results.redis = (await checks.redis()) ? "ok" : "error";
                if (results.redis === "error")
                    allOk = false;
            }
            catch {
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
