FROM node:16-alpine
WORKDIR /lookscanned
COPY ./ /lookscanned

RUN npm i
RUN npm run build


FROM httpd:2-alpine
COPY --from=0 /lookscanned/dist /usr/local/apache2/htdocs/

EXPOSE 80
