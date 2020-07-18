
#mkimage -C none -A arm -T script -d boot.cmd boot.scr
#bootm_size=0xa000000
#fdt_addr_r=0x4FA00000
#LINUX_addr_r=0x40080000
#pxefile_addr_r=0x4FD00000
#ramdisk_addr_r=0x4FE00000
#scriptaddr=0x4FC00000

setenv SCRIPT_LOAD_ADDR  0x4FE00000

echo "Boot Device  mmc 0:1"
setenv BOOT_LOAD_CMD         "ext4load mmc 0:1"
setenv ROOTFS_DISK_PART      "/dev/mmcblk0p1"
if $BOOT_LOAD_CMD $SCRIPT_LOAD_ADDR "boot/boot.scr"; then source $SCRIPT_LOAD_ADDR; else echo notfound;fi

echo "Boot Device  mmc 0:2"
setenv BOOT_LOAD_CMD         "ext4load mmc 0:2"
setenv ROOTFS_DISK_PART      "/dev/mmcblk0p2"
if $BOOT_LOAD_CMD $SCRIPT_LOAD_ADDR "boot/boot.scr"; then source $SCRIPT_LOAD_ADDR; else echo notfound;fi


echo "Boot Device  usb 0:1"
setenv BOOT_LOAD_CMD         "ext4load usb 0:1"
setenv ROOTFS_DISK_PART      "/dev/sda1"
if $BOOT_LOAD_CMD $SCRIPT_LOAD_ADDR "boot/boot.scr"; then source $SCRIPT_LOAD_ADDR; else echo notfound;fi

echo "Boot Device  usb 0:2"
setenv BOOT_LOAD_CMD         "ext4load usb 0:2"
setenv ROOTFS_DISK_PART      "/dev/sda2"
if $BOOT_LOAD_CMD $SCRIPT_LOAD_ADDR "boot/boot.scr"; then source $SCRIPT_LOAD_ADDR; else echo notfound;fi
