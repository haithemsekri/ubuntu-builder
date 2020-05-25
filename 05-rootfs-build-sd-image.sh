#!/bin/bash

source 00-rootfs-setup-env.sh
source 30-kernel-setup-env.sh
source 40-xen-setup-env.sh

[ ! -f $XEN_IMAGE_FILE ] &&  echo "$XEN_IMAGE_FILE not found" && exit 0
[ ! -f $TARGET_DISK_FILE ] &&  echo "$TARGET_DISK_FILE not found" && exit 0

echo "Building: $TARGET_ROOTFS_DISK_FILE"

rm -rf $TARGET_ROOTFS_DISK_FILE
cp $TARGET_DISK_FILE $TARGET_ROOTFS_DISK_FILE
sync

CHROOT_SCRIPT="/tmp/chroot-script.sh"
rm -rf  $CHROOT_SCRIPT

cat <<EOF > $CHROOT_SCRIPT
#!/bin/bash
$XEN_CHROOT_SCRIPT

apt-get -y remove binutils-aarch64-linux-gnu libc-dev-bin \
   zlib1g-dev linux-libc-dev libpcre3-dev libc6-dev \
   make libsqlite3-0 patch \
   binutils  binutils-common libbinutils libexpat1 libgdbm-compat4 libgdbm5 libmpdec2 libpcre16-3 \
   gcc-7-base libasan4 libatomic1 libgcc-7-dev libgomp1 libitm1 liblsan0 libncurses5-dev libstdc++-7-dev libsystemd-dev libtinfo-dev libtsan0 libubsan0 uuid-dev \
   libpcre32-3 libpcrecpp0v5 libreadline7 mime-support readline-common \
   python3  python3.6 python3.6-minimal libpython3-stdlib libpython3.6-minimal libpython3.6-stdlib  python3-minimal perl libperl5.26 perl-modules-5.26

apt-get -y clean

rm -rf /var/cache/apt
rm -rf /var/lib/apt
rm -rf /var/log/apt
rm /usr/lib/apt/apt.systemd.daily
rm -rf /usr/include/*
rm -rf /include
rm -rf /usr/locale
rm -rf /lib/*.a
rm -rf /usr/lib/aarch64-linux-gnu/*.a
rm -rf /usr/share/*
rm -rf /share/*
rm -rf /usr/lib/aarch64-linux-gnu/perl-base
EOF

export ROOTFS_DISK_PATH=$TARGET_ROOTFS_DISK_FILE
source 12-chroot-run.sh
echo "Add Overlays: $KERNEL_DOM0_IMAGE_FILE"
sudo tar -xzf $KERNEL_DOM0_IMAGE_FILE -C $TMP_DIR
echo "Add Overlays: $XEN_IMAGE_FILE"
sudo tar -xzf $XEN_IMAGE_FILE -C $TMP_DIR
sudo rsync -avlz  overlays/  ${TMP_DIR}/
chroot_run_script $CHROOT_SCRIPT
cleanup_on_exit
rm -rf $CHROOT_SCRIPT

echo "Rootfs Image: $TARGET_ROOTFS_DISK_FILE"
