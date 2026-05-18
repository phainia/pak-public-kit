local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local PVPRankedMatchModuleEvent = require("NewRoco.Modules.System.PVPQualifier.PVPRankedMatchModuleEvent")
local PVPRankedMatchModuleUtils = require("NewRoco.Modules.System.PVPQualifier.PVPRankedMatchModuleUtils")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local UMG_Activity_ShiningWeekend_C = Base:Extend("UMG_Activity_ShiningWeekend_C")

function UMG_Activity_ShiningWeekend_C:BindUIElements()
  local uiElements = {}
  uiElements.desireActivityType = Enum.ActivityType.ATP_PET_WEEKEND_CHALLENGE
  uiElements.title = self.Text_Title
  uiElements.titleLabelIcon = self.Label
  uiElements.titleLabelText = self.NRCText_61
  uiElements.promptText = self.Text_Describe
  uiElements.bgImage = self.BG
  uiElements.timeRemainingRoot = self.time
  uiElements.timeRemaining = self.Text_TimeRemaining
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  return uiElements
end

function UMG_Activity_ShiningWeekend_C:OnConstruct()
  Base.OnConstruct(self)
  local activity_id = self.activityInst:GetActivityId()
  local weekendChallengeConf = _G.DataConfigManager:GetActivityWeekendChallengeConf(activity_id)
  if 0 == weekendChallengeConf.entry_a then
    self.BtnRecommendedlineup:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if 0 == weekendChallengeConf.entry_b then
    self.BtnTimePet:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:OnAddEventListener()
  self.RedDot:SetupKey(214, {activity_id, 1})
  self.redPointNew:SetupKey(214, {activity_id, 2})
  self.NRCText_1:SetText(_G.LuaText.weekend_challenge_1)
  self.NRCText_166:SetText(_G.LuaText.weekend_challenge_2)
end

function UMG_Activity_ShiningWeekend_C:OnAddEventListener()
  self:AddButtonListener(self.TraceBtn.btnLevelUp, self.OpenBattleManual)
  self:AddButtonListener(self.BtnRecommendedlineup, self.OpenRecommendedTeam)
  self:AddButtonListener(self.BtnTimePet, self.OpenTimePet)
  _G.NRCEventCenter:RegisterEvent("UMG_Activity_ShiningWeekend_C", self, PVPRankedMatchModuleEvent.ShiningWeekendGetTrialPet, self.OpenPanel)
  _G.NRCEventCenter:RegisterEvent("UMG_Activity_ShiningWeekend_C", self, ActivityModuleEvent.SendShiningWeekendTLog, self.SendTLog)
end

function UMG_Activity_ShiningWeekend_C:OnRemoveEventListener()
  self:RemoveButtonListener(self.TraceBtn.btnLevelUp)
  self:RemoveButtonListener(self.BtnRecommendedlineup)
  self:RemoveButtonListener(self.BtnTimePet)
  _G.NRCEventCenter:UnRegisterEvent(self, PVPRankedMatchModuleEvent.ShiningWeekendGetTrialPet, self.OpenPanel)
  _G.NRCEventCenter:UnRegisterEvent(self, ActivityModuleEvent.SendShiningWeekendTLog, self.SendTLog)
end

function UMG_Activity_ShiningWeekend_C:OpenBattleManual()
  _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.OpenMagicManualByIndex, "MMT_PVP")
  self:SendTLog(3)
end

function UMG_Activity_ShiningWeekend_C:OpenRecommendedTeam()
  local trialPets = _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdGetTrialPets)
  if trialPets then
    self:OpenRecommendedTeamPanel()
  else
    self.openIndex = 1
    _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.ShiningWeekendGetTrialPet)
  end
  self:CheckAndEraseRedPoint(1)
end

function UMG_Activity_ShiningWeekend_C:OpenPanel()
  if 1 == self.openIndex then
    self:OpenRecommendedTeamPanel()
  elseif 2 == self.openIndex then
    self:OpenTimePetPanel()
  end
end

function UMG_Activity_ShiningWeekend_C:OpenRecommendedTeamPanel()
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenFriendPetTeamPanel, Enum.PlayerTeamType.PTT_PVP_BATTLE_4, self.activityInst:GetActivityId())
  self:SendTLog(1)
end

function UMG_Activity_ShiningWeekend_C:OpenTimePet()
  local trialPets = _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdGetTrialPets)
  if trialPets then
    self:OpenTimePetPanel()
  else
    self.openIndex = 2
    _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.ShiningWeekendGetTrialPet)
  end
  self:CheckAndEraseRedPoint(2)
end

function UMG_Activity_ShiningWeekend_C:OpenTimePetPanel()
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenTrialPVPPet)
  self:SendTLog(2)
end

function UMG_Activity_ShiningWeekend_C:OnDisable()
  Base.OnDisable(self)
  self:CheckAndEraseRedPoint(0)
end

function UMG_Activity_ShiningWeekend_C:CheckAndEraseRedPoint(index)
  if (1 == index or 0 == index) and self.RedDot:IsRed() then
    self.RedDot:EraseRedPoint(false)
  end
  if (2 == index or 0 == index) and self.redPointNew:IsRed() then
    self.redPointNew:EraseRedPoint(false)
  end
end

function UMG_Activity_ShiningWeekend_C:SendTLog(InteractionID)
  local key = "WeekendChallengeInteractionLog"
  local roleDataStr = _G.GEMPostManager:GetRoleDataForTLog()
  local RankStar = PVPRankedMatchModuleUtils.GetSelfRankStar()
  if not RankStar then
    return
  end
  local curRankConf = PVPRankedMatchModuleUtils.GetPvpRankConf(RankStar)
  local RankName = curRankConf.id
  local value = string.format("%s|%s|%d|%d", key, roleDataStr, RankName, InteractionID)
  _G.GEMPostManager:SendNRCTLog(key, value)
end

function UMG_Activity_ShiningWeekend_C:OnDestruct()
  self:OnRemoveEventListener()
end

return UMG_Activity_ShiningWeekend_C
