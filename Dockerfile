FROM node:24-bookworm-slim

# git: dsh plugin add github:... goes through pnpm and needs git
# socat: dsh web only listens on 127.0.0.1:3080, this republishes it on 3081
RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates socat \
 && rm -rf /var/lib/apt/lists/* \
 && corepack enable

# Pinned: dsh-onebot-qq requires dsh >=0.2.1-rc.2 <0.3.0
RUN npm install -g @deepseek-ai/dsh@0.2.1-rc.2 \
 && dsh --version

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Profile, plugin and agent workspace live here and survive restarts
ENV DSH_HOME=/app/data/dsh
VOLUME ["/app/data"]
WORKDIR /app/data

EXPOSE 3081
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
