
#mkimage -C none -A arm -T script -d boot.cmd boot.scr

setenv load_cmd "ext4load mmc 0:1"

setenv dtb_addr_r 0x4FA00000
setenv dtb_path boot/dtb
$load_cmd $dtb_addr_r $dtb_path

setenv kernel_addr_r 0x40080000
setenv kernel_path boot/kernel
$load_cmd $kernel_addr_r $kernel_path

setenv bootargs "root=/dev/mmcblk0p1 rootwait rw console=ttyS0,115200 panic=10 consoleblank=0 loglevel=7 ip=dhcp"

booti $kernel_addr_r - $fdt_addr_r
