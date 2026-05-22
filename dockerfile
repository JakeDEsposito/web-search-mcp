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

# Start the application
ENV PORT=3000
EXPOSE $PORT
CMD ["bun", "index.js"]