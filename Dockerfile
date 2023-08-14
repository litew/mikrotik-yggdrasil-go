FROM docker.io/golang:alpine as builder

ARG DUMB_INIT_VERSION=1.2.5 \
    DUMB_INIT_ARCH=aarch64 \
    YGGDRASIL_VERSION=0.4.7

RUN set -ex \
  && apk --no-cache add \
      build-base \
      curl \
      git \
  && git clone "https://github.com/yggdrasil-network/yggdrasil-go.git" /src \
  && cd /src \
  && git reset --hard v${YGGDRASIL_VERSION} \
  && ./build

FROM docker.io/alpine

RUN set -ex \
  && apk --no-cache add bash sed

COPY --from=builder /src/yggdrasil /usr/bin/
COPY --from=builder /src/yggdrasilctl /usr/bin/
COPY entrypoint.sh /usr/bin/

VOLUME [ "/config" ]

RUN chmod +x /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/yggdrasil
RUN chmod +x /usr/bin/yggdrasilctl

ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]
