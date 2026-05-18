require("UnLuaEx")
local PriorityEnum = require("PriorityEnum")
local BP_NRCTab_C = NRCViewBase:Extend("BP_NRCTab_C")

function BP_NRCTab_C:Ctor()
  NRCUmgClass.Ctor(self)
  self.addWidget = nil
  self.parentView = nil
  self.curView = nil
  self.ResReqList = nil
  self.curResReq = nil
end

function BP_NRCTab_C:SetShowTabIndex(parent, index)
  NRCResourceManager:UnLoadRes(self.curResReq)
  self.parentView = parent
  self:SetActiveWidgetIndex(index)
end

function BP_NRCTab_C:OnTabWidgetConstruct(widgetPanel, parentWidget)
  local widgetPath = widgetPanel.AssetPathName
  local resReq = NRCResourceManager:LoadResAsync(self, widgetPath, PriorityEnum.UI_NRCTab_Default, -1, function(caller, resRequest, asset)
    self.addWidget = asset
    self:AddPanel(asset, parentWidget)
  end, nil, nil)
  self.curResReq = resReq
  if self.ResReqList == nil then
    self.ResReqList = {}
  end
  table.insert(self.ResReqList, resReq)
end

function BP_NRCTab_C:AddPanel(asset, parentWidget)
  self.addWidget = asset
  if parentWidget then
    local panel = UE4.UWidgetBlueprintLibrary.Create(_G.UE4Helper.GetCurrentWorld(), asset)
    if self.parentView then
      self.parentView:DynamicAddChildView(panel)
      local childWidgetPanel = parentWidget:AddChild(panel)
      childWidgetPanel:SetZOrder(100)
      self:BindTab(panel)
    end
  else
    local panel = UE4.UWidgetBlueprintLibrary.Create(self.WidgetTree.RootWidget, asset)
    if self.parentView then
      self.parentView:DynamicAddChildView(panel)
      local childWidgetPanel = self.WidgetTree.RootWidget:AddChildToCanvas(panel)
      childWidgetPanel:SetZOrder(100)
      self:BindTab(panel)
    end
  end
end

function BP_NRCTab_C:OnTabWidgetDestruct(lastWidget)
  lastWidget:RemoveFromViewport()
end

function BP_NRCTab_C:OnDestruct()
  self.addWidget = nil
  self.parentView = nil
  self.curView = nil
  if self.ResReqList then
    for k, v in ipairs(self.ResReqList) do
      NRCResourceManager:UnLoadRes(v)
    end
    self.ResReqList = nil
  end
  self.curResReq = nil
end

return BP_NRCTab_C
