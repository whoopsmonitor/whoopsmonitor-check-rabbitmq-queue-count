FROM php:7.4.10-alpine3.12
LABEL maintainer="Daniel Rataj <daniel.rataj@centrum.cz>"
LABEL org.opencontainers.image.source="https://github.com/whoopsmonitor/whoopsmonitor-check-rabbitmq-queue-count"
LABEL com.whoopsmonitor.documentation="https://github.com/whoopsmonitor/whoopsmonitor-check-rabbitmq-queue-count"
LABEL com.whoopsmonitor.icon="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjM2MiIgaGVpZ2h0PSIyNTAwIiB2aWV3Qm94PSIwIDAgMjU2IDI3MSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiBwcmVzZXJ2ZUFzcGVjdFJhdGlvPSJ4TWlkWU1pZCI+PHBhdGggZD0iTTI0NS40NCAxMDguMzA4aC04NS4wOWE3LjczOCA3LjczOCAwIDAgMS03LjczNS03LjczNHYtODguNjhDMTUyLjYxNSA1LjMyNyAxNDcuMjkgMCAxNDAuNzI2IDBoLTMwLjM3NWMtNi41NjggMC0xMS44OSA1LjMyNy0xMS44OSAxMS44OTR2ODguMTQzYzAgNC41NzMtMy42OTcgOC4yOS04LjI3IDguMzFsLTI3Ljg4NS4xMzNjLTQuNjEyLjAyNS04LjM1OS0zLjcxNy04LjM1LTguMzI1bC4xNzMtODguMjQxQzU0LjE0NCA1LjMzNyA0OC44MTcgMCA0Mi4yNCAwSDExLjg5QzUuMzIxIDAgMCA1LjMyNyAwIDExLjg5NFYyNjAuMjFjMCA1LjgzNCA0LjcyNiAxMC41NiAxMC41NTUgMTAuNTZIMjQ1LjQ0YzUuODM0IDAgMTAuNTYtNC43MjYgMTAuNTYtMTAuNTZWMTE4Ljg2OGMwLTUuODM0LTQuNzI2LTEwLjU2LTEwLjU2LTEwLjU2em0tMzkuOTAyIDkzLjIzM2MwIDcuNjQ1LTYuMTk4IDEzLjg0NC0xMy44NDMgMTMuODQ0SDE2Ny42OWMtNy42NDYgMC0xMy44NDQtNi4xOTktMTMuODQ0LTEzLjg0NHYtMjQuMDA1YzAtNy42NDYgNi4xOTgtMTMuODQ0IDEzLjg0NC0xMy44NDRoMjQuMDA1YzcuNjQ1IDAgMTMuODQzIDYuMTk4IDEzLjg0MyAxMy44NDR2MjQuMDA1eiIgZmlsbD0iI0Y2MCIvPjwvc3ZnPg=="
LABEL com.whoopsmonitor.env.WM_RABBITMQ_QUEUE=""
LABEL com.whoopsmonitor.env.WM_RABBITMQ_HOST=""
LABEL com.whoopsmonitor.env.WM_RABBITMQ_PORT=""
LABEL com.whoopsmonitor.env.WM_RABBITMQ_LOGIN=""
LABEL com.whoopsmonitor.env.WM_RABBITMQ_PASSWORD=""
LABEL com.whoopsmonitor.env.WM_RABBITMQ_VHOST="/"
LABEL com.whoopsmonitor.env.WM_IS_PASSIVE="true, false or delete this line"
LABEL com.whoopsmonitor.env.WM_IS_DURABLE="true, false or delete this line"
LABEL com.whoopsmonitor.env.WM_IS_EXLUSIVE="true, false or delete this line"
LABEL com.whoopsmonitor.env.WM_IS_AUTO_DELETE="true, false or delete this line"
LABEL com.whoopsmonitor.env.WM_IS_IS_NOWAIT="true, false or delete this line"
LABEL com.whoopsmonitor.env.WM_THRESHOLD_WARNING="10"
LABEL com.whoopsmonitor.env.WM_THRESHOLD_CRITICAL="20"

SHELL ["/bin/sh", "-o", "pipefail", "-c"]

RUN apk add \
  # --repository http://dl-cdn.alpinelinux.org/alpine/v3.6/main \
  --no-cache \
  aspell-dev=0.60.8-r0 \
  autoconf=2.69-r2 \
  build-base=0.5-r2 \
  linux-headers=5.4.5-r1 \
  libaio-dev=0.3.112-r1 \
  rabbitmq-c-dev=0.10.0-r1 \
  && pecl install amqp \
  && docker-php-ext-enable amqp \
  && docker-php-ext-install sockets \
  && rm -rf /var/cache/apk/*

# installl composer
ARG COMPOSER_VERSION=1.8.5
ARG COMPOSER_SHA256=4e4c1cd74b54a26618699f3190e6f5fc63bb308b13fa660f71f2a2df047c0e17
# hadolint ignore=SC2046
RUN curl -Ls "https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar" > /usr/local/bin/composer \
  && test $(sha256sum /usr/local/bin/composer | cut -d ' ' -f 1) = ${COMPOSER_SHA256} \
  && chmod +x /usr/local/bin/composer

ARG COMPOSER_ALLOW_SUPERUSER=1

COPY ./src/composer.json .

RUN COMPOSER_CACHE_DIR=/tmp/composer_cache composer install --no-ansi --no-interaction --no-autoloader

COPY . .

RUN composer dump-autoload --no-ansi --no-interaction --optimize

CMD [ "php", "./src/index.php"]
