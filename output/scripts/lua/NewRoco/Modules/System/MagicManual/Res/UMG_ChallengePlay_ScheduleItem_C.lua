local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ChallengePlay_ScheduleItem_C = Base:Extend("UMG_ChallengePlay_ScheduleItem_C")

function UMG_ChallengePlay_ScheduleItem_C:OnConstruct()
end

function UMG_ChallengePlay_ScheduleItem_C:OnDestruct()
end

function UMG_ChallengePlay_ScheduleItem_C:OnItemUpdate(_data, datalist, index)
  self.Title:SetText(_data.ScheduleText)
  local Count = string.format("%d/%d", _data.FinishChallengeEventStarNum, _data.ChallengeEventSchedule)
  self.Text_Content_1:SetText(Count)
  self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if 2 == index or _data.bShouldShowStar then
    self.Switcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher:SetActiveWidgetIndex(1)
    if _data.starIconPath then
      self.NRCImage_35:SetPath(_data.starIconPath)
    else
      self.NRCImage_35:SetPath("PaperSprite'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Frames/img_xing4_png.img_xing4_png'")
    end
  end
end

function UMG_ChallengePlay_ScheduleItem_C:OnItemSelected(_bSelected)
end

function UMG_ChallengePlay_ScheduleItem_C:OnDeactive()
end

return UMG_ChallengePlay_ScheduleItem_C
