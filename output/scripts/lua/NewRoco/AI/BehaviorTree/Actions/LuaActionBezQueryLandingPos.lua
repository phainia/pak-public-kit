local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionBezQueryLandingPos = Base:Extend("LuaActionBezQueryLandingPos")

function LuaActionBezQueryLandingPos:OnStart(AIController)
  local owner = AIController
  self.owner = owner
  local Module = _G.NRCModuleManager:GetModule("NPCModule")
  local runner = Module.EQSManager:Get("FlyLandingPos")
  local result = runner:StartQuery(UE4.EEnvQueryRunMode.SingleResult, nil, owner.Npc.viewObj, self, self.FoundLandingPos)
  if result < 0 then
    Log.Error("StartQuery LandingPos failed")
    return self:Finish(false)
  end
end

function LuaActionBezQueryLandingPos:OnInterrupt()
  Log.Error("StartQuery LandingPos interrupted")
  self.owner = nil
end

function LuaActionBezQueryLandingPos:FoundLandingPos(Runner)
  if self.owner == nil then
    return
  end
  if not Runner.bFinished or not Runner.bSuccess then
    Log.Debug("LuaActionBezQueryLandingPos: Find LandingPos failed")
    self.owner = nil
    return self:Finish(false)
  end
  local result = Runner.AbsoluteResultLocations:Get(1)
  self.OutPos:SetValue(self.owner, result)
  self.owner = nil
  if GlobalConfig.DebugLuaBTree then
    UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), result, 20, 4, UE4.FLinearColor(0, 1, 0, 1), 5, 2)
  end
  return self:Finish(true)
end

return LuaActionBezQueryLandingPos
