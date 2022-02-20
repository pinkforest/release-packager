#!/bin/ash
set -ex

prepare_environment() {
    export INSTALL_DIR="/llvm"
    export SRC_DIR="/src"
    
    . /set_arch.sh && arch_env
}

prepare_sources() {

    mkdir -p $SRC_DIR
    cd $SRC_DIR

    wget https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VERSION/llvm-$LLVM_VERSION.src.tar.xz
    wget https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VERSION/clang-$LLVM_VERSION.src.tar.xz
    wget https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VERSION/lld-$LLVM_VERSION.src.tar.xz
    wget https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VERSION/lldb-$LLVM_VERSION.src.tar.xz
    wget https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VERSION/libunwind-$LLVM_VERSION.src.tar.xz

    tar xf llvm-$LLVM_VERSION.src.tar.xz
    tar xf clang-$LLVM_VERSION.src.tar.xz
    tar xf lld-$LLVM_VERSION.src.tar.xz
    tar xf lldb-$LLVM_VERSION.src.tar.xz
    tar xf libunwind-$LLVM_VERSION.src.tar.xz

    mv clang-$LLVM_VERSION.src clang
    mv lld-$LLVM_VERSION.src lld
    mv lldb-$LLVM_VERSION.src lldb
    mv libunwind-$LLVM_VERSION.src libunwind
    
}

compile_native() {
    export EXTRA_FLAGS="$2"

    mkdir -p $SRC_DIR/build-native
    cd $SRC_DIR/build-native
    cmake .. \
     -DCMAKE_BUILD_TYPE=Release \
     -DLLVM_OPTIMIZED_TABLEGEN=ON \
     -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
     -DCMAKE_PREFIX_PATH=$INSTALL_DIR \
     -DLLVM_PARALLEL_COMPILE_JOBS=$LLVM_PARALLEL_COMPILE_JOBS \
     -DLLVM_PARALLEL_LINK_JOBS=$LLVM_PARALLEL_LINK_JOBS \
     -DCMAKE_EXE_LINKER_FLAGS="-Wl,-no-keep-memory" \
     -DLLVM_ENABLE_THREADS=ON \
     -DLLVM_ENABLE_PROJECTS="clang;lld;lldb" \
     -DLLVM_ENABLE_TERMINFO=OFF \
     -DLLVM_ENABLE_BINDINGS=OFF \
     -DLLVM_BUILD_EXAMPLES=OFF \
     -DLLVM_BUILD_TESTS=OFF \
     -DLLVM_BUILD_BENCHMARKS=OFF \
     -DLLDB_ENABLE_LIBEDIT=OFF \
     -DLLDB_ENABLE_LUA=OFF \
     -DLLDB_ENABLE_PYTHON=OFF \
     -Wno-dev $EXTRA_FLAGS \
     -G Ninja ../llvm-$LLVM_VERSION.src

    ninja install

    cp $SRC_DIR/build-native/bin/*tblgen* $INSTALL_DIR/bin/

}

compile_cross() {
    export EXTRA_FLAGS="$2"
    
    mkdir -p $SRC_DIR/build-cross
    cd $SRC_DIR/build-cross

    # DCMAKE_SYSTEM_NAME="Linux"
    #  work/around with llvm13 cross-compile bug
    #  - https://reviews.llvm.org/D93164?id=312026
    #  - https://bugs.llvm.org/show_bug.cgi?id=52106
    
    cmake .. \
     -DCMAKE_BUILD_TYPE=Release \
     -DLLVM_OPTIMIZED_TABLEGEN=ON \
     -DCLANG_TOOLING_BUILD_AST_INTROSPECTION=OFF \
     -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
     -DCMAKE_PREFIX_PATH=$INSTALL_DIR \
     -DLLVM_PARALLEL_COMPILE_JOBS=$LLVM_PARALLEL_COMPILE_JOBS \
     -DLLVM_PARALLEL_LINK_JOBS=$LLVM_PARALLEL_LINK_JOBS \
     -DCMAKE_EXE_LINKER_FLAGS="-Wl,-no-keep-memory" \
     -DCMAKE_CROSSCOMPILING=True \
     -DCMAKE_SYSTEM_NAME="Linux" \
     -DCMAKE_CXX_FLAGS=--sysroot=$CROSS_SYSROOT \
     -DLLVM_TARGET_ARCH=$CROSS_ARCH \
     -DLLVM_TABLEGEN=/src/llvm-tblgen \
     -DCLANG_TABLEGEN=/src/clang-tblgen \
     -DLLDB_TABLEGEN=/src/lldb-tblgen \
     -DLLVM_TARGETS_TO_BUILD=$CROSS_ARCH \
     -DLLVM_DEFAULT_TARGET_TRIPLE=$CROSS_TOOLCHAIN \
     -DCMAKE_C_COMPILER=$CROSS_C_COMPILER \
     -DCMAKE_CXX_COMPILER=$CROSS_CXX_COMPILER \
     -DLLVM_ENABLE_THREADS=ON \
     -DLLVM_ENABLE_PROJECTS="clang;lld;lldb" \
     -DLLVM_USE_HOST_TOOLS=ON \
     -DLLVM_ENABLE_TERMINFO=OFF \
     -DLLVM_ENABLE_BINDINGS=OFF \
     -DLLVM_BUILD_EXAMPLES=OFF \
     -DLLVM_BUILD_TESTS=OFF \
     -DLLVM_BUILD_BENCHMARKS=OFF \
     -DLLDB_ENABLE_LUA=OFF \
     -DLLDB_ENABLE_PYTHON=OFF \
     -Wno-dev $EXTRA_FLAGS \
     -G Ninja ../llvm-$LLVM_VERSION.src

    cp $SRC_DIR/build-cross/bin/*tblgen* $INSTALL_DIR/bin/
    
}
