local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local EmailModuleEvent = require("NewRoco.Modules.System.Email.EmailModuleEvent")
local UMG_Email_ListItme1_C = Base:Extend("UMG_Email_ListItme1_C")

function UMG_Email_ListItme1_C:OnConstruct()
end

function UMG_Email_ListItme1_C:OnDestruct()
end

function UMG_Email_ListItme1_C:OnItemUpdate(_data, datalist, index)
  if nil == _data then
    return
  end
  self.RedDot_1:SetupKey(64, {
    tostring(_data.ID)
  })
  self:PlayAnimation(self.Unselect_normal)
  self.data = _data
  self.index = index - 1
  self:ShowSelect(_data, index)
  self:ShowUnSelect(_data, index)
end

function UMG_Email_ListItme1_C:ShowSelect(_data, index)
  self.Title_2:SetText(_data.Title)
end

function UMG_Email_ListItme1_C:ShowUnSelect(_data, index)
  self.Title_3:SetText(self.data.Title)
end

function UMG_Email_ListItme1_C:OnItemSelected(_bSelected)
  if _bSelected and self.data then
    _G.NRCModuleManager:DoCmd(_G.EmailModuleCmd.RemoveNoticeRedPoint, self.data.ID)
    _G.NRCAudioManager:PlaySound2DAuto(40007005, "UMG_Email_ListItme_C:OnItemSelected")
    _G.GEMPostManager:SendActivityTLog(self.data.ID)
    self:StopAllAnimations()
    self:PlayAnimation(self.Select)
    _G.NRCModuleManager:GetModule("EmailModule"):DispatchEvent(EmailModuleEvent.SelectNoticeEvent, self.data, self.index)
  else
    self:PlayAnimation(self.Unselect)
    self:ChangeItemColor()
  end
end

function UMG_Email_ListItme1_C:ChangeItemColor()
  if self.data.is_read == true or true == self.data.is_recv then
    self:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("FFFFFF99"))
  else
    self:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("FFFFFFFF"))
  end
end

function UMG_Email_ListItme1_C:OnDeactive()
end

return UMG_Email_ListItme1_C
