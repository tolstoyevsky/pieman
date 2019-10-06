info "build_kernel.sh"

if [[ ! -f "${SOURCE_DIR}"/Image ]]; then # fixme: temporary solution
  pushd ${SOURCE_DIR}
    if [ ! -d "gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu" ]; then
      wget "https://releases.linaro.org/components/toolchain/binaries/6.3-2017.02/aarch64-linux-gnu/gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu.tar.xz" -O "gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu.tar.xz"
      tar xJf "gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu.tar.xz"
      rm "gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu.tar.xz"
    fi

    if [ ! -d "linux" ]; then
      git clone https://github.com/friendlyarm/linux.git -b sunxi-4.x.y --depth 1
    fi  
  popd

  pushd "${SOURCE_DIR}"/linux
#    touch .scmversion
    make sunxi_arm64_defconfig ARCH=arm64 CROSS_COMPILE=$(pwd)/../gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
    make Image dtbs ARCH=arm64 CROSS_COMPILE=$(pwd)/../gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-

    cp arch/arm64/boot/Image ../Image
    # cp arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-k1-plus.dtb ../sun50i-h5-nanopi-k1-plus.dtb
    # cp arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo-core2.dtb ../sun50i-h5-nanopi-neo-core2.dtb
    # cp arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo-core2.dtb ../sun50i-h5-nanopi-m1-plus2.dtb
    # cp arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo-plus2.dtb ../sun50i-h5-nanopi-neo-plus2.dtb
    # cp arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dtb ../sun50i-h5-nanopi-neo2.dtb

    make modules ARCH=arm64 CROSS_COMPILE=$(pwd)/../gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
  popd
fi

pushd "${SOURCE_DIR}"/linux
  make modules_install INSTALL_MOD_PATH="${PIEMAN_DIR}/${R}/" ARCH=arm64 CROSS_COMPILE=$(pwd)/../gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
popd
