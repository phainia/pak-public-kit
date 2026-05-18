local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local AppearanceModuleEvent = require("NewRoco.Modules.System.Appearance.AppearanceModuleEvent")
local UMG_Beauty_Item1_C = Base:Extend("UMG_Beauty_Item1_C")

function UMG_Beauty_Item1_C:OnConstruct()
end

function UMG_Beauty_Item1_C:OnDestruct()
end

function UMG_Beauty_Item1_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  self:SetSelected(false)
  self:UpdateItemInfo()
end

function UMG_Beauty_Item1_C:UpdateItemInfo()
  if 0 == self.index % 2 then
    self.Switcher:SetActiveWidgetIndex(1)
  else
    self.Switcher:SetActiveWidgetIndex(0)
  end
  self.icon:SetPath(self.uiData.path)
  self.icon_1:SetPath(self.uiData.path)
end

function UMG_Beauty_Item1_C:OnItemSelected(_bSelected)
  if _bSelected then
    local ColorIndex = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.GetUIColorIndexToColorMap, self.index - 1).rank_value
    _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetBeauty, self.uiData.salonId, false, ColorIndex)
    self:SetSelected(true)
    self:PlayAnimation(self.Loop)
    _G.NRCAudioManager:PlaySound2DAuto(1004, "UMG_Beauty_Item1_C:OnItemSelected")
  else
    self:SetSelected(false)
  end
end

function UMG_Beauty_Item1_C:SetSelected(_bSelected)
  if _bSelected then
    self.Selected_1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Selected:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Selected_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Beauty_Item1_C:OnDeactive()
end

return UMG_Beauty_Item1_C
