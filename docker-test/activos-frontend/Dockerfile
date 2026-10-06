FROM node:24-alpine

WORKDIR /usr/src/activos-frontend

COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 5173



#CMD ["sh"]






CMD ["npm", "run","dev","--host"]
