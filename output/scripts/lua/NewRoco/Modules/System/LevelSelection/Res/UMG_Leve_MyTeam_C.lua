local LevelSelectionEnum = require("NewRoco.Modules.System.LevelSelection.LevelSelectionEnum")
local LevelSelectionModuleEvent = require("NewRoco.Modules.System.LevelSelection.LevelSelectionModuleEvent")
local UMG_Leve_MyTeam_C = _G.NRCViewBase:Extend("UMG_Leve_MyTeam_C")

function UMG_Leve_MyTeam_C:OnActive()
end

function UMG_Leve_MyTeam_C:OnDeactive()
end

function UMG_Leve_MyTeam_C:OnAddEventListener()
  self:AddButtonListener(self.BloodBtn, self.OpenBloodLineMagic)
  self:AddButtonListener(self.BloodBtn_1, self.OnClickBloodBtn_1)
  self:AddButtonListener(self.NRCButton1, self.OnClickNRCButton)
  self:AddButtonListener(self.Exchange_1.btnLevelUp, self.OpenBloodLineMagic)
  self:AddButtonListener(self.Button_96, self.OpenBloodLineMagic)
end

function UMG_Leve_MyTeam_C:OnConstruct()
  self.PetList:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:OnAddEventListener()
end

function UMG_Leve_MyTeam_C:OnDestruct()
end

function UMG_Leve_MyTeam_C:OnAnimationFinished(anim)
end

function UMG_Leve_MyTeam_C:UnSelectTeam()
  self.BlackHood1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.panelType == LevelSelectionEnum.BattlePanel.Silhouette then
    self:PlayAnimation(self.normal1)
  else
    self:PlayAnimation(self.normal2)
  end
end

function UMG_Leve_MyTeam_C:ClearItemSelect()
  local count = self.PetList:GetItemCount()
  for i = 0, count - 1 do
    local item = self.PetList:GetItemByIndex(i)
    if not item.isHaveDatat then
      item:ResetSelectNull()
    end
  end
end

function UMG_Leve_MyTeam_C:SelectTeam()
  self.BlackHood1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:ClearItemSelect()
  if self.panelType == LevelSelectionEnum.BattlePanel.Silhouette then
    self:PlayAnimation(self.Selcet1)
  else
    self:PlayAnimation(self.Selcet2)
  end
end

function UMG_Leve_MyTeam_C:ShowCover()
  self.BlackHood1:SetVisibility(UE4.ESlateVisibility.Visible)
  if self.panelType == LevelSelectionEnum.BattlePanel.Silhouette then
    self:PlayAnimation(self.Cover1)
  else
    self:PlayAnimation(self.Cover2)
  end
end

function UMG_Leve_MyTeam_C:OnClickNRCButton()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_Leve_BattleSilhouette_C:OnClickCharacterButton")
  self:DispatchEvent(LevelSelectionModuleEvent.OnOpenBattleTeamView)
end

function UMG_Leve_MyTeam_C:EnableTeamButton(isEnable)
  self.NRCButton1:SetVisibility(isEnable and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
end

function UMG_Leve_MyTeam_C:SetTeamType(types, paneType, activeId)
  self.SkillIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdSetCurSelectRuleBuffId, 0)
  self.List:InitGridView(types)
  self.panelType = paneType
  self.RuleBuffIds = {}
  self.BloodBtn_1:SetVisibility(self.panelType == LevelSelectionEnum.BattlePanel.Silhouette and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.Visible)
  if self.panelType == LevelSelectionEnum.BattlePanel.Silhouette then
    self:PlayAnimation(self.normal1)
  elseif self.panelType == LevelSelectionEnum.BattlePanel.Boss then
    local baseId = _G.DataConfigManager:GetActivityConf(activeId).base_id[1]
    local bossChallengeEventConf = _G.DataConfigManager:GetBossChallengeEventConf(baseId)
    self.RuleBuffIds = bossChallengeEventConf.buff
    self.ActivityId = activeId
    self:PlayAnimation(self.normal2)
  end
end

function UMG_Leve_MyTeam_C:SetTeamBuffRule(ruleId)
  if ruleId then
    self:OnUpdateRuleBuff(ruleId)
  end
end

function UMG_Leve_MyTeam_C:OnChangeSelectPet(petGidDic)
  if self.curTeamInfo then
    local teams = {}
    for i = 1, 6 do
      local gid = petGidDic[i]
      table.insert(teams, {pet_gid = gid})
    end
    self.curTeamInfo.teams = teams
    self:OnConfirmSelected(self.curTeamInfo)
  end
end

function UMG_Leve_MyTeam_C:OnUpdateBloodMagic(newTeamInfo, tabIdx)
  if self.curTeamInfo then
    local oldTeams = self.curTeamInfo.teams
    newTeamInfo.teams = oldTeams
  end
  if 1 == tabIdx then
    self:OnConfirmSelected(newTeamInfo)
  else
    self:ShowPetList(newTeamInfo)
  end
end

function UMG_Leve_MyTeam_C:OnUpdateCurSelectInfo()
  local teamInfos = _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdGetAllTeamDatas)
  for i = 1, #teamInfos do
    if teamInfos[i].type == self.curTeamInfo.type and teamInfos[i].idx == self.curTeamInfo.idx then
      self.curTeamInfo = teamInfos[i]
      break
    end
  end
  self:OnConfirmSelected(self.curTeamInfo)
end

function UMG_Leve_MyTeam_C:OnUpdateRuleBuff(id)
  self.curSelectRuleId = id
  local path = _G.DataConfigManager:GetBattleRuleConf(id).icon
  self.SkillIcon:SetVisibility(UE4.ESlateVisibility.Visible)
  self.SkillIcon:SetPath(path)
end

function UMG_Leve_MyTeam_C:OnConfirmSelected(teamInfo)
  self.curTeamInfo = teamInfo
  self.Headline:SetText(LuaText.challenge_text_20)
  local teams = teamInfo.teams
  local magicGid = teamInfo.magicGid
  local lightItemIdx = 0
  if nil == magicGid or 0 == magicGid then
    self.Switcher:SetActiveWidgetIndex(1)
  else
    self.Switcher:SetActiveWidgetIndex(0)
    local bagItemData = _G.NRCModeManager:DoCmd(_G.BagModuleCmd.GetBagItemByGid, magicGid)
    local bagitemConf = _G.DataConfigManager:GetBagItemConf(bagItemData.id)
    self.Icon:SetPath(bagitemConf.icon)
  end
  for i, team in pairs(teams) do
    if 0 == team.pet_gid then
      lightItemIdx = i
      break
    end
  end
  self.PetList:SetVisibility(UE4.ESlateVisibility.Visible)
  if #teams < 6 then
    for i = #teams + 1, 6 do
      table.insert(teams, {pet_gid = 0})
    end
  end
  self.PetList:InitGridView(teams)
  if lightItemIdx > 0 then
    self.isSave = false
    self.PetList:GetItemByIndex(lightItemIdx - 1):ShowSelectNull()
  elseif not self.isSave then
    self.isSave = true
    _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdSaveBattleTeam, teamInfo)
  end
end

function UMG_Leve_MyTeam_C:OnLeaveStorehouseSaved()
  _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdSetCacheTeamData, self.curTeamInfo)
  _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdSaveBattleTeam, self.curTeamInfo)
end

function UMG_Leve_MyTeam_C:ShowPetList(teamInfo)
  self.curTeamInfo = teamInfo
  self.Headline:SetText(LuaText.challenge_text_20)
  local teams = {}
  for i = 1, 6 do
    if teamInfo and i <= #teamInfo.teams then
      table.insert(teams, teamInfo.teams[i])
    else
      table.insert(teams, {pet_gid = 0})
    end
  end
  local magicGid = teamInfo.magicGid
  if nil == magicGid or 0 == magicGid then
    self.Switcher:SetActiveWidgetIndex(1)
  else
    self.Switcher:SetActiveWidgetIndex(0)
    local bagItemData = _G.NRCModeManager:DoCmd(_G.BagModuleCmd.GetBagItemByGid, magicGid)
    local bagitemConf = _G.DataConfigManager:GetBagItemConf(bagItemData.id)
    self.Icon:SetPath(bagitemConf.icon)
  end
  self.PetList:InitGridView(teams)
  self.curTeamInfo = teamInfo
  self.curTeamInfo.teams = teams
end

function UMG_Leve_MyTeam_C:OpenBloodLineMagic()
  local items = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemArrayByType, _G.Enum.BagItemType.BI_PLAYERSKILL)
  if items and #items > 0 then
    local gidList = {}
    for i = 1, #self.curTeamInfo.teams do
      table.insert(gidList, self.curTeamInfo.teams[i].pet_gid)
    end
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenBloodLineMagic, self.curTeamInfo.type, self.curTeamInfo.idx, gidList)
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.challenge_text_10)
  end
end

function UMG_Leve_MyTeam_C:OnClickBloodBtn()
end

function UMG_Leve_MyTeam_C:OnClickBloodBtn_1()
  _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdOpenRulePanel, self.ActivityId, self.RuleBuffIds)
end

function UMG_Leve_MyTeam_C:OnSwitcherSwitcher(SwitcherIndex)
  self.Switcher:SetActiveWidgetIndex(SwitcherIndex)
end

return UMG_Leve_MyTeam_C
