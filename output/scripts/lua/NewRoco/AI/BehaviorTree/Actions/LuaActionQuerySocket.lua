local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionQuerySocket = Base:Extend("LuaActionQuerySocket")

function LuaActionQuerySocket:OnStart(AIController)
  local owner = AIController
  self.owner = owner
  local SocketTag = self.SocketTag:GetValue(owner)
  local Radius = self.Radius:GetValue(owner)
  local NotUseTrace = false
  if self.NotUseTrace then
    NotUseTrace = self.NotUseTrace:GetValue(owner)
  end
  local Module = _G.NRCModuleManager:GetModule("NPCModule")
  local runner = Module.EQSManager:Get("StaticMeshSocket")
  if NotUseTrace then
    runner = Module.EQSManager:Get("StaticMeshSocketNoTrace")
  end
  local request = runner:MakeRequest(nil, owner.Npc.viewObj)
  request:SetFloatParam("StaticMeshSocket.SearchRadius", Radius)
  request:SetNameParam("StaticMeshSocket.SearchSocketTag", SocketTag)
  if self.VecDotMin then
    request:SetFloatParam("Dot.FloatValueMin", math.clamp(self.VecDotMin:GetValue(owner), -1, 1))
  end
  if self.VecDotMax then
    request:SetFloatParam("Dot.FloatValueMax", math.clamp(self.VecDotMax:GetValue(owner), -1, 1))
  end
  if self.DistMin then
    request:SetFloatParam("Distance.FloatValueMin", math.max(self.DistMin:GetValue(owner), 0))
  end
  local id, success = runner:StartQueryWithRequest(UE4.EEnvQueryRunMode.SingleResult, request, self, self.QueryCallback)
  if 0 == success then
    Log.Error("LuaActionQuerySocket: Start Query failed")
    self.owner = nil
    return self:Finish(false)
  end
end

function LuaActionQuerySocket:OnInterrupt()
  Log.Error("LuaActionQuerySocket interrupted")
  self.owner = nil
end

function LuaActionQuerySocket:QueryCallback(Result)
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
  self.OutRotation:SetValue(self.owner, resultRot)
  self.owner = nil
  if GlobalConfig.DebugLuaBTree then
    UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), resultPos, 20, 4, UE4.FLinearColor(0, 1, 0, 1), 5, 2)
  end
  return self:Finish(true)
end

return LuaActionQuerySocket
