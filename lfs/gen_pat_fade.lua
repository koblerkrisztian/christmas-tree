local Fade = {}
Fade.__index = Fade

function Fade.new(hsvColor, steps, repeatCount, finishCallback, interval, length, firstIndex, transformation)
  local self = setmetatable({}, Fade)
  self.color = hsvColor or {h=0, s=255, v=Lights.INTENSITY}
  self.steps = steps or 10
  self.repeatCount = repeatCount or 0
  self.finishCallback = finishCallback
  self.interval = interval or 50
  self.length = length or Lights.NUM_LEDS
  self.firstIndex = firstIndex or 1
  self.transformation = transformation or Lights.transformation_horizontal_vertical
  if self.length + self.firstIndex - 1 > Lights.NUM_LEDS then return nil end
  return self
end

function Fade:start()
  local l = Lights
  self.frameBuffer = ws2812.newBuffer(l.NUM_LEDS, l.NUM_COLORS)
  if self.length < l.NUM_LEDS then
    self.buffer = ws2812.newBuffer(self.length, l.NUM_COLORS)
  else
    self.buffer = nil
  end
  self.direction = 1
  self.step = 1
  self.reps = 0
  self.timer = tmr.create()
  self.timer:alarm(self.interval, tmr.ALARM_AUTO, function(t)
    local c = {l.getColor(self.color.h, self.color.s, self.color.v * self.step / self.steps)}
    if self.buffer then
      self.buffer:fill(unpack(c))
      self.frameBuffer:replace(self.buffer, self.firstIndex)
    else
      self.frameBuffer:fill(unpack(c))
    end
    ws2812.write(l.transform(self.transformation, self.frameBuffer))
    self.step = self.step + self.direction
    if self.step > self.steps then
      self.step = self.steps
      self.direction = -1
    elseif self.step < 0 then
      self.step = 0
      self.direction = 1
      self.reps = self.reps + 1
    end
    if self.repeatCount > 0 and self.reps == self.repeatCount then
      self:stop()
      if self.finishCallback then
        self.finishCallback()
      end
    end
  end)
end

function Fade:stop()
  self.timer:unregister()
  self.timer = nil
  self.buffer = nil
  self.frameBuffer = nil
 end

function Fade:pause()
  if self.timer then
    self.timer:stop()
  end
end

function Fade:resume()
  if self.timer then
    self.timer:start()
  end
end

return Fade
