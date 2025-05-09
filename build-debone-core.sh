#!/bin/sh

set -ex

# Set or get default ARCH to host
ARCH=${ARCH:-$(uname -m)}

# Validate supported architectures
case "$ARCH" in
  x86_64|aarch64)
    echo "ARCH is supported: $ARCH"
    ;;
  *)
    echo "Error: Unsupported ARCH '$ARCH'" >&2
    exit 1
    ;;
esac

# Linux kernel and console naming based on ARCH
if [ $ARCH = 'x86_64' ] ; then
    IMAGE="bzImage"
    CONSOLE="ttyS0"
    CROSS_COMPILE=x86_64-linux-gnu-
fi
if [ $ARCH = 'aarch64' ] ; then
    ARCH="arm64"
    IMAGE="Image"
    CONSOLE="ttyAMA0"
    CROSS_COMPILE=aarch64-linux-gnu-
fi

DISTRO_NAME="Debone"
DISTRO_EDITION="Core"
DISTRO_SLOGAN="Trim the fat. Keep the bits."

export HOSTNAME=$(echo $DISTRO_NAME | tr '[:upper:]' '[:lower:]')

BUSYBOX_VERSION=1.37.0
KERNEL_VERSION=6.13
KERNEL_MAJOR=$(echo $KERNEL_VERSION | sed -E 's/([0-9]+).*/\1/')

rebuild_busybox="y"
if [ -f busybox/busybox ] ; then
    printf "Rebuild busybox? (y/n): "
    read rebuild_busybox
fi

rebuild_kernel="y"
if [ -f linux/arch/$ARCH/boot/$IMAGE ] ; then
    printf "Rebuild linux kernel? (y/n): "
    read rebuild_kernel
fi

# Building busybox
if [ $rebuild_busybox = "y" ] ; then
    rm -rf busybox
    cd files
        [ ! -f busybox-$BUSYBOX_VERSION.tar.bz2 ] && \
        echo "Downloading busybox..." && \
        wget https://www.busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
    cd ..
    echo "Extracting busybox..."
    tar -xf files/busybox-$BUSYBOX_VERSION.tar.bz2
    mv busybox* busybox
    echo "Compiling busybox..."
    cd busybox
        make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE defconfig
        sed -i 's/^# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
        sed -i 's/^CONFIG_MAN=y/# CONFIG_MAN is not set/' .config
        patch -p1 < ../patches/fix-sha1-shani-portability.patch
        make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE -j$(nproc)
    cd ..
fi

# Building linux kernel
if [ $rebuild_kernel = "y" ] ; then
    rm -rf linux
    cd files
        [ ! -f linux-$KERNEL_VERSION.tar.xz ] && \
        echo "Downloading linux kernel..." && \
        wget https://cdn.kernel.org/pub/linux/kernel/v$KERNEL_MAJOR.x/linux-$KERNEL_VERSION.tar.xz
    cd ..
    echo "Extracting linux kernel..."
    tar -xf files/linux-$KERNEL_VERSION.tar.xz
    mv linux* linux
    echo "Compiling linux kernel..."
    cd linux
        make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE tinyconfig

        scripts/config --enable 64BIT
        scripts/config --enable BLK_DEV_INITRD
        scripts/config --enable PRINTK
        scripts/config --enable CONFIG_PRINTK_TIME
        scripts/config --enable BINFMT_ELF
        scripts/config --enable BINFMT_SCRIPT
        scripts/config --enable TTY
        scripts/config --enable SERIAL_8250
        scripts/config --enable SERIAL_8250_CONSOLE
        scripts/config --enable SERIAL_AMBA_PL011
        scripts/config --enable SERIAL_AMBA_PL011_CONSOLE
        scripts/config --enable PROC_FS
        scripts/config --enable SYSFS
        scripts/config --enable DEVTMPFS
        scripts/config --enable DEVTMPFS_MOUNT
        scripts/config --enable PM
        scripts/config --enable ACPI
        scripts/config --enable PCI

        make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE olddefconfig
        make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE -j$(nproc) $IMAGE $DTBS
    cd ..
fi

# Create a directory for the initial ram file system
rm -rf initramfs
mkdir initramfs && cd initramfs
    mkdir -p bin sbin etc proc sys dev usr/bin usr/sbin
cd ..

# Copy binaries
cp -a busybox/busybox initramfs/bin/

# Create init script
cat > initramfs/init << EOF
#!/bin/busybox sh
/bin/busybox --install -s
echo $HOSTNAME > /etc/hostname
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
sleep 1
cat << EEOF

Welcome to $DISTRO_NAME - $DISTRO_EDITION

 ____       _                       
|  _ \  ___| |__   ___  _ __   ___  
| | | |/ _ \ '_ \ / _ \| '_ \ / _ \ 
| |_| |  __/ |_) | (_) | | | |  __/ 
|____/ \___|_.__/ \___/|_| |_|\___| 

$DISTRO_SLOGAN


EEOF
exec /sbin/init
EOF
chmod +x initramfs/init

# Create inittab that gets called by SysVinit
cat << EOF > initramfs/etc/inittab
$CONSOLE::respawn:/bin/sh
::sysinit:/bin/hostname -F /etc/hostname
::ctrlaltdel:/sbin/reboot -f
::shutdown:/bin/echo "Shutting down..."
::shutdown:/bin/umount /proc
::shutdown:/bin/umount /sys
::shutdown:/bin/mount -o remount,ro /
::restart:/bin/echo "Rebooting..."
::restart:/bin/umount /proc
::restart:/bin/umount /sys
::restart:/bin/mount -o remount,ro /
::restart:/sbin/reboot -f
EOF

# Create initramfs image
cd initramfs
    find . | cpio -o -H newc | gzip > ../initramfs.img
cd ..

# Copy linux kernel to images directory
mkdir -p images/$ARCH/
cp linux/arch/$ARCH/boot/$IMAGE images/$ARCH/
cp initramfs.img images/$ARCH/
rm initramfs.img

# Completed
echo "All done!"
