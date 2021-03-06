FROM golang:1.9-alpine

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
