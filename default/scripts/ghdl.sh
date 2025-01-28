cd ghdl
param=--with-llvm-config="llvm-config"
sed -i 's,ghdl1-llvm,../bin/ghdl1-llvm,g' configure
if [ ${ARCH} == 'linux-arm64' ]; then
    sed -i 's,grt-all libs.vhdl.llvm all.vpi,grt-all all.vpi,g' Makefile.in
    sed -i 's,install.llvm.program install.vhdllib,install.llvm.program ,g' Makefile.in
    sed -i '130,133d' Makefile.in
    export GNATMAKE=${CROSS_NAME}-gnatmake
    param=--with-llvm-config='llvm-config'
    LDFLAGS=-L/usr/lib/${CROSS_NAME}
elif [ ${ARCH} == 'darwin-x64' ]; then
    wget https://github.com/ghdl/ghdl/releases/download/nightly/ghdl-macos-11-mcode.tgz
    mkdir -p ${OUTPUT_DIR}${INSTALL_PREFIX}
    tar xvfz ghdl-macos-11-mcode.tgz -C ${OUTPUT_DIR}${INSTALL_PREFIX}
    install_name_tool -id @executable_path/../lib/libghdl-5_0_0_dev.dylib ${OUTPUT_DIR}${INSTALL_PREFIX}/lib/libghdl-5_0_0_dev.dylib
    wget https://github.com/mmicko/macos-resources/releases/download/v2/libgnat-2019.dylib
    cp libgnat-2019.dylib ${OUTPUT_DIR}${INSTALL_PREFIX}/lib/.
    exit 0
elif [ ${ARCH} == 'darwin-arm64' ]; then
    #wget https://github.com/ghdl/ghdl/releases/download/nightly/ghdl-macos14-ARM64-llvm-jit.tgz
    wget https://github.com/ghdl/ghdl/releases/download/nightly/ghdl-llvm-jit-5.0.0-dev-macos14-aarch64.tar.gz
    mkdir -p ${OUTPUT_DIR}${INSTALL_PREFIX}
    #tar xvfz ghdl-macos14-ARM64-llvm-jit.tgz -C ${OUTPUT_DIR}${INSTALL_PREFIX}
    tar xvfz ghdl-llvm-jit-5.0.0-dev-macos14-aarch64.tar.gz  -C ${OUTPUT_DIR}${INSTALL_PREFIX}
    mv ${OUTPUT_DIR}${INSTALL_PREFIX}/ghdl-llvm-jit-5.0.0-dev-macos14-aarch64/* ${OUTPUT_DIR}${INSTALL_PREFIX}/
    rmdir ${OUTPUT_DIR}${INSTALL_PREFIX}/ghdl-llvm-jit-5.0.0-dev-macos14-aarch64/
    install_name_tool -id @executable_path/../lib/libghdl-5_0_0_dev.dylib ${OUTPUT_DIR}${INSTALL_PREFIX}/lib/libghdl-5_0_0_dev.dylib
    GNAT_NATIVE_VERSION="14.2.0"
    wget https://github.com/alire-project/GNAT-FSF-builds/releases/download/gnat-${GNAT_NATIVE_VERSION}-1/gnat-aarch64-darwin-${GNAT_NATIVE_VERSION}-1.tar.gz
    tar xvfz gnat-aarch64-darwin-${GNAT_NATIVE_VERSION}-1.tar.gz
    cp gnat-aarch64-darwin-${GNAT_NATIVE_VERSION}-1/lib/libgcc_s.1.1.dylib ${OUTPUT_DIR}${INSTALL_PREFIX}/lib/.
    cp gnat-aarch64-darwin-${GNAT_NATIVE_VERSION}-1/lib/gcc/aarch64-apple-darwin23.6.0/${GNAT_NATIVE_VERSION}/adalib/libgnat-14.dylib ${OUTPUT_DIR}${INSTALL_PREFIX}/lib/.
    exit 0
elif [ ${ARCH} == 'windows-x64' ]; then
    sed -i 's,grt-all libs.vhdl.llvm all.vpi,grt-all all.vpi,g' Makefile.in
    sed -i 's,install.llvm.program install.vhdllib,install.llvm.program ,g' Makefile.in
    sed -i '130,133d' Makefile.in
    export GNATMAKE=${CROSS_NAME}-gnatmake
    sed -i 's,$(LDFLAGS) `$(LLVM_LDFLAGS)`,`$(LLVM_LDFLAGS)` $(LDFLAGS),g' src/ortho/llvm6/Makefile
    param=--with-llvm-config="/usr/x86_64-w64-mingw32/bin/llvm-config"
    LDFLAGS="-luuid -lole32 -lz -lssp"
fi
./configure --prefix=${INSTALL_PREFIX} \
        --enable-checks \
        --enable-libghdl \
        --enable-synth \
        ${param} LDFLAGS="${LDFLAGS}"

make DESTDIR=${OUTPUT_DIR} -j${NPROC}
make DESTDIR=${OUTPUT_DIR} -j${NPROC} install

