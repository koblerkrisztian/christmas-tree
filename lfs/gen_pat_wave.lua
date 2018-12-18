local Wave = {}
Wave.__index = Wave

function Wave.new(hsvColor, steps, length, interval, firstIndex, transformation)
  local self = setmetatable({}, Wave)
  self.color = hsvColor or {h=240, s=255, v=Lights.INTENSITY}
  self.steps = steps or 3
  self.interval = interval or 50
  self.length = length or Lights.NUM_LEDS
  self.firstIndex = firstIndex or 1
  self.transformation = transformation or Lights.transformation_horizontal_vertical
  if self.length + self.firstIndex - 1 > Lights.NUM_LEDS then return nil end
  if self.steps * 2 - 1 > self.length then return nil end
  return self
end

function Wave:start()
  local l = Lights
  self.buffer = ws2812.newBuffer(l.NUM_LEDS, l.NUM_COLORS)
  for i=1,self.steps do
    local c = {l.getColor(self.color.h, self.color.s, self.color.v * i / self.steps)}
    self.buffer:set(i + self.firstIndex - 1, c)
    self.buffer:set(self.firstIndex + self.steps * 2 - i - 1, c)
  end
  ws2812.write(l.transform(self.transformation, self.buffer))
  self.timer = tmr.create()
  self.timer:alarm(self.interval, tmr.ALARM_AUTO, function(t)
    self.buffer:shift(1, ws2812.SHIFT_CIRCULAR, self.firstIndex, self.firstIndex + self.length - 1)
    ws2812.write(l.transform(self.transformation, self.buffer))
  end)
end

function Wave:stop()
 self.timer:unregister()
 self.timer = nil
 self.buffer = nil
end

function Wave:pause()
  if self.timer then
    self.timer:stop()
  end
end

function Wave:resume()
  if self.timer then
    self.timer:start()
  end
end

return Wave
