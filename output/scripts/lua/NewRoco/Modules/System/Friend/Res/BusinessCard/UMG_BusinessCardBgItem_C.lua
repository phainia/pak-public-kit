local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")
local RedPointModuleEvent = require("NewRoco.Modules.System.RedPoint.RedPointModuleEvent")
local UMG_BusinessCardBgItem_C = Base:Extend("UMG_BusinessCardBgItem_C")

function UMG_BusinessCardBgItem_C:OnConstruct()
  self.module = _G.NRCModuleManager:GetModule("FriendModule")
  self.moduleData = self.module:GetData("FriendModuleData")
  self.module:RegisterEvent(self, FriendModuleEvent.SetChooseCardBGPath, self.OnSetChooseCardBGPath)
  self.module:RegisterEvent(self, FriendModuleEvent.UpgradeCardSkinSucceed, self.UpgradeCardSkinSucceed)
  self.module:RegisterEvent(self, FriendModuleEvent.UpdateCardSkinInfo, self.UpdateCardSkinInfo)
  self.module:RegisterEvent(self, FriendModuleEvent.OnCardBackgroundItemSelect, self.OnCardBackgroundItemSelect)
  _G.NRCEventCenter:RegisterEvent("UMG_BusinessCardBgItem_C", self, RedPointModuleEvent.RedPointChange, self.OnUpdateRedPointData)
end

function UMG_BusinessCardBgItem_C:OnDestruct()
  self.module:UnRegisterEvent(self, FriendModuleEvent.SetChooseCardBGPath)
  self.module:UnRegisterEvent(self, FriendModuleEvent.UpgradeCardSkinSucceed)
  self.module:UnRegisterEvent(self, FriendModuleEvent.UpdateCardSkinInfo)
  self.module:UnRegisterEvent(self, FriendModuleEvent.OnCardBackgroundItemSelect)
  _G.NRCEventCenter:UnRegisterEvent(self, RedPointModuleEvent.RedPointChange, self.OnUpdateRedPointData)
end

function UMG_BusinessCardBgItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self:UpdateInfo()
  self:SetOnNewState()
end

function UMG_BusinessCardBgItem_C:UpdateInfo()
  if not self.data or not self.data.ConfigurationInfo then
    Log.Error("UMG_BusinessCardBgItem_C:UpdateInfo - Invalid data or ConfigurationInfo")
    return
  end
  local curSelectedCardSkinId = self.moduleData:GetEditSelectedCardSkinId()
  local curUsedCardSkinId = self.moduleData:GetCurUsedCardSkinId()
  local cardSkinConf = self.data.ConfigurationInfo
  self.CardBg:SetPath(string.format(UEPath.CARD_COMMON_PATH, cardSkinConf.skin_resource_path, "icon", cardSkinConf.skin_resource_path, "icon"))
  self.Name_content:SetText(cardSkinConf.skin_resource_name)
  self:SetSelectedVisible(self.data.card_item_id == curSelectedCardSkinId)
  self:IsShowCurrentUse(self.data.card_item_id == curUsedCardSkinId)
  self:RefreshUpgradeInfo()
end

function UMG_BusinessCardBgItem_C:RefreshUpgradeInfo()
  local canUpgrade = self:CanUpgradeForSelectedSkin()
  if canUpgrade then
    self.Upgradable:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Upgradable:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_BusinessCardBgItem_C:IsShowCurrentUse(_IsShow)
  if _IsShow then
    self.Checked:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Checked:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_BusinessCardBgItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_BusinessCardBgItem_C:OnItemSelected")
    self:SetSelectedVisible(true)
    self.moduleData:SetEditSelectedCardSkinId(self.data.card_item_id)
    self:SetOnNewStateRemove()
    self.module:DispatchEvent(FriendModuleEvent.OnCardBackgroundItemSelect)
  else
    self:SetSelectedVisible(false)
  end
end

function UMG_BusinessCardBgItem_C:CanUpgradeForSelectedSkin()
  local selectedCardSkinId = self.data.card_item_id
  local UMG_ChangeBackground_C = _G.NRCPanelManager:GetPanel("FriendModule", "CardChangeBackground")
  if not UMG_ChangeBackground_C then
    Log.Error("UMG_BusinessCardBgItem_C:CanUpgradeForSelectedSkin - UMG_ChangeBackground_C is nil")
    return false
  end
  local selectedSkinData = UMG_ChangeBackground_C.myCardSkinDic[selectedCardSkinId]
  if selectedSkinData and selectedSkinData.ConfigurationInfo then
    local upgradeCostId = selectedSkinData.ConfigurationInfo.level_up_cost
    if upgradeCostId and upgradeCostId > 0 then
      local upgradeCostSkinData = UMG_ChangeBackground_C.myCardSkinDic[upgradeCostId]
      if upgradeCostSkinData then
        if selectedCardSkinId == upgradeCostId then
          return upgradeCostSkinData.ownedNum > 1
        else
          return upgradeCostSkinData.ownedNum > 0
        end
      end
    end
  end
  return false
end

function UMG_BusinessCardBgItem_C:SetOnNewState()
  if self.data and self.data.card_item_id then
    self.RedDot:SetupKey(172, self.data.card_item_id)
  end
end

function UMG_BusinessCardBgItem_C:SetOnNewStateRemove()
  if self.data and self.data.is_initial_unlock and self.RedDot and self.RedDot:IsRed() then
    self.RedDot:EraseRedPoint()
  end
end

function UMG_BusinessCardBgItem_C:OnSetChooseCardBGPath()
  self:UpdateInfo()
end

function UMG_BusinessCardBgItem_C:OnCardBackgroundItemSelect()
  self:UpdateInfo()
end

function UMG_BusinessCardBgItem_C:UpdateCardSkinInfo()
  self:RefreshUpgradeInfo()
end

function UMG_BusinessCardBgItem_C:UpgradeCardSkinSucceed(origCardSkinId)
  self:RefreshUpgradeInfo()
  local oriCardSkinConf = _G.DataConfigManager:GetCardSkinConf(origCardSkinId)
  if not oriCardSkinConf then
    Log.Error("UMG_BusinessCardBgItem_C:UpgradeCardSkinSucceed - CardSkinConf is nil , origCardSkinId:" .. tostring(origCardSkinId))
    return
  end
  if self.data and oriCardSkinConf.level_up_card and self.data.card_item_id == oriCardSkinConf.level_up_card then
    self:SetOnNewStateRemove()
    Log.DebugFormat("UMG_BusinessCardBgItem_C:UpgradeCardSkinSucceed - Removed Red Dot for upgraded card_item_id:%s, origCardSkinId:%s", tostring(oriCardSkinConf.level_up_card), tostring(origCardSkinId))
  end
end

function UMG_BusinessCardBgItem_C:OnUpdateRedPointData(notify)
  if not self.data or not self.data.ConfigurationInfo then
    return
  end
  local cardSkinConf = self.data.ConfigurationInfo
  if not cardSkinConf.level_icon then
    return
  end
  if notify.rp_group then
    for _, group in pairs(notify.rp_group) do
      if group.reason_type == _G.Enum.RedPointReason.RPR_CARD_NEW_SKIN and group.point_data and #group.point_data > 0 then
        for i, gid in pairs(group.point_data) do
          if self.data.card_item_id == tonumber(gid) then
            self:SetOnNewStateRemove()
            Log.DebugFormat("UMG_BusinessCardBgItem_C:OnUpdateRedPointData - Removed Red Dot for card_item_id:%s from RedPoint notify", tostring(self.data.card_item_id))
            break
          end
        end
      end
    end
  end
end

function UMG_BusinessCardBgItem_C:SetSelectedVisible(visible)
  self:StopAllAnimations()
  if visible then
    self.Select:SetVisibility(UE4.ESlateVisibility.visible)
    self.Select_1:SetVisibility(UE4.ESlateVisibility.visible)
    self:PlayAnimation(self.Selected)
  else
    self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Select_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:PlayAnimation(self.Selected_out)
  end
end

function UMG_BusinessCardBgItem_C:OnDeactive()
end

return UMG_BusinessCardBgItem_C
