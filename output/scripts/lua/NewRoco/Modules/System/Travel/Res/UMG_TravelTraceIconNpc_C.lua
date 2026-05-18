local UMG_TravelTraceIconNpc_C = _G.NRCPanelBase:Extend("UMG_TravelTraceIconNpc_C")
local BigMapModuleEvent = reload("NewRoco.Modules.System.BigMap.BigMapModuleEvent")

function UMG_TravelTraceIconNpc_C:OnConstruct()
  self.Button.OnClicked:Add(self, self.OnClickRange)
end

function UMG_TravelTraceIconNpc_C:OnDestruct()
  self.uiData = nil
  self.Button.OnClicked:Remove(self, self.OnClickRange)
end

function UMG_TravelTraceIconNpc_C:OnClickRange()
  local BigMapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  BigMapModule:DispatchEvent(BigMapModuleEvent.ClickTraceIconEvent, self)
end

function UMG_TravelTraceIconNpc_C:SetData(_data)
  self.uiData = _data
  self.CanvasPanel_57:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:UpdatePanel()
  self:ShowIcon()
end

function UMG_TravelTraceIconNpc_C:ShowIcon()
  if self.uiData == nil then
    return
  end
  if self.uiData.travelInfo then
    local travelInfo = self.uiData.travelInfo
    if travelInfo.travel_complete then
      if travelInfo.will_lay_egg then
        self.Switcher:SetActiveWidgetIndex(0)
      else
        self.Switcher:SetActiveWidgetIndex(1)
      end
    else
      self.Switcher:SetActiveWidgetIndex(2)
    end
  end
end

function UMG_TravelTraceIconNpc_C:IsUsable()
  return self.uiData ~= nil
end

function UMG_TravelTraceIconNpc_C:GetId()
  if self.uiData and self.uiData.travelInfo then
    return self.uiData.travelInfo.camp_content_id
  end
  return 0
end

function UMG_TravelTraceIconNpc_C:GetImagePosition()
  return self.uiData.imagePosX or 0, self.uiData.imagePosY or 0
end

function UMG_TravelTraceIconNpc_C:UpdateImagePosition(_posX, _posY)
  local uiData = self.uiData
  uiData.imagePosX = _posX or 0
  uiData.imagePosY = _posY or 0
end

function UMG_TravelTraceIconNpc_C:SetVisible(_isVisible)
  if self.isVisible == _isVisible then
    return
  end
  self.isVisible = _isVisible
  if self.isVisible then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_TravelTraceIconNpc_C:UpdatePanel()
  if not self.uiData then
    self:SetVisible(false)
  end
end

function UMG_TravelTraceIconNpc_C:SetArrowDir(_angle)
  self.bg:SetRenderTransformAngle(180 - _angle)
end

return UMG_TravelTraceIconNpc_C
