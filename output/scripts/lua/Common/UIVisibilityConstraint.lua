local function RemoveConstraintsFactor(_widgetData, _blockingFactor)
  if not _widgetData or not _blockingFactor then
    return
  end
  local findIndex
  for _index, _factor in ipairs(_widgetData.blockingFactors) do
    if _factor == _blockingFactor then
      findIndex = _index
      break
    end
  end
  if findIndex then
    table.remove(_widgetData.blockingFactors, findIndex)
  end
end

local UIVisibilityConstraint = NRCClass()

function UIVisibilityConstraint:Ctor()
  self.blockingDisplayWidgets = {}
end

function UIVisibilityConstraint:AddWidgetDisplayConstraints(_widget, _blockingFactor)
  if not _widget or not _blockingFactor then
    Log.Error("AddWidgetDisplayConstraints: _widget and _blockingFactor should not be nil!")
    return
  end
  local widgetData = self.blockingDisplayWidgets[_widget]
  if not widgetData then
    widgetData = {}
    widgetData.visibilityRestore = _widget:GetVisibility()
    widgetData.blockingFactors = {_blockingFactor}
    self.blockingDisplayWidgets[_widget] = widgetData
    _widget:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    local _exists = false
    for _, _factor in ipairs(widgetData.blockingFactors) do
      if _factor == _blockingFactor then
        _exists = true
        break
      end
    end
    if not _exists then
      table.insert(widgetData.blockingFactors, _blockingFactor)
    end
  end
end

function UIVisibilityConstraint:RemoveWidgetDisplayConstraints(_widget, _blockingFactor)
  if not _widget or not _blockingFactor then
    Log.Error("RemoveWidgetDisplayConstraints: _widget and _blockingFactor should not be nil!")
    return
  end
  local widgetData = self.blockingDisplayWidgets[_widget]
  if widgetData then
    RemoveConstraintsFactor(widgetData, _blockingFactor)
    if #widgetData.blockingFactors <= 0 then
      _widget:SetVisibility(widgetData.visibilityRestore)
      self.blockingDisplayWidgets[_widget] = nil
    end
  end
end

function UIVisibilityConstraint:RemoveWidgetDisplayConstraintsByFactor(_blockingFactor)
  if not _blockingFactor then
    return
  end
  local waitRemoveWidgets = {}
  for _widget, _widgetData in pairs(self.blockingDisplayWidgets) do
    if UE4.UObject.IsValid(_widget) then
      RemoveConstraintsFactor(_widgetData, _blockingFactor)
      if #_widgetData.blockingFactors <= 0 then
        table.insert(waitRemoveWidgets, _widget)
        _widget:SetVisibility(_widgetData.visibilityRestore)
      end
    else
      Log.Debug("widget is not valid!")
    end
  end
  for _, _widget in ipairs(waitRemoveWidgets) do
    self.blockingDisplayWidgets[_widget] = nil
  end
end

function UIVisibilityConstraint:TrySetWidgetVisibility(_widget, _visibility)
  if not _widget then
    return
  end
  local widgetData = self.blockingDisplayWidgets[_widget]
  if widgetData then
    widgetData.visibilityRestore = _visibility
  else
    _widget:SetVisibility(_visibility)
  end
end

return UIVisibilityConstraint
