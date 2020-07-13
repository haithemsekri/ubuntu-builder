#!/bin/bash

[ ! -f $1 ] &&  echo "Invalid arg1 for source image file" && exit 0
[ ! -b $2 ] &&  echo "Invalid arg2 for destination device file" && exit 0

IMAGE=$1
DEVICE=$2

e2fsck -y -f $IMAGE
resize2fs -M $IMAGE
umount $DEVICE 2>/dev/null
dd if=$IMAGE of=$DEVICE status=progress
sync
e2fsck -y -f $DEVICE
resize2fs $DEVICE