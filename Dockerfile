FROM ubuntu:22.04

LABEL maintainer = "hello@mattbanner.co.uk"

# Build arguments.
ARG NODE_VERSION
ARG PHP_VERSION
ARG COMPOSER_VERSION

# System environment variables.
ENV DEBIAN_FRONTEND noninteractive

# Composer environment variables.
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /root/.composer

# Node/NVM environment variables.
ENV NVM_DIR /root/.nvm

# Create a directory for the configs
RUN mkdir -p configs

# Copy files into place.
COPY scripts/build.sh /build.sh
COPY scripts/start.sh /start.sh
COPY configs configs

# Make build and start scripts executable and run the build script.
RUN chmod +x /start.sh && \
    chmod +x /build.sh && \
    ./build.sh

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Set default command.
CMD ["/start.sh"]
