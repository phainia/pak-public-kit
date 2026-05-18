require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local PetUtils = require("NewRoco.Utils.PetUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local ResQueue = require("NewRoco.Utils.ResQueue")
local BP_NPCStoneTypeBox_C = Base:Extend("BP_NPCStoneTypeBox_C")
local TriggerNiagaraPathMap = {
  [_G.Enum.SkillDamType.SDT_NONE] = "",
  [_G.Enum.SkillDamType.SDT_COMMON] = "/Game/ArtRes/Effects/Particle/Scene/StonePillar/NS_Scene_StonePillar_Trigger_Nor.NS_Scene_StonePillar_Trigger_Nor",
  [_G.Enum.SkillDamType.SDT_GRASS] = "",
  [_G.Enum.SkillDamType.SDT_FIRE] = "",
  [_G.Enum.SkillDamType.SDT_WATER] = "",
  [_G.Enum.SkillDamType.SDT_LIGHT] = "",
  [_G.Enum.SkillDamType.SDT_EARTH] = "",
  [_G.Enum.SkillDamType.SDT_STONE] = "",
  [_G.Enum.SkillDamType.SDT_ICE] = "",
  [_G.Enum.SkillDamType.SDT_DRAGON] = "",
  [_G.Enum.SkillDamType.SDT_ELECTRIC] = "",
  [_G.Enum.SkillDamType.SDT_TOXIC] = "",
  [_G.Enum.SkillDamType.SDT_INSECT] = "",
  [_G.Enum.SkillDamType.SDT_FIGHT] = "",
  [_G.Enum.SkillDamType.SDT_WING] = "/Game/ArtRes/Effects/Particle/Scene/StonePillar/NS_Scene_StonePillar_Trigger_Win.NS_Scene_StonePillar_Trigger_Win",
  [_G.Enum.SkillDamType.SDT_MOE] = "",
  [_G.Enum.SkillDamType.SDT_GHOST] = "/Game/ArtRes/Effects/Particle/Scene/StonePillar/NS_Scene_StonePillar_Trigger_Gho.NS_Scene_StonePillar_Trigger_Gho",
  [_G.Enum.SkillDamType.SDT_DEMON] = "",
  [_G.Enum.SkillDamType.SDT_MECHANIC] = "",
  [_G.Enum.SkillDamType.SDT_PHANTOM] = ""
}

function BP_NPCStoneTypeBox_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_NPCStoneTypeBox_C:Init()
  Base.Init(self)
  self.IsActivate = false
end

function BP_NPCStoneTypeBox_C:GetUnlockType()
  local SceneCharacter = self.sceneCharacter
  if not SceneCharacter then
    return _G.Enum.SkillDamType.SDT_NONE
  end
  local serverData = SceneCharacter.serverData
  local property_type_info = serverData.property_type_info
  local Types = property_type_info and property_type_info.property_types
  if Types then
    if #Types > 0 then
      return Types[1]
    else
      Log.Warning("why property_type_info is none", serverData.base.name)
      return _G.Enum.SkillDamType.SDT_NONE
    end
  end
  local InteractionComponent = SceneCharacter.InteractionComponent
  if not InteractionComponent then
    return _G.Enum.SkillDamType.SDT_NONE
  end
  local PetAction
  for _, Option in pairs(InteractionComponent:GetAllOptions()) do
    local Action = Option:GetPetActionConf()
    if Action then
      PetAction = Action
      break
    end
  end
  if not PetAction then
    return _G.Enum.SkillDamType.SDT_NONE
  end
  local PetActionType = PetAction.action_type or _G.Enum.ActionType.ACT_NONE
  if PetActionType == _G.Enum.ActionType.ACT_NONE then
    return _G.Enum.SkillDamType.SDT_NONE
  end
  local ID = tonumber(PetAction.action_param1)
  local pet_interaction = ID and ID > 0 and _G.DataConfigManager:GetPetInteractionConf(ID) or false
  if pet_interaction then
    local interact_cond_group = pet_interaction.interact_cond_group
    for _, config in pairs(interact_cond_group or {}) do
      if config.interact_cond == _G.Enum.PetInteract_cond.COND_SKILLDAM then
        for _, Type in ipairs(config.interact_cond_param) do
          return _G.Enum.SkillDamType[Type]
        end
      end
    end
  end
  return _G.Enum.SkillDamType.SDT_NONE
end

function BP_NPCStoneTypeBox_C:ToPetType(SkillDamageType, Default)
  return PetUtils.DamageTypeToPetType(SkillDamageType, Default)
end

function BP_NPCStoneTypeBox_C:CanEnterThrowInter(Comp)
  return Comp == self.Capsule
end

function BP_NPCStoneTypeBox_C:CanThrowInter(throwInfo)
  if not self.sceneCharacter then
    return false
  end
  return not SceneUtils.IsLogicStatusUnlock(self.sceneCharacter)
end

function BP_NPCStoneTypeBox_C:OnVisible()
  Base.OnVisible(self)
  self:UpdateState(true)
end

function BP_NPCStoneTypeBox_C:UpdateType()
  if self.IsActivate then
    return
  end
  self:SetDamageType(self:GetUnlockType())
end

function BP_NPCStoneTypeBox_C:UpdateState(immediate)
  if not self.sceneCharacter then
    return
  end
  if self.is_unlocking then
    return
  end
  self:SetDamageType(self:GetUnlockType())
  if SceneUtils.IsLogicStatusUnlock(self.sceneCharacter) then
    self:Activate(immediate)
  else
    self:DeActivate(immediate)
  end
end

function BP_NPCStoneTypeBox_C:Activate(immediate, triggerUp, triggerDown, trigger)
  if immediate then
    self.NRCNiagaraSystemRing:SetVisibility(false, true)
    self.NRCNiagaraSystemIcon:SetVisibility(true, true)
  else
    self.NRCNiagaraSystemIcon:SetVisibility(true, true)
  end
  self:SetStoneActive(true, immediate, triggerUp, triggerDown, trigger)
  self.IsActivate = true
end

function BP_NPCStoneTypeBox_C:DeActivate(immediate)
  if immediate then
    self.NRCNiagaraSystemRing:SetVisibility(true, true)
    self.NRCNiagaraSystemIcon:SetVisibility(false, true)
  else
    self.NRCNiagaraSystemRing:SetVisibility(true, true)
    self.NRCNiagaraSystemIcon:SetVisibility(false, true)
  end
  self:SetStoneActive(false, immediate)
  self.IsActivate = false
end

function BP_NPCStoneTypeBox_C:UnlockBox()
  local loadQueue = ResQueue(30, ResQueue.RunMode.Concurrent, _G.PriorityEnum.Active_Player_Action)
  loadQueue:InsertObject("UnlockNiagaraTriggerUp", "/Game/ArtRes/Effects/Particle/Scene/StonePillar/NS_Scene_StonePillar_Trigger_Up.NS_Scene_StonePillar_Trigger_Up")
  loadQueue:InsertObject("UnlockNiagaraTriggerDown", "/Game/ArtRes/Effects/Particle/Scene/StonePillar/NS_Scene_StonePillar_Trigger_Down.NS_Scene_StonePillar_Trigger_Down")
  loadQueue:InsertObject("UnlockNiagaraTrigger", self:GetTriggerNiagaraPath())
  loadQueue:StartLoad(self, self.OnUnlockLoadFinished)
end

function BP_NPCStoneTypeBox_C:OnUnlockLoadFinished(Queue, Success)
  if not Success then
    Log.Error("Why Load failed")
  end
  self:Activate(false, Queue:GetResObject("UnlockNiagaraTriggerUp"):Get(), Queue:GetResObject("UnlockNiagaraTriggerDown"):Get(), Queue:GetResObject("UnlockNiagaraTrigger"):Get())
end

function BP_NPCStoneTypeBox_C:GetTriggerNiagaraPath()
  local path = TriggerNiagaraPathMap[self:GetUnlockType()]
  if "" == path then
    path = TriggerNiagaraPathMap[_G.Enum.SkillDamType.SDT_COMMON]
  end
  return path
end

function BP_NPCStoneTypeBox_C:SetDamageType(damageType)
  self:SetPetType(self:ToPetType(damageType))
end

return BP_NPCStoneTypeBox_C
