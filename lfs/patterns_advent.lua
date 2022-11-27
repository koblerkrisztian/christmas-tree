require("time")
require("events")

local Advent = {}

local buffer = nil
local timer = nil
local segmentNumber = 0
local hue = 20

local function ceilDiv(dividend, divisor)
  return (dividend + divisor - 1) / divisor
end

local function getAdventNumber(mon, day, wday)
  if mon == 1 and day <= 6 then return 4 end
  if mon < 11 then return 0 end

  local daysLeft = 0
  if mon == 11 then
    daysLeft = 30 - day + 24
  else
    daysLeft = 24 - day
  end
  if daysLeft <= 0 then return 4 end

  local wdayOfChristmas = (wday - 1 + daysLeft) % 7 + 1
  local daysToLastSunday = daysLeft - (wdayOfChristmas - 1)
  local adventNum = 4 - ceilDiv(daysToLastSunday, 7)

  return math.min(math.max(adventNum, 0), 4)
end

local function getSegmentNumber()
  if not Time.getTimeSynced() then return 0 end
  local t = Time.getLocalTime()
  return getAdventNumber(t.mon, t.day, t.wday)
end

local function clearBuffer()
  local l = Lights
  if buffer then
    buffer:fill(l.getBlack())
    buffer:set(25, {l.getColor(0, 255, l.INTENSITY)})
    buffer:set(26, {l.getColor(0, 255, l.INTENSITY)})
  end
end

function Advent.start()
  local l = Lights
  buffer = ws2812.newBuffer(l.NUM_LEDS, l.NUM_COLORS)
  clearBuffer()

  timer = tmr.create()
  timer:alarm(200, tmr.ALARM_AUTO, function(t)
    local intensity = l.INTENSITY
    for i=1, segmentNumber * 6 do
      local color = {l.getColor(hue, 224, intensity + (node.random(-2, 2) * intensity / 10))}
      buffer:set(i, color)
    end
    ws2812.write(l.transform(l.transformation_vertical_horizontal, buffer))
  end)
end

function Advent.stop()
  timer:unregister()
  timer = nil
  buffer = nil
end

function Advent.pause()
  if timer then
    timer:stop()
  end
end

function Advent.resume()
  if timer then
    timer:start()
  end
end

local function updateSegmentNumber()
  local num = getSegmentNumber()
  if num < segmentNumber then
    clearBuffer()
  end
  segmentNumber = num
end

local alarmSet = false
Events.TimeSynced:subscribe(function()
  updateSegmentNumber()
  if not alarmSet then
    Time.setAlarm(0, 0, function()
      updateSegmentNumber()
    end)
    alarmSet = true
  end
end)

function Advent.setHue(h)
  hue = h
end

return Advent
