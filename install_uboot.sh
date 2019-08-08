#!/bin/bash

set -e

BUILD="build"
OTHERDIR="otherfiles"
BUILD_ARCH=arm64
DEST="$1"
USER=`sudo who | head -1 | awk '{print $1}'`

export LC_ALL=C
# Add qemu emulation.
cp /usr/bin/qemu-aarch64-static "$DEST/usr/bin"
cp /usr/bin/qemu-arm-static "$DEST/usr/bin"

cleanup() {
	if [ -e "$DEST/proc/cmdline" ]; then
		umount "$DEST/proc"
	fi
	if [ -d "$DEST/sys/kernel" ]; then
		umount "$DEST/sys"
	fi
	umount "$DEST/dev" || true
	umount "$DEST/tmp" || true
	if [ -d "$TEMP" ]; then
		rm -rf "$TEMP"
	fi
}
trap cleanup EXIT

do_chroot() {
	cmd="$@"
	mount -o bind /tmp "$DEST/tmp"
	mount -o bind /dev "$DEST/dev"
	chroot "$DEST" mount -t proc proc /proc
	chroot "$DEST" mount -t sysfs sys /sys
	chroot "$DEST" $cmd
	chroot "$DEST" umount /sys
	chroot "$DEST" umount /proc
	umount "$DEST/dev"
	umount "$DEST/tmp"
}

cd ./ArchLinux-Build/uboot-pine64-git
sudo -u $USER CARCH=aarch64 CROSS_COMPILE=aarch64-linux-gnu- makepkg -sf
if [ ! -d "../../$DEST/packages" ]; then
mkdir "../../$DEST/packages"
fi
cp *.pkg.tar.* "../../$DEST/packages"
cd ../../

mv "$DEST/etc/resolv.conf" "$DEST/etc/resolv.conf.dist"
cp /etc/resolv.conf "$DEST/etc/resolv.conf"
sed -i 's|CheckSpace|#CheckSpace|' "$DEST/etc/pacman.conf"

cat > "$DEST/second-phase" <<EOF

#!/bin/sh

cd packages
ls
pacman -U --noconfirm *.pkg.tar.*

EOF
chmod +x "$DEST/second-phase"
do_chroot /second-phase
rm $DEST/second-phase

# Final touches
rm "$DEST/usr/bin/qemu-aarch64-static"
rm "$DEST/usr/bin/qemu-arm-static"
rm -f "$DEST"/*.core
mv "$DEST/etc/resolv.conf.dist" "$DEST/etc/resolv.conf"


echo "Installed kernel to $DEST"

set -x
echo "Done"
