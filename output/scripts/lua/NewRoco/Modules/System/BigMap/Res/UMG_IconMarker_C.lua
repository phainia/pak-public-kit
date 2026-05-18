local Base = require("NewRoco/Modules/System/BigMap/Res/UMG_IconTempBasic_C")
local BigMapModuleEvent = require("NewRoco.Modules.System.BigMap.BigMapModuleEvent")
local UMG_IconMarker_C = Base:Extend("UMG_IconMarker_C")

function UMG_IconMarker_C:Construct()
  self.isShowTraceEffect = false
  self.SelectMarkerInfo = nil
  self.uiData = nil
  self.element_show_scale = _G.DataConfigManager:GetMapGlobalConfig("oneself_mark_scale").num
end

function UMG_IconMarker_C:Destruct()
end

function UMG_IconMarker_C:OnActive()
end

function UMG_IconMarker_C:OnDeactive()
end

function UMG_IconMarker_C:IsUsable()
  return self.uiData ~= nil
end

function UMG_IconMarker_C:GetImagePosition()
  return self.uiData.imagePosX or 0, self.uiData.imagePosY or 0
end

function UMG_IconMarker_C:SetSelectMarkerInfo(Point)
  self.uiData = Point
  self.SelectMarkerInfo = Point
  if Point.is_track then
    self.element_show_scale = 1
  else
    self.element_show_scale = _G.DataConfigManager:GetMapGlobalConfig("oneself_mark_scale").num
  end
end

function UMG_IconMarker_C:showAni(MarkerPanelInfo, _SelectMarkerInfo, IsFirstOnclick)
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

function UMG_IconMarker_C:SetPath(worldMapCfgId)
  local WorldMapConf = _G.DataConfigManager:GetWorldMapConf(worldMapCfgId)
  if WorldMapConf then
    self.Icon:SetPath(WorldMapConf.map_markicon)
  end
end

function UMG_IconMarker_C:UpdateMapShowLevel(_level)
  local scaleConf = _G.DataConfigManager:GetWorldMapScaleConf(self.element_show_scale)
  if _level <= scaleConf.max_scale / 100.0 and _level >= scaleConf.min_scale / 100.0 then
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_IconMarker_C:SetIsVisible(_IsVisible)
  if _IsVisible then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_IconMarker_C:SetData(_data)
  self.uiData = _data
  self:UpdatePanel()
end

function UMG_IconMarker_C:GetData()
  return self.uiData
end

function UMG_IconMarker_C:SetVisible(_isVisible)
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

function UMG_IconMarker_C:UpdatePanel()
  if not self.uiData then
    self:SetVisible(false)
  else
    local WorldMapConf = _G.DataConfigManager:GetWorldMapConf(self.uiData.MarkInfo.world_map_cfg_id)
    self:SetPath(WorldMapConf)
  end
end

function UMG_IconMarker_C:OnAddEventListener()
end

function UMG_IconMarker_C:OnAnimationFinished(Anim)
  if Anim == self.In then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
  elseif Anim == self.TraceStart then
    self:PlayAnimation(self.TraceLoop, 0, 0)
  end
end

function UMG_IconMarker_C:PlayTraceEffect(_show)
  if self.isShowTraceEffect ~= _show then
    self.isShowTraceEffect = _show
    if _show then
      self.traceEffect:LoadPanel(nil)
    else
      self.traceEffect:UnLoadPanel(true)
    end
  end
end

return UMG_IconMarker_C
