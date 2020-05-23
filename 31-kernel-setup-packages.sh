#!/bin/bash

source 30-kernel-setup-env.sh

[ ! -f $KERNEL_DL_FILE ] && wget $KERNEL_DL_URL -O $KERNEL_DL_FILE
[ ! -f $KERNEL_DL_FILE ] && echo "$KERNEL_DL_FILE : not found"  && exit 0
