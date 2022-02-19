#!/bin/ash

#####################################################################
# LLVM Target Arguments for Cross Compiling - See: LLVM_ALL_TARGETS
#####################################################################
# https://github.com/llvm-mirror/llvm/blob/master/CMakeLists.txt#L284
# LLVM_DEFAULT_TARGET_TRIPLE =
#####################################################################
#  x86_64-unknown-linux-musl
#  aarch64-unknown-linux-musl
#  x86_64-unknown-linux-gnu
#  x86_64-(redhat|suse)-linux (RedHat|Suse)
#  x86_64-linux-gnu (Debian/Ubuntu)
#

llvm_target_platform() {
    export TARGETPLATFORM="$1"

    case $TARGETPLATFORM in
        linux/amd64)
            echo CROSS_ARCH="X86" > /cross.env
            echo CROSS_TOOLCHAIN="x86_64-unknown-linux-musl" >> /cross.env
	    echo CROSS_MUSL="x86_64-linux-musl" >> cross.env
	    echo CROSS_LD_ARCH="x86_64" >> cross.env
            ;;
        linux/arm64)
            echo CROSS_ARCH="AArch64" > /cross.env
            echo CROSS_TOOLCHAIN="aarch64-unknown-linux-musl" >> /cross.env
	    echo CROSS_MUSL="aarch64-linux-musl" >> cross.env
	    echo CROSS_LD_ARCH="aarch64" >> cross.env
            ;;
        *)
            echo "We don't know this --platform ? $TARGETARCH"
#            exit
            ;;
    esac
}

##################################################################
# For simply installing Zig it's aarch64 || x86_64
#
# https://ziglang.org/download/0.9.0/zig-linux-aarch64|x86_64-0.9.0.tar.xz
#
zig_target_platform() {
    export TARGETPLATFORM="$1"

    case $TARGETPLATFORM in
        linux/amd64)
            echo CROSS_ARCH="x86_64" > /cross.env
            echo CROSS_TOOLCHAIN="x86_64-unknown-linux-musl" >> /cross.env
            ;;
        linux/arm64)
            echo CROSS_ARCH="aarch64" > /cross.env
            echo CROSS_TOOLCHAIN="aarch64-unknown-linux-musl" >> /cross.env
            ;;
        *)
            echo "We don't know this --platform ? $TARGETARCH"
#            exit
            ;;
    esac
}

arch_env() {
#  export $(echo $(cat .env | sed 's/#.*//g' | sed 's/\r//g' | xargs) | envsubst)
    export CROSS_ARCH=$(grep -m 1 -oP 'CROSS_ARCH="*\K[^"]+' /cross.env)
    export CROSS_MUSL=$(grep -m 1 -oP 'CROSS_MUSL="*\K[^"]+' /cross.env)
    export CROSS_TOOLCHAIN=$(grep -m 1 -oP 'CROSS_TOOLCHAIN="*\K[^"]+' /cross.env)
    export CROSS_LDARCH=$(grep -m 1 -oP 'CROSS_LDARCH="*\K[^"]+' /cross.env)
}
 



