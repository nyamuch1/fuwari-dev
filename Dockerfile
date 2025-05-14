FROM node:alpine AS builder

WORKDIR /app
COPY . /app

RUN npm install -g pnpm
RUN pnpm install
RUN pnpm add sharp

RUN pnpm build

FROM nginx:1.27-alpine
WORKDIR /etc/nginx
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]