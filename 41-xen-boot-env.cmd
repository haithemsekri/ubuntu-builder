
#mkimage -C none -A arm -T script -d boot.cmd boot.scr

#setenv dev "mmc 0"

#setenv dtb_addr_r 0x4FA00000
#setenv dtb_path device-tree.dtb
#fatload $dev $dtb_addr_r $dtb_path

#setenv kernel_addr_r 0x40080000
#setenv kernel_path kernel.bin
#fatload $dev $kernel_addr_r $kernel_path
#setenv kernel_size 0x$filesize

#setenv bootargs root=/dev/mmcblk0p2 rootwait rw console=ttyS0,115200 panic=10 consoleblank=0 loglevel=7 ip=dhcp

#booti $kernel_addr_r - $fdt_addr_r


setenv kernel_path kernel.bin
setenv xen_path xen
setenv dtb_path device-tree.dtb

setenv kernel_addr_r 0x50000000
setenv xen_addr_r 0x46000000
setenv dtb_addr_r 0x45000000

fatload mmc 0 $kernel_addr_r $kernel_path
setenv kernel_size 0x$filesize
fatload mmc 0 $xen_addr_r $xen_path
fatload mmc 0 $dtb_addr_r $dtb_path

fdt addr $dtb_addr_r
fdt resize

fdt mknode /chosen modules
fdt set /chosen/modules '#address-cells' <1>
fdt set /chosen/modules '#size-cells' <1>

fdt mknode /chosen/modules module@0
fdt set /chosen/modules/module@0 compatible xen,linux-zimage xen,multiboot-module
fdt set /chosen/modules/module@0 reg <$kernel_addr_r $kernel_size>
fdt set /chosen xen,xen-bootargs "console=dtuart dtuart=serial0 dom0_mem=256M"
fdt set /chosen xen,dom0-bootargs "root=/dev/mmcblk0p2 rootwait rw console=hvc0 earlyprintk=xen panic=10 consoleblank=0 loglevel=7 ip=dhcp clk_ignore_unused"

fdt print /chosen
booti $xen_addr_r - $dtb_addr_r

