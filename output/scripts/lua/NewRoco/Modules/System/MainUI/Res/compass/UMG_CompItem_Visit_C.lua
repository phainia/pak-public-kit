local Base = require("NewRoco.Modules.System.MainUI.Res.compass.CompItemBase")
local UMG_CompItem_Visit_C = Base:Extend("UMG_CompItem_Visit_C")

function UMG_CompItem_Visit_C:SetIndex(Index)
  self.SerialNumber:SetText(Index)
end

return UMG_CompItem_Visit_C
