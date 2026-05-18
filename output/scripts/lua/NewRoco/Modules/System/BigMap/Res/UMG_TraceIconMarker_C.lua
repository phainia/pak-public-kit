local BigMapModuleEvent = require("NewRoco.Modules.System.BigMap.BigMapModuleEvent")
local BigMapUtils = require("NewRoco/Modules/System/BigMap/BigMapUtils")
local UMG_TraceIconMarker_C = _G.NRCPanelBase:Extend("UMG_TraceIconMarker_C")

function UMG_TraceIconMarker_C:Construct()
  self.SelectMarkerInfo = nil
  self.uiData = nil
  self.element_show_scale = _G.DataConfigManager:GetMapGlobalConfig("oneself_mark_scale").num
  self:SetBGVisibility(true)
  self.NRCButton_ClickRange.OnClicked:Add(self, self.OnClickRange)
end

function UMG_TraceIconMarker_C:Destruct()
  self.NRCButton_ClickRange.OnClicked:Remove(self, self.OnClickRange)
end

function UMG_TraceIconMarker_C:OnActive()
end

function UMG_TraceIconMarker_C:OnDeactive()
end

function UMG_TraceIconMarker_C:OnClickRange()
  Log.Debug("UMG_TraceIconMarker_C:OnClickRange")
  local BigMapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  BigMapModule:DispatchEvent(BigMapModuleEvent.ClickTraceIconEvent, self)
end

function UMG_TraceIconMarker_C:IsUsable()
  return self.uiData ~= nil
end

function UMG_TraceIconMarker_C:GetImagePosition()
  return self.uiData.imagePosX or 0, self.uiData.imagePosY or 0
end

function UMG_TraceIconMarker_C:SetSelectMarkerInfo(Point)
  self.SelectMarkerInfo = Point
  if Point.is_track then
    self.element_show_scale = 1
    self:PlayAnimation(self.Anim, 0, 99999)
  else
    self.element_show_scale = _G.DataConfigManager:GetMapGlobalConfig("oneself_mark_scale").num
    self:StopAllAnimations()
  end
end

function UMG_TraceIconMarker_C:showAni(MarkerPanelInfo, _SelectMarkerInfo, IsFirstOnclick)
  if MarkerPanelInfo and MarkerPanelInfo then
    if IsFirstOnclick then
      _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
      self:PlayAnimation(self.In)
    end
    self.Slot:SetPosition(MarkerPanelInfo.SelectImagePos)
    self.Icon:SetPath(_SelectMarkerInfo.map_markicon)
    self:SetIsVisible(true)
  end
end

function UMG_TraceIconMarker_C:SetPath(worldMapCfgId)
  local WorldMapConf = _G.DataConfigManager:GetWorldMapConf(worldMapCfgId)
  self.Icon:SetPath(WorldMapConf.map_markicon)
end

function UMG_TraceIconMarker_C:UpdateMapShowLevel(_level)
  local scaleConf = _G.DataConfigManager:GetWorldMapScaleConf(self.element_show_scale)
  if _level <= scaleConf.max_scale / 100.0 and _level >= scaleConf.min_scale / 100.0 then
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_TraceIconMarker_C:SetIsVisible(_IsVisible)
  if _IsVisible then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_TraceIconMarker_C:SetData(_data)
  self.uiData = _data
  self:UpdatePanel()
end

function UMG_TraceIconMarker_C:GetData()
  return self.uiData
end

function UMG_TraceIconMarker_C:GetSceneResId()
  local markerInfo = self.uiData.MarkInfo
  local posX = 0
  local posY = 0
  if markerInfo and markerInfo.pos then
    posX = markerInfo.pos.x
    posY = markerInfo.pos.y
  end
  return BigMapUtils.GetSceneResIdByPos(posX, posY)
end

function UMG_TraceIconMarker_C:SetVisible(_isVisible)
  if self.isVisible == _isVisible then
    return
  end
  self.isVisible = _isVisible
  if self.isVisible then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_TraceIconMarker_C:UpdatePanel()
  if not self.uiData then
    self:SetVisible(false)
  else
    self:SetPath(self.uiData.MarkInfo.world_map_cfg_id)
  end
end

function UMG_TraceIconMarker_C:SetArrowDir(_angle)
  self.dirIcon1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local dirMat = self.dirIcon1:GetDynamicMaterial()
  if dirMat then
    dirMat:SetScalarParameterValue("Angle", 90 - _angle)
  end
  self.dirIcon1:SetRenderTransformAngle(90 - _angle)
end

function UMG_TraceIconMarker_C:OnAddEventListener()
end

function UMG_TraceIconMarker_C:OnAnimationFinished(Anim)
  if Anim == self.In then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
  end
end

function UMG_TraceIconMarker_C:SetBGVisibility(bVisual)
  self.Click:SetVisibility(bVisual and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
end

return UMG_TraceIconMarker_C
