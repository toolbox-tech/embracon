FROM node:18

ARG ENVIRONMENT
ARG BUILD_ARGS


# Create app directory
WORKDIR /usr/src/app
COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 8080
CMD [ "node", "index.js" ]