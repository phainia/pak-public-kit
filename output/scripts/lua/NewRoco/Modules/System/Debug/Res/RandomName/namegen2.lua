local namegen = require("NewRoco.Modules.System.Debug.Res.RandomName.namegen")
local MaleNames = require("NewRoco.Modules.System.Debug.Res.RandomName.MaleNames")
local FemaleNames = require("NewRoco.Modules.System.Debug.Res.RandomName.FemaleNames")
local namegen2 = NRCClass()

function namegen2:Ctor()
  math.randomseed(os.time())
end

function namegen2:generate(bool)
  local dict = {}
  if 1 == bool then
    dict = MaleNames
  else
    dict = FemaleNames
  end
  local alpha = dict:GetData(math.random(1, dict:GetDataCount()))
  local num = tostring(math.random(0, 99999))
  if "John" == alpha then
    num = "117"
  end
  return alpha .. num
end

return namegen2
