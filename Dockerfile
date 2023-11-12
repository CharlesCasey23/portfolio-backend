FROM node:18-alpine as build
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev git > /dev/null 2>&1
# change NODE_ENV to production for prod build
ENV NODE_ENV=development

WORKDIR /opt/
COPY package.json yarn.lock ./
RUN yarn global add node-gyp
# add --production flag to yarn install
RUN yarn config set network-timeout 600000 -g && yarn && yarn cache clean
ENV PATH /opt/node_modules/.bin:$PATH
WORKDIR /opt/app
COPY . .
RUN yarn build


FROM node:18-alpine
RUN apk add --no-cache vips-dev
# change NODE_ENV to production for prod build
ENV NODE_ENV=development
WORKDIR /opt/
COPY --from=build /opt/node_modules ./node_modules
WORKDIR /opt/app
COPY --from=build /opt/app ./
ENV PATH /opt/node_modules/.bin:$PATH

RUN chown -R node:node /opt/app
USER node
EXPOSE 1337
# change CMD to ["yarn", "start"]
CMD ["yarn", "develop"]