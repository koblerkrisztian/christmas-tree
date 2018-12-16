local init_fn = node.flashindex("_init")
if not init_fn then
  if file.exists("lfs.img") then
    print("Loading LFS image")
    node.flashreload("lfs.img")
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
