local Base = require("NewRoco.Modules.System.MainUI.Res.compass.CompItemBase")
local UMG_CompItem_Task_C = Base:Extend("UMG_CompItem_Task_C")

function UMG_CompItem_Task_C:SetIcon(path)
  local IconName = NRCUtils:GetIconName(path)
  local newPath = string.format("%s%s'", _G.UIIconPath.CompassTaskIcon, IconName) or path
  Base.SetIcon(self, newPath)
end

return UMG_CompItem_Task_C
