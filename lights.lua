ws2812.init()
buffer = ws2812.newBuffer(26, 4)
--ws2812_effects.init(buffer)
--ws2812_effects.set_speed(100)
--ws2812_effects.set_brightness(50)
--ws2812_effects.set_color(128, 255, 0, 0)
--ws2812_effects.set_mode("flicker")
--ws2812_effects.start()

transformation_horizontal_vertical = {1, 2, 20, 15, 14, 13, 26, 21, 4, 3, 19, 16, 11, 12, 25, 22, 5, 6, 18, 17, 10, 9, 24, 23, 8, 7}

function transform(transformation, buffer)
  local newBuffer = ws2812.newBuffer(buffer:size(), 4)
  for from, to in ipairs(transformation) do
    newBuffer:set(to, buffer:get(from))
  end
  return newBuffer
end

buffer:fill(0, 0, 0, 0)
buffer:set(1, {50, 50, 50, 50})
ws2812.write(transform(transformation_horizontal_vertical, buffer))


tmr.create():alarm(100, tmr.ALARM_AUTO, function(t)
  buffer:shift(1, ws2812.SHIFT_CIRCULAR)
  ws2812.write(transform(transformation_horizontal_vertical, buffer))
end)
