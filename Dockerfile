FROM        nginx:latest
MAINTAINER  Benoit <benoit@terra-art.net>

# Set Environement variables
ENV         LC_ALL=C
ENV         DEBIAN_FRONTEND=noninteractive

# Update package repository and install packages
RUN         apt-get -y update && \
            apt-get -y install supervisor python php-common php-fpm php-zip php-sqlite3 nano wget curl php-curl php-cli php-mysql php-xml php-mbstring php-sabre-vobject&& \
            apt-get clean && \
            rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN         curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Fetch the latest software version from the official website if needed
RUN         test ! -d /usr/share/nginx/html/Baikal-0.4.6 && \
            wget https://github.com/skeal/docker-baikal/raw/master/0.4.6.tar.gz && \
            tar xvzf 0.4.6.tar.gz -C /usr/share/nginx/html && \
            chown -R www-data:www-data /usr/share/nginx/html/Baikal-0.4.6 && \
            rm 0.4.6.tar.gz

WORKDIR     /usr/share/nginx/html/Baikal-0.4.6
RUN         composer install

# Add configuration files. User can provides customs files using -v in the image startup command line.
COPY        supervisord.conf /etc/supervisor/supervisord.conf
COPY        nginx.conf /etc/nginx/nginx.conf
COPY        php-fpm.conf /etc/php/7.0/fpm/php-fpm.conf

# Expose HTTP port
EXPOSE      80

# Last but least, unleach the daemon!
ENTRYPOINT  ["/usr/bin/supervisord"]
