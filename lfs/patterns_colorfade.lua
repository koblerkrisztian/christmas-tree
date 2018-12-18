local Colorfade = {}

local buffer
local timer
local step = 0

function Colorfade.start()
  local l = Lights
  buffer = ws2812.newBuffer(l.NUM_LEDS, l.NUM_COLORS)
  timer = tmr.create()
  step = 0
  timer:alarm(50, tmr.ALARM_AUTO, function(t)
    buffer:fill(l.getColor(step, 255, l.INTENSITY))
    ws2812.write(buffer)
    step = (step + 1) % 360
  end)
end

function Colorfade.stop()
  timer:unregister()
  timer = nil
  buffer = nil
end

function Colorfade.pause()
  if timer then
    timer:stop()
  end
end

function Colorfade.resume()
  if timer then
    timer:start()
  end
end

return Colorfade
