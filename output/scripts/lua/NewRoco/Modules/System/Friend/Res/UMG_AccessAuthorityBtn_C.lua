local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local FriendModuleEvent = reload("NewRoco.Modules.System.Friend.FriendModuleEvent")
local UMG_AccessAuthorityBtn_C = Base:Extend("UMG_AccessAuthorityBtn_C")

function UMG_AccessAuthorityBtn_C:OnConstruct()
end

function UMG_AccessAuthorityBtn_C:OnDestruct()
end

function UMG_AccessAuthorityBtn_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.SortText:SetText(_data.text)
end

function UMG_AccessAuthorityBtn_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:StopAllAnimations()
    self:PlayAnimation(self.Press)
    _G.NRCModuleManager:GetModule("FriendModule"):DispatchEvent(FriendModuleEvent.OnAccessAuthorityClick, self.uiData.data)
  else
    self:StopAllAnimations()
    self:PlayAnimation(self.Cancel)
  end
end

function UMG_AccessAuthorityBtn_C:OnDeactive()
end

return UMG_AccessAuthorityBtn_C
