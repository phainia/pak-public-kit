local BehaviorConfBase = require("NewRoco.Modules.Core.Behavior.BehaviorConfBase")
local BehaviorConfFactory = {}
BehaviorConfFactory.Registry = {
  [Enum.BehaviorType.BT_OPEN_WORLDMAP] = require("NewRoco.Modules.Core.Behavior.BehaviorConfOpenWorldMap")
}

function BehaviorConfFactory:Get(Type, param)
  local BehaviorConf = BehaviorConfFactory.Registry[Type]
  Log.Dump(BehaviorConf, 2, "BehaviorConfFactory:Get")
  if BehaviorConf then
    return BehaviorConf(Type, param)
  else
    return BehaviorConfBase(Type, param)
  end
end

return BehaviorConfFactory
