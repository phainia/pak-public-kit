local HandbookModuleEvent = reload("NewRoco.Modules.System.Handbook.HandbookModuleEvent")
local HandbookModuleCmd = reload("NewRoco.Modules.System.Handbook.HandbookModuleCmd")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_BookDropDownList_C = _G.NRCPanelBase:Extend("UMG_BookDropDownList_C")

function UMG_BookDropDownList_C:OnConstruct()
  self.bListVisible = false
  self:SetScrollVisible(self.bListVisible)
  if UE4.UKismetSystemLibrary.IsValid(self.NRCButton_0) then
    self.NRCButton_0:SetRenderScale(UE4.FVector2D(-1, -1))
  end
  self:SetDropDownListInfo()
  self:OnAddEventListener()
end

function UMG_BookDropDownList_C:OnDestruct()
  self:RemoveButtonListener(self.SelectButton, self.OnSelectedBtnClick)
  self:RemoveButtonListener(self.NRCButton_0, self.OnClickNRCButton_0)
end

function UMG_BookDropDownList_C:OnActive()
  local selectId = _G.NRCModuleManager:GetModule("HandbookModule").data.HandbookLeftSortIndex or 1
  _G.NRCEventCenter:DispatchEvent(BagModuleEvent.UpdateSort, selectId)
  local sortConf = _G.DataConfigManager:GetPetHandbookSequence(selectId)
  local sortType = sortConf.sequence_switch
  local selected = {}
  table.insert(selected, sortType)
  self.ShowSelectedItem:InitGridView(selected)
end

function UMG_BookDropDownList_C:OnAddEventListener()
  self:AddButtonListener(self.SelectButton, self.OnSelectedBtnClick)
  self:AddButtonListener(self.NRCButton_0, self.OnClickNRCButton_0)
  self:AddButtonListener(self.Button_Search, self.OnOpenSearch)
end

function UMG_BookDropDownList_C:OnSelectedBtnClick()
  local list = {}
  local conf1 = _G.DataConfigManager:GetPetHandbookSequence(1)
  local conf2 = _G.DataConfigManager:GetPetHandbookSequence(2)
  local info1 = {
    id = conf1.id,
    text = conf1.sequence_desc,
    sequence = conf1.sequence_switch
  }
  local info2 = {
    id = conf2.id,
    text = conf2.sequence_desc,
    sequence = conf2.sequence_switch
  }
  table.insert(list, info1)
  table.insert(list, info2)
  local selectId = _G.NRCModuleManager:GetModule("HandbookModule").data.HandbookLeftSortIndex
  local sortConf = _G.DataConfigManager:GetPetHandbookSequence(selectId)
  local sortType = sortConf.sequence_switch
  _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenBagSortPanel, list, sortType)
  self:SetFlashBackBtnType(true)
end

function UMG_BookDropDownList_C:OnOpenSearch()
  _G.NRCAudioManager:PlaySound2DAuto(1013, "UMG_BookDropDownList_C:OnSelectedBtnClick")
  _G.NRCModeManager:DoCmd(_G.HandbookModuleCmd.OnCmdOpenHandbookSearch)
end

function UMG_BookDropDownList_C:OnClickNRCButton_0()
  if self.bListVisible then
    self:SetScrollVisible(false)
    _G.NRCModuleManager:GetModule("HandbookModule"):DispatchEvent(HandbookModuleEvent.OnBookDropDownListClose, false)
    return
  end
  local isReversal = NRCModuleManager:DoCmd(HandbookModuleCmd.GetHandbookLeftReversal)
  if 2 == self.sortIndex then
    if not isReversal then
      self.NRCButton_0:SetRenderScale(UE4.FVector2D(-1, 1))
    else
      self.NRCButton_0:SetRenderScale(UE4.FVector2D(-1, -1))
    end
  elseif not isReversal then
    self.NRCButton_0:SetRenderScale(UE4.FVector2D(-1, -1))
  else
    self.NRCButton_0:SetRenderScale(UE4.FVector2D(-1, 1))
  end
  NRCModuleManager:DoCmd(HandbookModuleCmd.ReversedSort)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1238, "UMG_BookDropDownList_C:OnClickNRCButton_0")
end

function UMG_BookDropDownList_C:ShowReversalButtonState()
  local isReversal = NRCModuleManager:DoCmd(HandbookModuleCmd.GetHandbookLeftReversal)
  if 2 == self.sortIndex then
    if isReversal then
      self.NRCButton_0:SetRenderScale(UE4.FVector2D(-1, 1))
    else
      self.NRCButton_0:SetRenderScale(UE4.FVector2D(-1, -1))
    end
  elseif isReversal then
    self.NRCButton_0:SetRenderScale(UE4.FVector2D(-1, -1))
  else
    self.NRCButton_0:SetRenderScale(UE4.FVector2D(-1, 1))
  end
end

function UMG_BookDropDownList_C:SetScrollVisible(visible)
  if visible then
    self.bListVisible = true
  else
    self.bListVisible = false
  end
  _G.NRCModuleManager:GetModule("HandbookModule"):DispatchEvent(HandbookModuleEvent.OnBookDropDownListClose, visible)
end

function UMG_BookDropDownList_C:SetIsCanSort(_IsCanSort)
  local uiData = self.uidata
  for i, v in ipairs(uiData) do
    v.IsCanSort = _IsCanSort
  end
end

function UMG_BookDropDownList_C:SetDropDownListInfo()
  local list = {1, 2}
  local index = self:GetSelectedIndex()
end

function UMG_BookDropDownList_C:SetFlashBackBtnType(_isascendingorder)
  if _isascendingorder then
    self:PlayAnimation(self.Expand)
  else
    self:PlayAnimation(self.Put_away)
  end
end

function UMG_BookDropDownList_C:SetSelectedIndex(index)
  self.selectedIndex = index
end

function UMG_BookDropDownList_C:GetSelectedIndex()
  return self.selectedIndex
end

function UMG_BookDropDownList_C:SetArrowBG(path)
  self.DownArrow:SetPath(path)
end

function UMG_BookDropDownList_C:SetScrollBG(path)
end

function UMG_BookDropDownList_C:SelectItem(sortType)
  if self.bListVisible == true then
    self:SetScrollVisible(false)
  end
  self:SetSelectedIndex(sortType)
  self.sortIndex = sortType
  self:ShowReversalButtonState()
  local selected = {}
  table.insert(selected, sortType)
  self.ShowSelectedItem:InitGridView(selected)
end

function UMG_BookDropDownList_C:OnDeactive()
end

return UMG_BookDropDownList_C
