local Base = require("NewRoco.Modules.Activity.Activity.Res.UMG_Activity_WeekendLoginGiftBase")
local UMG_Activity_WeekendLoginGiftPopUp_C = Base:Extend("UMG_Activity_WeekendLoginGiftPopUp_C")

function UMG_Activity_WeekendLoginGiftPopUp_C:OnConstruct()
  Base.OnConstruct(self)
  self:AddButtonListener(self.CloseBtn, self.OnClickClose)
end

function UMG_Activity_WeekendLoginGiftPopUp_C:OnActive(activityInst)
  _G.NRCAudioManager:PlaySound2DAuto(41400007, "UMG_Activity_WeekendLoginGiftPopUp_C:OnActive")
  self:InitSignStages(activityInst, self.ItemGridView)
  if activityInst then
    activityInst:ReqGetPlayerActivityData()
  end
end

function UMG_Activity_WeekendLoginGiftPopUp_C:OnClickClose()
  _G.NRCAudioManager:PlaySound2DAuto(41400008, "UMG_Activity_WeekendLoginGiftPopUp_C:OnClickClose")
  self:OnClose()
end

function UMG_Activity_WeekendLoginGiftPopUp_C:OnPcClose()
  self:OnClickClose()
end

return UMG_Activity_WeekendLoginGiftPopUp_C
