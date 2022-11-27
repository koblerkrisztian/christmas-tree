local Rainbow = {}

local buffer = nil
local timer = nil
local speed = 5
local phase = 0

local function getColor(offset, n)
  local l = Lights
  return {l.getColor(((n*360/l.NUM_LEDS) + offset) % 360, 255, l.INTENSITY)}
end

local function writeColors(offset)
  local l = Lights
  for i=1, l.NUM_LEDS do
    buffer:set(i, getColor(offset, i))
  end
  ws2812.write(l.transform(l.transformation_vertical_horizontal, buffer))
end

function Rainbow.start()
  local l = Lights
  buffer = ws2812.newBuffer(l.NUM_LEDS, l.NUM_COLORS)
  timer = tmr.create()

  writeColors(0)

  timer:alarm(150, tmr.ALARM_AUTO, function(t)
    buffer:shift(1, ws2812.SHIFT_CIRCULAR)
    ws2812.write(l.transform(l.transformation_vertical_horizontal, buffer))
  end)
end

function Rainbow.stop()
  timer:unregister()
  timer = nil
  buffer = nil
end

function Rainbow.pause()
  if timer then
    timer:stop()
  end
end

function Rainbow.resume()
  if timer then
    timer:start()
  end
end

return Rainbow
