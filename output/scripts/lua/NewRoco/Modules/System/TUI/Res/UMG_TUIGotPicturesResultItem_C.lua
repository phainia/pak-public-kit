require("UnLuaEx")
local TUIModuleEvent = require("NewRoco.Modules.System.TUI.TUIModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_TUIGotPicturesResultItem_C = Base:Extend("UMG_TUIGotPicturesResultItem_C")

function UMG_TUIGotPicturesResultItem_C:OnConstruct()
end

function UMG_TUIGotPicturesResultItem_C:OnDestruct(_data, datalist, index)
end

function UMG_TUIGotPicturesResultItem_C:OnItemUpdate(_data, datalist, index)
  Log.Debug("UMG_TUIGotPicturesResultItem_C:OnItemUpdate")
  self.index = index
  self.data = _data
  self:ShowItem()
end

function UMG_TUIGotPicturesResultItem_C:ShowItem()
  self.Text:SetText(self.data)
end

function UMG_TUIGotPicturesResultItem_C:OnDeactive()
end

return UMG_TUIGotPicturesResultItem_C
