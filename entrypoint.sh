#!/bin/sh
set -e

export DSH_HOME="${DSH_HOME:-/app/data/dsh}"
mkdir -p "$DSH_HOME" /app/data/workspace
cd /app/data/workspace

if [ -z "$DEEPSEEK_API_KEY" ]; then
  echo "[entrypoint] WARNING: DEEPSEEK_API_KEY is not set; dsh cannot call the model" >&2
fi

# Install the QQ bridge once; the marker lives in the persistent volume
MARK="$DSH_HOME/.installed-dsh-onebot-qq"
if [ ! -f "$MARK" ]; then
  echo "[entrypoint] installing dsh-onebot-qq into profile web"
  dsh plugin --profile web add github:YUsaltyfish/dsh-onebot-qq
  touch "$MARK"
fi

# dsh web is bound to 127.0.0.1:3080 only; expose it on 3081 for the platform
socat TCP-LISTEN:3081,fork,reuseaddr TCP:127.0.0.1:3080 &

exec dsh web
