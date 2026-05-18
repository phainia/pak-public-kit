local Base = require("NewRoco/Modules/System/MagicManual/Res/UMG_ChallengeItem_C")
local UMG_ChallengeItem_Dazzling_C = Base:Extend("UMG_ChallengeItem_Dazzling_C")

function UMG_ChallengeItem_Dazzling_C:OnConstruct()
  self.CueBubble:SetVisibility(UE.ESlateVisibility.Visible)
end

return UMG_ChallengeItem_Dazzling_C
