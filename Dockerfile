# FROM ubuntu:22.04
FROM eniocarboni/docker-ubuntu-systemd
# FROM ubuntu/bind9:latest
# ARG BIND9_USER=root

# Enable systemd
ARG DEBIAN_FRONTEND=noninteractive

RUN apt -y update
RUN apt -y upgrade
RUN add-apt-repository -y universe
# RUN add-apt-repository -y ppa:duplicity-team/duplicity-release-git
# RUN add-apt-repository --y ppa:ondrej/php

# install these at runtime to give a faster experience when installing MIAB
RUN apt -y install \
  adduser \
  apt \
  base-files \
  base-passwd \
  bash \
  bc \
  bind9 \
  bsdutils \
  ca-certificates \
  certbot \
  coreutils \
  cron \
  curl \
  dash \
  dbconfig-common \
  debconf \
  debianutils \
  dialog \
  diffutils \
  dovecot-antispam \
  dovecot-core \
  dovecot-imapd \
  dovecot-lmtpd \
  dovecot-managesieved \
  dovecot-pop3d \
  dovecot-sieve \
  dovecot-sqlite \
  dpkg \
  duplicity \
  e2fsprogs \
  fail2ban \
  file \
  findutils \
  gcc-12-base \
  gcc \
  gettext \
  git \
  gnupg2 \
  gpgv \
  grep \
  gzip \
  hostname \
  idn2 \
  init-system-helpers \
  iputils-ping \
  ldnsutils \
  libacl1 \
  libapt-pkg6.0 \
  libattr1 \
  libaudit-common \
  libaudit1 \
  libawl-php \
  libblkid1 \
  libbz2-1.0 \
  libc-bin \
  libc6 \
  libcap-ng0 \
  libcap2 \
  libcgi-fast-perl \
  libcom-err2 \
  libcrypt1 \
  libdb5.3 \
  libdebconfclient0 \
  libext2fs2 \
  libffi8 \
  libgcc-s1 \
  libgcrypt20 \
  libgmp10 \
  libgnutls30 \
  libgpg-error0 \
  libgssapi-krb5-2 \
  libhogweed6 \
  libidn2-0 \
  libjs-jquery-mousewheel \
  libjs-jquery \
  libk5crypto3 \
  libkeyutils1 \
  libkrb5-3 \
  libkrb5support0 \
  liblz4-1 \
  liblzma5 \
  libmagic1 \
  libmail-dkim-perl \
  libmount1 \
  libncurses6 \
  libncursesw6 \
  libnettle8 \
  libnsl2 \
  libp11-kit0 \
  libpam-modules-bin \
  libpam-modules \
  libpam-runtime \
  libpam0g \
  libpcre2-8-0 \
  libpcre3 \
  libprocps8 \
  librsync-dev \
  libseccomp2 \
  libselinux1 \
  libsemanage-common \
  libsemanage2 \
  libsepol2 \
  libsmartcols1 \
  libss2 \
  libssl3 \
  libstdc++6 \
  libsystemd0 \
  libtasn1-6 \
  libtinfo6 \
  libtirpc-common \
  libtirpc3 \
  libudev1 \
  libunistring2 \
  libuuid1 \
  libxxhash0 \
  libzstd1 \
  locales \
  login \
  logsave \
  lsb-base \
  lsb-release \
  mawk \
  mount \
  munin-node \
  munin \
  ncurses-base \
  ncurses-bin \
  net-tools \
  netcat-openbsd \
  nginx \
  nsd \
  ntp \
  opendkim-tools \
  opendkim \
  opendmarc \
  openssh-client \
  openssh-server \
  openssl \
  passwd \
  perl-base \
  php8.1-cli \
  php8.1-common \
  php8.1-curl \
  php8.1-fpm \
  php8.1-gd \
  php8.1-imap \
  php8.1-intl \
  php8.1-mbstring \
  php8.1-pspell \
  php8.1-soap \
  php8.1-sqlite3 \
  php8.1-xml \
  pollinate \
  postfix-pcre \
  postfix-sqlite \
  postfix \
  postgrey \
  procps \
  python3-dev \
  python3-pip \
  python3-setuptools \
  python3 \
  pyzor \
  razor \
  rsync \
  rsyslog \
  sed \
  sensible-utils \
  software-properties-common \
  spampd \
  sqlite3 \
  sudo \
  systemd-sysv \
  systemd \
  sysvinit-utils \
  tar \
  ubuntu-keyring \
  unattended-upgrades \
  unzip \
  usrmerge \
  util-linux \
  virtualenv \
  wget \
  zlib1g

RUN apt -y install \
  dnsutils \
  lsof \
  sniproxy \
  vim

# python3 \
# python3-dev \
# python3-pip \
# python3-setuptools \
# RUN git clone --branch dev https://gitlab.com/duplicity/duplicity.git
# RUN cd duplicity
# RUN python3 setup.py install --prefix=/usr/local

# remove files we don't need
RUN apt-get clean
RUN touch /var/log/syslog /var/log/auth.log
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# remove systemd files we don't need
RUN cd /lib/systemd/system/sysinit.target.wants/
# RUN ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1
RUN rm -f /lib/systemd/system/multi-user.target.wants/*
RUN rm -f /etc/systemd/system/*.wants/*
RUN rm -f /lib/systemd/system/local-fs.target.wants/*
RUN rm -f /lib/systemd/system/sockets.target.wants/*udev*
RUN rm -f /lib/systemd/system/sockets.target.wants/*initctl*
RUN rm -f /lib/systemd/system/basic.target.wants/*
RUN rm -f /lib/systemd/system/anaconda.target.wants/*
RUN rm -f /lib/systemd/system/plymouth*
RUN rm -f /lib/systemd/system/systemd-update-utmp*

COPY ./bin-container/install.sh /
COPY ./bin-container/status-check.sh /
COPY ./bin-container/named.conf /
EXPOSE 25
EXPOSE 53
EXPOSE 80
EXPOSE 443
EXPOSE 465
EXPOSE 587
EXPOSE 993
EXPOSE 995
EXPOSE 4190
EXPOSE 10025

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/lib/systemd/systemd"]
