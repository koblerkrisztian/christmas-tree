local Around = {}
Around.__index = Around

function Around:start()
  self.buffer = ws2812.newBuffer(NUM_LEDS, NUM_COLORS)
  self.timer = tmr.create()
  self.timer:alarm(100, tmr.ALARM_AUTO, function(t)
    self:writeStep(self.step)
    self.step = self.step + 1
    if self.step > NUM_LEDS then
      self.step = 0
      self.timer:interval(1000)
    else
      self.timer:interval(100)
    end
  end)
end

function Around:stop()
  self.buffer = nil
  self.timer:unregister()
  self.timer = nil
end

function Around:getColor(intensity, n)
  local color = {color_utils.colorWheel(n*360/NUM_LEDS)}
  for i,v in ipairs(color) do
    color[i] = v*intensity/255
  end
  table.insert(color, 0)
  return color
end

function Around:writeStep(n)
  if n < 1 then
    self.buffer:fill(0, 0, 0, 0)
  elseif n <= NUM_LEDS then
    self.buffer:set(n, self:getColor(50, n))
  end
  ws2812.write(transform(transformation_vertical_horizontal, self.buffer))
end

local self = setmetatable({}, Around)
self.buffer = nil
self.timer = nil
self.step = 1

patterns.around = self
