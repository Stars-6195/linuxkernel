export RELEASE_NAME ?= $(shell date +%Y%m%d)

rootfs-$(RELEASE_NAME).tar.gz:
	./make_rootfs.sh rootfs-$(RELEASE_NAME) $@
	./install_uboot.sh rootfs-$(RELEASE_NAME)
	./install_kernel.sh rootfs-$(RELEASE_NAME)
	./make_tarball.sh rootfs-$(RELEASE_NAME) $@

archlinux-xfce-oceanic_5205-$(RELEASE_NAME).img: rootfs-$(RELEASE_NAME).tar.gz
	./make_empty_image.sh $@
	./make_image.sh $@ $< u-boot-sunxi-with-spl-oceanic_5205.bin

.PHONY: image
archlinux-xfce-oceanic_5205: archlinux-xfce-oceanic_5205-$(RELEASE_NAME).img
