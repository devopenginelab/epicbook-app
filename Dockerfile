# Stage 1: Build Phase
FROM node:20-alpine AS builder

# Set production environment
ENV NODE_ENV=production

WORKDIR /app

# Copy package files first to leverage Docker layer caching
COPY package*.json ./

# Install all dependencies (including devDependencies for the build)
RUN npm ci

# Copy the rest of the application source
COPY . .

# Stage 2: Runtime Phase
FROM node:20-alpine

# Set production environment
ENV NODE_ENV=production
WORKDIR /app

# Copy only the necessary files from the builder stage
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/server.js ./
COPY --from=builder /app/config ./config
COPY --from=builder /app/db ./db
# Add any other source directories/files your app needs here

# Ensure the container runs as a non-privileged user
USER node

# Expose the port the app listens on
EXPOSE 3000

# Start the application
CMD ["node", "server.js"]