#!/bin/bash

source 00-rootfs-setup-env.sh

[ ! -d "cache" ] && mkdir cache
[ ! -d "build" ] && mkdir build

[ ! -d "$(pwd)/sources" ] && mkdir $(pwd)/sources
[ ! -f $DL_ROOTFS_FILE ] && wget $DL_ROOTFS_URL -O $DL_ROOTFS_FILE
[ ! -f $DL_ROOTFS_FILE ] && echo "$DL_ROOTFS_FILE : file not found"

SRC_TAR_FILE=$DL_ROOTFS_FILE
DISK_FILE=$BASE_DISK_FILE
DISK_TAR_FILE=$BASE_TAR_FILE
DISK_SIZE_MB=1024

create_rootfs_disk() {
if [ -f $DISK_TAR_FILE ]; then
   echo "Based on: $DISK_TAR_FILE"
   ./10-tar-to-disk-image.sh $DISK_TAR_FILE $DISK_FILE $DISK_SIZE_MB
else
   echo "Based on: $SRC_TAR_FILE"
   ./10-tar-to-disk-image.sh $SRC_TAR_FILE $DISK_FILE $DISK_SIZE_MB
   CHROOT_SCRIPT="/tmp/chroot-script.sh"
   rm -rf  $CHROOT_SCRIPT

cat <<EOF > $CHROOT_SCRIPT
#!/bin/bash
######################################Basic distro######################################
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 2001:4860:4860::8888" >> /etc/resolv.conf
echo "LANG=en_US.UTF-8" > /etc/default/locale
echo "APT::Install-Recommends "0";" >> /etc/apt/apt.conf.d/30norecommends
echo "APT::Install-Suggests "0";" >> /etc/apt/apt.conf.d/30norecommends

passwd
apt-get -y clean
apt-get -y update
apt-get -y install --no-install-recommends apt-utils dialog
apt-get -y install --no-install-recommends locales
locale-gen en_US.UTF-8

apt-get -y upgrade
apt-get -y install --no-install-recommends util-linux nano openssh-server
apt-get -y install --no-install-recommends systemd udev systemd-sysv
apt-get -y install --no-install-recommends net-tools iproute2 iputils-ping ethtool isc-dhcp-client

######################################Runtime libs######################################
apt-get -q -y install --no-install-recommends libyajl-dev \
   libfdt-dev libaio-dev libpixman-1-dev libglib2.0-dev

######################################Dev libs##########################################
##gcc-7-base libasan4 libatomic1 libgcc-7-dev libgomp1 libitm1 liblsan0 libncurses5-dev libstdc++-7-dev libsystemd-dev libtinfo-dev libtsan0 libubsan0 uuid-dev
apt-get -y install --no-install-recommends libgcc-7-dev libstdc++-7-dev libncurses-dev uuid-dev libglib2.0-dev libsystemd-dev
apt-get -y install --no-install-recommends symlinks
symlinks -c /usr/lib/aarch64-linux-gnu
EOF

   export ROOTFS_DISK_PATH=$DISK_FILE
   source 12-chroot-run.sh
   chroot_run_script $CHROOT_SCRIPT
   rm -rf $CHROOT_SCRIPT
   sudo rsync -avlz  overlays/  ${TMP_DIR}/
   cleanup_on_exit
fi
}

backup_rootfs_disk() {
   echo "Based on: $DISK_FILE"
   ./11-disk-image-to-tar.sh $DISK_FILE $DISK_TAR_FILE
}

echo "Building $DISK_FILE"
[ ! -f $DISK_FILE ] && create_rootfs_disk
echo "Building $DISK_TAR_FILE"
[ ! -f $DISK_TAR_FILE ] && backup_rootfs_disk
