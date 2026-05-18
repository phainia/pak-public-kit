require("UnLuaEx")
local Delegate = require("Utils.Delegate")
local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = require("NewRoco.Modules.Core.NPC.Box.BP_NPCBox_C")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local PetUtils = require("NewRoco.Utils.PetUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BP_NPCBox_PetType_C = Base:Extend("BP_NPCBox_PetType_C")

function BP_NPCBox_PetType_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self.LockSmith = false
  self.UnlockFinishDelegate = Delegate()
  self.UnLockSkillBackup = false
  self.is_unlocking = false
end

function BP_NPCBox_PetType_C:OnVisible()
  Base.OnVisible(self)
  self:UpdateLockEffect()
end

function BP_NPCBox_PetType_C:SetSceneCharacter(sceneCharacter)
  Base.SetSceneCharacter(self, sceneCharacter)
  if self.resourceLoaded and sceneCharacter then
    self:UpdateLockEffect()
  end
end

function BP_NPCBox_PetType_C:UpdateLockEffect()
  if self:GetUnLock() then
    self.NRCChildActor:SetVisibility(false)
  else
    self.NRCChildActor:SetVisibility(true)
    local EffectActor = self.NRCChildActor:GetChildActor()
    if EffectActor then
      if EffectActor.SetTotalNum then
        EffectActor:SetTotalNum(self:GetLockTime())
      end
      if EffectActor.SetPetType then
        EffectActor:SetPetType(self:ToPetType(self:GetUnlockType()))
      end
      if EffectActor.ForceLock then
        EffectActor:ForceLock()
      end
    end
  end
end

function BP_NPCBox_PetType_C:LoadLockEffect()
  self:UpdateLockEffect()
  return self.NRCChildActor
end

function BP_NPCBox_PetType_C:PlayUnlockEffect(lockNum)
  Log.Debug("BP_NPCBox_PetType_C:PlayUnlockEffect 0 :", lockNum, self:GetDebugInfo())
  if not self.NRCChildActor then
    Log.Error("ViewNPCBase:PlayUnlockEffect \232\175\149\229\155\190\230\146\173\230\148\190\232\167\163\233\148\129\230\149\136\230\158\156\230\151\182\230\137\190\228\184\141\229\136\176\231\187\132\228\187\182")
    return
  end
  if lockNum > 0 then
    return
  end
  self.RocoSkill:StopCurrentSkill()
  if not self.is_unlocking then
    self:UnlockBox()
  end
end

function BP_NPCBox_PetType_C:UnlockBox()
  Log.Debug("BP_NPCBox_PetType_C:UnlockBox")
  local effectActor = self.NRCChildActor:GetChildActor()
  if effectActor and UE.UObject.IsValid(effectActor) and effectActor.UnlockOnce then
    effectActor:UnlockOnce()
  end
end

function BP_NPCBox_PetType_C:GetUnlockType()
  local SceneCharacter = self.sceneCharacter
  if not SceneCharacter then
    return Enum.SkillDamType.SDT_INVALID
  end
  local InteractionComponent = SceneCharacter.InteractionComponent
  if not InteractionComponent then
    return Enum.SkillDamType.SDT_INVALID
  end
  local PetAction
  local Options = InteractionComponent:GetAllOptions()
  for _, Option in pairs(Options) do
    local Action = Option:GetPetActionConf()
    if Action then
      PetAction = Action
      break
    end
  end
  if not PetAction then
    return Enum.SkillDamType.SDT_INVALID
  end
  local PetActionType = PetAction.action_type or Enum.ActionType.ACT_NONE
  if PetActionType == Enum.ActionType.ACT_NONE then
    return Enum.SkillDamType.SDT_INVALID
  end
  local ID = tonumber(PetAction.action_param1)
  local pet_interaction = ID and ID > 0 and _G.DataConfigManager:GetPetInteractionConf(ID) or false
  local PetTypeName = PetAction.action_param1
  if pet_interaction then
    PetTypeName = pet_interaction.action_param1
  end
  if string.IsNilOrEmpty(PetTypeName) then
    return Enum.SkillDamType.SDT_INVALID
  end
  return Enum.SkillDamType[PetTypeName] or Enum.SkillDamType.SDT_INVALID
end

function BP_NPCBox_PetType_C:ToPetType(SkillDamageType, Default)
  return PetUtils.DamageTypeToPetType(SkillDamageType, Default)
end

function BP_NPCBox_PetType_C:Recycle()
  if self.UnlockFinishDelegate then
    self.UnlockFinishDelegate:Clear()
  end
  ViewNPCBase.Recycle(self)
end

function BP_NPCBox_PetType_C:ResetOpenState()
  Base.ResetOpenState(self)
  self:UpdateLockEffect()
end

function BP_NPCBox_PetType_C:CanEnterThrowInter(Comp)
  return Comp == self.SkeletalMesh
end

function BP_NPCBox_PetType_C:CanThrowInter(throwInfo)
  if not self.sceneCharacter then
    return false
  end
  return not SceneUtils.IsLogicStatusUnlock(self.sceneCharacter)
end

return BP_NPCBox_PetType_C
