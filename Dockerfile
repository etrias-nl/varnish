FROM emgag/varnish:6.6.2 AS varnish

ARG GEOIP_VERSION=1.2.2
ENV GEOIP_VERSION=$GEOIP_VERSION

ARG CFG_VERSION=6.6-11.0
ENV CFG_VERSION=$CFG_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
	libmaxminddb-dev \
	libcurl4-openssl-dev \
  libluajit-5.1-dev \
  xxd \
	&& rm -rf /var/lib/apt/lists/*


RUN cd /usr/local/src/ && \
	curl -sfLO https://github.com/fgsch/libvmod-geoip2/archive/refs/tags/v${GEOIP_VERSION}.tar.gz && \
	tar -xzf v${GEOIP_VERSION}.tar.gz && \
	cd libvmod-geoip2-${GEOIP_VERSION} && \
	./autogen.sh && \
	./configure && \
	make install && \
	cd /usr/local/src && \
	rm -rf libvmod-geoip2-${GEOIP_VERSION}

RUN cd /usr/local/src/ && \
	curl -sfLO https://github.com/carlosabalde/libvmod-cfg/archive/refs/tags/${CFG_VERSION}.tar.gz && \
	tar -xzf ${CFG_VERSION}.tar.gz && \
	cd libvmod-cfg-${CFG_VERSION} && \
	./autogen.sh && \
	./configure && \
	make install && \
	cd /usr/local/src && \
	rm -rf libvmod-cfg-${CFG_VERSION}