local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionQueryTaggedFoliage = Base:Extend("LuaActionQueryTaggedFoliage")

function LuaActionQueryTaggedFoliage:OnStart(AIController)
  local owner = AIController
  self.owner = owner
  local InstanceTag = self.InstanceTag:GetValue(owner)
  local Radius = self.Radius:GetValue(owner)
  local Module = _G.NRCModuleManager:GetModule("NPCModule")
  local runner = Module.EQSManager:Get("TaggedFoliage")
  if not runner then
    self.owner = nil
    return self:Finish(false)
  end
  local request = runner:MakeRequest(nil, owner.Npc.viewObj)
  if not request then
    Log.Error("LuaActionQueryTaggedFoliage failed to create query request")
    self.owner = nil
    return self:Finish(false)
  end
  request:SetFloatParam("TaggedFoliage.SearchRadius", Radius)
  request:SetNameParam("TaggedFoliage.SearchTag", InstanceTag)
  local id, success = runner:StartQueryWithRequest(UE4.EEnvQueryRunMode.SingleResult, request, self, self.QueryCallback)
  if 0 == success then
    Log.Error("LuaActionQueryTaggedFoliage: Start Query failed")
    self.owner = nil
    return self:Finish(false)
  end
end

function LuaActionQueryTaggedFoliage:OnInterrupt()
  Log.Error("LuaActionQueryTaggedFoliage interrupted")
  self.owner = nil
end

function LuaActionQueryTaggedFoliage:QueryCallback(Result)
  if self.owner == nil then
    return
  end
  if not Result.bFinished or not Result.bSuccess then
    self.owner = nil
    return self:Finish(false)
  end
  local resultPos = Result.AbsoluteResultLocations:Get(1)
  local resultRot = Result.ResultRotations:Get(1)
  self.OutPosition:SetValue(self.owner, resultPos)
  self.OutRotation:SetValue(self.owner, UE.FVector(resultRot.Pitch, resultRot.Yaw, resultRot.Roll))
  self.owner = nil
  if GlobalConfig.DebugLuaBTree then
    UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), resultPos, 20, 4, UE4.FLinearColor(0, 1, 0, 1), 5, 2)
  end
  return self:Finish(true)
end

return LuaActionQueryTaggedFoliage
