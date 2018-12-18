local Fade = {}

local p

function Fade.start()
  if p then
    p:stop()
  end
  p = require("gen_pat_fade").new({h=120,s=210,v=Lights.INTENSITY}, 25)
  p:start()
end

function Fade.stop()
  if p then
    p:stop()
    p = nil
  end
end

function Fade.pause()
  if p then
    p:pause()
  end
end

function Fade.resume()
  if p then
    p:resume()
  end
end

return Fade
