FROM ghcr.io/hassio-addons/debian-base:7.1.0

LABEL io.hass.version="1.0" io.hass.type="addon" io.hass.arch="aarch64|amd64"

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        sudo \
        locales \
        cups \
        avahi-daemon \
        libnss-mdns \
        dbus \
        colord \
        printer-driver-all \
        printer-driver-gutenprint \
        openprinting-ppds \
        hpijs-ppds \
        hp-ppd  \
        hplip \
        printer-driver-foo2zjs \
        cups-pdf \
        gnupg2 \
        lsb-release \
        nano \
        samba \
        bash-completion \
        procps \
        whois \
        apt-utils \
        qemu-user-t static

# Canon driver installation
COPY canon-drivers/full/cnijfilter-common.deb /tmp/
RUN dpkg -i /tmp/cnijfilter-common.deb \
    && rm -rf /tmp/cnijfilter-common.deb

# Install Canon filter
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys 3BA6E6CCE411CFCF \
    && gpg --no-default-keyring --keyring /etc/apt/keyrings/thierry-fork-michael-gruz.gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys 3BA6E6CCE411CFCF \
    && echo "deb [signed-by=/etc/apt/keyrings/thierry-fork-michael-gruz.gpg] https://ppa.launchpadcontent.net/thierry-f/fork-michael-gruz/ubuntu focal main" | tee /etc/apt/sources.list.d/thierry-f-fork-michael-gruz.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        cnijfilter2 \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

COPY rootfs /

# Add user and disable sudo password checking
RUN useradd \
  --groups=sudo,lp,lpadmin \
  --create-home \
  --home-dir=/home/print \
  --shell=/bin/bash \
  --password=$(mkpasswd print) \
  print \
&& sed -i '/%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers

EXPOSE 631

RUN chmod a+x /run.sh

CMD ["/run.sh"]