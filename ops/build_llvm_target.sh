#!/bin/ash
set -ex

setup_environment_native() {

    . /set_arch.sh && arch_env

    export INSTALL_DIR="/llvm_native"
    export SRC_DIR="/src"
    
    export CMAKE_FLAGS="-DLLVM_PARALLEL_COMPILE_JOBS=$LLVM_PARALLEL_COMPILE_JOBS -DLLVM_PARALLEL_LINK_JOBS=$LLVM_PARALLEL_LINK_JOBS -DCMAKE_EXE_LINKER_FLAGS=\"-Wl,-no-keep-memory\""

}

setup_environment_cross() {

    . /set_arch.sh && arch_env

    export INSTALL_DIR="/llvm"
    export SRC_DIR="/src"

    export CMAKE_FLAGS="-DLLVM_PARALLEL_COMPILE_JOBS=$LLVM_PARALLEL_COMPILE_JOBS -DLLVM_PARALLEL_LINK_JOBS=$LLVM_PARALLEL_LINK_JOBS -DCMAKE_EXE_LINKER_FLAGS=\"-Wl,-no-keep-memory,$CROSS_LD_PATHS\" -DCMAKE_CROSSCOMPILING=True -DLLVM_TABLEGEN=$CROSS_LLVM_TABLEGEN -DCLANG_TABLEGEN=$CROSS_CLANG_TABLEGEN -DLLVM_TARGET_ARCH=$CROSS_ARCH -DLLVM_TARGETS_TO_BUILD=$CROSS_ARCH -DLLVM_DEFAULT_TARGET_TRIPLE=$CROSS_TOOLCHAIN -DCMAKE_CXX_FLAGS=$CROSS_CXX_FLAGS -DCMAKE_C_COMPILER=$CROSS_C_COMPILER -DCMAKE_CXX_COMPILER=$CROSS_CXX_COMPILER"

}

compile_target() {
    export COMPILE_TARGET="$1"
    export EXTRA_FLAGS="$2"

    mkdir -p $SRC_DIR
    cd $SRC_DIR

    if [ ! -f "$SRC_DIR/$COMPILE_TARGET-$LLVM_VERSION.src.tar.xz" ]; then
        wget https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VERSION/$COMPILE_TARGET-$LLVM_VERSION.src.tar.xz
    fi
    
    if [ -d "$SRC_DIR/$COMPILE_TARGET-$LLVM_VERSION.src" ]; then
       rm -rf $SRC_DIR/$COMPILE_TARGET-$LLVM_VERSION.src
    fi
       
    tar xf $COMPILE_TARGET-$LLVM_VERSION.src.tar.xz
    mkdir -p $SRC_DIR/$COMPILE_TARGET-$LLVM_VERSION.src/build    
    cd $SRC_DIR/$COMPILE_TARGET-$LLVM_VERSION.src/build
    cmake .. $CMAKE_FLAGS -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR -DCMAKE_PREFIX_PATH=$INSTALL_DIR $EXTRA_FLAGS -G Ninja
    ninja install

    # clang has a thing where we have to fish out manually the clang-tblgen after install
    if [ "$COMPILE_TARGET" == "clang" ]; then
      cp $SRC_DIR/$COMPILE_TARGET-$LLVM_VERSION.src/build/bin/clang-tblgen $INSTALL_DIR/bin/
    fi
    
    cd $SRC_DIR
    rm -rf $COMPILE_TARGET-$LLVM_VERSION.src

}
