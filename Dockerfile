FROM ubuntu:latest
MAINTAINER Larry Chow <larry@51.is>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update 
RUN apt-get -y upgrade

# PHPMOADMIN Requirements
RUN apt-get -y install nginx php5-fpm php5-mongo python-setuptools

# nginx config
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf

# nginx site conf
ADD docker/phpmoadminplus.conf /etc/nginx/conf.d/phpmoadminplus.conf
RUN rm -rf /etc/nginx/sites-enabled/*

# Supervisor Config
RUN /usr/bin/easy_install supervisor
RUN /usr/bin/easy_install supervisor-stdout
ADD docker/supervisord.conf /etc/supervisord.conf

# Install phpMoAdminPlus
ADD src/ /usr/share/nginx/html
RUN chown -R www-data:www-data /usr/share/nginx/html

# Startup Script
ADD docker/bootstrap.sh /bootstrap.sh
RUN chmod 755 /bootstrap.sh

EXPOSE 80
CMD ["/bin/bash", "/bootstrap.sh"]
