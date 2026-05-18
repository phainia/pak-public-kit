local UMG_GlobalBlack_C = require("NewRoco.Modules.System.BlackScreen.Res.UMG_GlobalBlack_C")
local Base = UMG_GlobalBlack_C
local UMG_GlobalWhite_C = Base:Extend("UMG_GlobalWhite_C")

function UMG_GlobalWhite_C:OnConstruct()
  Base.OnConstruct(self)
  self.bIsBlack = false
end

return UMG_GlobalWhite_C
