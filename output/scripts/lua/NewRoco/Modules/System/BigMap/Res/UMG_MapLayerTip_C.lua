local BigMapModuleEvent = require("NewRoco.Modules.System.BigMap.BigMapModuleEvent")
local UMG_MapLayerTip_C = _G.NRCPanelBase:Extend("UMG_MapLayerTip_C")

function UMG_MapLayerTip_C:OnConstruct()
  self:OnAddEventListener()
  self:SetTipVisibility(false)
end

function UMG_MapLayerTip_C:OnActive(layerMapInfo)
  self:UpdatePanel(layerMapInfo)
end

function UMG_MapLayerTip_C:OnDeactive()
end

function UMG_MapLayerTip_C:OnAddEventListener()
end

function UMG_MapLayerTip_C:OnRemoveEventListener()
end

function UMG_MapLayerTip_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_MapLayerTip_C:UpdatePanel(layerMapInfo)
  self:SetTipVisibility(true)
  self.right_buttons:InitGridView(layerMapInfo.layerInfo)
  for k, v in ipairs(layerMapInfo.layerInfo) do
    if v.id == layerMapInfo.selectedLayerId then
      self.right_buttons:selectItemByIndex(k - 1)
    end
  end
end

function UMG_MapLayerTip_C:SetTipVisibility(bShow)
  if bShow then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_MapLayerTip_C
