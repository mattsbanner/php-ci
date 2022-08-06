#!/bin/bash

## External build script to run everything in a single Docker layer, whilst keeping the script somewhat readable.

# Replace shell with bash so we can source files
rm /bin/sh
ln -s /bin/bash /bin/sh

# Update package lists.
apt-get update

# Install base dependencies.
apt-get install -y \
  acl \
  apt-transport-https \
  apt-utils \
  autoconf \
  build-essential \
  ca-certificates \
  curl \
  g++ \
  git \
  gcc \
  imagemagick \
  libaio1 \
  libc-dev \
  libfontconfig \
  libmagickwand-dev \
  libmcrypt-dev \
  libnuma1 \
  libssl-dev \
  libsqlite3-dev \
  libtinfo5 \
  make \
  nginx \
  pkg-config \
  python \
  rsync \
  software-properties-common \
  sqlite3 \
  supervisor \
  unzip \
  wget \
  xvfb \
  zip \
  zlib1g-dev

# Install MySQL 5.7 (Client only)
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-common_5.7.34-1ubuntu18.04_amd64.deb
dpkg -i mysql-common_5.7.34-1ubuntu18.04_amd64.deb
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-client_5.7.34-1ubuntu18.04_amd64.deb
dpkg -i mysql-community-client_5.7.34-1ubuntu18.04_amd64.deb

# Install NVM and default to the provided NPM version.
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
. $NVM_DIR/nvm.sh
nvm install $NODE_VERSION
nvm alias default $NODE_VERSION
nvm use default

# Install PHP.
add-apt-repository -y universe && \
add-apt-repository -y ppa:ondrej/php && \
apt-get update &&  \
apt-get install -y \
  php$PHP_VERSION-fpm

# Set the default PHP version.
update-alternatives --set php /usr/bin/php$PHP_VERSION

# Install PHP extensions.
apt-get install -y \
  php$PHP_VERSION-bcmath \
  php$PHP_VERSION-curl \
  php$PHP_VERSION-dev \
  php$PHP_VERSION-gd \
  php$PHP_VERSION-intl \
  php$PHP_VERSION-mbstring \
  php$PHP_VERSION-mongodb \
  php$PHP_VERSION-mysql \
  php$PHP_VERSION-soap \
  php$PHP_VERSION-sqlite3 \
  php$PHP_VERSION-xml \
  php$PHP_VERSION-zip \
  php-dev \
  php-imagick \
  php-pear \
  php-xml

# Configure PHP.
mkdir /run/php
phpenmod -v ${PHP_VERSION} intl

# Install Composer
php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer --version=${COMPOSER_VERSION}

# Configure NPM.
npm config set prefix /usr/local

# Install Deployer
curl -LO https://deployer.org/deployer.phar
mv deployer.phar /usr/local/bin/dep
chmod +x /usr/local/bin/dep

# Configure Nginx to run containerised.
echo "daemon off;" >> /etc/nginx/nginx.conf && \
ln -sf /dev/stdout /var/log/nginx/access.log && \
ln -sf /dev/stderr /var/log/nginx/error.log

# Copy config files into position.
cp configs/nginx-default /etc/nginx/sites-available/default
cp configs/php-fpm.conf /etc/php/$PHP_VERSION/fpm/php-fpm.conf
cp configs/php.ini /etc/php/$PHP_VERSION/fpm/conf.d/99-php.ini
cp configs/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Update config files with the PHP version.
sed -i s/%%PHP_VERSION%%/$PHP_VERSION/g /etc/php/$PHP_VERSION/fpm/php-fpm.conf
sed -i s/%%PHP_VERSION%%/$PHP_VERSION/g /etc/supervisor/conf.d/supervisord.conf
sed -i s/%%PHP_VERSION%%/$PHP_VERSION/g /etc/nginx/sites-available/default

# Cleanup temporary and unused files.
apt-get remove -y --purge software-properties-common
apt-get -y autoremove
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/*
