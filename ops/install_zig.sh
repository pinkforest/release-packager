#!/bin/ash
set -ex

setup_environment() {

    . /set_arch.sh && arch_env

    export INSTALL_DIR="/zig"
}

install_target() {

    mkdir $INSTALL_DIR
    cd $INSTALL_DIR
    wget -O zig.tar.xz https://ziglang.org/download/0.9.0/zig-linux-$CROSS_ARCH-0.9.0.tar.xz
    tar --strip-components=1 -xvf zig.tar.xz
    rm zig.tar.xz

}
