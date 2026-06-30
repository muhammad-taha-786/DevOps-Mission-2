# ---------- Stage 1: Build ----------
FROM node:20-alpine AS build

WORKDIR /app

# Leverage Docker layer caching: copy only package files first
COPY package.json package-lock.json ./
RUN npm ci

# Copy rest of the source and build the frontend (Vite -> dist/)
COPY . .
RUN npm run build

# ---------- Stage 2: Production ----------
FROM node:20-alpine AS production

WORKDIR /app
ENV NODE_ENV=production

# Copy only package files and install production deps only
COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Copy backend entry file
COPY index.js ./

# Copy built frontend assets from the build stage (dist, not public!)
COPY --from=build /app/dist ./dist

EXPOSE 5000

CMD ["node", "index.js"]
