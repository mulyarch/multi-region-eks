FROM httpd:2.4-alpine

ARG REGION=unknown

COPY index.html /usr/local/apache2/htdocs/

RUN sed -i "s/__REGION__/${REGION}/" /usr/local/apache2/htdocs/index.html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

