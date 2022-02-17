#!/bin/ash
set -ex

. /set_arch.sh
arch_env

. ./build_llvm_target.sh
setup_environment_native

export INSTALL_DIR="/llvm"
export SRC_DIR="/src"

# Build - llvm - Native
compile_target llvm "-DLLVM_ENABLE_LIBXML2=OFF -DLLVM_ENABLE_TERMINFO=OFF"
# Build - clang - Native
compile_target clang

if [ "$BUILDPLATFORM" == "$TARGETPLATFORM" ]; then
    # Build - lld - Native
    compile_target lld
    # Build - lldb - Native
    compile_target lldb
else
    # For cross compile all we needed were the tblgens..
    # clang-tblgen is not included in any packages :(
    # Probably due to it missing from install:
    # https://github.com/NixOS/nixpkgs/issues/40602#issuecomment-390085669
    mv /llvm/bin/*tblgen* /src/
    rm -rf /llvm
    
    export CROSS_LLVM_TABLEGEN=/src/llvm-tblgen
    export CROSS_CLANG_TABLEGEN=/src/clang-tblgen   
    
    cd $SRC_DIR
    wget http://musl.cc/$CROSS_MUSL-cross.tgz
    tar xf $CROSS_MUSL-cross.tgz
    export CROSS_C_COMPILER=/src/$CROSS_MUSL-cross/bin/$CROSS_MUSL-gcc
    export CROSS_CXX_COMPILER=/src/$CROSS_MUSL-cross/bin/$CROSS_MUSL-g++
    export CROSS_SYSROOT="/src/$CROSS_MUSL-cross/$CROSS_MUSL"
    export CROSS_LD_PATHS="-L/src/$CROSS_MUSL-cross/$CROSS_MUSL/lib,-L/src/$CROSS_MUSL-cross/lib/gcc/aarch64-linux-musl/11.2.1"
    export CROSS_CXX_FLAGS="--sysroot=/src/$CROSS_MUSL-cross/$CROSS_MUSL"
    
    setup_environment_cross
    
    # Build - llvm - Cross
    compile_target llvm "-DLLVM_ENABLE_LIBXML2=OFF -DLLVM_ENABLE_TERMINFO=OFF"
    # Build - clang - Cross
    compile_target clang

    # Build - lld - Cross
    compile_target lld
    # Build - lldb - Cross
    compile_target lldb    
fi
