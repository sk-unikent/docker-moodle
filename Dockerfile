FROM kentis/centos:latest
MAINTAINER "Skylar Kelty" <s.kelty@kent.ac.uk>
ADD ./shared/files/remi.repo /etc/yum.repos.d/remi.repo
ADD ./shared/files/nginx.repo /etc/yum.repos.d/nginx.repo
ADD ./shared/files/supervisord.service /etc/systemd/system/multi-user.target.wants/supervisord.service
RUN yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm \
                   nginx ImageMagick aspell texlive-latex graphviz mimetex cronie python-setuptools \
                   && yum clean all
RUN easy_install supervisor
RUN yum-config-manager --enable remi-php70 && \
    yum install -y php70 php70-php-fpm php70-php-opcache php70-php-cli \
    php70-php-gd php70-php-pdo php70-php-xml php70-php-intl php70-php-pear \
    php70-php-soap php70-php-xmlrpc php70-php-process php70-php-sqlsrv \
    php70-php-mbstring php70-php-ldap php70-php-mcrypt php70-php-mysqlnd \
    php70-php-pecl-memcache php70-php-pecl-memcached php70-php-pecl-solr2 \
    php70-php-pecl-mongodb php70-php-pecl-redis php70-php-pecl-zip && yum clean all
RUN ln -s /usr/bin/php70 /usr/bin/php && \
    ln -s /usr/bin/php70-cgi /usr/bin/php-cgi && \
    ln -s /usr/bin/php70-pear /usr/bin/php-pear && \
    ln -s /usr/bin/php70-phar /usr/bin/php-phar
ADD ./shared/phpredmin /var/www/vhosts/moodle-dev.kent.ac.uk/phpredmin
ADD ./shared/simplesamlphp /var/www/vhosts/moodle-dev.kent.ac.uk/sp/simplesamlphp
ADD ./shared/puppet /puppet
RUN yum install -y puppet && \
    puppet apply --modulepath=/puppet/modules /puppet/manifests/site.pp && \
    yum remove -y puppet && yum clean all

# Libreoffice - https://www.libreoffice.org/download/libreoffice-fresh/
ENV LIBREOFFICE_VER 5.2.3
ENV LIBREOFFICE_VER_MINOR .3

RUN wget http://linorg.usp.br/LibreOffice/libreoffice/stable/$LIBREOFFICE_VER/rpm/x86_64/LibreOffice_${LIBREOFFICE_VER}_Linux_x86-64_rpm.tar.gz \
	&& echo "06edfe30aebb00ff80738855ae22b01c  LibreOffice_${LIBREOFFICE_VER}_Linux_x86-64_rpm.tar.gz" > LIBREOFFICEMD5 \
	&& RESULT=$(md5sum -c LIBREOFFICEMD5) \
	&& echo ${RESULT} > ~/check-libreoffice-md5.txt \
	&& tar xf LibreOffice_${LIBREOFFICE_VER}_Linux_x86-64_rpm.tar.gz \
	&& cd LibreOffice_${LIBREOFFICE_VER}${LIBREOFFICE_VER_MINOR}_Linux_x86-64_rpm/RPMS \
	&& yum -y install *.rpm \
	&& yum clean all \
	&& cd && rm -f LIBREOFFICEMD5 && rm -f LibreOffice_${LIBREOFFICE_VER}_Linux_x86-64_rpm.tar.gz \
	&& rm -rf LibreOffice_${LIBREOFFICE_VER}${LIBREOFFICE_VER_MINOR}_Linux_x86-64_rpm

RUN yum update -y && yum install -y nano

RUN date > /etc/docker-release

EXPOSE 22 80 443

CMD ["/usr/sbin/init"]
