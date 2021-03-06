#!/bin/bash

BUILD_DIR=obj
TEST_MODE=

while getopts "hd:t" opt; do
    case $opt in
        d)
            BUILD_DIR=$OPTARG
            ;;
        h)
            echo "Usage $0 [options]"
            echo "Options:"
            echo "  -d <directory>                 uCore build directory"
            echo "                                 default to obj/"
            echo "  -t                             run in background for test"
            echo "                                 i.e. do not use stdio or open SDL window"
            echo ""
            echo "Supported architectures: i386, arm(goldfishv7), x86_64"
            echo ""
            echo "Report bugs to https://github.com/chyyuu/ucore_plus/issues"
            exit 0
            ;;
        t)
            TEST_MODE=y
            ;;
        ?)
            exit 1
            ;;
    esac
done

if [[ ! -d $BUILD_DIR ]]; then
    echo $BUILD_DIR does not exist or is not a directory.
    echo Use -d to specify your custom build directory.
    exit 1
fi

if [[ ! -e $BUILD_DIR/config/auto.conf ]]; then
    echo Is $BUILD_DIR properly configured?
    exit 1
fi

source $BUILD_DIR/config/auto.conf

case $UCONFIG_ARCH in
    arm)
        if [[ $UCONFIG_ARM_BOARD_GOLDFISH = y ]]; then
            if [[ $AVD = "" ]]; then
                AVD=`android list avd | grep "Name" -m 1 | sed "s/[ \t]*Name:[ \t]*//"`
                echo AVD not specified. Fetch the first avd from \"android list avd\" and get \"$AVD\"
            fi
            if [[ $TEST_MODE = y ]]; then
                QEMU_OPT="-s -S -serial file:$BUILD_DIR/serial.log"
            else
                QEMU_OPT="-serial stdio"
            fi
            exec emulator-arm -avd $AVD -kernel $BUILD_DIR/kernel/kernel-arm.elf -no-window -qemu $QEMU_OPT
        else
            echo What kind of board for ARM is this?
            echo Consider supporting your board in uCore_run
            exit 1
        fi
        ;;
    i386)
        QEMU=qemu
        which qemu-system-i386 > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            QEMU=qemu-system-i386
        fi
        if [[ $TEST_MODE = y ]]; then
            EXTRA_OPT="-S -display none"
        else
            EXTRA_OPT="-monitor stdio"
        fi
        exec $QEMU -m 128 \
            -hda $BUILD_DIR/kernel.img \
            -drive file=$BUILD_DIR/sfs.img,media=disk,cache=writeback,index=2 \
            -s -serial file:$BUILD_DIR/serial.log \
            $EXTRA_OPT
        ;;
    x86_64)
        QEMU=qemu
        which qemu-system-x86_64 > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            QEMU=qemu-system-x86_64
        fi
        if [[ $TEST_MODE = y ]]; then
            EXTRA_OPT="-S -display none"
        else
            EXTRA_OPT="-monitor stdio"
        fi
        exec $QEMU -smp 4 -m 512 \
            -hda $BUILD_DIR/kernel.img \
            -drive file=$BUILD_DIR/swap.img,media=disk,cache=writeback \
            -drive file=$BUILD_DIR/sfs.img,media=disk,cache=writeback \
            -s -serial file:$BUILD_DIR/serial.log \
            $EXTRA_OPT
        ;;
esac
