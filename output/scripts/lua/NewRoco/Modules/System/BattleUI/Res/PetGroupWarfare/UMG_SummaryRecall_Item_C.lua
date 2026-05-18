local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SummaryRecall_Item_C = Base:Extend("UMG_SummaryRecall_Item_C")

function UMG_SummaryRecall_Item_C:OnConstruct()
  self.NRCImage_47:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_SummaryRecall_Item_C:OnDestruct()
end

function UMG_SummaryRecall_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.isLock = false
  self:SetUpInfo()
end

function UMG_SummaryRecall_Item_C:SetUpInfo()
  if self.data.itemType then
    local recoveryItemType = self.data.itemType
    local vItemsConf = _G.DataConfigManager:GetVisualItemConf(recoveryItemType)
    self.Icon:SetPath(NRCUtils:FormatConfIconPath(vItemsConf.bigIcon, _G.UIIconPath.BagItemPath))
    self.GreyOut:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if recoveryItemType == _G.Enum.VisualItem.VI_STAR_DEBRIS then
      local StarDebrisNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.Enum.VisualItem.VI_STAR_DEBRIS)
      StarDebrisNum = StarDebrisNum or 0
      local CostStar = _G.DataConfigManager:GetPetGlobalConfig("team_battle_starlink")
      if StarDebrisNum < CostStar.num then
        self.isLock = true
        self.GreyOut:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  end
end

function UMG_SummaryRecall_Item_C:OnItemSelected(_bSelected)
  if not self.isLock then
    if _bSelected then
      self.NRCImage_47:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if self.data.itemType == _G.Enum.VisualItem.VI_STAR_DEBRIS then
        _G.NRCModeManager:DoCmd(BattleUIModuleCmd.ShowStarDebrisText, true)
        _G.NRCModeManager:DoCmd(BattleUIModuleCmd.RefreshCatchConsumeInfo, _G.Enum.VisualItem.VI_STAR_DEBRIS)
        _G.NRCModeManager:DoCmd(BattleUIModuleCmd.SetSelectRecoveryItem, _G.Enum.VisualItem.VI_STAR_DEBRIS)
      else
        _G.NRCModeManager:DoCmd(BattleUIModuleCmd.ShowStarDebrisText, false)
        _G.NRCModeManager:DoCmd(BattleUIModuleCmd.RefreshCatchConsumeInfo, _G.Enum.VisualItem.VI_STAR)
        _G.NRCModeManager:DoCmd(BattleUIModuleCmd.SetSelectRecoveryItem, _G.Enum.VisualItem.VI_STAR)
      end
    else
      self.NRCImage_47:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  elseif _bSelected then
    _G.NRCModeManager:DoCmd(BattleUIModuleCmd.SelectRecoveryItem, 0)
    if self.data.itemType == _G.Enum.VisualItem.VI_STAR_DEBRIS then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Error_code_30079)
    end
  end
end

function UMG_SummaryRecall_Item_C:SetSelectState(_bSelected)
  if _bSelected then
    self.NRCImage_47:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.NRCImage_47:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_SummaryRecall_Item_C:OnDeactive()
end

return UMG_SummaryRecall_Item_C
