#!/usr/bin/env bash
# exit on error
set -o errexit

wget http://www.erlang.org/download/otp_src_23.2.tar.gz

tar -zxf otp_src_23.2.tar.gz

cd otp_src_23.2

./configure --prefix "$XDG_CACHE_HOME/opt/erlang/23.2"

make install
