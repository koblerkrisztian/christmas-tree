require("events")

Button = {}

local buttonPin = 5
local lastLevel = 1

function Button.init()
  gpio.mode(buttonPin, gpio.INT)
  gpio.trig(buttonPin, "both", function(level, timestamp)
    local level = gpio.read(buttonPin) -- Don't trust the provided level, it's bouncy
    if level == 0 and lastLevel == 1 then
      Events.ButtonDown:post()
      lastLevel = 0
    elseif level == 1 and lastLevel == 0 then
      Events.ButtonUp:post()
      lastLevel = 1
    end
  end)
end

function Button.isPressed()
  if gpio.read(buttonPin) == 0 then
    return true
  else
    return false
  end
end

Button.init()

return Button
