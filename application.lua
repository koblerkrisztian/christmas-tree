local lfsFileNew = "lfs.img"
local lfsFileCurrent = "lfs-current.img"

if file.exists(lfsFileNew) then
  if file.exists(lfsFileCurrent) then
    file.remove(lfsFileCurrent)
  end
  file.rename(lfsFileNew, lfsFileCurrent)
  node.flashreload(lfsFileCurrent)
end

local init_fn = node.flashindex("_init")
if not init_fn then
  if file.exists(lfsFileCurrent) then
    print("Loading LFS image")
    node.flashreload(lfsFileCurrent)
  end
end
init_fn()

require("events")
require("time")
require("button")

-- Start connectgion to Wifi
require("network")

-- Start lights
require("lights")
