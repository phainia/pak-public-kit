require("UnLuaEx")
local LoginModuleEvent = require("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ServerListItem_C = Base:Extend("UMG_ServerListItem_C")

function UMG_ServerListItem_C:OnItemUpdate(data, datalist, index)
  self.index = index
  self:SetData(data)
end

function UMG_ServerListItem_C:SetData(data)
  self.Display:SetText(data.key)
  self.data = data
  self.parent = self.data.parent
  local TargetIndex
  if self.data.isGroup then
    if not _G.GameSetting.GroupIndex then
      _G.GameSetting.GroupIndex = 1
    end
    TargetIndex = _G.GameSetting.GroupIndex
  else
    if not _G.GameSetting.ServerIndex then
      _G.GameSetting.ServerIndex = 1
    end
    TargetIndex = _G.GameSetting.ServerIndex
  end
  self:MarkItemSelected(TargetIndex == self.index)
  self:Log(">>>>>", self.index, _G.GameSetting.GroupIndex or -1, _G.GameSetting.ServerIndex or -1)
end

function UMG_ServerListItem_C:OnItemSelected(_bSelect)
  if _bSelect and self.data then
    self:MarkItemSelected(true)
    if self.data.isGroup then
      _G.GameSetting.GroupIndex = self.index
    else
      _G.GameSetting.ServerIndex = self.index
    end
    self:Log(">>>>>", _G.GameSetting.GroupIndex or -1, _G.GameSetting.ServerIndex or -1)
    NRCModuleManager:GetModule("LoginModule"):DispatchEvent(LoginModuleEvent.ItemClick, self.data)
  end
end

function UMG_ServerListItem_C:MarkItemSelected(Enable)
  self.Selected:SetVisibility(Enable and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Hidden)
  self.Display:SetColorAndOpacity(Enable and UE4.UNRCStatics.HexToSlateColor("#272727FF") or UE4.UNRCStatics.HexToSlateColor("#C3C1B4FF"))
end

function UMG_ServerListItem_C:ClearItemSelected()
  self.Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Display:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#C3C1B4FF"))
end

function UMG_ServerListItem_C:Destruct()
  self:ReleaseForce()
end

return UMG_ServerListItem_C
