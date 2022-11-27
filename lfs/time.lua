require("events")

Time = {}

local defaultOffset = 3600

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

function Time.getOffset()
  return offset
end

function Time.setAlarm(hours, minutes, callback)
  if not timeSynced then return false end

  local seconds = hours * 3600 + minutes * 60
  local utcSeconds = (seconds - offset) % (24 * 3600)
  local utcHours = utcSeconds / 3600
  local utcMinutes = (utcSeconds / 60) % 60
  cron.schedule(string.format("%d %d * * *", utcMinutes, utcHours), function(e)
    callback()
  end)

  return true
end

local syncTime
local function retrySync()
  tmr.create():alarm(5000, tmr.ALARM_SINGLE, function()
    syncTime()
  end)
end

function printTime()
  local t = Time.getLocalTime()
  print(string.format("%d.%d.%d %d:%d:%d (%d)", t.year, t.mon, t.day, t.hour, t.min, t.sec, t.wday))
end

function syncTime()
  local success = pcall(function()
    sntp.sync(nil, function(sec, usec, server, info)
      timeSynced = true
      Events.TimeSynced:post()
      printTime()
    end,
    function(error, info)
      print('time sync failed!', error, info)
      retrySync()
    end,
    1)
  end)
  if not success then retrySync() end
end

local function acquireLocationInfo(callback)
  http.get("http://gd.geobytes.com/GetCityDetails",
  nil,
  function(status, body)
    if status < 0 then
      tmr.create():alarm(5000, tmr.ALARM_SINGLE, function()
        acquireLocationInfo(callback)
      end)
    else
      local loc = sjson.decode(body)
      callback(loc)
    end
  end)
end

local function parseOffset(loc)
  if not loc or not loc.geobytestimezone then
    return defaultOffset
  end

  local sign, hours, minutes = string.match(loc.geobytestimezone, "^([%+%-]?)(%d%d):(%d%d)$")
  local offset = tonumber(hours) * 3600 + tonumber(minutes) * 60
  if sign and sign == "-" then
    offset = -offset
  end
  return offset
end

Events.ConnectedToInternet:subscribe(function()
  acquireLocationInfo(function(loc)
    offset = parseOffset(loc)
    locationAcquired = true
    Events.LocationAcquired:post()
  end)
end)

Events.LocationAcquired:subscribe(function()
  syncTime()
end)

return Time