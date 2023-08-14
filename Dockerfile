FROM docker.io/golang:alpine as builder

#ENV CGO_ENABLED=0
ENV DUMB_INIT_VERSION=1.2.5 \
    DUMB_INIT_ARCH=x86_64 \
    YGGDRASIL_VERSION=0.4.7

RUN set -ex \
  && apk --no-cache add \
      build-base \
      curl \
      git \
  && git clone "https://github.com/yggdrasil-network/yggdrasil-go.git" /src \
  && cd /src \
  && git reset --hard v${YGGDRASIL_VERSION} \
  && ./build \
  && curl -sSfLo /tmp/dumb-init "https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_${DUMB_INIT_ARCH}" \
  && chmod 0755 /tmp/dumb-init

FROM docker.io/alpine

RUN set -ex \
  && apk --no-cache add bash

COPY --from=builder /src/yggdrasil /usr/bin/
COPY --from=builder /src/yggdrasilctl /usr/bin/
COPY --from=builder /tmp/dumb-init /usr/bin/
COPY entrypoint.sh /usr/bin/

VOLUME [ "/config" ]

RUN chmod +x /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/yggdrasil
RUN chmod +x /usr/bin/yggdrasilctl

ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]
