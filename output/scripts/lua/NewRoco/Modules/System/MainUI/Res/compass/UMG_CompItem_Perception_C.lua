local Base = require("NewRoco.Modules.System.MainUI.Res.compass.CompItemBase")
local UMG_CompItem_Perception_C = Base:Extend("UMG_CompItem_Perception_C")

function UMG_CompItem_Perception_C:SetIcon(iconPath)
  if not string.IsNilOrEmpty(iconPath) then
    Base.SetIcon(self, iconPath)
  end
end

return UMG_CompItem_Perception_C
