ON_FPGA=n make ARCH=mips menuconfig
ON_FPGA=n make ARCH=mips sfsimg 2> ewlog.txt
ON_FPGA=n make ARCH=mips kernel 2>> ewlog.txt
