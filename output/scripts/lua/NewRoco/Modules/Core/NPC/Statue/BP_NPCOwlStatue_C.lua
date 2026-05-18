require("UnLuaEx")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local NpcOptionEvent = require("NewRoco.Modules.Core.NPC.Executors.NpcOptionEvent")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local BP_NPCOwlStatue_C = Base:Extend("BP_NPCOwlStatue_C")

function BP_NPCOwlStatue_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self._isActived = false
end

function BP_NPCOwlStatue_C:SetSceneCharacter(sceneCharacter)
  Base.SetSceneCharacter(self, sceneCharacter)
  self:SetActorHiddenInGame(false)
  if sceneCharacter then
    self:UpdateLookAtPos()
    self._initActived = SceneUtils.IsLogicStatusTriggerOn(sceneCharacter)
  else
    self._isActived = true
  end
end

function BP_NPCOwlStatue_C:UpdateData(ServerData, bIsReconnect)
  Base.UpdateData(self, ServerData, bIsReconnect)
  if not bIsReconnect then
    return
  end
  if not self.resourceLoaded then
    return
  end
  self:UpdateLookAtPos()
  self._initActived = SceneUtils.IsLogicStatusTriggerOn(self.sceneCharacter)
  self:OnOptionChange()
  self:RefreshABP()
  if self._initActived then
    self:ActiveLookAt()
  end
end

function BP_NPCOwlStatue_C:OnLoadResource()
  Base.OnLoadResource(self)
  if self.sceneCharacter then
    self:UpdateLookAtPos()
  end
  self:RefreshABP()
  if self._initActived then
    self:ActiveLookAt()
  end
end

function BP_NPCOwlStatue_C:OnFirstVisible()
  self:FirstVisible()
end

function BP_NPCOwlStatue_C:OnNPCHeadLookAt(pos)
  self._posLookAt = UE4.FVector(pos.x, pos.y, pos.z)
  self._rotLookAt = UE.UKismetMathLibrary.MakeRotFromX(self._posLookAt - self:Abs_K2_GetActorLocation())
  self:RefreshABP()
  if self:IsPosValid(self._posLookAt) then
    self:ActiveLookAt()
  end
end

function BP_NPCOwlStatue_C:OnOptionChange()
  local _, option = next(self.sceneCharacter.InteractionComponent._options)
  if not option then
    return
  end
  local Activated = not option:IsOptionEnable()
  if Activated and self:IsPosValid(self._posLookAt) then
    self:ActiveLookAt()
  end
end

function BP_NPCOwlStatue_C:UpdateLookAtPos()
  local pos = self.sceneCharacter.serverData.npc_base.related_npc_pos
  if pos then
    self._posLookAt = UE4.FVector(pos.x, pos.y, pos.z)
  else
    self._posLookAt = _G.FVectorZero
  end
  self._rotLookAt = UE.UKismetMathLibrary.MakeRotFromX(self._posLookAt - self:Abs_K2_GetActorLocation())
end

function BP_NPCOwlStatue_C:IsPosValid(pos)
  return 0 ~= pos.X or 0 ~= pos.Y or 0 ~= pos.Z
end

function BP_NPCOwlStatue_C:RefreshABP()
  if not self._rotLookAt then
    return
  end
  local AnimInstance = self:GetAnimInstance()
  if not AnimInstance then
    return
  end
  AnimInstance:InitABP(self._initActived, self._rotLookAt)
end

function BP_NPCOwlStatue_C:ActiveLookAt()
  if self._initActived then
    return
  end
  local AnimInstance = self:GetAnimInstance()
  if not AnimInstance then
    return
  end
  self._isActived = true
  AnimInstance:PlayActiveAnim()
  self.Overridden.ActiveLookAt(self)
end

function BP_NPCOwlStatue_C:OnAnimFinished()
  self.Overridden.OnAnimFinished(self)
  _G.DelayManager:DelaySeconds(2.0, self.PostLookAt, self)
end

function BP_NPCOwlStatue_C:PostLookAt()
  if self.sceneCharacter then
    _G.NRCModuleManager:DoCmd(_G.SceneModuleCmd.ConsumeCachedActorTag, self.sceneCharacter:GetServerId())
    self.sceneCharacter:SetNotDestroyFlag(false)
  end
end

function BP_NPCOwlStatue_C:GetAnimInstance()
  if not self.SkeletalMesh then
    return nil
  end
  return self.SkeletalMesh:GetAnimInstance()
end

function BP_NPCOwlStatue_C:ReceiveBeginPlay()
  Base.ReceiveBeginPlay(self)
end

function BP_NPCOwlStatue_C:Recycle()
  self:BPRecycle()
  self._isActived = false
  Base.Recycle(self)
end

return BP_NPCOwlStatue_C
