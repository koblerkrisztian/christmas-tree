FW_DIR:=nodemcu-fw
LFS_DIR:=lfs
LFS_IMAGE:=lfs.img
VERSION:=$(shell git describe --dirty)
DATE:=$(shell date -Iseconds)

.PHONY: FORCE
FORCE:

.PHONY: clean lfs-image firmware flash-firmware


clean:
	$(MAKE) -C $(FW_DIR) clean
	$(RM) $(LFS_IMAGE)
	$(RM) $(LFS_DIR)/version.lua

firmware:
	$(MAKE) -C $(FW_DIR) all

flash-firmware: firmware
	$(MAKE) -C $(FW_DIR) flash4m

$(LFS_DIR)/version.lua: FORCE
	sed -e "s;%version%;$(VERSION);g" -e "s;%date%;$(DATE);g" $(LFS_DIR)/version.lua.template > $(LFS_DIR)/version.lua

$(FW_DIR)/luac.cross:
	$(MAKE) -C $(FW_DIR) all

$(LFS_IMAGE): $(LFS_DIR)/version.lua $(LFS_DIR)/*.lua $(FW_DIR)/luac.cross
	$(FW_DIR)/luac.cross -o $(LFS_IMAGE) -f $(LFS_DIR)/*.lua

lfs-image: $(LFS_IMAGE)
