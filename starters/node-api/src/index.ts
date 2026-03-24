import { createApp } from "./server";
import { loadConfig } from "./config";

const config = loadConfig();
const app = createApp();
// TODO: add database/redis checks when configured

const server = app.listen(config.port, () => {
  console.log(`Listening on port ${config.port}`);
});

process.on("SIGTERM", () => {
  server.close(() => {
    process.exit(0);
  });
});
