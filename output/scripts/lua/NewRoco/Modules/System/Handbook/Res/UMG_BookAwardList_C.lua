local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BookAwardList_C = Base:Extend("UMG_BookAwardList_C")

function UMG_BookAwardList_C:OnConstruct()
end

function UMG_BookAwardList_C:OnDestruct()
  self.btnFightValue.OnClicked:Remove(self, self.OnClickbtnFightValue)
  self.Btn_Icon.OnClicked:Remove(self, self.OnClickBtn_Icon)
end

function UMG_BookAwardList_C:OnItemUpdate(_data, datalist, index)
  Log.Dump(_data, 6, "UMG_BookAwardList_C:OnItemUpdate")
  self.data = _data
  self:OnAddEventListener()
  self:SetAwardListInfo()
end

function UMG_BookAwardList_C:OnAddEventListener()
  self.btnFightValue.OnClicked:Add(self, self.OnClickbtnFightValue)
  self.Btn_Icon.OnClicked:Add(self, self.OnClickBtn_Icon)
end

function UMG_BookAwardList_C:SetAwardListInfo()
  local data = self.data
  self:SetBasicInfo()
  self:SetAwardBtn()
  self.Selected:SetVisibility(UE4.ESlateVisibility.Hidden)
  if data.StudyLvList then
    self.CatchHardLv:InitGridView(data.StudyLvList)
  end
  if data.award_type == _G.Enum.PetHandbookAward.AWARD_ITEM then
    self.TextBG:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NumText:SetVisibility(UE4.ESlateVisibility.Visible)
    self.ItemIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.ItemIcon:SetPath(NRCUtils:FormatConfIconPath(data.itemCfg.icon, _G.UIIconPath.BagItemPath))
    self.NumText:SetText(data.AwardNum)
    self.Name:SetText(data.itemCfg.name)
    self:SetQuality(data.itemCfg.item_quality)
  elseif data.award_type == _G.Enum.PetHandbookAward.AWARD_SKILL then
    self.ItemIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.ItemIcon:SetPath(NRCUtils:FormatConfIconPath(data.skillConfig.icon, _G.UIIconPath.SkillIconPath))
    local skilltext = string.format("[%s]", data.skillConfig.name)
    self.Name:SetText(skilltext)
  elseif data.award_type == _G.Enum.PetHandbookAward.AWARD_CATCH then
    self.SkillsIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.SkillsIcon:SetPath(data.CatchCfg.icon)
    self.Name:SetText(data.CatchCfg.name)
  elseif data.award_type == _G.Enum.PetHandbookAward.AWARD_ROLE_EXP then
    self.SkillsIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.SkillsIcon:SetPath(data.CatchCfg.icon)
    self.Name:SetText(data.CatchCfg.name)
  end
end

function UMG_BookAwardList_C:SetAwardBtn()
  local data = self.data
  local IsUnLock = self.data.IsUnLock
  local awardget = self.data.awardget
  if data.award_type == _G.Enum.PetHandbookAward.AWARD_ITEM then
    if true == IsUnLock then
      if false == awardget then
        self.Dot:SetVisibility(UE4.ESlateVisibility.Visible)
        self.btnFightValue:SetVisibility(UE4.ESlateVisibility.Visible)
      elseif true == awardget then
        self.btnFightValue:SetVisibility(UE4.ESlateVisibility.Hidden)
        self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    elseif false == IsUnLock then
      self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.btnFightValue:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  elseif data.award_type == _G.Enum.PetHandbookAward.AWARD_SKILL or data.award_type == _G.Enum.PetHandbookAward.AWARD_CATCH or data.award_type == _G.Enum.PetHandbookAward.AWARD_ROLE_EXP then
    if true == IsUnLock then
      self.btnFightValue:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.btnFightValue:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  end
end

function UMG_BookAwardList_C:SetBasicInfo()
  self.Dot:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TextBG:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.btnFightValue:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.NumText:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.ItemIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.SkillsIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_BookAwardList_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_1)
  elseif 2 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_2)
  elseif 3 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_3)
  elseif 4 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_4)
  elseif 5 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_5)
  end
end

function UMG_BookAwardList_C:OnClickbtnFightValue()
  local AwardList = {}
  table.insert(AwardList, {
    id = self.data.itemCfg.id,
    num = self.data.AwardNum,
    type = _G.Enum.GoodsType.GT_BAGITEM
  })
  self.btnFightValue:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.Dot:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Visible)
  NRCModeManager:DoCmd(HandbookModuleCmd.GetHandbookAward, self.data.record.pet_base_id, self._index)
  _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, AwardList, "")
end

function UMG_BookAwardList_C:OnClickBtn_Icon()
  local data = self.data
  if data then
    local ani = self.select
    if not self:IsAnimationPlaying(ani) then
      self:PlayAnimation(ani, 0, 0)
    end
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1004, "UMG_PetGrowUp_Icon_C:OnBtnItemIconClick")
    if data.award_type == _G.Enum.PetHandbookAward.AWARD_ITEM then
      _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, data.itemCfg.id, _G.Enum.GoodsType.GT_BAGITEM)
    elseif data.award_type == _G.Enum.PetHandbookAward.AWARD_SKILL then
      Log.Debug("UMG_BookAwardList_C:OnClickBtn_Icon")
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.OpenPetFeatureTips, data.skillConfig)
    elseif data.award_type == _G.Enum.PetHandbookAward.AWARD_CATCH then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.OpenPetFeatureTips, data.CatchCfg)
    elseif data.award_type == _G.Enum.PetHandbookAward.AWARD_ROLE_EXP then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.OpenPetFeatureTips, data.CatchCfg)
    end
  end
end

function UMG_BookAwardList_C:OnItemSelected(_bSelected)
end

function UMG_BookAwardList_C:OnDeactive()
end

return UMG_BookAwardList_C
