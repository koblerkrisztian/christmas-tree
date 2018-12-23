local Around = {}

local buffer = nil
local timer = nil
local step = 1

local function getColor(n)
  local l = Lights
  return {l.getColor(n*360/l.NUM_LEDS, 255, l.INTENSITY)}
end

local function writeStep(n)
  local l = Lights
  if n < 1 then
    buffer:fill(l.getBlack())
  elseif n <= l.NUM_LEDS then
    buffer:set(n, getColor(n))
  end
  ws2812.write(l.transform(l.transformation_vertical_horizontal, buffer))
end

function Around.start()
  local l = Lights
  buffer = ws2812.newBuffer(l.NUM_LEDS, l.NUM_COLORS)
  timer = tmr.create()
  step = 1
  timer:alarm(100, tmr.ALARM_AUTO, function(t)
    writeStep(step)
    step = step + 1
    if step > l.NUM_LEDS then
      step = 0
      timer:interval(1000)
    else
      timer:interval(100)
    end
  end)
end

function Around.stop()
  timer:unregister()
  timer = nil
  buffer = nil
end

function Around.pause()
  if timer then
    timer:stop()
  end
end

function Around.resume()
  if timer then
    timer:start()
  end
end

return Around
