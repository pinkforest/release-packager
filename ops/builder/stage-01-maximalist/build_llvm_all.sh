#!/bin/ash
set -ex

. /set_arch.sh
arch_env

. ./build_llvm_target.sh
prepare_environment
prepare_sources

compile_native "-DLLVM_ENABLE_LIBXML2=OFF -DLLVM_ENABLE_TERMINFO=OFF"

if [ "$BUILDPLATFORM" == "$TARGETPLATFORM" ]; then
    # leave as-is
    echo "Native build all done."
else
    # For cross compile all we needed were the tblgens..
    # clang-tblgen & lldb-tblgen is not included in any packages :(
    # Probably due to it missing from install:
    # https://github.com/NixOS/nixpkgs/issues/40602#issuecomment-390085669
    mv /llvm/bin/*tblgen* $SRC_DIR/
    rm -rf /llvm
    
    export CROSS_LLVM_TABLEGEN=$SRC_DIR/llvm-tblgen
    export CROSS_CLANG_TABLEGEN=$SRC_DIR/clang-tblgen   
    
    cd $SRC_DIR
    wget http://musl.cc/$CROSS_MUSL-cross.tgz
    tar xf $CROSS_MUSL-cross.tgz
    export CROSS_C_COMPILER=$SRC_DIR/$CROSS_MUSL-cross/bin/$CROSS_MUSL-gcc
    export CROSS_CXX_COMPILER=$SRC_DIR/$CROSS_MUSL-cross/bin/$CROSS_MUSL-g++
    export CROSS_SYSROOT=$SRC_DIR/$CROSS_MUSL-cross/$CROSS_MUSL
    export CROSS_LD_PATHS="-L$SRC_DIR/$CROSS_MUSL-cross/$CROSS_MUSL/lib,-L$SRC_DIR/$CROSS_MUSL-cross/lib/gcc/aarch64-linux-musl/11.2.1"
    
    cp $SRC_DIR/$CROSS_MUSL-cross/$CROSS_MUSL/lib/libc.so /lib/ld-musl-$CROSS_LDARHC.so.1
    
    compile_cross "-DLLVM_ENABLE_LIBXML2=OFF -DLLVM_ENABLE_TERMINFO=OFF"
fi
