# Stage 1: Build the application
FROM oven/bun:canary AS builder
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
RUN bun install

# Bundle app source
COPY . .
RUN bun build ./src/index.ts --outdir dist --packages external --target bun --minify

# Stage 2: Production
FROM oven/bun:slim
WORKDIR /usr/src/app

RUN bunx playwright install
COPY --from=builder /usr/src/app/dist/index.js .

ENV PORT=3000
EXPOSE $PORT

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD curl -f http://localhost:$PORT/health || exit 1

CMD ["bun", "index.js"]