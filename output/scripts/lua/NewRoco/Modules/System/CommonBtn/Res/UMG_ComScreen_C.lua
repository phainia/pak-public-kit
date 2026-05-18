local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local LevelSelectionModuleEvent = require("NewRoco.Modules.System.LevelSelection.LevelSelectionModuleEvent")
local UMG_ComScreen_C = _G.NRCPanelBase:Extend("UMG_ComScreen_C")

function UMG_ComScreen_C:OnActive()
end

function UMG_ComScreen_C:OnDeactive()
end

function UMG_ComScreen_C:SetPetInfos(datas)
  self.petInfos = datas
end

function UMG_ComScreen_C:SetCurSortId(sortId)
  self.curSortId = sortId
  local name = _G.DataConfigManager:GetTravelSequenceConf(sortId).sequence_desc
  self.SortText:SetText(name)
end

function UMG_ComScreen_C:SetFilterCondition(condition)
  self.FilterCondition = condition
  local isSwitch = condition.FilterDepartCondition and #condition.FilterDepartCondition > 0 or condition.FilterGenderCondition and #condition.FilterGenderCondition > 0
  if isSwitch then
    self.ScreenBtnSwitcher:SetActiveWidgetIndex(1)
  else
    self.ScreenBtnSwitcher:SetActiveWidgetIndex(0)
  end
end

function UMG_ComScreen_C:SetReverse(Reverse)
  self.IsReverse = Reverse
  if self.IsReverse then
    self.sequencebtn:SetRenderScale(UE4.FVector2D(-1, 1))
  else
    self.sequencebtn:SetRenderScale(UE4.FVector2D(-1, -1))
  end
end

function UMG_ComScreen_C:OnAddEventListener()
  self:AddButtonListener(self.ScreenBtn, self.OnClickScreenBtn)
  self:AddButtonListener(self.SortBtn, self.OnClickSortBtn)
  self:AddButtonListener(self.sequencebtn, self.OnClicksequencebtn)
  self.ScreenBtn.OnPressed:Add(self, self.OnScreenBtnPressed)
  self.ScreenBtn.OnReleased:Add(self, self.OnScreenBtnReleased)
  self.SortBtn.OnPressed:Add(self, self.OnSortBtnPressed)
  self.SortBtn.OnReleased:Add(self, self.OnSortBtnReleased)
end

function UMG_ComScreen_C:OnScreenBtnPressed()
  self:PlayAnimation(self.Btn1_press)
end

function UMG_ComScreen_C:OnScreenBtnReleased()
  self:PlayAnimation(self.Btn1_up)
end

function UMG_ComScreen_C:OnSortBtnPressed()
  self:PlayAnimation(self.Btn2_press)
end

function UMG_ComScreen_C:OnSortBtnReleased()
  self:PlayAnimation(self.Btn2_up)
end

function UMG_ComScreen_C:OnsequencebtnPressed()
  self:PlayAnimation(self.Btn3_press)
end

function UMG_ComScreen_C:OnsequencebtnReleased()
  self:PlayAnimation(self.Btn3_up)
end

function UMG_ComScreen_C:OnConstruct()
  self.FilterCondition = {}
  if not self.IsInit then
    self:OnAddEventListener()
    self.IsInit = true
    return
  end
  self.Customize = false
end

function UMG_ComScreen_C:OnSetSortConf(Customize)
  self.Customize = Customize
end

function UMG_ComScreen_C:OnDestruct()
  self:RemoveButtonListener(self.ScreenBtn, self.OnClickScreenBtn)
  self:RemoveButtonListener(self.SortBtn, self.OnClickSortBtn)
  self:RemoveButtonListener(self.sequencebtn, self.OnClicksequencebtn)
  self.ScreenBtn.OnPressed:Remove(self, self.OnScreenBtnPressed)
  self.ScreenBtn.OnReleased:Remove(self, self.OnScreenBtnReleased)
  self.SortBtn.OnPressed:Remove(self, self.OnSortBtnPressed)
  self.SortBtn.OnReleased:Remove(self, self.OnSortBtnReleased)
end

function UMG_ComScreen_C:OnAnimationFinished(anim)
end

function UMG_ComScreen_C:OnClickScreenBtn()
  if self.petInfos == nil then
    return
  end
  for i = 1, #self.petInfos do
    local filterData = {}
    filterData.petbase_id = self.petInfos[i].base_conf_id
    filterData.gid = self.petInfos[i].gid
    filterData.gender = self.petInfos[i].gender
    self.petInfos[i].filterData = filterData
  end
  _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenFilterPanel, self.petInfos, _G.DataConfigManager.ConfigTableId.TRAVEL_FILTER_CONF, self.FilterCondition)
end

function UMG_ComScreen_C:OnSwitcherScreenBtnSwitcher(SwitcherIndex)
  self.ScreenBtnSwitcher:SetActiveWidgetIndex(SwitcherIndex)
end

function UMG_ComScreen_C:OnClickSortBtn()
  if self.Customize == true then
    return
  end
  local list = {}
  for i = 1, 2 do
    local sortInfo = {}
    local sortId = i
    local name = _G.DataConfigManager:GetTravelSequenceConf(sortId).sequence_desc
    sortInfo.text = name
    sortInfo.sequence = sortId
    table.insert(list, sortInfo)
  end
  _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenBagSortPanel, list, self.curSortId)
end

function UMG_ComScreen_C:OnClicksequencebtn()
  _G.NRCEventCenter:DispatchEvent(LevelSelectionModuleEvent.OnPetListReversalSort)
end

return UMG_ComScreen_C
