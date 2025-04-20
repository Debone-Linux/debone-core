# Debone Core

Debone Core is built around a streamlined Linux kernel configured with tinyconfig, paired with BusyBox to provide essential userland tools in a very minimal footprint.

Project link: https://github.com/Debone-Linux/debone-core

## Hardware Requirement

1. Intel PC running Debian for building Linux kernel and initramfs.
2. Internet connection to download source code.

If you own ARM64 machine, aarch64 build is functional by now (testing).

## Software Requirement
```
apt update
apt install -y git build-essential bison flex bc libelf-dev libssl-dev libncurses-dev qemu-system-x86 qemu-system-arm cpio gzip
```

## Building Debone

In case the script is not executable do the following:
```
chmod +x build-debone-core.sh
```

Execute the script to build Debone Core:
```
./build-debone-core.sh
```

## Run on QEMU
Linux x86_64
```
qemu-system-x86_64 -m 32M -kernel bzImage -initrd initramfs.img \
    -machine pc -cpu qemu64 \
    -append "console=ttyS0" -nographic
```
Linux ARM64 and macOS Apple Silicon
```
qemu-system-aarch64 -m 32M -kernel Image -initrd initramfs.img \
    -machine virt -cpu cortex-a53 \
    -append "console=ttyAMA0" -nographic
```

## Run on QEMU with Hardware Acceleration

Linux x86_64
```
qemu-system-x86_64  -m 32M -kernel bzImage -initrd initramfs.img \
    -machine pc,accel=kvm -cpu host \
    -append "console=ttyS0" -nographic
```
Linux ARM64
```
qemu-system-aarch64 -m 32M -kernel Image -initrd initramfs.img \
    -machine virt,accel=kvm -cpu host \
    -append "console=ttyAMA0" -nographic
```
macOS Apple Silicon
```
qemu-system-aarch64 -m 32M -kernel Image -initrd initramfs.img \
    -machine virt,accel=hvf -cpu host \
    -append "console=ttyAMA0" -nographic
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details