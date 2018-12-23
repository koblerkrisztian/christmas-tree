require("time")
require("events")

local Calendar = {}

local buffer = nil
local timer = nil
local intensity = 0
local direction = 1
local step = 5

function Calendar.start()
  local l = Lights
  timer = tmr.create()
  timer:alarm(50, tmr.ALARM_AUTO, function(t)
    local color = {l.getColor(30, 128, intensity)}
    buffer:set(25, color)
    buffer:set(26, color)
    ws2812.write(l.transform(l.transformation_horizontal_vertical, buffer))
    intensity = intensity + step * direction
    if intensity >= l.INTENSITY then
      intensity = l.INTENSITY
      direction = -1
    elseif intensity < 0 then
      intensity = 0
      direction = 1
    end
  end)
end

function Calendar.pause()
  if timer then
    timer:stop()
  end
end

function Calendar.resume()
  if timer then
    timer:start()
  end
end

function Calendar.stop()
  timer:unregister()
  timer = nil
end

local function isEmptyColor(color)
  for k,v in pairs(color) do
    if v ~= 0 then return false end
  end
  return true
end

local function getNewColor()
  local l = Lights
  return {l.getColor(node.random(0, 359), node.random(192, 255), l.INTENSITY)}
end

local function fillDays()
  local t = Time.getLocalTime()
  local numDays = 0
  if t.mon == 12 then
    numDays = math.min(t.day, 24)
  end
  for i=1,numDays do
    if isEmptyColor({buffer:get(i)}) then
      buffer:set(i, getNewColor())
    end
  end
end

local alarmSet = false
Events.TimeSynced:subscribe(function()
  fillDays()
  if not alarmSet then
    Time.setAlarm(0, 0, function()
      fillDays()
    end)
    alarmSet = true
  end
end)

buffer = ws2812.newBuffer(Lights.NUM_LEDS, Lights.NUM_COLORS)
buffer:fill(Lights.getBlack())

return Calendar
