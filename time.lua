require("events")

Time = {}

local timeSynced = false
local locationAcquired = false
local offset = 0

function Time.getLocalTime()
  if not timeSynced and not locationAcquired then return nil end
  
  return rtctime.epoch2cal(rtctime.get() + offset)
end

function Time.getUtcTime()
  if not timeSynced then return nil end

  return rtctime.epoch2cal(rtctime.get())
end

function Time.getLocationAcquired()
  return locationAcquired
end

function Time.getTimeSynced()
  return timeSynced
end

local function syncTime()
  sntp.sync(nil, 
  function(sec, usec, server, info)
    timeSynced = true
    Events.TimeSynced:post()
  end,
  function(error, info)
    print('time sync failed!', error, info)
    tmr.create():alarm(5000, tmr.ALARM_SINGLE, function()
      syncTime()
    end)
  end,
  1)
end

local function acquireLocationInfo(callback)
  http.get("http://gd.geobytes.com/GetCityDetails",
  nil,
  function(status, body)
    if status < 0 then
      tmr.create():alarm(5000, tmr.ALARM_SINGLE, function()
        acquireLocationInfo()
      end)
    else
      local loc = sjson.decode(body)
      callback(loc)
    end
  end)
end

Events.ConnectedToInternet:subscribe(function()
  acquireLocationInfo(function(loc)
    local sign, hours, minutes = string.match(loc.geobytestimezone, "^([%+%-]?)(%d%d):(%d%d)$")
    offset = tonumber(hours) * 3600 + tonumber(minutes) * 60
    if sign and sign == "-" then
      offset = -offset
    end
    locationAcquired = true
    Events.LocationAcquired:post()
  end)
end)

Events.LocationAcquired:subscribe(function()
  syncTime()
end)

return Time