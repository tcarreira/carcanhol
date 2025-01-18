# syntax=docker/dockerfile:1

#######################
# Multi-Stage: basenode
#######################
FROM node:23-alpine AS basenode

USER node
WORKDIR /app

COPY --chown=node ["package.json", "package-lock.json*", "./"]
# clean with: docker buildx prune --filter 'type=exec.cachemount'
RUN --mount=type=cache,id=npmcache,target=/home/node/.npm,uid=1000,gid=1000 \
    npm ci --omit dev

#######################
# Multi-Stage: dev
#######################
FROM basenode AS dev
COPY --chown=node . .
ENTRYPOINT ./scripts/docker-entrypoint.sh

#######################
# Multi-Stage: build
#######################
FROM basenode AS build
COPY --chown=node . .
RUN npm run build --production


#######################
# Multi-Stage: final
#######################
FROM nginx:alpine AS final
COPY --from=build /app/dist /usr/share/nginx/html
