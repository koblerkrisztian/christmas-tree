Settings = {}

local SETTINGS_FILE = "settings.json"

local store = {}

local function load()
  local fd = file.open(SETTINGS_FILE, "r")
  if not fd then
    print("Reading settings file failed")
    return
  end
  -- NOTE: this can only handle settings files smaller than 1024 bytes
  --       if they grow larger, streaming should be used
  local content = fd:read()
  fd:close()
  store = sjson.decode(content)
end

local function save()
  local fd = file.open(SETTINGS_FILE, "w+")
  if not fd then
    print("Open settings for save failed")
    return
  end
  success, json = pcall(sjson.encode, store)
  if not success then
    print("Json encode failed")
    fd:close()
    return
  end
  fd:write(json)
  fd:close()
end

function Settings.init()
  load()
end

function Settings.getLastPatter()
  return store.lastPattern
end

function Settings.setLastPattern(pattern)
  if store.lastPattern ~= pattern then
    store.lastPattern = pattern
    save()
  end
end

Settings.init()

return Settings