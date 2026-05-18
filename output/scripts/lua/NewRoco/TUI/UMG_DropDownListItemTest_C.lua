require("UnLuaEx")
local TUIModuleEvent = require("NewRoco.Modules.System.TUI.TUIModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_DropDownListItemTest_C = Base:Extend("UMG_DropDownListItemTest_C")

function UMG_DropDownListItemTest_C:Destruct()
end

function UMG_DropDownListItemTest_C:OnItemUpdate(_data, datalist, index)
  Log.Debug("UMG_DropDownListItemTest_C:OnItemUpdate")
  self.index = index
  self:SetData(_data)
end

function UMG_DropDownListItemTest_C:SetData(data)
  self.TText:SetText(data.key)
  self.TText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(data.color))
end

function UMG_DropDownListItemTest_C:OnClick()
  Log.Debug("UMG_DropDownListItemTest_C:OnClick")
  NRCModuleManager:DoCmd(TUIModuleCmd.ItemSelected, self.index)
end

return UMG_DropDownListItemTest_C
