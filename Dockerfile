FROM debian:jessie

VOLUME /var/repo
EXPOSE  80

RUN apt-get clean && apt-get update && apt-get install -y \
      git \
      apache2 \
      curl \
      libapache2-mod-php5 \
      libmysqlclient18 \
      mercurial \
      mysql-client \
      php-apc \
      php5 \
      php5-apcu \
      php5-cli \
      php5-curl \
      php5-gd \
      php5-json \
      php5-ldap \
      php5-mysql \
      python-pygments \
      sendmail \
      subversion \
      tar \
      sudo \
      && apt-get clean && rm -rf /var/lib/apt/lists/*

# Setup apache
RUN a2enmod rewrite
ADD phabricator.conf /etc/apache2/sites-available/phabricator.conf
RUN ln -s /etc/apache2/sites-available/phabricator.conf /etc/apache2/sites-enabled/phabricator.conf && \
      rm -f /etc/apache2/sites-enabled/000-default.conf

# Make sure MySQL is actually available, not just that the container was created
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /usr/sbin/wait-for-it.sh
RUN chmod +x /usr/sbin/wait-for-it.sh

# Setup git-http
RUN echo "www-data ALL=(ALL) SETENV: NOPASSWD: /usr/lib/git-core/git-http-backend" >> /etc/sudoers

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["wait-for-it.sh", "db:3306", "--", "/entrypoint.sh"]

WORKDIR /opt/phabricator

CMD ["start"]
