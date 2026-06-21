#!/usr/bin/env bash

# Author: AA. Gargoura
# Description: This script checks if a specified Linux systemd service is active and provides details if it is not.
# Created: 2024-06-20
# Modified: 2024-06-21
# Usage:
#   ./check_service.sh <service-name>
# Example:
#   ./check_service.sh ssh
#   ./check_service.sh nginx
#   ./check_service.sh docker

# Exit immediately if a command fails.
# Treat unset variables as errors.
# Make pipelines fail if any command inside the pipeline fails.
set -euo pipefail

# SERVICE is the Linux systemd service name we want to check.
# The service name is expected as the first script argument.
SERVICE="${1:-}"

# If no service name is provided, print usage information and exit.
if [[ -z "$SERVICE" ]]; then
  echo "Usage: $0 <service-name>"
  echo "Examples:"
  echo "  $0 ssh"
  echo "  $0 nginx"
  echo "  $0 docker"
  exit 2
fi

echo "Checking Linux service"
echo "Service: $SERVICE"
echo "Timestamp: $(date)"
echo

# systemctl is the main command used to manage systemd services.
#
# command -v checks whether a command exists in the current environment.
# If systemctl is missing, this script cannot check the service properly.
if ! command -v systemctl >/dev/null 2>&1; then
  echo "ERROR: systemctl is not available on this system."
  exit 2
fi

# systemctl list-unit-files checks whether the service is known to systemd.
# We use grep to search for a matching service unit.
#
# The service may be written as:
#   nginx
# or:
#   nginx.service
#
# This check helps detect wrong service names early.
if ! systemctl list-unit-files | grep -q "^${SERVICE}\.service\|^${SERVICE}"; then
  echo "WARNING: Service '$SERVICE' was not found in systemd unit files."
  echo "The service name may be wrong, or the service may be dynamically generated."
  echo
fi

# systemctl is-active --quiet checks whether the service is currently running.
#
# Exit code meaning:
#   0 = service is active/running
#   non-zero = service is inactive, failed, unknown, or not running
#
# We use this as the main health check.
if systemctl is-active --quiet "$SERVICE"; then
  echo "OK: Service '$SERVICE' is active."

  echo
  echo "Service status summary:"
  # systemctl status gives a human-readable summary of the service.
  # --no-pager prevents systemctl from opening an interactive pager like less.
  # sed -n '1,12p' prints only the first 12 lines to keep the output short.
  systemctl status "$SERVICE" --no-pager | sed -n '1,12p'

  # Exit code 0 means healthy / successful check.
  exit 0
else
  echo "ALERT: Service '$SERVICE' is not active."
  echo

  echo "Service status:"
  # systemctl status may return a non-zero exit code when the service is failed.
  # We add '|| true' so the script continues and can print logs.
  systemctl status "$SERVICE" --no-pager || true

  echo
  echo "Recent service logs:"
  # journalctl reads logs collected by systemd-journald.
  # -u "$SERVICE" filters logs for this specific service.
  # -n 50 shows the last 50 log lines.
  # --no-pager prevents interactive output.
  #
  # We add '|| true' because journalctl may fail if:
  #   - the service does not exist
  #   - the user has no permission to read logs
  #   - journald is unavailable
  journalctl -u "$SERVICE" -n 50 --no-pager || true

  echo
  echo "Suggested next steps:"
  echo "1. Check whether the service name is correct."
  echo "2. Review the recent logs above for errors."
  echo "3. Check for configuration, permission, dependency, or port conflicts."
  echo "4. If safe and approved, restart the service:"
  echo "   sudo systemctl restart $SERVICE"
  echo "5. If this is production or customer-impacting, escalate to the service owner."

  # Exit code 1 means unhealthy / alert condition.
  exit 1
fi