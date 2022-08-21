FROM node:14
ENV NODE_ENV=production
ENV PORT=3003
ENV DB_HOST=127.0.0.1
ENV DB_USER=root
ENV DB_PASSWORD=123456
ENV DB_DATABASE=clipmysql
ENV DB_PORT=production
WORKDIR /usr/src/app
COPY . .
RUN npm i mysql
RUN npm install
EXPOSE 3003
CMD ["node", "index.js"]
