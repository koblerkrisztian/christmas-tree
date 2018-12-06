local Around = {}

local buffer = nil
local timer = nil
local step = 1

local function getColor(intensity, n)
  local color = {color_utils.colorWheel(n*360/NUM_LEDS)}
  for i,v in ipairs(color) do
    color[i] = v*intensity/255
  end
  table.insert(color, 0)
  return color
end

local function writeStep(n)
  if n < 1 then
    buffer:fill(0, 0, 0, 0)
  elseif n <= NUM_LEDS then
    buffer:set(n, getColor(50, n))
  end
  ws2812.write(lights.transform(lights.transformation_vertical_horizontal, buffer))
end

function Around.start()
  buffer = ws2812.newBuffer(NUM_LEDS, NUM_COLORS)
  timer = tmr.create()
  timer:alarm(100, tmr.ALARM_AUTO, function(t)
    writeStep(step)
    step = step + 1
    if step > NUM_LEDS then
      step = 0
      timer:interval(1000)
    else
      timer:interval(100)
    end
  end)
end

function Around.stop()
  buffer = nil
  timer:unregister()
  timer = nil
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
