local TUIModuleEvent = require("NewRoco.Modules.System.TUI.TUIModuleEvent")
local UMG_NRCDropDownList_C = _G.NRCPanelBase:Extend("UMG_NRCDropDownList_C")

function UMG_NRCDropDownList_C:OnConstruct()
  _G.Log.Debug("UMG_NRCDropDownList_C:OnConstruct")
  self.uidata = nil
  self.selectedIndex = -1
  self.bListVisible = false
  self:SetScrollVisible(self.bListVisible)
  self:OnAddEventListener()
end

function UMG_NRCDropDownList_C:OnAddEventListener()
  self:AddButtonListener(self.SelectButton, self.OnSelectedBtnClick)
end

function UMG_NRCDropDownList_C:OnDestruct()
end

function UMG_NRCDropDownList_C:OnActive(data)
  Log.Debug("UMG_NRCDropDownList_C:OnActive")
  self.uidata = nil
  self.selectedIndex = -1
  self.bListVisible = false
  self:SetScrollVisible(self.bListVisible)
  self.uidata = data
  self:SetDropDownListInfo(data)
end

function UMG_NRCDropDownList_C:OnDeactive()
end

function UMG_NRCDropDownList_C:OnSelectedBtnClick()
  Log.Debug("UMG_DropDownList_C:OnSelectedBtnClick", self.bListVisible)
  if self.bListVisible == true then
    self:SetScrollVisible(false)
  else
    self:SetScrollVisible(true)
  end
end

function UMG_NRCDropDownList_C:SetScrollVisible(visible)
  Log.Debug("UMG_NRCDropDownList_C:SetScrollVisible", visible)
  if visible then
    self.CandidateListScroll:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Background:SetVisibility(UE4.ESlateVisibility.Visible)
    self.DownArrow:SetRenderTransformAngle(180)
    self.bListVisible = true
  else
    self.CandidateListScroll:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Background:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.DownArrow:SetRenderTransformAngle(0)
    self.bListVisible = false
  end
end

function UMG_NRCDropDownList_C:SetTemplateClass(templateClass)
end

function UMG_NRCDropDownList_C:SetDropDownListInfo(data)
  Log.Dump(data, 2, "UMG_DropDownList_C:SetDropDownListInfo")
  self.CandidateListScroll:InitList(data)
end

function UMG_NRCDropDownList_C:SetSelectedIndex(index)
  self.selectedIndex = index
end

function UMG_NRCDropDownList_C:GetSelectedIndex()
  return self.selectedIndex
end

function UMG_NRCDropDownList_C:SetArrowBG(path)
  self.DownArrow:SetPath(path)
end

function UMG_NRCDropDownList_C:SetScrollBG(path)
end

function UMG_NRCDropDownList_C:SelectItem(index)
  self:SetScrollVisible(false)
  self.SetSelectedIndex = index
  local selected = {}
  if self.uidata then
    table.insert(selected, self.uidata[index])
  end
  self.ShowSelectedItem:InitGridView(selected)
end

return UMG_NRCDropDownList_C
