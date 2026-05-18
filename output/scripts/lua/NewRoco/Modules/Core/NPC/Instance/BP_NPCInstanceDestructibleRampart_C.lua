local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local MiniGameModuleEvent = require("NewRoco.Modules.System.MiniGame.MiniGameModuleEvent")
require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.Instance.BP_NPCInstanceMechanismBase_C")
local BP_NPCInstanceDestructibleRampart_C = Base:Extend("BP_NPCInstanceDestructibleRampart_C")

function BP_NPCInstanceDestructibleRampart_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self.HoldPerform = false
end

function BP_NPCInstanceDestructibleRampart_C:ReceiveBeginPlay()
  Base.ReceiveBeginPlay(self)
  _G.NRCEventCenter:RegisterEvent("BP_NPCInstanceDestructibleRampart_C", self, SceneEvent.OnEnterSceneFinishNtyAckEnd, self.OnEnterSceneFinishNtyAckEnd)
  _G.NRCEventCenter:RegisterEvent("BP_NPCInstanceDestructibleRampart_C", self, MiniGameModuleEvent.End, self.MiniGameEnd)
end

function BP_NPCInstanceDestructibleRampart_C:OnEnterSceneFinishNtyAckEnd()
  self:ResetStatus()
end

function BP_NPCInstanceDestructibleRampart_C:MiniGameEnd()
  local SceneCharacter = self.sceneCharacter
  SceneCharacter:SetNotDestroyFlag(false)
end

function BP_NPCInstanceDestructibleRampart_C:ReceiveEndPlay()
  Base.ReceiveEndPlay(self)
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnEnterSceneFinishNtyAckEnd, self.OnEnterSceneFinishNtyAckEnd)
  _G.NRCEventCenter:UnRegisterEvent(self, MiniGameModuleEvent.End, self.MiniGameEnd)
end

function BP_NPCInstanceDestructibleRampart_C:ResetStatus()
  local SceneCharacter = self.sceneCharacter
  local InterComp = SceneCharacter and SceneCharacter.InteractionComponent
  local bBroken = InterComp and table.len(InterComp:GetAllOptions()) > 0 and not InterComp:GetMainAction() or false
  if bBroken then
    self:SetActorHiddenInGame(true)
    self:SetActorNeedTick(false)
    self:SetActorEnableCollision(false)
    if self.Beam then
      self.Beam:SetHiddenInGame(true)
    end
    local ChildActorComps = self:K2_GetComponentsByClass(UE.UChildActorComponent)
    for _, Comp in tpairs(ChildActorComps) do
      Comp:NRCDestroyChildActor()
    end
    local PrimComps = self:K2_GetComponentsByClass(UE.UPrimitiveComponent)
    for _, Comp in tpairs(PrimComps) do
      Comp:SetCollisionEnabled(UE.ECollisionEnabled.NoCollision)
    end
  else
    self:SetActorHiddenInGame(false)
    self:SetActorEnableCollision(true)
    if SceneCharacter then
      SceneCharacter:SetNotDestroyFlag(true)
    end
    if self.Beam then
      self.Beam:SetHiddenInGame(false)
    end
  end
end

function BP_NPCInstanceDestructibleRampart_C:UpdateState(bInit)
  self.InitFlag = bInit
  if self.HoldPerform then
    return
  end
  if not self.Fracture then
    Base.UpdateState(self, bInit)
  end
end

function BP_NPCInstanceDestructibleRampart_C:TurnOffCollision()
end

function BP_NPCInstanceDestructibleRampart_C:CanEnterThrowInter(Comp)
  if not Comp then
    return false
  end
  return Comp == self.Wall or Comp == self.BoxMid or Comp == self.BoxDown
end

function BP_NPCInstanceDestructibleRampart_C:GetHalfHeight()
  return 0
end

function BP_NPCInstanceDestructibleRampart_C:ApplyPhysicsHit(hitPos, hitVec)
  if self.Fracture and type(self.Fracture) == "function" then
    self:Fracture(hitPos, hitVec)
    if self.Beam then
      self.Beam:SetHiddenInGame(true)
    end
    _G.NRCAudioManager:PlaySound3DWithActor(10020006, self, "BP_NPCInstanceDestructibleRampart", false, false)
  end
end

function BP_NPCInstanceDestructibleRampart_C:OnLoadResource()
  Base.OnLoadResource(self)
  self:ResetStatus()
end

function BP_NPCInstanceDestructibleRampart_C:OnVisible()
  Base.OnVisible(self)
  self:ResetStatus()
end

function BP_NPCInstanceDestructibleRampart_C:OnLeaveBattle()
  Base.OnLeaveBattle(self)
  self:ResetStatus()
end

function BP_NPCInstanceDestructibleRampart_C:SetCollisionEnableInternal(Flag)
end

return BP_NPCInstanceDestructibleRampart_C
