#!/bin/sh
set -eu

export DSH_HOME="${DSH_HOME:-/app/data/dsh}"

mkdir -p "$DSH_HOME" /app/data/workspace
cd /app/data/workspace

if [ -z "${DEEPSEEK_API_KEY:-}" ]; then
  echo "[entrypoint] WARNING: DEEPSEEK_API_KEY is not set" >&2
fi

# Install QQ bridge once
MARK="$DSH_HOME/.installed-dsh-onebot-qq"

if [ ! -f "$MARK" ]; then
  echo "[entrypoint] installing dsh-onebot-qq"
  dsh plugin --profile web add github:YUsaltyfish/dsh-onebot-qq
  touch "$MARK"
fi

# Start DSH web server
echo "[entrypoint] starting DSH web"
dsh web --no-open &
DSH_PID=$!

# Wait until DSH listens on port 3080
echo "[entrypoint] waiting for DSH on 127.0.0.1:3080"

i=0

until node -e '
const net = require("node:net");
const socket = net.connect(3080, "127.0.0.1");

socket.setTimeout(1000);

socket.on("connect", () => {
  socket.end();
  process.exit(0);
});

socket.on("error", () => process.exit(1));

socket.on("timeout", () => {
  socket.destroy();
  process.exit(1);
});
' 2>/dev/null
do
  if ! kill -0 "$DSH_PID" 2>/dev/null; then
    echo "[entrypoint] ERROR: DSH exited before port 3080 became ready" >&2
    exit 1
  fi

  i=$((i + 1))

  if [ "$i" -ge 60 ]; then
    echo "[entrypoint] ERROR: DSH port 3080 timeout" >&2
    kill "$DSH_PID" 2>/dev/null || true
    exit 1
  fi

  sleep 1
done

echo "[entrypoint] DSH is ready; exposing port 3081"

# Forward Blitz port 3081 to DSH port 3080
exec socat TCP-LISTEN:3081,fork,reuseaddr TCP:127.0.0.1:3080
