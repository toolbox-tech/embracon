FROM php:7.2-apache

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY . /var/www/html/clienterei

RUN apt-get update && apt-get install --no-install-recommends -y unzip
RUN mkdir /opt/oracle \
    && cd /opt/oracle \
    && unzip /var/www/html/clienterei/lib/instantclient-basic-linux.x64-12.1.0.2.0.zip -d /opt/oracle \
    && unzip /var/www/html/clienterei/lib/instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /opt/oracle \
    && ln -s /opt/oracle/instantclient_12_1/libclntsh.so.12.1 /opt/oracle/instantclient_12_1/libclntsh.so \
    && ln -s /opt/oracle/instantclient_12_1/libclntshcore.so.12.1 /opt/oracle/instantclient_12_1/libclntshcore.so \
    && ln -s /opt/oracle/instantclient_12_1/libocci.so.12.1 /opt/oracle/instantclient_12_1/libocci.so \
    && rm -rf /opt/oracle/*.zip
	
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_12_1
ENV ORACLE_HOME=/opt/oracle/instantclient_12_1

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apt-get install --no-install-recommends -y libxml2-dev libaio-dev \
	&& echo "instantclient,/opt/oracle/instantclient_12_1" | pecl install oci8-2.1.8 \
	&& docker-php-ext-enable oci8 \
	&& docker-php-ext-configure oci8 --with-oci8=instantclient,/opt/oracle/instantclient_12_1,12.1 \
        && docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/opt/oracle/instantclient_12_1 \
        && docker-php-ext-install oci8 pdo_oci soap

RUN a2enmod php7 && a2enmod rewrite && a2enmod headers && a2enmod expires
    ENV APACHE_RUN_USER www-data
    ENV APACHE_RUN_GROUP www-data
    ENV APACHE_LOG_DIR /var/log/apache2
    ENV APACHE_PID_FILE /var/run/apache2.pid
    ENV APACHE_RUN_DIR /var/run/apache2
    ENV APACHE_LOCK_DIR /var/lock/apache2
	
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

workdir 'clienterei'

RUN composer install

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
