FROM golang:1.9-alpine as builder

WORKDIR /go/src/github.com/wuping/etcdkeeper

ENV ETCDKEEPER_VERSION 0.7.5

RUN wget -c -q -O etcdkeeper-${ETCDKEEPER_VERSION}.tar.gz https://github.com/evildecay/etcdkeeper/archive/v${ETCDKEEPER_VERSION}.tar.gz \
 && tar zxf etcdkeeper-${ETCDKEEPER_VERSION}.tar.gz \
 && rm -f etcdkeeper-${ETCDKEEPER_VERSION}.tar.gz \
 && apk add -U git \
 && go get github.com/golang/dep/... \
 && mv -f etcdkeeper-${ETCDKEEPER_VERSION}/src/* ./ \
 && mv -f etcdkeeper-${ETCDKEEPER_VERSION}/Gopkg.* ./ \
 && ln -sf github.com/wuping/etcdkeeper/etcdkeeper /go/src/ \
 && dep ensure -update \
 && go build -o etcdkeeper.bin etcdkeeper/main.go


FROM alpine:3.10.1

ENV ETCDKEEPER_VERSION 0.7.5
ENV HOST="0.0.0.0"
ENV PORT="8080"

RUN apk add --no-cache ca-certificates

WORKDIR /etcdkeeper
COPY --from=builder /go/src/github.com/wuping/etcdkeeper/etcdkeeper.bin .
COPY --from=builder /go/src/github.com/wuping/etcdkeeper/etcdkeeper-${ETCDKEEPER_VERSION}/assets ./assets

EXPOSE ${PORT}

ENTRYPOINT ./etcdkeeper.bin -h $HOST -p $PORT
