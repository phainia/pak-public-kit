local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local LuaServiceUpdateTod = Base:Extend("LuaServiceUpdateTod")
local EnvSystem = _G.NRCModuleManager:GetModule("EnvSystemModule")

function LuaServiceUpdateTod:OnUpdateService(OwnerController, DeltaTime, ...)
  local aiController = OwnerController
  local curTime = math.floor(EnvSystem:GetCurrentTime() / 3600.0)
  if curTime ~= self.HourTime then
    self.OutTime:SetValue(aiController, curTime)
    self.HourTime = curTime
  end
end

return LuaServiceUpdateTod
