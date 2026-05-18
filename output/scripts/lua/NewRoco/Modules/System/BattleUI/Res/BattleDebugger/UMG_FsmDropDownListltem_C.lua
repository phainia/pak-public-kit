local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_FsmDropDownListltem_C = Base:Extend("UMG_FsmDropDownListltem_C")

function UMG_FsmDropDownListltem_C:OnConstruct()
end

function UMG_FsmDropDownListltem_C:OnDestruct()
end

function UMG_FsmDropDownListltem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetPanelInfo()
  self.CheckBtn.OnClicked:Add(self, self.OnCheckBtn)
  self.Button_41.OnClicked:Add(self, self.OnButton_41)
end

function UMG_FsmDropDownListltem_C:OnCheckBtn()
  self.data.IsCheck = not self.data.IsCheck
  self:SetCheckSwitcher(self.data.IsCheck)
end

function UMG_FsmDropDownListltem_C:OnButton_41()
  self.data.Parent:SetChildPosition(self.data.name)
end

function UMG_FsmDropDownListltem_C:SetPanelInfo()
  local data = self.data
  self.TText:SetText(data.name)
  if data.IsNewAdd then
    self.TText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#FF0000FF"))
  else
    self.TText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#FFFFFFFF"))
  end
  self.Num:SetText(data.num)
  self:SetCheckSwitcher(data.IsCheck)
end

function UMG_FsmDropDownListltem_C:SetCheckSwitcher(IsCheck)
  if IsCheck then
    self.CheckSwitcher:SetActiveWidgetIndex(1)
  else
    self.CheckSwitcher:SetActiveWidgetIndex(0)
  end
end

function UMG_FsmDropDownListltem_C:OnItemSelected(_bSelected)
  if _bSelected and self.data.Parent then
    self.data.Parent:SetChildPosition(self.data.name)
  end
end

function UMG_FsmDropDownListltem_C:OnDeactive()
end

return UMG_FsmDropDownListltem_C
