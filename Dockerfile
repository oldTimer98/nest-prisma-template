#prisma问题 不使用alpine
FROM node:lts-alpine3.14 as build-stage

#指定工作目录
WORKDIR /app

#复制package.json和pnpm-lock.yaml 到工作目录 这里单独复制是为了利用缓存
COPY package.json .
COPY pnpm-lock.yaml .
COPY prisma ./prisma

RUN npm config set registry https://registry.npmmirror.com/

RUN npm i -g pnpm

RUN pnpm i

COPY . .

RUN pnpm build

# production stage
FROM node:lts-alpine3.14  AS production-stage

#指定工作目录
WORKDIR /app
COPY --from=build-stage /app/prisma ./prisma
COPY --from=build-stage /app/dist ./dist
COPY --from=build-stage /app/package.json ./package.json
COPY --from=build-stage /app/pnpm-lock.yaml ./pnpm-lock.yaml

RUN npm config set registry https://registry.npmmirror.com/
RUN npm i -g pnpm
RUN pnpm i
RUN npm i pm2 -g

EXPOSE 3000

CMD ["pm2-runtime", "/app/dist/main.js"]
