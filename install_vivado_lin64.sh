#!/usr/bin/env bash

# script for automatic installing of Xilinx Vivado suite
# on Debian-based Linux distributions

# the first step is downloading and verifing the TAR/GZIP version of AMD Unified Installer
# from https://www.xilinx.com/support/download.html.

# update according to the version of the installer you heve downloaded
UNIFIED_INSTALLER_PATH=./FPGAs_AdaptiveSoCs_Unified_2023.2_1013_2256.tar.gz

# path to the directory where you want Vivado to be installed
INSTALL_PATH="$HOME"/Xilinx/

# necessary if you want to program your board
INSTALL_CABLE_DRIVERS=true

EDITION="Vivado ML Standard"
UNPACKED_DIR=$(basename "$UNIFIED_INSTALLER_PATH" .tar.gz)


[ ! -d "$INSTALL_PATH" ] && echo "Invalid Vivado install path. Directory does not exist." && exit 1
[ ! -f "$UNIFIED_INSTALLER_PATH" ] && echo "Invalid installer path. Please download the installer or provide a valid path." && exit 1

set -e

sudo apt-get update && sudo apt-get upgrade
sudo apt install python3 default-jre libstdc++6 libgtk2.0-0 dpkg-dev libtinfo6 libncurses6

# older installers may look for libtinfo5 and libncurses5
sudo ln -s /lib/x86_64-linux-gnu/libtinfo.so.6 /lib/x86_64-linux-gnu/libtinfo.so.5
sudo ln -s /lib/x86_64-linux-gnu/libncurses.so.6 /lib/x86_64-linux-gnu/libncurses.so.5

tar vfxz "$UNIFIED_INSTALLER_PATH" -C $UNPACKED_DIR 
echo "entering installer directory ($UNPACKED_DIR) ..."
cd "$UNPACKED_DIR"

./xsetup --agree 3rdPartyEULA,XilinxEULA --batch Install --product "Vivado" --edition "$EDITION" --location "$INSTALL_PATH"

echo "exiting installer directory ($UNPACKED_DIR) ..."
cd -

if [ $INSTALL_CABLE_DRIVERS = "true" ]
then
	echo "installing cable drivers..."
	install_scripts_dir=$INSTALL_PATH/Vivado/$(basename "$UNIFIED_INSTALLER_PATH" | cut -d'_' -f 4)/data/xicom/cable_drivers/lin64/install_scripts/install_drivers/
	echo "entering Vivado install scripts directory ($install_scripts_dir) ..."
	cd "$install_scripts_dir"
	sudo ./install_drivers
	echo "exiting Vivado install scripts directory ($install_scripts_dir) ..."
	cd -
fi

echo "installation finished successfully :3"
