local UIUtils = require("NewRoco.Utils.UIUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_InvitationRecord_Item_C = Base:Extend("UMG_InvitationRecord_Item_C")

function UMG_InvitationRecord_Item_C:OnConstruct()
end

function UMG_InvitationRecord_Item_C:OnDestruct()
end

function UMG_InvitationRecord_Item_C:OnItemUpdate(_data, datalist, index)
  self.TextTime:SetText(_data.registerTime)
  UIUtils.SetPlayerHeadIcon(self.HeadIcon, _data.headIconId)
  self.RemarkName:SetText(_data.gameName)
  self.Name_1:SetText(_data.platformName)
  self.TextGrade:SetText(_data.role_level)
  self.TextUID:SetText(_data.uin)
end

function UMG_InvitationRecord_Item_C:OnItemSelected(_bSelected)
end

function UMG_InvitationRecord_Item_C:OnDeactive()
end

return UMG_InvitationRecord_Item_C
