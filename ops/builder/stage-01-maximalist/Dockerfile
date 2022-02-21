#########################################################
#
# LLVM Cross Compile For Alpine under Docker --platform
#
FROM --platform=$BUILDPLATFORM alpine:3.15.0 AS build

##### Arguments via --build_arg
# 
# e.g. LLVM_VERSION=13.0.1  (Builds from release source)
# e.g. ZIG_VERSION=0.9.0    (Installs from binary)
#
ARG LLVM_VERSION=13.0.1
ARG ZIG_VERSION=0.9.0
ARG LLVM_PARALLEL_COMPILE_JOBS=4
ARG LLVM_PARALLEL_LINK_JOBS=1

##### Derived derived from --platform
#
# Docker TARGETARCH gives amd64 / arm64 from --platform
#
ARG TARGETARCH

#
# Docker TARGETPLATFORM gives linux/[amd64|arm64]
# Depending on which cross-compile is done for via --platform
#
ARG TARGETPLATFORM

#
# Docker BUILDPLATFORM gives linux/[amd64|arm64]
# Depending on which host is building this
#
ARG BUILDPLATFORM

###########################################################
# TODO Items?:
# 1-Mold?:
#  -DCMAKE_EXE_LINKER_FLAGS=-Wl,-no-keep-memory,-fuse-ld=mold
# 2-Win?:
#  https://cmake.org/cmake/help/v3.8/generator/Visual%20Studio%2014%202015.html
#  x86_64-pc-windows-msvc18.0.0 -DLLVM_TARGETS_TO_BUILD=x86_64 -G "Visual Studio 14" -A Win64

RUN /bin/ash -c "set -ex && \
    echo \"Preparing LLVM (Build) $LLVM_VERSION / ZIG (Install) $ZIG_VERSION for TargetArch: $TARGETARCH Platform: $TARGETPLATFORM\" && \
    mkdir -p /deps && \
    apk update && \
    apk add gcc g++ automake autoconf pkgconfig python2-dev cmake ninja libc-dev binutils zlib-static libstdc++ python3-dev llvm llvm-libunwind-dev perf lld linux-virt-dev musl-dev linux-headers grep"

##################################################
# set_arch.sh - Set and Get /cross.env
#
# arch_env()
#  export CROSS_[ARCH|TOOLCHAIN] from /cross.env
#
# llvm_target_platform(Docker::TARGETPLATFORM)
#  Fills into /cross.env
#   - CROSS_ARCH relevant for LLVM build
#   - CROSS_TOOLCHAIN relevant for LLVM build
#
# zig_target_platform(Docker::TARGETPLATFORM)
#  Fills ZIG equivalent into /cross.env
#
COPY set_arch.sh ./

##################################################
# Prepare the environment for LLVM cross compile
#
RUN /bin/ash -c "source set_arch.sh && \
    llvm_target_platform $TARGETPLATFORM && \
    . ./set_arch.sh && arch_env && \
    echo \"Compiling LLVM in Host: $BUILDPLATFORM - LLVM_Arch: $CROSS_ARCH / LLVM_Triplet: $CROSS_TOOLCHAIN\""

##################################################
# build_llvm_target.sh
##################################################
# setup_environment()
# - Setups LLVM CMAKE_FLAGS based on arch_env()
# 
# compile_target(llvm_target, extra_flags)
# - Compile LLVM Target e.g. llvm/lld/clang/..
# 
COPY build_llvm_target.sh ./

COPY build_llvm_all.sh ./
RUN /bin/ash ./build_llvm_all.sh

#################################################
# Prepare the environment for & Install ZIG
#
COPY install_zig.sh /
RUN /bin/ash -c "set -ex && source set_arch.sh && \
    zig_target_platform $TARGETPLATFORM && \
    . install_zig.sh && setup_environment && \
    install_target"

# Build - llvm
#RUN /bin/ash -c 'set -ex && . ./build_llvm.sh && setup_environment && compile_target llvm "-DLLVM_ENABLE_LIBXML2=OFF -DLLVM_ENABLE_TERMINFO=OFF"'
#
## Build - lld
#RUN /bin/ash -c 'set -ex && . ./build_llvm.sh && setup_environment && compile_target lld'
#
## Build - clang
#RUN /bin/ash -c 'set -ex && . ./build_llvm.sh && setup_environment && compile_target clang'
#
## Build - lldb
#RUN /bin/ash -c 'set -ex && . ./build_llvm.sh && setup_environment && compile_target lldb'
# Multiarch - Emulated/Native Stage

FROM alpine:3.15.0

COPY --from=build /llvm /llvm
COPY --from=build /zig /zig
#COPY --from=build /src /src

RUN apk update && \
    apk add gcc g++ openssl openssl-dev automake autoconf make pkgconfig cmake ninja samurai binutils zlib-static libstdc++ python3-dev linux-virt-dev musl-dev linux-headers grep git && \
    apk upgrade

#WORKDIR /src
#RUN git clone https://github.com/rui314/mold.git && cd mold && \
#    git checkout v1.0.3 && \
#    export PATH=/llvm/bin:/usr/local/bin:$PATH && \
#    export SYSTEM_MIMALLOC=1 && \
#    # version too old in alpine
#    # export SYSTEM_LIBTBB=1
#    export SYSTEM_XXHASH=1 && \
#    export CC=clang && \
#    export CXX=clang++ && \
#    export LTO=1 && \
#    make -j4 CXX=clang++ \
#     CXXFLAGS="-gcc-toolchain= -I/llvm/lib/clang/13.0.1/include -I/usr/include/c++/10.3.1 -I/usr/include/c++/10.3.1/`arch -m`-alpine-linux-musl" \
#     LDFLAGS="--ld-path=/llvm/bin/ld.lld -L/usr/lib/gcc/`arch -m`-alpine-linux-musl/10.3.1"
#
#     LDFLAGS="--ld-path=/usr/bin/ld -L/usr/lib/gcc/`arch -m`-alpine-linux-musl/10.3.1"

