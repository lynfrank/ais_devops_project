# syntax=docker/dockerfile:1

FROM node:18-alpine
WORKDIR /app

# Installation des dépendances (optimise le cache)
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production

# Copie de l'application
COPY . .

# Écoute sur toutes les interfaces
CMD ["node", "src/index.js", "--host", "0.0.0.0"]

EXPOSE 3000
