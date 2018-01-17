FROM ubuntu:14.04

ARG RELEASE_DATE="2016-06-21"
ARG RELEASE_DATE_SIGN=""
ARG VERSION="8.9.0.190"
ARG SOURCE_REPO_URL="deb http://static.teamlab.com.s3.amazonaws.com/repo/debian squeeze main"
ARG DEBIAN_FRONTEND=noninteractive 

LABEL onlyoffice.community.release-date="${RELEASE_DATE}" \
      onlyoffice.community.version="${VERSION}" \
      onlyoffice.community.release-date.sign="${RELEASE_DATE_SIGN}" \
      maintainer="Ascensio System SIA <support@onlyoffice.com>"

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 

RUN echo "${SOURCE_REPO_URL}" >> /etc/apt/sources.list && \
    echo "deb http://download.mono-project.com/repo/ubuntu trusty main" | sudo tee /etc/apt/sources.list.d/mono-official.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CB2DE8E5 && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    locale-gen en_US.UTF-8 && \
    apt-get -y update && \
    apt-get install --force-yes -yq software-properties-common wget curl cron rsyslog gcc make && \
    wget https://www.openssl.org/source/openssl-1.1.0f.tar.gz && \
    tar xzvf openssl-1.1.0f.tar.gz && \
    cd openssl-1.1.0f && \
    ./config && \
    make && \
    make install && \
    cd .. && \
    rm -f openssl-1.1.0f.tar.gz && \
    wget http://nginx.org/keys/nginx_signing.key && \
    apt-key add nginx_signing.key && \
    echo "deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list.d/nginx.list && \
    echo "deb-src http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list.d/nginx.list && \	
    apt-get install --force-yes -yq default-jdk && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get -y update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections && \
    sed -i 's|JAVA_VERSION=8u151|JAVA_VERSION=8u162|' /var/lib/dpkg/info/oracle-java8-installer.* && \
    sed -i 's|PARTNER_URL=http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/|PARTNER_URL=http://download.oracle.com/otn-pub/java/jdk/8u162-b12/0da788060d494f5095bf8624735fa2f1/|' /var/lib/dpkg/info/oracle-java8-installer.* && \
    sed -i 's|SHA256SUM_TGZ="c78200ce409367b296ec39be4427f020e2c585470c4eed01021feada576f027f"|SHA256SUM_TGZ="68ec82d47fd9c2b8eb84225b6db398a72008285fafc98631b1ff8d2229680257"|' /var/lib/dpkg/info/oracle-java8-installer.* && \
    sed -i 's|J_DIR=jdk1.8.0_151|J_DIR=jdk1.8.0_162|' /var/lib/dpkg/info/oracle-java8-installer.* && \
    apt-get install --force-yes -yq oracle-java8-installer &&  \
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
    apt-get install --force-yes -yq apt-transport-https && \
    echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list && \
    apt-get update && \
    apt-get install --force-yes -yq elasticsearch && \
    add-apt-repository -y ppa:certbot/certbot && \
    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - && \
    apt-get install -y nodejs && \
    apt-get -y update && \
    apt-get install --force-yes -yq mono-complete ca-certificates-mono && \
    echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d && \
    apt-get install --force-yes -yq dumb-init certbot onlyoffice-communityserver htop nano dnsutils && \
    rm -rf /var/lib/apt/lists/*


ADD config /app/onlyoffice/config/
ADD assets /app/onlyoffice/assets/
ADD run-community-server.sh /app/onlyoffice/run-community-server.sh
RUN chmod -R 755 /app/onlyoffice/*.sh

VOLUME ["/var/log/onlyoffice"]
VOLUME ["/var/www/onlyoffice/Data"]
VOLUME ["/var/lib/mysql"]

EXPOSE 80 443 5222 3306 9865 9888 9866 9871 9882 5280

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/app/onlyoffice/run-community-server.sh"];
