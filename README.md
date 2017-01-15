# Gomb
Go minified binaries.

[![Build Status](https://travis-ci.org/myreentt/gomb.svg?branch=master)](https://travis-ci.org/myrenett/gomb)
[![license](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

Inspired by this [blog post](https://blog.filippo.io/shrink-your-go-binaries-with-this-one-weird-trick/), gomb is a small docker container that relies on [Alpine linux](https://www.alpinelinux.org/) and [UPX](http://upx.sourceforge.net/) to build minified static binaries for Go applications for use in e.g. scratch docker container.

Using this container, some binaries could become as small as 15% of the default compilation size with go build, or more than 6x smaller. Around 20% - 25% of the size is dropped by using the '-s -w' linker flags (drops debugging symbols). The remaining is stripped away by UPX. Be aware that UPX compresses the binary, and that there is a small overhead associated by uncompressing the application into memory on application startup.

This container image only fully supports Go gettable applications that can be fetched using Git. Applications that relay on a different SCM or dependency resolver, must currently provide a pre-populated GOPATH with the relevant version(s) checked out. Projects with a more complex build process than simply `go build` will need to extend the container.

## Usage

    $ docker run -v WORKDIR:/go:rw -u $(id -u) [ -e GO_GET=1] myrenett/gomb IMPORT_PATH[ GIT_REF|GIT_SHA1]


Where user referred to by `-u` must have read/write permissions to `WORKDIR`.

Relevant environment variables:

- `GO_GET`: Set to "1" to run `go get -d IMPORT_PATH`.
- `GO_FLAGS`: Flags to pass to the `go build` command. The default strips debug symbols and disables dynamic links to C libraries for the standard library. See `docker run --entrypoint go myrenett/gomb help build` for available options.
- `UPX_FLAGS`: See `docker run --entrypoint upx myrenett/gomb --help` for available options.

# Example

    $ mdir -p go
    $ docker run -v "$PWD/go":/go:rw -u $(id -u) myrenett/gomb github.com/myrenett/examples/hello-server

Comparing the file size for this example from the result of a normal `go build` with GOOS=linux, we can see a 4x decrease:

    $ du -h examples/hello-server/hello-server
    7.4M	examples/hello-server/hello-server
    $ du -h go/bin/hello-server
    1.6M	go/bin/hello-server

To further decrease the file size at the expense of compile time, we can send in `-e "UPX_OPTS=-9"` or the very slow `-e "UPX_OPTS=--brute"` into the container.

Using the latter, we can get down to a 6x decrease:

    % du -h go/bin/hello-server
    1.1M	go/bin/hello-server
