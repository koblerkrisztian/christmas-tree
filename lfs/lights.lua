require("events")

Lights = {}

Lights.NUM_LEDS = 26
Lights.NUM_COLORS = 4
Lights.INTENSITY = 50

Lights.patterns = {}

Lights.transformation_horizontal_vertical = {1, 2, 20, 15, 14, 13, 26, 21, 4, 3, 19, 16, 11, 12, 25, 22, 5, 6, 18, 17, 10, 9, 24, 23, 8, 7}
Lights.transformation_vertical_horizontal = {1, 4, 5, 2, 3, 6, 20, 19, 18, 15, 16, 17, 14, 11, 10, 13, 12, 9, 26, 25, 24, 21, 22, 23, 8, 7}

local activePattern = 0
local isRunning = false

function Lights.transform(transformation, buffer)
  local newBuffer = ws2812.newBuffer(buffer:size(), Lights.NUM_COLORS)
  for from, to in ipairs(transformation) do
    newBuffer:set(to, buffer:get(from))
  end
  return newBuffer
end

function Lights.clear()
  local buffer = ws2812.newBuffer(Lights.NUM_LEDS, Lights.NUM_COLORS)
  buffer:fill(0, 0, 0, 0)
  ws2812.write(buffer)
end

function Lights.start(index)
  if isRunning then return end
  if index == nil then index = activePattern end
  if index > 0 and index <= #Lights.patterns then
    Lights.patterns[index]:start()
    isRunning = true
    activePattern = index
  end
end

function Lights.stop()
  if not isRunning then return end
  local index = activePattern
  if index > 0 and index <= #Lights.patterns then
    Lights.patterns[index]:stop()
    isRunning = false
  end
end

local function loadPatterns(matchPattern)
  local files = file.list(matchPattern);
  for name,size in pairs(files) do
    local path, fileName, _ = string.match(name, matchPattern)
    print("Loading pattern name:"..fileName..", size:"..size)
    table.insert(Lights.patterns, require(path .. fileName))
  end
end

local function selectPattern(index)
  Lights.stop()
  Lights.start(index)
end

function Lights.init()
  ws2812.init()

  local matchPatternLua = "(patterns/)(%w+)(%.lua)"
  local matchPatternLc = "(patterns/)(%w+)(%.lc)"

  loadPatterns(matchPatternLua)
  loadPatterns(matchPatternLc)

  Lights.start(1)

  Events.ButtonDown:subscribe(function()
    selectPattern(activePattern % #Lights.patterns + 1)
  end)
end

Lights.init()

return Lights
