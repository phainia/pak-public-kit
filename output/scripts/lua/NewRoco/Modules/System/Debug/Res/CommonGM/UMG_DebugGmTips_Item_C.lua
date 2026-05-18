local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_DebugGmTips_Item_C = Base:Extend("UMG_DebugGmTips_Item_C")

function UMG_DebugGmTips_Item_C:OnConstruct()
  self.IsSpinner = false
  self.UMG_DebugDropGmDownList:OnConstruct()
  self.InputList = {}
end

function UMG_DebugGmTips_Item_C:OnDestruct()
  self.UMG_DebugDropGmDownList:OnDestruct()
end

function UMG_DebugGmTips_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetInfo()
end

function UMG_DebugGmTips_Item_C:SetInfo()
  local data = self.data
  if not self:IsEmpty(data.param_str) then
    self.Switcher:SetActiveWidgetIndex(1)
    self.UMG_DebugDropGmDownList:SetData(data)
    self.IsSpinner = true
  else
    self.IsSpinner = false
    self.Switcher:SetActiveWidgetIndex(0)
    self.AddBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:OnAddBtn()
    if data.type > 200 then
      self.AddBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.AddBtn.btnLevelUp.OnClicked:Add(self, self.OnAddBtn)
    end
  end
end

function UMG_DebugGmTips_Item_C:IsEmpty(List)
  if List and #List > 0 then
    return false
  end
  return true
end

function UMG_DebugGmTips_Item_C:OnItemSelected(_bSelected)
end

function UMG_DebugGmTips_Item_C:OnDeactive()
end

function UMG_DebugGmTips_Item_C:SetDebugGmDropDownListInfo(CommGm)
end

function UMG_DebugGmTips_Item_C:OnAddBtn()
  self:CreateInputWidget(self.InputScrollView, self.InputItem)
end

function UMG_DebugGmTips_Item_C:CreateInputWidget(iconLayer, iconTemple)
  local iconWidget
  iconWidget = UE4.UWidgetBlueprintLibrary.Create(self, iconTemple)
  local iconSlot
  if iconWidget then
    iconSlot = iconLayer:AddChild(iconWidget)
    iconWidget:SetText(self.data.param_name, self.data.param_desc, self.data.require)
    table.insert(self.InputList, iconWidget)
  end
end

function UMG_DebugGmTips_Item_C:GetAutoParam()
  local AutoParam = {}
  local IsSatisfy = true
  table.copy(self.data, AutoParam)
  if self.IsSpinner then
    if AutoParam.param_str and #AutoParam.param_str > 0 then
      AutoParam.param_str, IsSatisfy = self:GetDebugDropGmDownMultiSelectList()
    else
      AutoParam.param_str, IsSatisfy = self:GetDebugDropGmDownSingleSelection()
    end
  else
    AutoParam.param_str = {}
    for i, IconWidget in ipairs(self.InputList) do
      if IconWidget:GetInputBox() and IconWidget:GetInputBox() ~= "" then
        table.insert(AutoParam.param_str, IconWidget:GetInputBox())
      else
        IconWidget:SetColor("FF0000FF")
      end
    end
  end
  return AutoParam, IsSatisfy
end

function UMG_DebugGmTips_Item_C:GetDebugDropGmDownSingleSelection()
  local SingleSelection = self.UMG_DebugDropGmDownList:GetSingleSelection()
  local List = {}
  local IsSatisfy = true
  if SingleSelection then
    table.insert(List, SingleSelection)
    self.UMG_DebugDropGmDownList:SetColor("000000FF")
  else
    self.UMG_DebugDropGmDownList:SetColor("FF0000FF")
  end
  return List, IsSatisfy
end

function UMG_DebugGmTips_Item_C:GetDebugDropGmDownMultiSelectList()
  local IsSatisfy = true
  local MultiSelectList = self.UMG_DebugDropGmDownList:GetMultiSelectList()
  if MultiSelectList and #MultiSelectList > 0 then
    self.UMG_DebugDropGmDownList:SetColor("000000FF")
    return MultiSelectList, IsSatisfy
  else
    self.UMG_DebugDropGmDownList:SetColor("FF0000FF")
  end
  return MultiSelectList, IsSatisfy
end

return UMG_DebugGmTips_Item_C
