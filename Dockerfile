FROM skylarkelty/centos:latest
MAINTAINER "Skylar Kelty" <s.kelty@kent.ac.uk>
ADD ./shared/files/remi.repo /etc/yum.repos.d/remi.repo
ADD ./shared/files/nginx.repo /etc/yum.repos.d/nginx.repo
ADD ./shared/files/supervisord.service /etc/systemd/system/multi-user.target.wants/supervisord.service
RUN mkdir -p /etc/ssl/certs/
RUN mkdir -p /etc/ssl/private/
ADD ./shared/files/ssc /etc/ssl/certs/nginx-selfsigned.crt
ADD ./shared/files/ssk /etc/ssl/private/nginx-selfsigned.key
ADD ./shared/files/ssp /etc/ssl/certs/dhparam.pem
RUN yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm && yum clean all
RUN curl https://packages.microsoft.com/config/rhel/7/prod.repo | tee /etc/yum.repos.d/mssql-tools.repo
RUN yum-config-manager --enable remi-php72 && yum update -y && yum clean all
RUN ACCEPT_EULA=Y yum install -y msodbcsql nginx ImageMagick aspell texlive-latex graphviz \
    mimetex cronie python-setuptools sendmail postfix \
    php72 php72-php-fpm php72-php-opcache php72-php-cli \
    php72-php-gd php72-php-pdo php72-php-xml php72-php-intl php72-php-pear \
    php72-php-soap php72-php-xmlrpc php72-php-process php72-php-mysqlnd \
    php72-php-mbstring php72-php-ldap php72-php-mcrypt php72-php-sqlsrv \
    php72-php-pecl-memcache php72-php-pecl-memcached php72-php-pecl-solr2 \
    php72-php-pecl-mongodb php72-php-pecl-redis php72-php-pecl-zip php72-php-xdebug \
    php72-php-pecl-event && yum clean all
RUN easy_install supervisor
RUN ln -s /usr/bin/php72 /usr/bin/php && \
    ln -s /usr/bin/php72-cgi /usr/bin/php-cgi && \
    ln -s /usr/bin/php72-pear /usr/bin/php-pear && \
    ln -s /usr/bin/php72-phar /usr/bin/php-phar
ADD ./shared/phpredmin /var/www/vhosts/moodle-dev.kent.ac.uk/phpredmin
ADD ./shared/simplesamlphp /var/www/vhosts/moodle-dev.kent.ac.uk/sp/simplesamlphp
ADD ./shared/puppet /puppet
RUN yum install -y puppet && \
    puppet apply --modulepath=/puppet/modules /puppet/manifests/site.pp && \
    yum remove -y puppet && yum clean all
RUN date > /etc/docker-release

# Reinstall glibc-common to make sure the locale required for unit testing is installed
RUN yum reinstall -q -y glibc-common
RUN localedef --quiet -c -i /usr/share/i18n/locales/en_AU -f UTF-8 en_AU
RUN localedef --quiet -c -i /usr/share/i18n/locales/en_GB -f UTF-8 en_GB
RUN localedef --quiet -c -i /usr/share/i18n/locales/en_US -f UTF-8 en_US

# Support Moodle-perf-comparison
RUN yum install -y git mariadb  && yum clean all

# Support Snark dev.
RUN yum install -y libreoffice libreoffice-pyuno libreoffice-ure && yum clean all
RUN curl -SsL https://raw.githubusercontent.com/dagwieers/unoconv/master/unoconv > /usr/local/bin/unoconv
RUN chmod 0755 /usr/local/bin/unoconv

EXPOSE 22 80 443

CMD ["/usr/sbin/init"]
