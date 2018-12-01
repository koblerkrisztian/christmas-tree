NUM_LEDS = 26
NUM_COLORS = 4

ws2812.init()

patterns = {}

transformation_horizontal_vertical = {1, 2, 20, 15, 14, 13, 26, 21, 4, 3, 19, 16, 11, 12, 25, 22, 5, 6, 18, 17, 10, 9, 24, 23, 8, 7}

function transform(transformation, buffer)
  local newBuffer = ws2812.newBuffer(buffer:size(), 4)
  for from, to in ipairs(transformation) do
    newBuffer:set(to, buffer:get(from))
  end
  return newBuffer
end

local files = file.list("patterns/.+%.lua");
for name,size in pairs(files) do
  print("Loading pattern name:"..name..", size:"..size)
  dofile(name)
end

patterns.around:start()
