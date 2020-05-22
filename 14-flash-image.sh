#!/bin/bash

[ ! -f $1 ] &&  echo "Invalid arg1 for source image file" && exit 0
[ ! -b $2 ] &&  echo "Invalid arg2 for destination device file" && exit 0

IMAGE=$1
DEVICE=$2

e2fsck -y -f $IMAGE
resize2fs -M $IMAGE

sudo umount $DEVICE 2>/dev/null
sudo dd if=$IMAGE of=$DEVICE status=progress
sync
sudo e2fsck -y -f $DEVICE
sudo resize2fs $DEVICE