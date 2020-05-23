
#mkimage -C none -A arm -T script -d boot.cmd boot.scr

setenv dev "mmc 0"

setenv dtb_addr_r 0x4FA00000
setenv dtb_path device-tree.dtb
fatload $dev $dtb_addr_r $dtb_path

setenv kernel_addr_r 0x40080000
setenv kernel_path kernel.bin
fatload $dev $kernel_addr_r $kernel_path
setenv kernel_size 0x$filesize

setenv bootargs root=/dev/mmcblk0p2 rootwait rw console=ttyS0,115200 panic=10 consoleblank=0 loglevel=7 ip=dhcp

booti $kernel_addr_r - $fdt_addr_r

