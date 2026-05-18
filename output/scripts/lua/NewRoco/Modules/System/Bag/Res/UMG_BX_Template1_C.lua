local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BX_Template1_C = Base:Extend("UMG_BX_Template1_C")

function UMG_BX_Template1_C:OnConstruct()
  self.itemId = nil
end

function UMG_BX_Template1_C:OnDestruct()
end

function UMG_BX_Template1_C:OnItemUpdate(_data, datalist, index)
  self.Data = _data
  self.index = index
  self:InitPanel()
end

function UMG_BX_Template1_C:InitPanel()
  local BagItemConf = _G.DataConfigManager:GetBagItemConf(self.Data.Id)
  local bagItemInfo = self:GetItem(self.Data.Id)
  self.OwnedText:SetText(bagItemInfo and bagItemInfo.num or 0)
  self.Num:SetText(self.Data.Count)
  self.Name:SetText(BagItemConf.name)
  self.Icon:SetPath(BagItemConf.icon)
  self:SetQuality(BagItemConf.item_quality)
  self:SetSelectedVisible(false)
end

function UMG_BX_Template1_C:SetParent(_Parent)
  self.Parent = _Parent
end

function UMG_BX_Template1_C:OnItemSelected(Selected)
  if Selected then
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_BX_Template1_C:OnItemSelected")
    if self.canOpenTips then
      local BagItemConf = _G.DataConfigManager:GetBagItemConf(self.Data.Id)
      _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, BagItemConf.id, _G.Enum.GoodsType.GT_BAGITEM, false)
    end
    self:StopAllAnimations()
    self:SetSelectedVisible(true)
    self:PlayAnimation(self.Select_loop)
    if self.Parent then
      self.Parent:SelectChange(true, self.Data, self.index)
    end
    self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("FCB641FF"))
    self.Name:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("272727FF"))
    self.Bagicon:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("272727FF"))
    self.OwnedText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("272727FF"))
    self.canOpenTips = true
  else
    self:StopAllAnimations()
    self:PlayAnimation(self.Select_out)
    self.Name:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("62605EFF"))
    self.Bagicon:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("62605EFF"))
    self.OwnedText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("62605EFF"))
    self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("DFD8BEFF"))
    self.canOpenTips = false
  end
end

function UMG_BX_Template1_C:SetSelectedVisible(visible)
  self.BGSwitcher:SetActiveWidgetIndex(visible and 1 or 0)
end

function UMG_BX_Template1_C:GetItem(id)
  local item = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByID, id)
  return item
end

function UMG_BX_Template1_C:OnAnimationFinished(Anim)
  if Anim == self.Select_out then
    self:SetSelectedVisible(false)
  end
end

function UMG_BX_Template1_C:OnDeactive()
end

function UMG_BX_Template1_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.HexToLinearColor))
  elseif 4 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

return UMG_BX_Template1_C
