FROM node:24-bookworm-slim

# Install required system packages
RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates socat \
 && rm -rf /var/lib/apt/lists/* \
 && corepack enable

# Install pinned DSH version
RUN npm install -g @deepseek-ai/dsh@0.2.1-rc.2 \
 && dsh --version

# Copy entrypoint with executable permission
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

# Persistent data directory
ENV DSH_HOME=/app/data/dsh
VOLUME ["/app/data"]

WORKDIR /app/data

# Blitz exposes this port
EXPOSE 3081

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
