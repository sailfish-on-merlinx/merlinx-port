#!/bin/bash
set -e

source /home/ponm21/.hadk.env
source build/envsetup.sh
breakfast merlinx

CORES=$(nproc)
echo "Building hybris-hal and droidmedia with $CORES CPU cores..."
make -j$CORES hybris-hal droidmedia libui_compat_layer
