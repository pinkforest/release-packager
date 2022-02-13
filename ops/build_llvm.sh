#!/bin/ash
set -ex

setup_environment() {

    . /set_arch.sh && arch_env

    export INSTALL_DIR="/llvm"
    export SRC_DIR="/src"
    
    export CMAKE_FLAGS="-DLLVM_PARALLEL_COMPILE_JOBS=$LLVM_PARALLEL_COMPILE_JOBS -DLLVM_PARALLEL_LINK_JOBS=$LLVM_PARALLEL_LINK_JOBS -DCMAKE_EXE_LINKER_FLAGS=\"-Wl,-no-keep-memory\" -DLLVM_TARGETS_TO_BUILD=$CROSS_ARCH -DLVM_DEFAULT_TARGET_TRIPLE=$CROSS_TOOLCHAIN"

}

compile_target() {
    export COMPILE_TARGET="$1"
    export EXTRA_FLAGS="$2"

    mkdir -p $SRC_DIR
    cd $SRC_DIR
    wget https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VERSION/$COMPILE_TARGET-$LLVM_VERSION.src.tar.xz
    tar xf $COMPILE_TARGET-$LLVM_VERSION.src.tar.xz
    mkdir -p $SRC_DIR/$COMPILE_TARGET-$LLVM_VERSION.src/build    
    cd $SRC_DIR/$COMPILE_TARGET-$LLVM_VERSION.src/build
    cmake .. $CMAKE_FLAGS -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR -DCMAKE_PREFIX_PATH=$INSTALL_DIR $EXTRA_FLAGS -G Ninja
    ninja install
          
    cd $SRC_DIR
    rm -rf $COMPILE_TARGET-$LLVM_VERSION.src $COMPILE_TARGET-$LLVM_VERSION.src.tar.xz

}
