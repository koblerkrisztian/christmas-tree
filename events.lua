local Event = {}
Event.__index = Event

function Event.new(name)
  local self = setmetatable({}, Event)
  self.callbacks = {}
  self.name = name
  return self
end

function Event:subscribe(callback)
  table.insert(self.callbacks, callback)
end

local function findCallback(callbacks, cb)
  for k, v in ipairs(callbacks) do
    if cb == v then return k end
  end
  return 0
end

function Event:unsubscribe(callback)
  local i = findCallback(self.callbacks)
  if i > 0 then
    table.remove(self.callbacks, i)
  end
end

function Event:post(...)
  print("Event: "..self.name)
  for k, v in ipairs(self.callbacks) do
    v(...)
  end
end


Events = {}
local function addEvent(name)
  Events[name] = Event.new(name)
end

addEvent("WifiConnected")
addEvent("WifiDisconnected")
addEvent("ConnectedToInternet")
addEvent("TimeSynced")
addEvent("LocationAcquired")

return Events
