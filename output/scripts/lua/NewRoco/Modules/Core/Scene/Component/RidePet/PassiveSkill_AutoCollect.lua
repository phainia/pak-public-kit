local Base = require("NewRoco.Modules.Core.Scene.Component.RidePet.PassiveSkill_EnvBase")
local EnvSystemModuleEvent = reload("NewRoco.Modules.System.EnvSystem.EnvSystemModuleEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local PassiveSkill_AutoCollect = Base:Extend("PassiveSkill_AutoCollect")

function PassiveSkill_AutoCollect:Ctor(owner, config)
  Base.Ctor(self, owner, config)
  self.tempActorArr = UE.TArray(UE.AActor)
  self.overlapRadius = tonumber(config.param_1)
  self.vitalityNum = tonumber(config.param_2)
  self.collectType = self:ParseCollectType(config.param_3)
  Log.DebugFormat("PassiveSkill_AutoCollect:Ctor self.overlapRadius[%f],self.vitalityNum[%f],self.collectType %s", self.overlapRadius, self.vitalityNum, config.param_3)
end

function PassiveSkill_AutoCollect:ParseCollectType(strType)
  local outType = ProtoEnum.RidePetCollect.RPC_FLOWER
  if "RPC_FLOWER" == strType then
    outType = ProtoEnum.RidePetCollect.RPC_FLOWER
  end
  return outType
end

function PassiveSkill_AutoCollect:OnSetViewObj()
  if UE.UObject.IsValid(self.owner.viewObj) and self.owner.owner and self.owner.owner.isLocal then
    self.bStarted = true
    _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.SyncStatusImmediately)
  else
    self.bStarted = false
  end
end

function PassiveSkill_AutoCollect:GetOverlapRadius()
  if self:ParseCollectType() == ProtoEnum.RidePetCollect.RPC_FLOWER and self.owner and self.owner.TalentEffectMap and self.owner.TalentEffectMap[Enum.PetTalentEffect.PTE_MOUNT_GATHER_RANGE_RATIO] then
    statComponent = self.owner.owner.statComponent
    if statComponent then
      local ratio = statComponent:GetValue(StatType.PTE_MOUNT_GATHER_RANGE_RATIO)
      if ratio and ratio > 0 then
        return self.overlapRadius * ratio
      end
    end
  end
  return self.overlapRadius
end

function PassiveSkill_AutoCollect:Update(deltaTime)
  if self.bStarted then
    local pos = self.owner.viewObj:K2_GetActorLocation()
    self.tempActorArr:Clear()
    UE.URocoMapUtils.SphereOverlapMultiByChannel(UE4Helper.GetCurrentWorld(), self.tempActorArr, pos, UE.ECollisionChannel.Collectable, self:GetOverlapRadius())
    for k, v in tpairs(self.tempActorArr) do
      self:TryCollect(v)
    end
  end
end

function PassiveSkill_AutoCollect:TryCollect(npcActor)
  local sceneNpc = npcActor and npcActor.sceneCharacter
  if sceneNpc and sceneNpc.InteractionComponent and not sceneNpc:IsHidden() then
    local collected = sceneNpc.InteractionComponent:CollectByType(self.collectType)
  end
end

function PassiveSkill_AutoCollect:Stop()
  self.bStarted = false
end

return PassiveSkill_AutoCollect
