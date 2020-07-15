#!/bin/bash

IMAGE_PATH="$1"
[ -z "$IMAGE_PATH" ] && echo "Arg1 : empty image name"  && exit 0

source $(dirname $(realpath $0))/00-common-env.sh

IMAGE_SIZE=0
PART_NB=0

for ((i = 2; i <= $#; i++ )); do
   arg="${!i}"
   #printf 'Arg "%s"\n' "$arg"
   PART_TYPE="$(echo $arg | cut -d':' -f 1)"
   PART_SIZE="$(echo $arg | cut -d':' -f 2)"
   PART_NAME="$(echo $arg | cut -d':' -f 3)"

   let "PART_NB++"
   [ -z $PART_TYPE ] && echo "PART-$PART_NB : empty type"  && exit 0
   [ -z $PART_SIZE ] && echo "PART-$PART_NB : empty size"  && exit 0
   [ -z $PART_NAME ] && echo "PART-$PART_NB : empty name"  && exit 0

   if [ "$PART_TYPE" == "raw" ]; then
      :
   elif [ "$PART_TYPE" == "ext3" ]; then
      :
   elif [ "$PART_TYPE" == "ext4" ]; then
      :
   elif [ "$PART_TYPE" == "fat32" ]; then
      :
   else
      echo "Invalid PART_TYPE: $PART_TYPE"
      exit 1
   fi

   if [[ $PART_SIZE =~ ^-?[0-9]+$ ]]; then
      #echo "   PART_SIZE: $PART_SIZE"
      if [[ $PART_SIZE -eq 0 ]]; then
         echo "Invalid PART_SIZE: $PART_SIZE"
         exit 1
      fi
   else
      echo "Invalid PART_SIZE: $PART_SIZE"
      exit 1
   fi

   #echo "   PART_NAME: $PART_NAME"
   IMAGE_SIZE_MB=$(($IMAGE_SIZE_MB+$PART_SIZE))
done

echo "IMAGE_SIZE_MB: $IMAGE_SIZE_MB"
[ "$IMAGE_SIZE_MB" == "0" ] && echo "cannot create an empty image" && exit 0
IMAGE_SIZE_MB=$(($IMAGE_SIZE_MB+2))

rm -rf $IMAGE_PATH
fallocate -l $((1024*1024*$IMAGE_SIZE_MB)) $IMAGE_PATH
/sbin/parted $IMAGE_PATH --script -- mklabel gpt

START_BLOCKS=0
END_BLOCKS=2047
PART_NB=0
for ((i = 2; i <= $#; i++ )); do
   arg="${!i}"
   PART_TYPE="$(echo $arg | cut -d':' -f 1)"
   PART_SIZE="$(echo $arg | cut -d':' -f 2)"
   PART_NAME="$(echo $arg | cut -d':' -f 3)"

   START_BLOCKS=$(($END_BLOCKS+1))
   END_BLOCKS=$((2048*$PART_SIZE+$START_BLOCKS-1))
   echo "$PART_NAME:$PART_TYPE:$START_BLOCKS:$END_BLOCKS"


   if [ "$PART_TYPE" == "raw" ]; then
      :
   else
      let "PART_NB++"
      /sbin/parted $IMAGE_PATH --script -- mkpart primary $PART_TYPE "$START_BLOCKS"s "$END_BLOCKS"s
      /sbin/parted $IMAGE_PATH --script -- name $PART_NB $PART_NAME
   fi
done

/sbin/parted $IMAGE_PATH --script -- print

exit 0

[ ! -f $UBOOT_ATF_IMAGE_FILE ] && echo "$UBOOT_ATF_IMAGE_FILE : file not found" && exit 0

if [ "$1" == "--rebuild" ]; then
   echo -n ""
fi

if [ "$1" == "--clean-rebuild" ]; then
   echo "delete $LOADER_DISK"
   rm -rf $LOADER_DISK
fi

echo "Building: $LOADER_DISK"
if [ ! -f $LOADER_DISK ]; then
   echo "Based on: $UBOOT_ATF_IMAGE_FILE"
   IMAGE_SIZE=0
   IMAGE_SIZE=$(expr "$IMAGE_SIZE" + "$LOADER_PART_SIZE")
   IMAGE_SIZE=$(expr "$IMAGE_SIZE" + "$BOOT_PART_SIZE")
   IMAGE_SIZE=$(expr "$IMAGE_SIZE" + "$ROOTA_PART_SIZE")
   IMAGE_SIZE=$(expr "$IMAGE_SIZE" + "$ROOTB_PART_SIZE")
   IMAGE_SIZE=$(expr "$IMAGE_SIZE" + "$DATA_PART_SIZE")
   [ "$IMAGE_SIZE" == "0" ] && echo "IMAGE_SIZE : cannot create an empty image" && exit 0

   dd if=/dev/zero of=$LOADER_DISK bs=1M count=$IMAGE_SIZE
   /sbin/parted $LOADER_DISK --script -- mklabel msdos

   START_BLOCKS=0
   END_BLOCKS=$((2048*$LOADER_PART_SIZE+$START_BLOCKS-1))
   echo "START_BLOCKS: $START_BLOCKS, END_BLOCKS: $END_BLOCKS"
   TRUNC_BLOCK=$((2048*$LOADER_PART_SIZE))

   if [ $BOOT_PART_SIZE != 0 ]; then
   START_BLOCKS=$(($END_BLOCKS+1))
   END_BLOCKS=$((2048*$BOOT_PART_SIZE+$START_BLOCKS-1))
   #TRUNC_BLOCK=$(($END_BLOCKS+1))
   echo "START_BLOCKS: $START_BLOCKS, END_BLOCKS: $END_BLOCKS"
   /sbin/parted $LOADER_DISK --script -- mkpart primary $EXT_FS_TYPE "$START_BLOCKS"s "$END_BLOCKS"s
   fi

   if [ $ROOTA_PART_SIZE != 0 ]; then
   START_BLOCKS=$(($END_BLOCKS+1))
   END_BLOCKS=$((2048*$ROOTA_PART_SIZE+$START_BLOCKS-1))
   echo "START_BLOCKS: $START_BLOCKS, END_BLOCKS: $END_BLOCKS"
   /sbin/parted $LOADER_DISK --script -- mkpart primary $EXT_FS_TYPE "$START_BLOCKS"s "$END_BLOCKS"s
   fi

   if [ $ROOTB_PART_SIZE != 0 ]; then
   START_BLOCKS=$(($END_BLOCKS+1))
   END_BLOCKS=$((2048*$ROOTB_PART_SIZE+$START_BLOCKS-1))
   echo "START_BLOCKS: $START_BLOCKS, END_BLOCKS: $END_BLOCKS"
   /sbin/parted $LOADER_DISK --script -- mkpart primary $EXT_FS_TYPE "$START_BLOCKS"s "$END_BLOCKS"s
   fi

   if [ $DATA_PART_SIZE != 0 ]; then
   START_BLOCKS=$(($END_BLOCKS+1))
   END_BLOCKS=$((2048*$DATA_PART_SIZE+$START_BLOCKS-1))
   echo "START_BLOCKS: $START_BLOCKS, END_BLOCKS: $END_BLOCKS"
   /sbin/parted $LOADER_DISK --script -- mkpart primary $EXT_FS_TYPE "$START_BLOCKS"s "$END_BLOCKS"s
   fi

   TMP_DIR=$BUILD_DIR/build.bootfs.disk.tmp
   rm -rf $TMP_DIR
   mkdir $TMP_DIR
   tar -xzf $UBOOT_ATF_IMAGE_FILE -C $TMP_DIR
   [ ! -f $TMP_DIR/u-boot-spl ] && echo "$TMP_DIR/u-boot-spl : file not found" && rm -rf $TMP_DIR && exit 0

   echo "Writing uboot-spl"
   dd if=$TMP_DIR/u-boot-spl of=$LOADER_DISK seek=16 conv=notrunc
   rm -rf $TMP_DIR

   echo "TRUNC_BLOCK: $TRUNC_BLOCK"
   truncate -s $((512*$TRUNC_BLOCK)) $LOADER_DISK
fi

echo "Loader disk: $LOADER_DISK"
