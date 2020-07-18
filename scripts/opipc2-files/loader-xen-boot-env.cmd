

#mkimage -C none -A arm -T script -d boot.cmd boot.scr

echo "======================================================================="
echo "BOOT_LOAD_CMD:       $BOOT_LOAD_CMD"
echo "ROOTFS_DISK_PART:    $ROOTFS_DISK_PART"
echo "======================================================================="

$BOOT_LOAD_CMD 0x50000000 "boot/kernel"
setenv LINUX_SIZE 0x$filesize
$BOOT_LOAD_CMD 0x46000000 "boot/xen"
$BOOT_LOAD_CMD 0x45000000 "boot/dtb"

fdt addr 0x45000000
fdt resize

fdt mknode /chosen modules
fdt set /chosen/modules '#address-cells' <1>
fdt set /chosen/modules '#size-cells' <1>

fdt mknode /chosen/modules module@0
fdt set /chosen/modules/module@0 compatible xen,linux-zimage xen,multiboot-module
fdt set /chosen/modules/module@0 reg <0x50000000 $LINUX_SIZE>
fdt set /chosen xen,xen-bootargs "console=dtuart dtuart=serial0 dom0_mem=256M"
fdt set /chosen xen,dom0-bootargs "clk_ignore_unused console=hvc0 earlyprintk=xen consoleblank=0 loglevel=7 root=$ROOTFS_DISK_PART rootwait rw"

fdt print /chosen
booti 0x46000000 - 0x45000000
