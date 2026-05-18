require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.Box.BP_NPCBox_PetType_C")
local PetActionCommon = require("NewRoco.Modules.Core.NPC.Actions.PetActions.PetActionCommon")
local BP_NPCBox_PetType_Thorns_C = Base:Extend("BP_NPCBox_PetType_Thorns_C")

function BP_NPCBox_PetType_Thorns_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self.DestroyByFire = true
end

function BP_NPCBox_PetType_Thorns_C:Init()
  Log.Error("\232\191\153\228\184\170\232\141\134\230\163\152\229\174\157\231\174\177\229\186\148\232\175\165\229\183\178\231\187\143\232\162\171\229\186\159\229\188\131\228\186\134\230\137\141\229\175\185\239\188\140\230\131\179\229\134\141\230\172\161\229\144\175\231\148\168\232\175\183\230\143\144\233\156\128\230\177\130\239\188\140\229\174\131\229\129\156\230\173\162\231\187\180\230\138\164\228\186\134")
  Base.Init(self)
end

function BP_NPCBox_PetType_Thorns_C:LoadLockEffect()
  return self.NRCChildActor
end

function BP_NPCBox_PetType_Thorns_C:GetUnlockType()
  local SceneCharacter = self.sceneCharacter
  if not SceneCharacter then
    return Enum.SkillDamType.SDT_INVALID, nil
  end
  local InteractionComponent = SceneCharacter.InteractionComponent
  if not InteractionComponent then
    return Enum.SkillDamType.SDT_INVALID, nil
  end
  local PetAction
  for _, Option in pairs(InteractionComponent:GetAllOptions()) do
    local Action = Option:EnsurePetAction()
    if Action then
      PetAction = Action
      break
    end
  end
  if not PetAction then
    return Enum.SkillDamType.SDT_INVALID, nil
  end
  if PetAction:InstanceOf(PetActionCommon) then
    local Skill, Eco
    for _, Group in ipairs(PetAction.PetInteractionConf.pet_interact_group) do
      for _, Cond in ipairs(Group.interact_cond_group) do
        if Cond.interact_cond == Enum.PetInteract_cond.COND_SKILLDAM then
          if nil == Skill then
            Skill = Enum.SkillDamType[Cond.interact_cond_param[1]]
          end
        elseif Cond.interact_cond == Enum.PetInteract_cond.COND_ECOLOGY and nil == Eco then
          Eco = Enum.ECOLOGY_FEATURE[Cond.interact_cond_param[1]]
        end
      end
    end
    return Skill, Eco
  else
    local Config = PetAction.Config
    if not Config then
      return Enum.SkillDamType.SDT_INVALID, nil
    end
    local PetActionType = Config.action_type or Enum.ActionType.ACT_NONE
    if PetActionType == Enum.ActionType.ACT_NONE then
      return Enum.SkillDamType.SDT_INVALID, nil
    end
    local PetTypeName = Config.action_param1
    local PetEcoName = Config.action_param2
    if string.IsNilOrEmpty(PetTypeName) or string.IsNilOrEmpty(PetEcoName) then
      return Enum.SkillDamType.SDT_INVALID, nil
    end
    return Enum.SkillDamType[PetTypeName] or Enum.SkillDamType.SDT_INVALID, Enum.ECOLOGY_FEATURE[PetEcoName] or nil
  end
end

function BP_NPCBox_PetType_Thorns_C:UnlockBox(Name, Skill)
  local effectActor = self.lockEffectComp:GetChildActor()
  if effectActor.PlayDestroyEffect then
    effectActor:PlayDestroyEffect(self.DestroyByFire)
  end
end

function BP_NPCBox_PetType_Thorns_C:UseNewUnlockSkill(SkillPath)
  if not SkillPath then
    if self.UnLockSkillBackup then
      self.UnLockSkill = self.UnLockSkillBackup
    end
    return
  end
  local SoftClassPath = UE4.UKismetSystemLibrary.MakeSoftClassPath(SkillPath)
  local NewSkill
  if SoftClassPath then
    NewSkill = UE4.UKismetSystemLibrary.Conv_SoftClassPathToSoftClassRef(SoftClassPath)
  end
  if NewSkill then
    self.UnLockSkill = NewSkill
  end
end

return BP_NPCBox_PetType_Thorns_C
