local Class = _G.MakeSimpleClass
local NRCPanelDynamicData = Class("NRCPanelDynamicData")
NRCPanelDynamicData:SetMemberCount(2)

function NRCPanelDynamicData:Ctor()
end

function NRCPanelDynamicData:SetOpenCallback(caller, func, ...)
  OnOpenCallback = _G.MakeWeakFunctor(caller, func, ...)
end

function NRCPanelDynamicData:SetCloseCallback(caller, func, ...)
  OnCloseCallback = _G.MakeWeakFunctor(caller, func, ...)
end

function NRCPanelDynamicData:TriggerOpen(panelData)
  if OnOpenCallback then
    local ok, msg = pcall(OnOpenCallback, panelData)
    if not ok then
      Log.Error(msg)
    end
    OnOpenCallback = nil
  end
end

function NRCPanelDynamicData:TriggerClose(panelData)
  if OnCloseCallback then
    local ok, msg = pcall(OnCloseCallback, panelData)
    if not ok then
      Log.Error(msg)
    end
    OnCloseCallback = nil
  end
end

function NRCPanelDynamicData:GetModifiedPanelLayerType()
  return self.modifiedPanelLayerType
end

function NRCPanelDynamicData:SetModifiedPanelLayerType(modifiedLayerType)
  self.modifiedPanelLayerType = modifiedLayerType
end

return NRCPanelDynamicData
