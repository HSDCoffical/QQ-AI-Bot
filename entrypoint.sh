
#!/bin/sh
set -e

export DSH_HOME="${DSH_HOME:-/app/data/dsh}"
mkdir -p "$DSH_HOME" /app/data/workspace
cd /app/data/workspace

if [ -z "$DEEPSEEK_API_KEY" ]; then
  echo "[entrypoint] WARNING: DEEPSEEK_API_KEY is not set" >&2
fi

# Install the QQ bridge once
MARK="$DSH_HOME/.installed-dsh-onebot-qq"
if [ ! -f "$MARK" ]; then
  echo "[entrypoint] installing dsh-onebot-qq into profile web"
  dsh plugin --profile web add github:YUsaltyfish/dsh-onebot-qq
  touch "$MARK"
fi

# Start DSH first
echo "[entrypoint] starting DSH web"
dsh web --no-open &
DSH_PID=$!

# Wait for DSH port 3080 to become available
echo "[entrypoint] waiting for DSH on 127.0.0.1:3080"
i=0
until node -e "
const net = require('node:net');
const s = net.connect(3080, '127.0.0.1');
s.setTimeout(1000);
s.on('connect', () => { s.end(); process.exit(0); });
s.on('error', () => process.exit(1));
s.on('timeout', () => { s.destroy(); process.exit(1); });
" 2>/dev/null; do
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
exec socat TCP-LISTEN:3081,fork,reuseaddr TCP:127.0.0.1:3080
