FROM ubuntu:14.04

VOLUME /var/repo
EXPOSE  80

# Install deps
RUN apt-get update && apt-get install -y \
      # wait-for-it.sh dep
      realpath \
      # Apache
      apache2 \
      libapache2-mod-php5 \
      # Phabricator deps
      mysql-client \
      git \
      php5 php5-mysql php5-gd php5-dev php5-curl php-apc php5-cli php5-json

# Setup apache
RUN a2enmod rewrite
ADD apache-vhost.conf /etc/apache2/sites-available/000-default.conf

# Make sure MySQL is actually available, not just that the container was created.
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /usr/sbin/wait-for-it.sh
RUN chmod +x /usr/sbin/wait-for-it.sh

# Setup git-http
RUN echo "www-data ALL=(ALL) SETENV: NOPASSWD: /usr/lib/git-core/git-http-backend" >> /etc/sudoers

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["wait-for-it.sh", "-t", "30", "db:3306", "--", "/entrypoint.sh"]

WORKDIR /opt/phabricator

CMD ["start"]
