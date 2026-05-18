local UMG_AlchemySort_C = _G.NRCPanelBase:Extend("UMG_AlchemySort_C")

function UMG_AlchemySort_C:OnActive(filterList, confName, condition)
  _G.NRCAudioManager:PlaySound2DAuto(40008005, "UMG_AlchemySort_C:OnActive")
  self.FilterItemList = filterList
  self.condition = condition
  local dataList = _G.DataConfigManager:GetTable(confName):GetAllDatas()
  self.SortList:InitGridView(dataList)
  self:ShowSelectCondition()
  self:OnAddEventListener()
end

function UMG_AlchemySort_C:OnDeactive()
end

function UMG_AlchemySort_C:OnAddEventListener()
  self:AddButtonListener(self.Btn1.btnLevelUp, self.OnConfirm)
  self:AddButtonListener(self.Btn2.btnLevelUp, self.OnReset)
  self:AddButtonListener(self.BtnClose, self.OnBtnClose)
end

function UMG_AlchemySort_C:ShowSelectCondition()
  if not self.condition then
    return
  end
  if not self.condition.FilterBasicCondition then
    return
  end
  for i = 1, self.SortList:GetItemCount() do
    local item = self.SortList:GetItemByIndex(i - 1)
    local conf = item.conf
    for j = 1, #self.condition.FilterBasicCondition do
      local enum = _G.Enum[conf.filter_enum_name][conf.filter_enum_value]
      if self.condition.FilterBasicCondition[j] == enum then
        self.SortList:SelectItemByIndex(i - 1)
      end
    end
  end
end

function UMG_AlchemySort_C:OnConfirm()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_AlchemySort_C:OnConfirm")
  local filterList, condition = self:OnFilterBasic()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.SelectManufactureBasicType, filterList, condition)
  self:OnClose()
end

function UMG_AlchemySort_C:OnFilterBasic()
  local filterBasic = {}
  for i = 1, self.SortList:GetItemCount() do
    local item = self.SortList:GetItemByIndex(i - 1)
    if item.clickToggle == true then
      local enum_type = item.conf.filter_enum_name
      local enum_value = item.conf.filter_enum_value
      local enum_filter = _G.Enum[enum_type][enum_value]
      table.insert(filterBasic, enum_filter)
    end
  end
  local filterList = {}
  filterList = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetFilterBasicList, filterBasic, self.FilterItemList)
  self.condition = {}
  self.condition.FilterBasicCondition = filterBasic
  return filterList, self.condition
end

function UMG_AlchemySort_C:OnReset()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_AlchemySort_C:OnReset")
  for i = 1, self.SortList:GetItemCount() do
    local item = self.SortList:GetItemByIndex(i - 1)
    item.clickToggle = false
    item.NRCSwitcher_48:SetActiveWidgetIndex(0)
  end
end

function UMG_AlchemySort_C:OnBtnClose()
  _G.NRCAudioManager:PlaySound2DAuto(40008006, "UMG_BagScreen_C:OnActive")
  self:OnClose()
end

return UMG_AlchemySort_C
