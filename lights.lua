NUM_LEDS = 26
NUM_COLORS = 4

ws2812.init()

lights = {}
lights.patterns = {}

lights.transformation_horizontal_vertical = {1, 2, 20, 15, 14, 13, 26, 21, 4, 3, 19, 16, 11, 12, 25, 22, 5, 6, 18, 17, 10, 9, 24, 23, 8, 7}
lights.transformation_vertical_horizontal = {1, 4, 5, 2, 3, 6, 20, 19, 18, 15, 16, 17, 14, 11, 10, 13, 12, 9, 26, 25, 24, 21, 22, 23, 8, 7}

function lights.transform(transformation, buffer)
  local newBuffer = ws2812.newBuffer(buffer:size(), NUM_COLORS)
  for from, to in ipairs(transformation) do
    newBuffer:set(to, buffer:get(from))
  end
  return newBuffer
end

local matchPatternLua = "(patterns/)(%w+)(%.lua)"
local matchPatternLc = "(patterns/)(%w+)(%.lc)"

local function loadPatterns(matchPattern)
  local files = file.list(matchPattern);
  for name,size in pairs(files) do
    local path, fileName, _ = string.match(name, matchPattern)
    print("Loading pattern name:"..fileName..", size:"..size)
    lights.patterns[fileName] = require(path .. fileName)
  end
end

loadPatterns(matchPatternLua)
loadPatterns(matchPatternLc)

function lights.clear()
  local buffer = ws2812.newBuffer(NUM_LEDS, NUM_COLORS)
  buffer:fill(0, 0, 0, 0)
  ws2812.write(buffer)
end

lights.patterns.around:start()
