local Flash = {}

local buffer
local timer

local baseColor = {Lights.getColor(20, 224, Lights.INTENSITY)}
local flashColor = {Lights.getColor(240, 72, math.min(Lights.INTENSITY * 2, 255))}

local lastFlashIndex = 0

function Flash.start()
  local l = Lights
  buffer = ws2812.newBuffer(l.NUM_LEDS, l.NUM_COLORS)
  buffer:fill(unpack(baseColor))

  timer = tmr.create()
  timer:alarm(500, tmr.ALARM_AUTO, function(t)
    if lastFlashIndex > 0 then
      buffer:set(lastFlashIndex, baseColor)
      lastFlashIndex = 0
      timer:interval(node.random(100, 1000))
    else
      lastFlashIndex = node.random(1, l.NUM_LEDS)
      buffer:set(lastFlashIndex, flashColor)
      timer:interval(50)
    end
    ws2812.write(buffer)
  end)
end

function Flash.stop()
  timer:unregister()
  timer = nil
  buffer = nil
end

function Flash.pause()
  if timer then
    timer:stop()
  end
end

function Flash.resume()
  if timer then
    timer:start()
  end
end

return Flash
