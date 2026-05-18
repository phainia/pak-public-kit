local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local AppearanceModuleEvent = require("NewRoco.Modules.System.Appearance.AppearanceModuleEvent")
local UMG_CombinationBagTab_C = Base:Extend("UMG_CombinationBagTab_C")

function UMG_CombinationBagTab_C:OnConstruct()
  self.uiData = {}
end

function UMG_CombinationBagTab_C:OnDestruct()
end

function UMG_CombinationBagTab_C:OnActive()
end

function UMG_CombinationBagTab_C:OnDeactive()
end

function UMG_CombinationBagTab_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.Index = index
  self:UpdateUI()
end

function UMG_CombinationBagTab_C:OnItemSelected(_bSelected)
  if self.uiData.FashionPackageId == nil then
    return
  end
  if _bSelected then
    self.Frame:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if nil == self.uiData.ActivityId then
      local appearanceModule = NRCModuleManager:GetModule("AppearanceModule")
      appearanceModule:DispatchEvent(AppearanceModuleEvent.UpdateShowingFashionPackage, self.Index)
    else
      local activityModule = NRCModuleManager:GetModule("ActivityModule")
      activityModule:DispatchEvent(ActivityModuleEvent.UpdateShowingFashionPackage, self.Index)
    end
  else
    self.Frame:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_CombinationBagTab_C:UpdateUI()
  if self.uiData.FashionPackageId == nil then
    return
  end
  local fashionPackageConf = _G.DataConfigManager:GetFashionPackageConf(self.uiData.FashionPackageId, true)
  if fashionPackageConf then
    self.NRCImage_26:SetPath(fashionPackageConf.kv_small)
    self.NRCText_45:SetText(fashionPackageConf.name)
  end
  self.Frame:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_CombinationBagTab_C:GetFashionPackageId()
  return self.uiData.FashionPackageId
end

return UMG_CombinationBagTab_C
