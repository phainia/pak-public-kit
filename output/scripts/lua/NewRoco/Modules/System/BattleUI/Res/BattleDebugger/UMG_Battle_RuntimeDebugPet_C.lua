local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local UMG_Battle_RuntimeDebugPet_C = Base:Extend("UMG_Battle_RuntimeDebugPet_C")

function UMG_Battle_RuntimeDebugPet_C:OnConstruct()
  self.debugControl = _G.BattleManager.battleRuntimeData.battleDebugControl
  self.NRCButtonAddSkill.OnClicked:Add(self, self.OnAddSkillClick)
end

function UMG_Battle_RuntimeDebugPet_C:OnDestruct()
  self.NRCButtonAddSkill.OnClicked:Remove(self, self.OnAddSkillClick)
end

function UMG_Battle_RuntimeDebugPet_C:OnItemUpdate(_data, datalist, index)
  self.skillPanel = _data.panel
  self.petTeam = _data.team
  self.index = index
  self.teamPets = self.debugControl:GetInBattlePetList(BattleEnum.Team.ENUM_TEAM, true)
  self.enemyPets = self.debugControl:GetInBattlePetList(BattleEnum.Team.ENUM_ENEMY, false)
  if self.petTeam == BattleEnum.Team.ENUM_ENEMY then
    self.teamPets = self.debugControl:GetInBattlePetList(BattleEnum.Team.ENUM_ENEMY, true)
    self.enemyPets = self.debugControl:GetInBattlePetList(BattleEnum.Team.ENUM_TEAM, false)
  end
  self.skillInfos = {}
  self:AddPetOption(true)
  self:AddPetOption(false)
  self:OnAddSkillClick()
  local battleType = self.debugControl.cacheBattleParams.battleType
  local showAdd = battleType == self.debugControl:GetBattleType("BossFight") and self.petTeam == BattleEnum.Team.ENUM_TEAM
  self.NRCButtonAddSkill:SetVisibility(showAdd and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Hidden)
  self.NRCTextPetIdx:SetText("\229\174\160\231\137\169" .. self.index)
end

function UMG_Battle_RuntimeDebugPet_C:AddPetOption(isTeam)
  local petMap = isTeam and self.teamPets or self.enemyPets
  local comboBox = isTeam and self.ComboBoxStringPetList or self.ComboBoxStringTarget
  comboBox:ClearOptions()
  local curIndex = 0
  local curSelectPet = 0
  for i, v in pairs(petMap) do
    if isTeam then
      if v.pos == self.index then
        curSelectPet = curIndex
      end
    elseif v:IsInBattle() then
      curSelectPet = curIndex
    end
    curIndex = curIndex + 1
    comboBox:AddOption(i)
  end
  comboBox:SetSelectedIndex(curSelectPet)
end

function UMG_Battle_RuntimeDebugPet_C:OnAddSkillClick()
  local skillInfo = {
    team = self.petTeam,
    pos = self.index,
    skillPanel = self.skillPanel
  }
  table.insert(self.skillInfos, skillInfo)
  self.List_Skill:InitList(self.skillInfos)
end

function UMG_Battle_RuntimeDebugPet_C:GetSkillParam()
  local teamPetInfos = self.ComboBoxStringPetList:GetSelectedOption()
  local teamPetId = self.teamPets[teamPetInfos].guid
  local enemyPetInfos = self.ComboBoxStringTarget:GetSelectedOption()
  local enemyPetId = self.enemyPets[enemyPetInfos].guid
  local skillOrder = tonumber(self.EditableTextBoxOrder:GetText()) or 1
  for i, v in ipairs(self.skillInfos) do
    v.petGuid = teamPetId
    v.skillTargetId = enemyPetId
    v.playOrder = skillOrder
    local childItem = self.List_Skill:GetItemByIndex(i - 1)
    local skillId, attackCount, isKill = childItem:GetSkillCmd()
    v.skillId = skillId
    v.attackCount = attackCount
    v.isKill = isKill
    v.skillPanel = nil
  end
  return self.skillInfos
end

function UMG_Battle_RuntimeDebugPet_C:GetCurSelectSkill()
  local childItem = self.List_Skill:GetItemByIndex(0)
  local skillId, attackCount, isKill = childItem:GetSkillCmd()
  return skillId
end

return UMG_Battle_RuntimeDebugPet_C
