local UMG_CollegeRanking_C = _G.NRCPanelBase:Extend("UMG_CollegeRanking_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")

function UMG_CollegeRanking_C:OnConstruct()
  self:AddButtonListener(self.btnCloseRenamePanel, self.OnBtnClose)
  self:AddButtonListener(self.DetailsBtn.btnLevelUp, self.OnBtnDetails)
  self:AddButtonListener(self.Button, self.OnClickShowRankTips1)
  self:AddButtonListener(self.Button_1, self.OnClickShowRankTips2)
  self:AddButtonListener(self.Button_2, self.OnClickShowRankTips3)
  self.Button.OnPressed:Add(self, self.OnRankBtn1Pressed)
  self.Button.OnReleased:Add(self, self.OnRankBtn1Released)
  self.Button_1.OnPressed:Add(self, self.OnRankBtn2Pressed)
  self.Button_1.OnReleased:Add(self, self.OnRankBtn2Released)
  self.Button_2.OnPressed:Add(self, self.OnRankBtn3Pressed)
  self.Button_2.OnReleased:Add(self, self.OnRankBtn3Released)
  self:RegisterEvent(self, ActivityModuleEvent.MixActivityFactionRankDataChange, self.OnMixActivityFactionRankDataChange)
end

function UMG_CollegeRanking_C:OnDestruct()
  self.Button.OnPressed:Clear()
  self.Button.OnReleased:Clear()
  self.Button_1.OnPressed:Clear()
  self.Button_1.OnReleased:Clear()
  self.Button_2.OnPressed:Clear()
  self.Button_2.OnReleased:Clear()
  self:UnRegisterEvent(self, ActivityModuleEvent.MixActivityFactionRankDataChange)
end

function UMG_CollegeRanking_C:OnActive(activityInst)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41400002, "UMG_CollegeRanking_C:OnActive")
  self.activityInst = activityInst
  self.rankRewardsData = {}
  local factionConf = activityInst:GetFactionConf()
  local rankData = {
    "1",
    "2",
    "3/4"
  }
  local rankRewards
  if factionConf then
    rankRewards = {
      factionConf.first_reward,
      factionConf.second_reward,
      factionConf.third_reward,
      factionConf.fourth_reward
    }
  else
    rankRewards = {}
  end
  for index, rankDesc in ipairs(rankData) do
    local nameCtrl = self["Name_" .. index]
    if nameCtrl then
      nameCtrl:SetText(string.format(_G.LuaText.Activity_CollegeGlory_RankList_num, rankDesc))
    end
    local rewardData = ActivityUtils.GetActivityRewardData(rankRewards[index], true)
    local iconCtrl = self["Icon_" .. index]
    if iconCtrl then
      iconCtrl:SetPath(rewardData.showIcon)
    end
    local colorCtrl = self["Color_" .. index]
    if colorCtrl then
      ActivityUtils.SetRewardItemQuality(colorCtrl, rewardData.itemQuality)
    end
    self.rankRewardsData[index] = rewardData
  end
  self:OnMixActivityFactionRankDataChange(activityInst, activityInst:GetFactionRankData())
  self:LoadAnimation(0)
end

function UMG_CollegeRanking_C:OnMixActivityFactionRankDataChange(activityInst, factionRankData)
  if nil ~= activityInst and activityInst == self.activityInst then
    local factionTypeNames = {}
    local factionConf = activityInst:GetFactionConf()
    if factionConf then
      for _, group in ipairs(factionConf.faction_group or {}) do
        factionTypeNames[group.faction_type] = group.name
      end
    end
    local items = {}
    for _, rankData in ipairs(factionRankData or {}) do
      local rankItem = {}
      rankItem.name = factionTypeNames[rankData.faction]
      rankItem.score = rankData.score
      table.insert(items, rankItem)
    end
    self.RankingList:InitGridView(items)
  end
end

function UMG_CollegeRanking_C:OnBtnClose()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41400003, "UMG_CollegeRanking_C:OnActive")
  self:LoadAnimation(2)
end

function UMG_CollegeRanking_C:OnPcClose()
  self:OnBtnClose()
end

function UMG_CollegeRanking_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:OnClose()
  end
end

function UMG_CollegeRanking_C:OnBtnDetails()
  local activityInst = self.activityInst
  local factionCfg = activityInst and activityInst:GetFactionConf()
  if factionCfg then
    local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
    local Context = DialogContext()
    Context:SetTitle(factionCfg.rank_list_tips_title):SetContent(factionCfg.rank_list_tips):SetContentTextJustify(UE4.ETextJustify.Center):SetMode(DialogContext.Mode.NotBtn):SetClickAnywhereClose(true)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenLongDialog, Context)
  else
    Log.Error("UMG_CollegeRanking_C:OnBtnDetails: factionCfg is nil")
  end
end

function UMG_CollegeRanking_C:OnClickShowRankTips(index)
  local rewardData = self.rankRewardsData[index]
  if rewardData then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, rewardData.itemId, rewardData.itemType)
  end
end

function UMG_CollegeRanking_C:OnClickShowRankTips1()
  self:OnClickShowRankTips(1)
end

function UMG_CollegeRanking_C:OnClickShowRankTips2()
  self:OnClickShowRankTips(2)
end

function UMG_CollegeRanking_C:OnClickShowRankTips3()
  self:OnClickShowRankTips(3)
end

function UMG_CollegeRanking_C:OnRankBtn1Pressed()
  self:PlayPressedOrReleasedAnimation(true, self.Press_1, self.Up_1)
end

function UMG_CollegeRanking_C:OnRankBtn1Released()
  self:PlayPressedOrReleasedAnimation(false, self.Press_1, self.Up_1)
end

function UMG_CollegeRanking_C:OnRankBtn2Pressed()
  self:PlayPressedOrReleasedAnimation(true, self.Press_2, self.Up_2)
end

function UMG_CollegeRanking_C:OnRankBtn2Released()
  self:PlayPressedOrReleasedAnimation(false, self.Press_2, self.Up_2)
end

function UMG_CollegeRanking_C:OnRankBtn3Pressed()
  self:PlayPressedOrReleasedAnimation(true, self.Press_3, self.Up_3)
end

function UMG_CollegeRanking_C:OnRankBtn3Released()
  self:PlayPressedOrReleasedAnimation(false, self.Press_3, self.Up_3)
end

return UMG_CollegeRanking_C
