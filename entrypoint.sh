#!/bin/sh
set -e
if test -z "$1"; then
	echo 'Builds and minifies a Go binary. Building libraries or plugins is not supported.'
	echo ''
	echo 'Usage:'
	echo '  docker run -v WORKDIR:/go:rw -u UID[:GID][ -e GO_GET=1] myrenett/gomb IMPORT_PATH[ GIT_REF|GIT_SHA1]'
	echo ''
	echo 'Find the resulting bianry in WORKDIR/bin. Go get is not run by default. Ensure USER have write'
	echo 'permissions to WORKDIR. To get the UID of the' echo 'current user, you can use $(id -u) in the command'
	echo 'line.'
	exit 2
fi

TARGET="$GOPATH/bin/$(basename "$1")"
set -x

# If GO_GET is not 1, assume the source code is mounted into the container.
if test "$GO_GET" = 1; then
	go get -d "$1"
fi
cd "$GOPATH/src/$1"

if test -n "$2"; then
	git checkout "$2"
fi

eval "go build -o '$TARGET' $GO_FLAGS ."
eval "upx $UPX_FLAGS '$TARGET'"
