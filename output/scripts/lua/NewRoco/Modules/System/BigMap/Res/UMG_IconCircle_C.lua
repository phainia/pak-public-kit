local UMG_IconCircle_C = _G.NRCPanelBase:Extend("UMG_IconCircle_C")

function UMG_IconCircle_C:OnActive()
end

function UMG_IconCircle_C:OnDeactive()
end

function UMG_IconCircle_C:OnAddEventListener()
end

function UMG_IconCircle_C:OnConstruct()
  self.circleRadius = UE4.FVector2D(0, 0)
end

function UMG_IconCircle_C:OnDestruct()
end

function UMG_IconCircle_C:SetData(circleInfo)
  self.uiData = circleInfo
end

function UMG_IconCircle_C:SetCircleRadius(radius, imageToSceneScale)
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  if self.circleRadius then
    self.circleRadius.X = radius * imageToSceneScale * 2
    self.circleRadius.Y = radius * imageToSceneScale * 2
    self.Scope:SetRenderScale(self.circleRadius)
  end
end

function UMG_IconCircle_C:UpdateMapShowLevel(_level, bForceRefresh)
  if _level == self.curMapShowLevel and not bForceRefresh then
    return
  end
  self.curMapShowLevel = _level
  if self.uiData.showScale then
    if 0 == self.uiData.showScale then
      self.uiData.showScale = 1
    end
    local scaleConf = _G.DataConfigManager:GetWorldMapScaleConf(self.uiData.showScale)
    if nil == scaleConf or self.curMapShowLevel <= scaleConf.max_scale / 100.0 and self.curMapShowLevel >= scaleConf.min_scale / 100.0 then
      self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

return UMG_IconCircle_C
