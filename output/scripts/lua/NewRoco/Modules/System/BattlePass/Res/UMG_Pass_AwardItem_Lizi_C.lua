local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Pass_AwardItem_Lizi_C = Base:Extend("UMG_Pass_AwardItem_Lizi_C")

function UMG_Pass_AwardItem_Lizi_C:OnConstruct()
end

function UMG_Pass_AwardItem_Lizi_C:OnDestruct()
end

function UMG_Pass_AwardItem_Lizi_C:OnDeactive()
end

function UMG_Pass_AwardItem_Lizi_C:PlayLoopAnim()
  self:PlayAnimation(self.Lizi_Loop, 0, 0)
end

function UMG_Pass_AwardItem_Lizi_C:StopLoopAnim()
  self:StopAnimation(self.Lizi_Loop)
end

return UMG_Pass_AwardItem_Lizi_C
