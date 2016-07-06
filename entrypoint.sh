#!/bin/sh
set -e
if test -z "$1"; then
	echo "Usage:"
	echo "  docker run -v WORKDIR:/go:rw -u UID[:GID][ -e GO_GET=no] myrenett/gomb IMPORT_PATH[ GIT_REF|GIT_SHA1]"
	echo ""
	echo "where USER must have write permissions to WORKDIR."
	exit 2
fi

TARGET="$GOPATH/bin/$(basename "$1")"
set -x

# If GO_GET is not yes, assume the source code is mounted into the container.
if test "$GO_GET" = "yes"; then
	go get -d "$1"
fi
cd "$GOPATH/src/$1"

if test -n "$2"; then
	git checkout "$2"
fi

go build -o "$TARGET" -installsuffix cgo -tags netgo -ldflags '-w -s'  .
upx $UPX_OPTS "$TARGET"
