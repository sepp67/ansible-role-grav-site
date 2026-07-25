# syntax=docker/dockerfile:1

# php:8.3-fpm-alpine is precise down to the PHP minor version and variant,
# but it is not pinned to an exact PHP patch version or Alpine base layer:
# it moves as upstream publishes new patch/security builds under the same
# tag. See README.md "Limitations connues" for how to pin it further
# (by digest) if stricter reproducibility is required.
ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-fpm-alpine

# Grav release vendored into this image. 2.0.11 is the version validated in
# production use at the time this runtime was extracted (see
# README.md "Versionnement").
ARG GRAV_VERSION=2.0.11

# Official GitHub Release asset for Grav Core + Admin, and the sha256
# digest GitHub computed and publishes for that exact asset (retrieved via
# `gh api repos/getgrav/grav/releases/tags/<version>`). getgrav.org's own
# "latest" download links carry no checksum at all; the versioned GitHub
# Release asset does, so that is used here as the source of truth instead.
ARG GRAV_ZIP_URL=https://github.com/getgrav/grav/releases/download/${GRAV_VERSION}/grav-admin-v${GRAV_VERSION}.zip
ARG GRAV_ZIP_SHA256=c5538943b96e73eaf5ada4b4a898f25fb07ad84c617f7617d11855857fa5079c

RUN apk add --no-cache \
    nginx \
    curl \
    unzip \
    su-exec \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    icu-dev \
    oniguruma-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip intl mbstring opcache

WORKDIR /var/www/html

# Download, verify, extract. Fails the build clearly on any mismatch or
# download error instead of silently continuing with corrupt/unverified
# content.
#
# The official zip also ships demo/starter content (pages, stock site and
# system config) directly under user/ — exactly the directories this
# runtime treats as persistent/seedable (§10-11 of the design). That content
# is stripped below so the image keeps only the generic technical layer
# (user/themes, user/plugins); pages/accounts/data/config start empty.
RUN set -eu; \
    curl -fsSL "$GRAV_ZIP_URL" -o /tmp/grav.zip; \
    echo "${GRAV_ZIP_SHA256}  /tmp/grav.zip" | sha256sum -c -; \
    mkdir -p /tmp/grav-extracted; \
    unzip -q /tmp/grav.zip -d /tmp/grav-extracted; \
    DIR="$(find /tmp/grav-extracted -mindepth 1 -maxdepth 1 -type d -name 'grav*' | head -n 1)"; \
    if [ -z "$DIR" ]; then echo "Grav archive layout not recognized" >&2; exit 1; fi; \
    cp -a "$DIR"/. .; \
    rm -rf /tmp/grav-extracted /tmp/grav.zip; \
    rm -rf user/pages user/accounts user/data user/config; \
    mkdir -p user/pages user/accounts user/data user/config; \
    chown -R www-data:www-data /var/www/html

# Seed directory for a child image's initial content. Empty by default:
# grav-runtime ships no business content of its own. A child image
# populates the subdirectories it needs (pages/, accounts/, data/,
# images/) at build time; see README.md "Répertoire seed".
RUN mkdir -p /opt/grav-seed

COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf
COPY docker/healthz.php /var/www/html/healthz.php
COPY docker/entrypoint.sh /entrypoint.sh
COPY docker/bootstrap-admin.sh /bootstrap-admin.sh
COPY docker/seed-init.sh /seed-init.sh
COPY docker/healthcheck.sh /healthcheck.sh

RUN chown www-data:www-data /var/www/html/healthz.php \
    && chmod +x /entrypoint.sh /bootstrap-admin.sh /seed-init.sh /healthcheck.sh

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD ["/healthcheck.sh"]

# The base php-fpm image sets STOPSIGNAL SIGQUIT (meaningful when php-fpm
# itself is PID 1). Here PID 1 is entrypoint.sh, which traps SIGTERM to
# shut both processes down cleanly — so `docker stop` must send SIGTERM.
STOPSIGNAL SIGTERM

ENTRYPOINT ["/entrypoint.sh"]
