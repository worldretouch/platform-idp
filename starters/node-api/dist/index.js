"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const server_1 = require("./server");
const config_1 = require("./config");
const config = (0, config_1.loadConfig)();
const app = (0, server_1.createApp)();
// TODO: add database/redis checks when configured
const server = app.listen(config.port, () => {
    console.log(`Listening on port ${config.port}`);
});
process.on("SIGTERM", () => {
    server.close(() => {
        process.exit(0);
    });
});
