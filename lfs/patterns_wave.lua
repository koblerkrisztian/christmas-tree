local Wave = {}

local p

function Wave.start()
  if p then
    p:stop()
  end
  p = require("gen_pat_wave").new({h=240,s=192,v=Lights.INTENSITY}, 5)
  p:start()
end

function Wave.stop()
  if p then
    p:stop()
    p = nil
  end
end

function Wave.pause()
  if p then
    p:pause()
  end
end

function Wave.resume()
  if p then
    p:resume()
  end
end

return Wave
