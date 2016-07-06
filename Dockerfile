FROM alpine:edge
MAINTAINER Sindre Myren <sindre@myrenett.no>

ARG GO_VERSION=1.6.2-r4
ARG UPX_VERSION=3.91

RUN apk upgrade --no-cache --available && \
	apk add --no-cache \
		ca-certificates \
		git \
		"go=${GO_VERSION}" \
		openssl \
		scanelf

ADD https://github.com/lalyos/docker-upx/releases/download/v${UPX_VERSION}/upx /bin/upx
RUN chmod +x /bin/upx
COPY entrypoint.sh /entrypoint.sh

VOLUME [/go]

# Go build configuration.
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOPATH=/go

# Entrypoint configuration.
ENV UPX_OPTS=-8
ENV GO_GET=yes

WORKDIR $GOPATH
ENTRYPOINT ["/entrypoint.sh"]
