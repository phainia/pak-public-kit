local HandbookModuleEvent = reload("NewRoco.Modules.System.Handbook.HandbookModuleEvent")
local UMG_HandBook_RegionalSelection_C = _G.NRCPanelBase:Extend("UMG_HandBook_RegionalSelection_C")

function UMG_HandBook_RegionalSelection_C:OnConstruct()
end

function UMG_HandBook_RegionalSelection_C:OnActive()
  self:PlayAnimation(self.In)
  self:OnAddEventListener()
  local confs = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.AREA_HANDBOOK)
  if confs then
    local areaConfs = confs:GetAllDatas()
    local datas = {}
    for key, value in pairs(areaConfs) do
      local data = {}
      data.conf = value
      table.insert(datas, data)
    end
    self.NRCScrollView_66:InitList(datas)
    self.NRCScrollView_66:SetItemCanClickChecker(self.CheckTabCanClick, self)
  end
  self:BindInputAction()
end

function UMG_HandBook_RegionalSelection_C:OnDeactive()
end

function UMG_HandBook_RegionalSelection_C:OnAddEventListener()
  self:AddButtonListener(self.close_btn, self.OnClosePanel)
  self:RegisterEvent(self, HandbookModuleEvent.OnChangeAreaData, self.OnChangeAreaData)
end

function UMG_HandBook_RegionalSelection_C:OnChangeAreaData(areaItem)
  for i = 1, self.NRCScrollView_66:GetItemCount() do
    local item = self.NRCScrollView_66:GetItemByIndex(i - 1)
    item:UnSelectItem(areaItem)
  end
  self:OnClosePanel()
end

function UMG_HandBook_RegionalSelection_C:OnClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_Handbook1_C:ClickChangeAreaBtn")
  self:PlayAnimation(self.Out)
  self:RemoveButtonListener(self.close_btn, self.OnClosePanel)
  self:UnRegisterEvent(self, HandbookModuleEvent.OnChangeAreaData)
end

function UMG_HandBook_RegionalSelection_C:OnDestruct()
  self:RemoveButtonListener(self.close_btn, self.OnClosePanel)
  self:UnRegisterEvent(self, HandbookModuleEvent.OnChangeAreaData)
end

function UMG_HandBook_RegionalSelection_C:OnAnimationFinished(anim)
  if anim == self.Out then
    if GlobalConfig.DebugOpenUI then
      self:OnClose()
    end
    self:ClearAllEnhancedInput()
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_HandBook_RegionalSelection_C:BindInputAction()
  local priority = self.panel and self.panel.depth
  local mappingContext = self:AddInputMappingContext("IMC_HandBookRegionalSelection", priority)
  if mappingContext then
    mappingContext:BindAction("IA_CloseHandBookRegionalSelection", self, "OnPcClose2")
  end
end

function UMG_HandBook_RegionalSelection_C:OnPcClose2()
  self:OnClosePanel()
end

function UMG_HandBook_RegionalSelection_C:CheckTabCanClick(tabItem, tabIndex, userClick)
  local isBan = false
  if userClick then
    local tabIndexFunctionEntrance = {
      [1] = Enum.FunctionEntrance.FE_A1_HANDBOOK,
      [2] = Enum.FunctionEntrance.FE_A2_HANDBOOK
    }
    local funcId = tabIndexFunctionEntrance[tabIndex]
    if funcId then
      isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, funcId, true)
    end
    if isBan then
      _G.NRCAudioManager:PlaySound2DAuto(41401015, "UMG_RegionalSelection_List_C:OnItemSelected")
    end
  end
  return not isBan
end

return UMG_HandBook_RegionalSelection_C
