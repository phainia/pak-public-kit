local UMG_DebugDropGmDownList_C = _G.NRCViewBase:Extend("UMG_DebugDropGmDownList_C")

function UMG_DebugDropGmDownList_C:OnConstruct()
  self.IsMultiSelect = false
  self.selectedIndex = -1
  self.bListVisible = false
  self.MultiSelectList = {}
  self.SingleSelection = nil
  self.Data = nil
  self:SetScrollVisible(self.bListVisible)
  self:OnAddEventListener()
end

function UMG_DebugDropGmDownList_C:OnDestruct()
end

function UMG_DebugDropGmDownList_C:OnActive()
end

function UMG_DebugDropGmDownList_C:OnDeactive()
end

function UMG_DebugDropGmDownList_C:OnAddEventListener()
  self:AddButtonListener(self.SelectButton, self.OnSelectedBtnClick)
end

function UMG_DebugDropGmDownList_C:SetData(params)
  self.Data = params
  self:SetScrollVisible(self.bListVisible)
  local List = {}
  if params.param_str and #params.param_str > 0 then
    List = self:ConstructionList(params.param_str, true)
  else
    List = self:ConstructionList(params.param_str, false)
  end
  self.CandidateListScroll:InitList(List)
  local _Text
  if params.require then
    _Text = string.format("%s%s", params.param_name, "*")
  else
    _Text = params.param_name
  end
  self.Text:SetText(_Text)
  self.TText:SetText(params.param_desc)
end

function UMG_DebugDropGmDownList_C:ConstructionList(_List, _IsMultiSelect)
  self.IsMultiSelect = _IsMultiSelect
  local List = {}
  for i, _ in ipairs(_List) do
    table.insert(List, {
      Name = _,
      IsMultiSelect = _IsMultiSelect,
      Call = self,
      handler = self.SelectInfo
    })
  end
  return List
end

function UMG_DebugDropGmDownList_C:OnSelectedBtnClick()
  if self.bListVisible == true then
    _G.NRCAudioManager:PlaySound2DAuto(1089, "UMG_BagDropDownList_C:OnSelectedBtnClick")
    self:SetScrollVisible(false)
  else
    _G.NRCAudioManager:PlaySound2DAuto(1086, "UMG_BagDropDownList_C:OnSelectedBtnClick")
    self:SetScrollVisible(true)
  end
end

function UMG_DebugDropGmDownList_C:SetScrollVisible(visible)
  if visible then
    self.CandidateListScroll:SetVisibility(UE4.ESlateVisibility.Visible)
    self.FrameBG:SetVisibility(UE4.ESlateVisibility.Visible)
    self.DownArrow:SetRenderTransformAngle(180)
    self.bListVisible = true
  else
    self.CandidateListScroll:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.FrameBG:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.DownArrow:SetRenderTransformAngle(0)
    self.bListVisible = false
  end
end

function UMG_DebugDropGmDownList_C:SelectItem(sortType)
  self:SetScrollVisible(false)
  self:SetSelectedIndex(sortType)
  local selected = {}
  table.insert(selected, sortType)
  self.ShowSelectedItem:InitGridView(selected)
end

function UMG_DebugDropGmDownList_C:SelectInfo(Data, IsAdd)
  if self.IsMultiSelect then
    if IsAdd then
      table.insert(self.MultiSelectList, Data)
    else
      for i = #self.MultiSelectList, 1, -1 do
        if self.MultiSelectList[i] == Data then
          table.remove(self.MultiSelectList, i)
        end
      end
    end
  else
    self.SingleSelection = Data
  end
end

function UMG_DebugDropGmDownList_C:SetTText()
  if self.IsMultiSelect then
    if self.MultiSelectList and #self.MultiSelectList > 0 then
      self.TText:SetText("\229\183\178\233\128\137\229\134\133\229\174\185")
    else
      self.TText:SetText("\230\156\170\233\128\137\229\134\133\229\174\185")
    end
  elseif self.SingleSelection then
    self.TText:SetText("\229\183\178\233\128\137\229\134\133\229\174\185")
  else
    self.TText:SetText("\230\156\170\233\128\137\229\134\133\229\174\185")
  end
end

function UMG_DebugDropGmDownList_C:Conversion(Data)
  if self.Data.type == ProtoEnum.AutoParamType.APT_INT or self.Data.type == ProtoEnum.AutoParamType.APT_INTLIST then
    return tonumber(Data)
  elseif self.Data.type == ProtoEnum.AutoParamType.APT_STRING or self.Data.type == ProtoEnum.AutoParamType.APT_STRINGLIST then
    return tostring(Data)
  elseif self.Data.type == ProtoEnum.AutoParamType.APT_FLOAT or self.Data.type == ProtoEnum.AutoParamType.APT_FLOATLIST then
    return tonumber(Data)
  end
end

function UMG_DebugDropGmDownList_C:GetMultiSelectList()
  return self.MultiSelectList
end

function UMG_DebugDropGmDownList_C:GetSingleSelection()
  return self.SingleSelection
end

function UMG_DebugDropGmDownList_C:SetColor(LinearColor)
  self.Text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(LinearColor))
end

return UMG_DebugDropGmDownList_C
