# syntax=docker/dockerfile:1
FROM node:22-alpine

ENV NODE_ENV=production
WORKDIR /app

# Lockfile first so the dependency layer survives source-only changes.
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

COPY . .

# Default listener port in lib/netease-client.js:getAdapterPort().
EXPOSE 3017

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:'+(process.env.ADAPTER_PORT||3017)+'/api?action=health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

USER node
CMD ["node", "server.js"]
