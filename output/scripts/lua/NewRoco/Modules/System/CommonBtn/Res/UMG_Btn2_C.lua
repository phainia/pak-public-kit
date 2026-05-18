local UMG_BtnBase = require("NewRoco.Modules.System.CommonBtn.Res.UMG_BtnBase")
local UMG_Btn2_C = UMG_BtnBase:Extend("UMG_Btn2_C")

function UMG_Btn2_C:SetShowLockIcon(_bShow)
  if _bShow then
    self.img_suo:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.img_suo:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_Btn2_C
