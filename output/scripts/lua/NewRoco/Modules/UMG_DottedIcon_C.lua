local UMG_DottedIcon_C = NRCUmgClass:Extend("UMG_DottedIcon_C")
local Utils = require("NewRoco/Modules/System/BigMap/BigMapUtils")

function UMG_DottedIcon_C:SetPath(Path, TUIWidget)
  Utils.SetupDottedEdgeImage(TUIWidget or self, self.IconFlag, Path)
end

function UMG_DottedIcon_C:SetDottedEdgeEnabled(bEnabled, TUIWidget)
  Utils.SetDottedEdgeEnabled(TUIWidget or self, self.IconFlag, bEnabled)
end

return UMG_DottedIcon_C
