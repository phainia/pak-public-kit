local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BeautyLogin_Item1_C = Base:Extend("UMG_BeautyLogin_Item1_C")

function UMG_BeautyLogin_Item1_C:OnConstruct()
end

function UMG_BeautyLogin_Item1_C:OnDestruct()
end

function UMG_BeautyLogin_Item1_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  Log.Dump(_data, 3, "UMG_Beauty_Item1_C:OnItemUpdate")
  self:SetSelected(false)
  self:UpdateItemInfo()
end

function UMG_BeautyLogin_Item1_C:UpdateItemInfo()
  if 0 == self.index % 2 then
    self.Switcher:SetActiveWidgetIndex(1)
  else
    self.Switcher:SetActiveWidgetIndex(0)
  end
  local salonItemConf = _G.DataConfigManager:GetSalonItemConf(self.uiData)
  if salonItemConf.colour_type == Enum.HairColours.HC_PURE then
    local showColor = salonItemConf.colour_id[1]
    self.icon:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(showColor))
    self.icon_1:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(showColor))
  end
end

function UMG_BeautyLogin_Item1_C:OnItemSelected(_bSelected)
  if _bSelected then
    if self.uiData == nil then
      return
    end
    local salonItemConf = _G.DataConfigManager:GetSalonItemConf(self.uiData)
    if salonItemConf then
      _G.NRCModuleManager:DoCmd(_G.AppearanceLoginModuleCmd.SetAvatarSalon, salonItemConf.avatar_id, salonItemConf.texture_id)
      self:SetSelected(true)
      self:PlayAnimation(self.Loop)
    end
  else
    self:SetSelected(false)
  end
end

function UMG_BeautyLogin_Item1_C:SetSelected(_bSelected)
  if _bSelected then
    self.Selected_1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Selected:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Selected_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_BeautyLogin_Item1_C
