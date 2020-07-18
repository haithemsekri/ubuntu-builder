#!/bin/bash

[ -z "$1" ] && echo "Arg1 : empty image name"  && exit 0
[ -z "$2" ] && echo "Arg2 : empty parts size"  && exit 0

source $(dirname $(realpath $0))/00-common-env.sh

IMAGE_PATH="$1"
IMAGE_SIZE=0
PART_NB=0

for ((i = 2; i <= $#; i++ )); do
   let "PART_NB++"
   PART_SIZE="${!i}"

   if [[ $PART_SIZE =~ ^-?[0-9]+$ ]]; then
      if [[ $PART_SIZE -eq 0 ]]; then
         echo "Invalid PART_SIZE: $PART_SIZE"
         exit 1
      fi
   else
      echo "Invalid PART_SIZE: $PART_SIZE"
      exit 1
   fi

   IMAGE_SIZE_MB=$(($IMAGE_SIZE_MB+$PART_SIZE))
done

[ "$IMAGE_SIZE_MB" == "0" ] && echo "cannot create an empty image" && exit 0
IMAGE_SIZE_MB=$(($IMAGE_SIZE_MB+$MBR_SIZE_MB))
echo "IMAGE_SIZE_MB: $IMAGE_SIZE_MB"
echo "IMAGE_BLOCKS: $((2048*$IMAGE_SIZE_MB))"

rm -rf $IMAGE_PATH
fallocate -l $((1024*1024*$IMAGE_SIZE_MB)) $IMAGE_PATH
dd if=/dev/zero of=$IMAGE_PATH bs=1M count=2 conv=notrunc
/sbin/parted $IMAGE_PATH --script -- mklabel msdos  &> /dev/null

START_BLOCKS=0
END_BLOCKS=$(($MBR_SIZE_MB*2048-1))
PART_NB=0
for ((i = 2; i <= $#; i++ )); do
   PART_SIZE="${!i}"
   START_BLOCKS=$(($END_BLOCKS+1))
   END_BLOCKS=$((2048*$PART_SIZE+$START_BLOCKS-1))
   echo "$START_BLOCKS:$END_BLOCKS"
   let "PART_NB++"
   /sbin/parted $IMAGE_PATH --script -- mkpart primary ext3 "$START_BLOCKS"s "$END_BLOCKS"s
done

/sbin/parted $IMAGE_PATH --script -- print
