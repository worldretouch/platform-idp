import { buildRequestLog } from "./server";

describe("observability log schema", () => {
  it("includes request_id and trace_id fields", () => {
    const log = buildRequestLog("GET", "/health/live", 200, "req-123", "trace-456");

    expect(log).toHaveProperty("request_id", "req-123");
    expect(log).toHaveProperty("trace_id", "trace-456");
    expect(log).toHaveProperty("http.method", "GET");
  });
});
