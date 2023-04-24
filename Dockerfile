# hadolint ignore=DL3006
FROM golang as exporter_builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/jonnenauha/prometheus_varnish_exporter.git

WORKDIR /go/prometheus_varnish_exporter
RUN go build

FROM emgag/varnish:6.6.2 AS varnish

ARG GEOIP_VERSION=1.2.2
ENV GEOIP_VERSION=$GEOIP_VERSION

ARG CFG_VERSION=6.6-11.0
ENV CFG_VERSION=$CFG_VERSION

ARG AWSREST_VERSION="70.12"
ENV AWSREST_VERSION=$AWSREST_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
    libmaxminddb-dev \
    libcurl4-openssl-dev \
    libluajit-5.1-dev \
    gettext-base \
    xxd \
    && rm -rf /var/lib/apt/lists/*

# hadolint ignore=DL3003,SC2035
RUN cd /usr/local/src/ && \
    curl -sfLO https://github.com/fgsch/libvmod-geoip2/archive/refs/tags/v${GEOIP_VERSION}.tar.gz && \
    tar -xzf v${GEOIP_VERSION}.tar.gz && \
    cd libvmod-geoip2-${GEOIP_VERSION} && \
    ./autogen.sh && \
    ./configure && \
    make install && \
    cd /usr/local/src && \
    rm -rf libvmod-geoip2-${GEOIP_VERSION} *.tar.gz

# hadolint ignore=DL3003,SC2035
RUN cd /usr/local/src/ && \
    curl -sfLO https://github.com/carlosabalde/libvmod-cfg/archive/refs/tags/${CFG_VERSION}.tar.gz && \
    tar -xzf ${CFG_VERSION}.tar.gz && \
    cd libvmod-cfg-${CFG_VERSION} && \
    ./autogen.sh && \
    ./configure && \
    make install && \
    cd /usr/local/src && \
    rm -rf libvmod-cfg-${CFG_VERSION} *.tar.gz

# hadolint ignore=DL3003,SC2035
RUN cd /usr/local/src/ && \
    curl -sfLO https://github.com/xcir/libvmod-awsrest/archive/refs/tags/v${AWSREST_VERSION}.tar.gz && \
    tar -xzf v${AWSREST_VERSION}.tar.gz && \
    cd libvmod-awsrest-${AWSREST_VERSION} && \
    ./autogen.sh && \
    ./configure && \
    make install && \
    cd /usr/local/src && \
    rm -rf libvmod-awsrest-${AWSREST_VERSION} *.tar.gz

COPY --from=exporter_builder /go/prometheus_varnish_exporter/prometheus_varnish_exporter /usr/bin/prometheus-varnish-exporter
COPY varnishreload /usr/local/bin/varnishreload
COPY vcl/kubernetes_checks.vcl /etc/varnish/

COPY docker-entrypoint.d /docker-entrypoint.d/
COPY docker-entrypoint.sh /

COPY static /static

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh", "/init.sh"]
