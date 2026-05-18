local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Friend_Report_Item_C = Base:Extend("UMG_Friend_Report_Itme_C")

function UMG_Friend_Report_Item_C:OnConstruct()
end

function UMG_Friend_Report_Item_C:OnDestruct()
end

function UMG_Friend_Report_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.Index = index
  self:SetParent()
  self:SetInfo()
  self:OnAddEventListener()
  self.Parent:OnInitReportItem(index, self)
end

function UMG_Friend_Report_Item_C:SetParent()
  self.Parent = self.data.Parent
end

function UMG_Friend_Report_Item_C:OnAddEventListener()
  self.NRCButton_67.OnClicked:Add(self, self.OnClickCheckBtn)
end

function UMG_Friend_Report_Item_C:SetInfo()
  local data = self.data
  self.Text:SetText(self.data.Text)
  self:SetIsCheck(self.data.IsCheck)
end

function UMG_Friend_Report_Item_C:SetIsCheck(_IsCheck)
  self:StopAllAnimations()
  if _IsCheck then
    self:PlayAnimation(self.Click)
  elseif 0 ~= self.Check:GetRenderOpacity() then
    self:PlayAnimation(self.Click_out)
  end
end

function UMG_Friend_Report_Item_C:OnClickCheckBtn()
  local CheckResult = not self.data.IsCheck
  if CheckResult and self.Parent:CheckIsSelectEnough() then
    return
  end
  if CheckResult then
    self.Parent:OnSelectItem(self.Index)
  end
  self.data.IsCheck = CheckResult
  self:SetIsCheck(self.data.IsCheck)
  self.Parent:SetReportContentListInfo(CheckResult, self.Index)
  _G.NRCAudioManager:PlaySound2DAuto(41401019, "UMG_Plane_ExchangeVisits_C:OnActive")
end

function UMG_Friend_Report_Item_C:OnItemSelected(_bSelected)
end

function UMG_Friend_Report_Item_C:OnDeactive()
end

return UMG_Friend_Report_Item_C
