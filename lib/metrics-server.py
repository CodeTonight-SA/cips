#!/usr/bin/env python3
"""CIPS Metrics Server - serves metrics.jsonl as JSON for Grafana Infinity."""

import json
import os
from http.server import HTTPServer, BaseHTTPRequestHandler
from pathlib import Path

METRICS_FILE = Path.home() / ".claude" / "metrics.jsonl"
PORT = 9100


class MetricsHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/metrics":
            self.serve_metrics()
        elif self.path == "/metrics/summary":
            self.serve_summary()
        elif self.path == "/health":
            self.send_json({"status": "ok"})
        else:
            self.send_error(404)

    def serve_metrics(self):
        """Serve all metrics as JSON array."""
        metrics = []
        if METRICS_FILE.exists():
            with open(METRICS_FILE) as f:
                for line in f:
                    line = line.strip()
                    if line:
                        try:
                            metrics.append(json.loads(line))
                        except json.JSONDecodeError:
                            pass
        self.send_json(metrics)

    def serve_summary(self):
        """Serve aggregated summary."""
        metrics = []
        if METRICS_FILE.exists():
            with open(METRICS_FILE) as f:
                for line in f:
                    line = line.strip()
                    if line:
                        try:
                            metrics.append(json.loads(line))
                        except json.JSONDecodeError:
                            pass

        # Aggregate by event type
        counts = {}
        for m in metrics:
            event = m.get("event", "unknown")
            counts[event] = counts.get(event, 0) + 1

        summary = [{"event": k, "count": v} for k, v in counts.items()]
        self.send_json(summary)

    def send_json(self, data):
        content = json.dumps(data, indent=2).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", len(content))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(content)

    def log_message(self, format, *args):
        pass  # Suppress logging


if __name__ == "__main__":
    print(f"CIPS Metrics Server on http://localhost:{PORT}")
    print(f"  /metrics        - All events")
    print(f"  /metrics/summary - Aggregated counts")
    print(f"  /health         - Health check")
    HTTPServer(("", PORT), MetricsHandler).serve_forever()
