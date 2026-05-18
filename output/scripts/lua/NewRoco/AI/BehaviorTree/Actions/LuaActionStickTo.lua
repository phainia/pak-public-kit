local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local SocketSnapComponent = require("NewRoco.Modules.Core.Scene.Component.Movement.SocketSnapComponent")
local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionStickTo = Base:Extend("LuaActionAnimPauseOrResume")
local MaxStickRange = _G.DataConfigManager:GetNpcGlobalConfig("max_stick_range", true).num or 500

function LuaActionStickTo:OnStart(owner, ...)
  local UseSocket = self.UseSocket:GetValue(owner)
  local TargetObject = self.TargetObject:GetValue(owner)
  local TargetSocket = self.TargetSocket:GetValue(owner)
  local StickSpeed = self.StickSpeed:GetValue(owner)
  local LoopAnimation = self.LoopAnimation:GetValue(owner)
  local Translate = self.Translate and self.Translate:GetValue(owner)
  local Rotate = self.Rotate:GetValue(owner)
  if not TargetObject or TargetObject.isDestroy then
    return self:Finish(false)
  end
  local AIComp = TargetObject.AIComponent
  if AIComp and AIComp:IsLockedForReason(AIDefines.LockReason.CATCH) then
    return self:Finish(false)
  end
  if owner.Npc:GetActorLocation():Dist(TargetObject:GetActorLocation()) > MaxStickRange then
    return self:Finish(false)
  end
  local snapComp = owner.Npc:EnsureComponent(SocketSnapComponent)
  snapComp:SetRelativeRotation(Rotate.X, Rotate.Y, Rotate.Z)
  if Translate then
    snapComp:GetRelativeTransformRef().Translation = Translate
  end
  local success = snapComp:SnapTo(TargetObject, UseSocket, TargetSocket, StickSpeed, LoopAnimation)
  if not success then
    return self:Finish(false)
  end
  self.snapComp = snapComp
  if TargetObject.config then
    self.registered = true
    self.TargetObjectRef = TargetObject
    TargetObject:AddEventListener(self, NPCModuleEvent.On_NPC_Destroy, self.OnTargetDestroy)
    TargetObject:AddEventListener(self, NPCModuleEvent.On_NPC_LEAVE, self.OnTargetBeCatched)
    TargetObject:AddEventListener(self, NPCModuleEvent.CatchStart, self.OnTargetBeCatched)
  end
end

function LuaActionStickTo:OnInterrupt(owner, Finalized)
  if Finalized then
    return
  end
  self:UnRegisterTarget()
  local snapComp = self.snapComp or owner.Npc:EnsureComponent(SocketSnapComponent)
  if snapComp then
    snapComp:CancelSnap()
  end
  self.snapComp = nil
end

function LuaActionStickTo:OnTargetBeCatched()
  self:UnRegisterTarget()
  if self.snapComp then
    self.snapComp:CancelSnap()
    self.snapComp = nil
  end
  self:Finish(true)
end

function LuaActionStickTo:OnTargetDestroy()
  self.snapComp = nil
  self:UnRegisterTarget()
  self:Finish(false)
end

function LuaActionStickTo:UnRegisterTarget()
  if self.registered and self.TargetObjectRef then
    local TargetObj = self.TargetObjectRef
    if TargetObj then
      TargetObj:RemoveEventListener(self, NPCModuleEvent.On_NPC_Destroy, self.OnTargetDestroy)
      TargetObj:RemoveEventListener(self, NPCModuleEvent.On_NPC_LEAVE, self.OnTargetBeCatched)
      TargetObj:RemoveEventListener(self, NPCModuleEvent.CatchStart, self.OnTargetBeCatched)
    end
    self.TargetObjectRef = nil
    self.registered = false
  end
end

return LuaActionStickTo
