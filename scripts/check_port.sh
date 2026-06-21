#!/usr/bin/env bash

# Author: AA. Gargoura
# Description: This script checks if a specified TCP port on a host is open and provides details if it is not.
# Created: 2024-06-21
# Modified: 2024-06-21
# Usage:
#   ./check_port.sh <host> <port>
# Example:
#   ./check_port.sh localhost 22
#   ./check_port.sh example.com 443
#   ./check_port.sh 

# Exit immediately if a command fails.
# Treat unset variables as errors.
# Make pipelines fail if any command inside the pipeline fails.
set -euo pipefail

# HOST is the hostname or IP address we want to test.
# It is expected as the first script argument.
#
# Examples:
#   localhost
#   127.0.0.1
#   example.com
HOST="${1:-}"

# PORT is the TCP port we want to test.
# It is expected as the second script argument.
#
# Examples:
#   22   -> SSH
#   80   -> HTTP
#   443  -> HTTPS
#   8080 -> common application port
PORT="${2:-}"

# If HOST or PORT is missing, print usage information and exit.
# Exit code 2 means invalid input or incorrect script usage.
if [[ -z "$HOST" || -z "$PORT" ]]; then
  echo "Usage: $0 <host> <port>"
  echo
  echo "Examples:"
  echo "  $0 localhost 22"
  echo "  $0 example.com 443"
  echo "  $0 127.0.0.1 8080"
  exit 2
fi

# Validate that PORT contains only numbers.
# This avoids running the check with invalid values like "abc".
if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
  echo "ERROR: Port must be a number."
  echo "Provided port: $PORT"
  exit 2
fi

# Validate that PORT is within the valid TCP port range.
# Valid TCP/UDP ports are from 1 to 65535.
if (( PORT < 1 || PORT > 65535 )); then
  echo "ERROR: Port must be between 1 and 65535."
  echo "Provided port: $PORT"
  exit 2
fi

echo "Checking TCP port connectivity"
echo "Host: $HOST"
echo "Port: $PORT"
echo "Timestamp: $(date)"
echo

# nc, also called netcat, is a common tool for testing TCP connectivity.
#
# Options used:
#   -z  -> zero-I/O mode. It checks whether the port is open without sending data.
#   -v  -> verbose output. It prints connection details.
#   -w 5 -> timeout after 5 seconds.
#
# Example:
#   nc -zv -w 5 example.com 443
#
# Meaning:
#   Try to connect to example.com on TCP port 443.
if command -v nc >/dev/null 2>&1; then
  echo "Using nc/netcat for connectivity check..."
  echo

  if nc -zv -w 5 "$HOST" "$PORT"; then
    echo
    echo "OK: TCP connection to $HOST:$PORT succeeded."
    echo "This means the host is reachable and the port is accepting TCP connections."
    exit 0
  else
    echo
    echo "ALERT: TCP connection to $HOST:$PORT failed."
    echo
    echo "Possible causes:"
    echo "1. The service is not running."
    echo "2. The service is not listening on this port."
    echo "3. A firewall or security group is blocking traffic."
    echo "4. The host is unreachable."
    echo "5. DNS resolves to the wrong IP address."
    echo "6. The service is bound only to localhost/127.0.0.1."
    exit 1
  fi
fi

# Fallback method if nc/netcat is not installed.
#
# Bash supports a special /dev/tcp/HOST/PORT feature on many systems.
# It tries to open a TCP connection using Bash itself.
#
# timeout 5 prevents the command from hanging forever.
#
# Note:
#   /dev/tcp is a Bash feature, not a real file.
#   It may not be available in every shell, but it works in Bash.
if command -v timeout >/dev/null 2>&1; then
  echo "nc/netcat not found."
  echo "Using Bash /dev/tcp fallback with timeout..."
  echo

  if timeout 5 bash -c "cat < /dev/null > /dev/tcp/$HOST/$PORT" 2>/dev/null; then
    echo "OK: TCP connection to $HOST:$PORT succeeded."
    exit 0
  else
    echo "ALERT: TCP connection to $HOST:$PORT failed."
    echo
    echo "Possible causes:"
    echo "1. The service is not running."
    echo "2. The service is not listening on this port."
    echo "3. A firewall or security group is blocking traffic."
    echo "4. The host is unreachable."
    echo "5. DNS resolves to the wrong IP address."
    echo "6. The service is bound only to localhost/127.0.0.1."
    exit 1
  fi
fi

# If neither nc nor timeout is available, the script cannot perform the check.
echo "ERROR: No supported TCP check tool found."
echo "Install netcat/nc or ensure timeout is available."
exit 2
