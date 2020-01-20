FROM debian:stretch-slim AS base

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
        dumb-init \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

FROM base as builder

ENV MAJVERS 2.13
ENV MINVERS .1
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	wget \
        git \
        build-essential \
        cmake \
	ca-certificates

WORKDIR /tmp/sdrlib
RUN wget https://www.sdrplay.com/software/SDRplay_RSP_API-Linux-${MAJVERS}${MINVERS}.run && \
        export ARCH=`arch` && \
        sh ./SDRplay_RSP_API-Linux-${MAJVERS}${MINVERS}.run --tar xvf && \
        cp ${ARCH}/libmirsdrapi-rsp.so.${MAJVERS} /usr/local/lib/. && \
        chmod 644 /usr/local/lib/libmirsdrapi-rsp.so.${MAJVERS} && \
        ln -s /usr/local/lib/libmirsdrapi-rsp.so.${MAJVERS} /usr/local/lib/libmirsdrapi-rsp.so.2 && \
        ln -s /usr/local/lib/libmirsdrapi-rsp.so.2 /usr/local/lib/libmirsdrapi-rsp.so && \
        cp mirsdrapi-rsp.h /usr/local/include/. && \
        chmod 644 /usr/local/include/mirsdrapi-rsp.h
WORKDIR /tmp
RUN git clone https://github.com/ON5HB/rsp_tcp.git ./rsp_tcp
WORKDIR /tmp/rsp_tcp/build
RUN cmake .. && make && make install

FROM base

COPY --from=builder /usr/local/bin/ /usr/local/bin/
# Workaround a docker bug with 2 consecutive COPY
RUN true
COPY --from=builder /usr/local/lib/ /usr/local/lib/
RUN ldconfig

ENV     PORT=1234 \
        GAIN_REDUCTION=34 \
        GAIN_AUTO=-34 \
        GAIN_LOOP=0 \
        LNA=2 \
        DEVICE=1 \
        ANTENNA=1

CMD [ "bash", "-c", "exec rsp_tcp -a 0.0.0.0 -p ${PORT} -d ${DEVICE} -P ${ANTENNA} -r ${GAIN_REDUCTION} -L ${LNA} -A ${GAIN_AUTO} -G ${GAIN_LOOP}" ]
