require("events")
require("settings")

Lights = {}

Lights.NUM_LEDS = 26
Lights.NUM_COLORS = 4
Lights.INTENSITY = 50
Lights.AUTO_CYCLE_INTERVAL_MS = 10 * 60 * 1000

Lights.patterns = {}

Lights.transformation_horizontal_vertical = {1, 2, 20, 15, 14, 13, 26, 21, 4, 3, 19, 16, 11, 12, 25, 22, 5, 6, 18, 17, 10, 9, 24, 23, 8, 7}
Lights.transformation_vertical_horizontal = {1, 4, 5, 2, 3, 6, 20, 19, 18, 15, 16, 17, 14, 11, 10, 13, 12, 9, 26, 25, 24, 21, 22, 23, 8, 7}

local activePattern = 0
local isRunning = false
local autoCycle = false
local autoCycleTimer = nil

function Lights.transform(transformation, buffer)
  local newBuffer = ws2812.newBuffer(buffer:size(), Lights.NUM_COLORS)
  for from, to in ipairs(transformation) do
    newBuffer:set(to, buffer:get(from))
  end
  return newBuffer
end

function Lights.getColor(h, s, v)
  if Lights.NUM_COLORS == 4 then
    return color_utils.hsv2grbw(h, s, v)
  else
    return color_utils.hsv2grb(h, s, v)
  end
end

function Lights.getBlack()
  return Lights.getColor(0, 0, 0)
end

function Lights.clear()
  local buffer = ws2812.newBuffer(Lights.NUM_LEDS, Lights.NUM_COLORS)
  buffer:fill(Lights.getBlack())
  ws2812.write(buffer)
end

local function getActivePattern()
  local index = activePattern
  if index > 0 and index <= #Lights.patterns then
    return Lights.patterns[index]
  else
    return nil
  end
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
  local pattern = getActivePattern()
  if pattern then
    pattern:stop()
    isRunning = false
  end
end

function Lights.pause()
  if not isRunning then return end

  local pattern = getActivePattern()
  if pattern then
    pattern:pause()
  end
  Lights.clear()
end

function Lights.resume()
  if not isRunning then return end

  local pattern = getActivePattern()
  if pattern then
    pattern:resume()
  end
end

function Lights.pauseFor(time_ms, callback_func)
  Lights.pause()
  tmr.create():alarm(time_ms, tmr.ALARM_SINGLE, function()
    Lights.resume()
    callback_func()
  end)
end

local function loadPatterns(matchPattern)
  local files = file.list(matchPattern);
  for name,size in pairs(files) do
    local path, fileName, _ = string.match(name, matchPattern)
    print("Loading pattern name:"..fileName..", size:"..size)
    table.insert(Lights.patterns, require(path .. fileName))
  end
end

local function loadPatternsLfs()
  local files = LFS._list
  for i, name in ipairs(files) do
    local prefix, patternName = name:match("(patterns_)(%w+)")
    if prefix and patternName then
      print("Loading pattern from LFS: "..patternName)
      table.insert(Lights.patterns, require(prefix..patternName))
    end
  end
end

function Lights.selectPattern(index)
  Lights.stop()
  if not autoCycle then
    Settings.setLastPattern(index)
  end
  Lights.start(index)
end

function Lights.selectNextPattern()
  Lights.selectPattern(activePattern % #Lights.patterns + 1)
end

function Lights.getNumPatterns()
  return #Lights.patterns
end

local function specialPatternAutostopped()
  Lights.start()
end

local specialPatterns = {
  endUserSetup = require("gen_pat_wave").new({h=240, s=255, v=Lights.INTENSITY}, 2, 8),
  endUserSetupSuccess = require("gen_pat_fade").new({h=120, s=255, v=Lights.INTENSITY}, 10, 3, specialPatternAutostopped, nil, 8),
  endUserSetupFail = require("gen_pat_fade").new({h=0, s=255, v=Lights.INTENSITY}, 10, 3, specialPatternAutostopped, nil, 8)
}
local specialPatternRunning = ""

function Lights.startSpecialPattern(name)
  Lights.stop()
  Lights.clear()
  if specialPatternRunning ~= "" then
    local p = specialPatterns[specialPatternRunning]
    if p and p.stop then
      p:stop()
    end
  end
  local p = specialPatterns[name]
  if p and p.start then
    p:start()
    specialPatternRunning = name
  end
end

function Lights.stopSpecialPattern()
  local p = specialPatterns[specialPatternRunning]
  if p and p.stop then
    p:stop()
  end
  specialPatternRunning = ""
  Lights.start()
end

local function loadHwinfo()
  if file.exists("hwinfo.lua") or file.exists("hwinfo.lc") then
    local hwinfo = require("hwinfo")
    if hwinfo then
      Lights.NUM_LEDS = hwinfo.NUM_LEDS or Lights.NUM_LEDS
      Lights.NUM_COLORS = hwinfo.NUM_COLORS or Lights.NUM_COLORS
    end
  end
end

function Lights.startAutoCycle()
  Lights.pauseFor(300, function()
    autoCycleTimer = tmr.create()
    autoCycleTimer:alarm(Lights.AUTO_CYCLE_INTERVAL_MS, tmr.ALARM_AUTO, function()
      Lights.selectNextPattern()
    end)
    autoCycle = true
    Settings.setLastPattern("auto")
  end)
end

function Lights.stopAutoCycle()
  Lights.pauseFor(300, function()
    autoCycleTimer:unregister()
    autoCycleTimer = nil
    autoCycle = false
  end)
end

function Lights.toggleAutoCycle()
  if autoCycle then
    Lights.stopAutoCycle()
  else
    Lights.startAutoCycle()
  end
end

local function isNumber(n)
  return type(n) == "number"
end

local function getInitialPattern()
  local lastPattern = Settings.getLastPatter()
  if lastPattern == "auto" then
    return true, 1
  end
  if lastPattern and isNumber(lastPattern) and lastPattern <= #Lights.patterns then
    return false, lastPattern
  end
  return false, 1
end

function Lights.init()
  loadHwinfo()

  ws2812.init()

  local matchPatternLua = "(patterns_)(%w+)(%.lua)"
  local matchPatternLc = "(patterns_)(%w+)(%.lc)"

  loadPatterns(matchPatternLua)
  loadPatterns(matchPatternLc)
  loadPatternsLfs()

  local auto, patternIndex = getInitialPattern()
  Lights.start(patternIndex)
  if auto then
    Lights.startAutoCycle()
  end

  Events.ButtonDown:subscribe(function()
    Lights.selectNextPattern()
  end)
  Events.ButtonLongPress:subscribe(function()
    Lights.toggleAutoCycle()
  end)
end

Lights.init()

return Lights
