"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.createApp = createApp;
const express_1 = __importDefault(require("express"));
const health_1 = require("./health");
function createApp(healthChecks) {
    const app = (0, express_1.default)();
    app.use(express_1.default.json());
    app.use("/health", (0, health_1.createHealthRouter)(healthChecks));
    return app;
}
