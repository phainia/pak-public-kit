local BigMapModuleEvent = reload("NewRoco.Modules.System.BigMap.BigMapModuleEvent")
local UIUtils = require("NewRoco.Utils.UIUtils")
local BigMapUtils = require("NewRoco/Modules/System/BigMap/BigMapUtils")
local UMG_TraceIconVisit_C = _G.NRCPanelBase:Extend("UMG_TraceIconVisit_C")

function UMG_TraceIconVisit_C:OnConstruct()
  self.NRCButton_ClickRange.OnClicked:Add(self, self.OnClickRange)
end

function UMG_TraceIconVisit_C:OnDestruct()
  self.uiData = nil
  self.NRCButton_ClickRange.OnClicked:Remove(self, self.OnClickRange)
end

function UMG_TraceIconVisit_C:OnAddEventListener()
end

function UMG_TraceIconVisit_C:OnClickRange()
  Log.Debug("UMG_TraceIconVisit_C:OnClickRange")
  local BigMapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  BigMapModule:DispatchEvent(BigMapModuleEvent.ClickTraceIconEvent, self)
end

function UMG_TraceIconVisit_C:SetData(_data, _index)
  self.uiData = _data
  self:UpdatePanel(self.uiData, _index)
end

function UMG_TraceIconVisit_C:UpdatePanel(_data, _index)
  if not self.uiData then
    self:SetVisible(false)
  else
    self.IconVisit:SetMarkerIndex(self.uiData.data, _index)
  end
end

function UMG_TraceIconVisit_C:GetSceneResId()
  local sceneResId, iconSceneResId = BigMapUtils.GetVisitorIconSceneResIdAndPos(self.uiData.data)
  return iconSceneResId
end

function UMG_TraceIconVisit_C:IsUsable()
  return self.uiData ~= nil
end

function UMG_TraceIconVisit_C:GetImagePosition()
  return self.uiData.imagePosX or 0, self.uiData.imagePosY or 0
end

function UMG_TraceIconVisit_C:UpdateImagePosition(_posX, _posY)
  local uiData = self.uiData
  uiData.imagePosX = _posX or 0
  uiData.imagePosY = _posY or 0
end

function UMG_TraceIconVisit_C:SetVisible(_isVisible)
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

function UMG_TraceIconVisit_C:SetArrowDir(_angle)
  local dirMat = self.dirIcon1:GetDynamicMaterial()
  if dirMat then
    dirMat:SetScalarParameterValue("Angle", 90 - _angle)
  end
  self.dirIcon1:SetRenderTransformAngle(90 - _angle)
end

return UMG_TraceIconVisit_C
