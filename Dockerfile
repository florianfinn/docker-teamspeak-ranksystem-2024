FROM php:8.2.20-apache


RUN apt-get update -y && \
        apt-get install -y busybox libcurl3-dev libzip-dev libssh2-1-dev libonig-dev && \
        \
        pecl install ssh2-1.4.1
		
RUN docker-php-ext-install curl && \
        docker-php-ext-install zip && \
        docker-php-ext-install pdo && \
        docker-php-ext-install pdo_mysql && \
        docker-php-ext-install mbstring && \
        \
        docker-php-ext-enable curl && \
        docker-php-ext-enable zip && \
        docker-php-ext-enable pdo && \
        docker-php-ext-enable pdo_mysql && \
        docker-php-ext-enable ssh2 && \
        docker-php-ext-enable mbstring && \
        \
        mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
		
RUN rm -rf /var/lib/apt/lists/* && \
    echo "deb http://deb.debian.org/debian buster main" > /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian buster main" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian-security/ buster/updates main" >> /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian-security/ buster/updates main" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian buster-updates main" >> /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian buster-updates main" >> /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y cron

# Add crontab file in the cron directory
ADD crontab /etc/cron.d/hello-cron

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/hello-cron

# Apply cron job
#RUN crontab /etc/cron.d/hello-cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Run the command on container startup
CMD cron && /usr/sbin/apache2ctl -D FOREGROUND && tail -f /var/log/cron.log

RUN apt-get update && \
    apt-get upgrade -y
		
COPY "./fix-rank/entrypoint.sh" "/usr/local/bin/"

RUN chmod -R ugo=rx /usr/local/bin/entrypoint.sh

ENTRYPOINT entrypoint.sh

EXPOSE 80/tcp

ENV RANKSYSTEM_VERSION=1.3.23 \
	VOLUME="/var/www/html"

VOLUME [ "/var/www/html" ]
