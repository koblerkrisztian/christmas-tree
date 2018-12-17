local Around = {}

local buffer = nil
local timer = nil
local step = 1

local function getColor(intensity, n)
  local color = {color_utils.colorWheel(n*360/Lights.NUM_LEDS)}
  for i,v in ipairs(color) do
    color[i] = v*intensity/255
  end
  table.insert(color, 0)
  return color
end

local function writeStep(n)
  if n < 1 then
    buffer:fill(0, 0, 0, 0)
  elseif n <= Lights.NUM_LEDS then
    buffer:set(n, getColor(Lights.INTENSITY, n))
  end
  ws2812.write(Lights.transform(Lights.transformation_vertical_horizontal, buffer))
end

function Around.start()
  buffer = ws2812.newBuffer(Lights.NUM_LEDS, Lights.NUM_COLORS)
  timer = tmr.create()
  step = 1
  timer:alarm(100, tmr.ALARM_AUTO, function(t)
    writeStep(step)
    step = step + 1
    if step > Lights.NUM_LEDS then
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
