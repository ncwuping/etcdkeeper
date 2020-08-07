FROM golang:1.13.14-alpine3.11 as builder

ENV ETCDKEEPER_VERSION 0.7.6
ENV GO111MODULE on
ENV GOPROXY "https://goproxy.io"

WORKDIR /opt
RUN mkdir etcdkeeper \
 && wget -c -q -O etcdkeeper-${ETCDKEEPER_VERSION}.tar.gz https://github.com/evildecay/etcdkeeper/archive/v${ETCDKEEPER_VERSION}.tar.gz \
 && tar zxf etcdkeeper-${ETCDKEEPER_VERSION}.tar.gz -C etcdkeeper --strip-components=1 \
 && rm -f etcdkeeper-${ETCDKEEPER_VERSION}.tar.gz
WORKDIR /opt/etcdkeeper/src/etcdkeeper

RUN go mod download \
 && go build -o etcdkeeper.bin main.go

FROM alpine:3.11.6

ENV ETCDKEEPER_VERSION 0.7.6
ENV HOST="0.0.0.0"
ENV PORT="8080"

RUN apk add --no-cache ca-certificates

WORKDIR /etcdkeeper
COPY --from=builder /opt/etcdkeeper/src/etcdkeeper/etcdkeeper.bin .
COPY --from=builder /opt/etcdkeeper/assets ./assets

EXPOSE ${PORT}

ENTRYPOINT ./etcdkeeper.bin -h $HOST -p $PORT
