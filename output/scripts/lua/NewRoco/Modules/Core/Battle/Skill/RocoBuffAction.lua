local RocoSkillAction = require("NewRoco.Modules.Core.Battle.Skill.RocoSkillAction")
local WorldCombatSkillComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatSkillComponent")
local WorldCombatBuffComponent = require("NewRoco.Modules.Core.Scene.Component.WorldCombat.WorldCombatBuffComponent")
local ProtoMessage = require("Data.PB.ProtoMessage")
local Base = RocoSkillAction
local RocoBuffAction = Base:Extend("RocoBuffAction")

function RocoBuffAction:Ctor()
  self.buffUniqueId = 1
end

function RocoBuffAction:GetUniqueId()
  local tempId = self.buffUniqueId
  self.buffUniqueId = self.buffUniqueId + 1
  return tempId
end

function RocoBuffAction:OnActionStart()
  if not self:IsSkillEditor() and _G.WorldCombatModuleCmd and not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    return
  end
  local ActorInfo = ProtoMessage:newActorInfo_Npc()
  local buff_info = ProtoMessage:newBuffInfo()
  buff_info.buff_cfg_id = self.BuffId
  buff_info.id = self:GetUniqueId()
  self.currentBuffId = buff_info.id
  ActorInfo.buff_info = ProtoMessage:newActorInfo_Buffs()
  ActorInfo.buff_info.buff_infos = {}
  table.insert(ActorInfo.buff_info.buff_infos, buff_info)
  local skillObj = self:GetSkill()
  local caster = skillObj:GetCaster().sceneCharacter
  if not caster then
    return
  end
  caster:EnsureComponent(WorldCombatBuffComponent):UpdateData(ActorInfo, false)
end

function RocoBuffAction:OnActionEnd()
  if not self:IsSkillEditor() and _G.WorldCombatModuleCmd and not _G.NRCModuleManager:DoCmd(_G.WorldCombatModuleCmd.IsInOfflineMode) then
    return
  end
  local skillObj = self:GetSkill()
  local caster = skillObj:GetCaster().sceneCharacter
  if not caster then
    return
  end
  local BuffInfo = ProtoMessage:newSpaceAct_BuffInfoChange()
  BuffInfo.actor_id = caster:GetServerId()
  BuffInfo.removed_buff_id = self.currentBuffId
  BuffInfo.changed_buff_info = nil
  caster:EnsureComponent(WorldCombatBuffComponent):OnBuffChanges(BuffInfo)
end

return RocoBuffAction
