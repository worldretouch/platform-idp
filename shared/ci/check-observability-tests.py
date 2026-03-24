#!/usr/bin/env python3
"""
Ensure starter runtimes include observability tests covering request_id/trace_id.
"""

from __future__ import annotations

from pathlib import Path
import sys


REQUIRED_TESTS = {
    "node": Path("starters/node-api/src/observability.test.ts"),
    "go": Path("starters/go-api/internal/server/observability_test.go"),
    "python": Path("starters/python-api/tests/test_observability.py"),
    "rails": Path("starters/rails-api/spec/requests/observability_spec.rb"),
}


def main() -> int:
    violations: list[str] = []

    for runtime, file_path in REQUIRED_TESTS.items():
        if not file_path.exists():
            violations.append(f"{runtime}: missing observability test file {file_path}")
            continue
        content = file_path.read_text(encoding="utf-8")
        if "request_id" not in content:
            violations.append(f"{runtime}: test missing request_id assertion/reference")
        if "trace_id" not in content:
            violations.append(f"{runtime}: test missing trace_id assertion/reference")

    if violations:
        print("ERROR: observability test policy violated")
        for item in violations:
            print(f" - {item}")
        return 1

    print("OK: observability test policy passed for all starters")
    return 0


if __name__ == "__main__":
    sys.exit(main())
