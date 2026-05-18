local WeeklyChallengeBattleModuleEvent = require("NewRoco.Modules.System.WeeklyChallengeBattle.WeeklyChallengeBattleModuleEvent")
local UMG_PreviousTeams1_C = _G.NRCPanelBase:Extend("UMG_PreviousTeams1_C")

function UMG_PreviousTeams1_C:OnConstruct()
  self:OnAddEventListener()
  self:_InitPanel()
end

function UMG_PreviousTeams1_C:SetParent(parent)
  self.parent = parent
end

function UMG_PreviousTeams1_C:OnActive()
end

function UMG_PreviousTeams1_C:OnDeactive()
end

function UMG_PreviousTeams1_C:OnAddEventListener()
  self:AddButtonListener(self.NRCButton1, self.OnTeamListButtonClick)
  self:AddButtonListener(self.BloodBtn_1, self.OnClickTeamSkillButtonClick)
  self:AddButtonListener(self.Exchange_2.btnLevelUp, self.OnClickTeamSkillButtonClick)
  self:AddButtonListener(self.BloodBtn, self.OnClickTeamSkillButtonClick)
  self:AddButtonListener(self.Exchange.btnLevelUp, self.OnClickTeamSkillButtonClick)
  self:AddButtonListener(self.Button_96, self.OnClickTeamSkillButtonClick)
  self:AddButtonListener(self.Exchange_1.btnLevelUp, self.OnClickTeamSkillButtonClick)
end

function UMG_PreviousTeams1_C:OnTeamListButtonClick()
  _G.NRCAudioManager:PlaySound2DAuto(40008035, "UMG_PreviousTeams1_C:OnTeamListButtonClick")
  if self.parent.bIsEventOOD then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.weekly_challenge_text_24)
    return
  end
  if self.bClicked then
    return
  end
  self.bClicked = true
  self.parent:OpenTeamEditPanel()
end

function UMG_PreviousTeams1_C:OnClickTeamSkillButtonClick()
  if self.parent.bIsEventOOD then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.weekly_challenge_text_24)
    return
  end
  local gidList = {}
  local currentTeamList = _G.NRCModuleManager:DoCmd(_G.WeeklyChallengeBattleModuleCmd.GetCurrentTeamPetList)
  for k, v in ipairs(currentTeamList) do
    if v.gid and 0 ~= v.gid then
      table.insert(gidList, v.gid)
    end
  end
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenBloodLineMagic, _G.Enum.PlayerTeamType.PTT_PVE_WEEKLY_CHALLENGE_FIGHT, 0, gidList)
end

function UMG_PreviousTeams1_C:_InitPanel()
  self.Switcher:SetActiveWidgetIndex(1)
  self:SetPetTeamList(_G.NRCModuleManager:DoCmd(_G.WeeklyChallengeBattleModuleCmd.GetCurrentTeamPetList))
end

function UMG_PreviousTeams1_C:SetPetTeamList(petList)
  self.PetList:InitGridView(petList)
  local totalCheerUpPoint = 0
  for k, v in ipairs(petList) do
    if v.gid and 0 ~= v.gid and v.cheer_point_info and #v.cheer_point_info > 0 then
      for k1, v1 in ipairs(v.cheer_point_info) do
        totalCheerUpPoint = totalCheerUpPoint + v1.cheer_point
      end
    end
  end
  self.Headline_1:SetText(string.format("x%s", totalCheerUpPoint))
  local oldCheerUpPoint = 0
  self.WeeklyChallengeEventActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, Enum.ActivityType.ATP_WEEKLY_CHALLENGE_EVENT)
  if self.WeeklyChallengeEventActivityObject and self.WeeklyChallengeEventActivityObject[1] then
    oldCheerUpPoint = self.WeeklyChallengeEventActivityObject[1]:GetFinishWeeklyChallengeEventSchedule()
  end
  if totalCheerUpPoint <= oldCheerUpPoint then
    self.Headline_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("AF3D3EFF"))
  else
    self.Headline_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("000000FF"))
  end
end

function UMG_PreviousTeams1_C:SetSkill(skill)
  if not skill or 0 == skill then
    self.Switcher:SetActiveWidgetIndex(1)
  else
    self.Switcher:SetActiveWidgetIndex(0)
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(skill)
    if bagItemConf then
      self.Icon:SetPath(bagItemConf.icon)
    end
  end
end

function UMG_PreviousTeams1_C:SetPanelData(petList, skill)
  self:SetPetTeamList(petList)
  self:SetSkill(skill)
end

function UMG_PreviousTeams1_C:_SetCheerUpCount(count)
  if count <= 0 then
    return
  end
  local finalStr = string.format("x%d", count)
  self.Headline_1:SetText(finalStr)
end

function UMG_PreviousTeams1_C:UpdatePetData(newPetData)
  for i = 0, self.PetList:GetItemCount() - 1 do
    local item = self.PetList:GetItemByIndex(i)
    if item then
      item:UpdatePetData(newPetData)
    end
  end
end

return UMG_PreviousTeams1_C
