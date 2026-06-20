#!/usr/bin/env bash
set -euo pipefail

SERVICE="${1:-}"

if [[ -z "$SERVICE" ]]; then
  echo "Usage: $0 <service-name>"
  echo "Example: $0 nginx"
  exit 2
fi

echo "Checking service: $SERVICE"
echo "Timestamp: $(date)"
echo

if ! command -v systemctl >/dev/null 2>&1; then
  echo "ERROR: systemctl is not available on this system."
  exit 2
fi

if systemctl is-active --quiet "$SERVICE"; then
  echo "OK: Service '$SERVICE' is active."
  systemctl status "$SERVICE" --no-pager | sed -n '1,10p'
  exit 0
else
  echo "ALERT: Service '$SERVICE' is not active."
  echo
  echo "Service status:"
  systemctl status "$SERVICE" --no-pager || true
  echo
  echo "Recent logs:"
  journalctl -u "$SERVICE" -n 50 --no-pager || true
  exit 1
fi