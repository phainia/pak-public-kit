local Base = require("NewRoco.Modules.System.Common.res.CommonAttrBase")
local UMG_Common_Attr_C = Base:Extend("UMG_Common_Attr_C")

function UMG_Common_Attr_C:OpItem(opType)
  if opType.type and 0 == opType.type and opType.animName and opType.animName == "Press" then
    self:PlayAnimation(self.Press)
  end
end

return UMG_Common_Attr_C
