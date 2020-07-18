
# mkimage -C none -A arm -T script -d boot.cmd boot.scr

echo "======================================================================="
echo "BOOT_LOAD_CMD:       $BOOT_LOAD_CMD"
echo "ROOTFS_DISK_PART:    $ROOTFS_DISK_PART"
echo "======================================================================="

# setenv bootargs "console=ttyS0,115200 panic=10 consoleblank=0 loglevel=7 root=$ROOTFS_DISK_PART rootwait rw ip=dhcp"
setenv bootargs "console=ttyS0,115200 panic=10 consoleblank=0 loglevel=7 root=$ROOTFS_DISK_PART rootwait rw"
$BOOT_LOAD_CMD 0x50000000 "boot/kernel"
$BOOT_LOAD_CMD 0x45000000 "boot/dtb"
booti 0x50000000 - 0x45000000
