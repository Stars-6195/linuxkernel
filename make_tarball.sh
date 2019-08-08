#!/bin/bash

set -e

BUILD="build"
OTHERDIR="otherfiles"
DEST="$1"
OUT_TARBALL="$2"
# Create tarball with BSD tar
echo -n "Creating tarball ... "
pushd .
cd $DEST && tar -zcvf ../$OUT_TARBALL .
popd

set -x
echo "Done"
