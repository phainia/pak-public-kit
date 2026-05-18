local Base = require("NewRoco.Modules.Activity.Activity.Res.UMG_Activity_WeekendLoginGiftBase")
local UMG_Activity_WeekendLoginGift_C = Base:Extend("UMG_Activity_WeekendLoginGift_C")

function UMG_Activity_WeekendLoginGift_C:BindUIElements()
  local uiElements = {}
  uiElements.desireActivityType = Enum.ActivityType.ATP_ACTIVITY_REWARD_BY_STAGE
  uiElements.title = self.Text_Title
  uiElements.promptText = self.Text_Describe
  uiElements.bgImage = self.BG
  uiElements.timeRemaining = self.Text_TimeRemaining
  uiElements.timeRemainingRoot = self.CanvasPanel_356
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  uiElements.closeAnimName = "Out"
  return uiElements
end

function UMG_Activity_WeekendLoginGift_C:OnConstruct()
  Base.OnConstruct(self)
  self:InitSignStages(self.activityInst, self.ItemGridView)
end

return UMG_Activity_WeekendLoginGift_C
