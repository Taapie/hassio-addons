#!/usr/bin/env sh
set +u

GOARCH=$(cat go_arch)
echo Go arch: $GOARCH
go version
