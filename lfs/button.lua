require("events")

Button = {}

Button.LONG_PRESS_TIME_MS = 3000

local buttonPin = 5
local lastLevel = 1
local longPressTimer = nil

local function buttonDown()
  longPressTimer:alarm(Button.LONG_PRESS_TIME_MS, tmr.ALARM_SINGLE, function()
    Events.ButtonLongPress:post()
  end)
  Events.ButtonDown:post()
end

local function buttonUp()
  longPressTimer:unregister()
  Events.ButtonUp:post()
end

function Button.init()
  gpio.mode(buttonPin, gpio.INT)
  gpio.trig(buttonPin, "both", function(level, timestamp)
    local level = gpio.read(buttonPin) -- Don't trust the provided level, it's bouncy
    if level == 0 and lastLevel == 1 then
      buttonDown()
      lastLevel = 0
    elseif level == 1 and lastLevel == 0 then
      buttonUp()
      lastLevel = 1
    end
  end)
  longPressTimer = tmr.create()
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
