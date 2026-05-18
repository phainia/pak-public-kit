local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local LuaServiceUpdateFollowPos = Base:Extend("LuaServiceUpdateFollowPos")

function LuaServiceUpdateFollowPos:OnStart(OwnerController)
  local owner = OwnerController
  local actorFollowTo = self:TryGetFollowActor(owner)
  if nil == actorFollowTo or not actorFollowTo.GetActorTransform then
    self.offsetDir = nil
    return
  end
  local prevPlayerPos = actorFollowTo:GetActorLocation()
  local prevOwnerPos
  if self.StartFollowInfo and self.StartFollowInfo.type == LuaParamType.Vector then
    prevOwnerPos = self.StartFollowInfo:GetValue(owner)
  elseif self.StartFollowInfo and self.StartFollowInfo.type == LuaParamType.Object then
    prevOwnerPos = self.StartFollowInfo:GetValue(owner):GetActorLocation()
  else
    Log.Warning("LuaServiceUpdateFollowPos : `StartFollowInfo` type error, should be Vector/Object, use owner's pos for default")
    prevOwnerPos = owner.Npc:GetActorLocation()
  end
  self.offsetDir = prevOwnerPos - prevPlayerPos
  local prevPlayerTrans = actorFollowTo:GetActorTransform()
  self.offsetDir = prevPlayerTrans:InverseTransformVectorNoScale(self.offsetDir)
end

function LuaServiceUpdateFollowPos:OnUpdateService(OwnerController, DeltaTime, ...)
  local owner = OwnerController
  if self.offsetDir == nil then
    return
  end
  local actorFollowTo = self:TryGetFollowActor(owner)
  if nil == actorFollowTo or not actorFollowTo.GetActorTransform then
    return
  end
  local newTransform = actorFollowTo:GetActorTransform()
  local finalOffsetDir = newTransform:TransformVectorNoScale(self.offsetDir)
  self.FollowPos:SetValue(owner, newTransform.Translation + finalOffsetDir)
  if GlobalConfig.DebugLuaBTree then
    UE4.UKismetSystemLibrary.Abs_DrawDebugLine(owner, owner.Npc:GetActorLocation(), newTransform.Translation + finalOffsetDir, UE4.FLinearColor(1, 1, 0), 0.5, 1)
    UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(owner, newTransform.Translation + finalOffsetDir, 20, 10, UE4.FLinearColor(1, 1, 0), 0.5, 1)
  end
end

function LuaServiceUpdateFollowPos:OnEnd(OwnerController)
  self.offsetDir = nil
end

function LuaServiceUpdateFollowPos:TryGetFollowActor(owner)
  local actorFollowTo
  if self.ActorFollowTo then
    actorFollowTo = self.ActorFollowTo:GetValue(owner)
  else
    actorFollowTo = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  end
  return actorFollowTo
end

return LuaServiceUpdateFollowPos
