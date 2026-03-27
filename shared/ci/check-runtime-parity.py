#!/usr/bin/env python3
"""
Validate runtime starter parity for core platform contracts.
Checks:
- health endpoint semantics
- observability correlation IDs
- graceful shutdown strategy
"""

from __future__ import annotations

from pathlib import Path
import sys


RULES: dict[str, list[tuple[str, list[str]]]] = {
    "node": [
        ("starters/node-api/src/health.ts", ["/live", "/ready", "503"]),
        ("starters/node-api/src/server.ts", ["request_id", "trace_id"]),
        ("starters/node-api/src/index.ts", ["SIGTERM", "server.close"]),
    ],
    "go": [
        ("starters/go-api/internal/health/handler.go", ["/health/live", "/health/ready", "StatusServiceUnavailable"]),
        ("starters/go-api/internal/server/observability.go", ["request_id", "trace_id"]),
        ("starters/go-api/cmd/server/main.go", ["signal.Notify", "Shutdown"]),
    ],
    "python": [
        ("starters/python-api/app/health.py", ["/live", "/ready", "degraded"]),
        ("starters/python-api/app/main.py", ["request_id", "trace_id", "uvicorn.run"]),
    ],
    "rails": [
        ("starters/rails-api/config/routes.rb", ["health/live", "health/ready"]),
        ("starters/rails-api/config/application.rb", ["request_id", "X-Trace-Id"]),
        ("starters/rails-api/config/puma.rb", ["plugin :tmp_restart", "threads"]),
    ],
}


def main() -> int:
    if not Path("starters").exists():
        print("OK: runtime parity policy skipped (non-template repository)")
        return 0

    violations: list[str] = []

    for runtime, checks in RULES.items():
        for file_path, required_tokens in checks:
            path = Path(file_path)
            if not path.exists():
                violations.append(f"{runtime}: missing file {file_path}")
                continue
            content = path.read_text(encoding="utf-8")
            for token in required_tokens:
                if token not in content:
                    violations.append(
                        f"{runtime}: {file_path} missing token '{token}'"
                    )

    if violations:
        print("ERROR: runtime parity check failed")
        for item in violations:
            print(f" - {item}")
        return 1

    print("OK: runtime parity check passed for all starters")
    return 0


if __name__ == "__main__":
    sys.exit(main())
