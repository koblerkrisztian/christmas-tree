require("events")
require("button")
require("lights")

Network = {}

local telnet = nil
Network.TELNET_PORT = 2323

function checkInternet()
  net.dns.resolve("google.com", function(sk, ip)
    if ip then
      Events.ConnectedToInternet:post()
    else
      print("No internet")
      tmr.create():alarm(5000, tmr.ALARM_SINGLE, function()
        checkInternet()
      end)
    end
  end)
end

local function hasSavedAp()
  local ap = wifi.sta.getapinfo()
  if ap == nil or ap[1] == nil or ap[1].ssid == nil or ap[1].ssid == "" then
    return false
  else
    return true
  end
end

local function needEndUserSetup()
  if not hasSavedAp() or Button.isPressed() then
    return true
  else
    return false
  end
end

local function startEndUserSetup()
  Lights.startSpecialPattern("endUserSetup")
  wifi.sta.clearconfig()
  enduser_setup.start(function()
    print("Enduser setup finshed successfully")
    Lights.startSpecialPattern("endUserSetupSuccess")
  end,
  function(err, str)
    print("Enduser setup error #" .. err .. ": " .. str)
    Lights.startSpecialPattern("endUserSetupFail")
  end)
end

local function setUpTelnet()
  Events.WifiConnected:subscribe(function()
    if not telnet then
      telnet = require("telnet")
    end
    telnet:open(Network.TELNET_PORT)
  end)

  Events.WifiDisconnected:subscribe(function()
    if telnet then
      telnet:close()
    end
  end)
end

local function setUpMdns()
  Events.WifiConnected:subscribe(function()
    mdns.register("christmastree", {
      description = "Christmas Tree",
      service = "telnet",
      port = 2323
    })
  end)
end

function Network.init()
  -- Register WiFi Station event callbacks
  wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
    print("Connection to AP("..T.SSID..") established!")
  end)
  wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
    print("Wifi connection is ready! IP address is: "..T.IP)
    Events.WifiConnected:post()
    checkInternet()
  end)
  wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
    if T.reason == wifi.eventmon.reason.ASSOC_LEAVE then
      --the station has disassociated from a previously connected AP
      return
    end
    -- total_tries: how many times the station will attempt to connect to the AP. Should consider AP reboot duration.
    local total_tries = 5
    print("\nWiFi connection to AP("..T.SSID..") has failed!")
  
    --There are many possible disconnect reasons, the following iterates through
    --the list and returns the string corresponding to the disconnect reason.
    for key,val in pairs(wifi.eventmon.reason) do
      if val == T.reason then
        print("Disconnect reason: "..val.."("..key..")")
        break
      end
    end

    Events.WifiDisconnected:post()
  end)

  setUpTelnet()
  setUpMdns()

  if needEndUserSetup() then
    startEndUserSetup()
  else
    print("Connecting to WiFi access point...")
    wifi.sta.connect()
  end
end

Network.init()

return Network
