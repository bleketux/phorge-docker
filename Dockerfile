from debian:bullseye-slim

LABEL maintainer="M Sulchan Darmawan <bleketux@gmail.com>" \
   description="Simple Dockerized Phorge based on Debian Bullseye Slim"

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

RUN apt update && apt install -y --no-install-recommends \
   apt-transport-https \
   ca-certificates \
   curl \
   git \
   lsb-release \
   mariadb-client \
   sudo \
   vim-tiny \
   wget \
   && apt-get clean \
   && apt-get autoremove \
   && rm -rf /var/lib/apt/lists/*

RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
   && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list \
   && apt update && apt install -y \
   php7.4 \
   php7.4-apcu \
   php7.4-bz2 \
   php7.4-curl \
   php7.4-mysql \
   php7.4-gd \
   php7.4-iconv \
   php7.4-intl \
   php7.4-ldap \
   php7.4-mbstring \
   php7.4-memcache \
   php7.4-zip \
   php7.4-opcache \
   && apt-get clean \
   && apt-get autoremove \
   && rm -rf /var/lib/apt/lists/*

RUN git -C /var/www/html clone https://we.phorge.it/source/arcanist.git \
   && git -C /var/www/html clone https://we.phorge.it/source/phorge.git \
   && git -C /var/www/html clone https://github.com/PHPOffice/PHPExcel.git \
   && git config --system --add safe.directory /var/www/html/arcanist \
   && git config --system --add safe.directory /var/www/html/phorge

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
   && apt update && apt install -y \
   nodejs \
   python3-pip \
   python3-pygments \
   && apt-get clean \
   && apt-get autoremove \
   && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html/phorge/support/aphlict/server
RUN npm init -y \
   && npm install ws

COPY conf/php.ini /etc/php/7.4/apache2/php.ini
COPY conf/apache2.conf /etc/apache2/
COPY conf/000-default.conf /etc/apache2/sites-available/
COPY conf/local.json /var/www/html/phorge/conf/local/
# uncomment below to support https behind proxy
#COPY conf/preamble.php /var/www/html/phorge/support/

WORKDIR /var/www/html/phorge

RUN mkdir -p /var/repo \
   && ln -sv /usr/lib/git-core/git-http-backend /usr/bin/ \
   && ./bin/config set phd.user root \
   && echo "www-data ALL=(root) SETENV: NOPASSWD: /usr/bin/git-http-backend" >> /etc/sudoers \
   && echo "www-data ALL=(root) SETENV: NOPASSWD: /usr/bin/git" >> /etc/sudoers \
   && a2enmod rewrite

CMD ["/usr/sbin/apachectl", "-D", "FOREGROUND"]
