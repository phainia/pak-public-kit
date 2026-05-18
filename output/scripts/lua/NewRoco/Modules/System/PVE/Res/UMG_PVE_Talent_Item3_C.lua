local Base = require("NewRoco.Modules.System.PVE.Res.UMG_PVE_Talent_Item")
local UMG_PVE_Talent_Item3_C = Base:Extend("UMG_PVE_Talent_Item3_C")

function UMG_PVE_Talent_Item3_C:InitItem(itemConf)
  Base.InitItem(self, itemConf)
end

return UMG_PVE_Talent_Item3_C
