FROM ubuntu:jammy 

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ Etc/UTC

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y software-properties-common apt-utils tzdata apache2 certbot python3-certbot-apache git curl gnupg && \
    mkdir -p /etc/apt/keyrings && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    a2enmod ssl && a2enmod proxy && a2enmod proxy_http && \ 
    a2enmod proxy_balancer && a2enmod proxy_ajp && a2enmod proxy_wstunnel && \
    a2enmod lbmethod_byrequests && a2enmod rewrite && \
    a2enmod headers && a2dissite 000-default.conf && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt install -y nodejs && \
    echo "00 00 * * * root  /bin/echo "\$\(date\)" | /bin/cat >> /var/log/certbot-renew.log && /usr/bin/certbot renew >> /var/log/certbot-renew.log" >> /etc/crontab

WORKDIR /etc/apache2

COPY .env .env
COPY scripts/init_ca.sh init_ca.sh

RUN chmod +x init_ca.sh && \ 
    git clone https://github.com/raventools-labs/ca-tools.git && \
    cp .env ca-tools && \
    cd ca-tools && npm install


VOLUME [ "/etc/letsencrypt", "/etc/apache2/sites-available", "/var/log/apache2", "/var/www/html","/etc/apache2/certs", "/etc/apache2/ca-tools/data" ]

EXPOSE 80
EXPOSE 443

CMD ./init_ca.sh; a2ensite `ls /etc/apache2/sites-available`;  service cron start; service apache2 reload; apachectl -D FOREGROUND
