local Base = require("NewRoco.TUI.BP_ScrollViewItemBase_C")
local ColorType = {
  Grey = 1,
  Yellow = 2,
  Green = 3
}
local UMG_LevelUpIconTemplate_C = Base:Extend("UMG_LevelUpIconTemplate_C")

function UMG_LevelUpIconTemplate_C:Construct()
end

function UMG_LevelUpIconTemplate_C:Destruct()
  self.scrollView = nil
end

function UMG_LevelUpIconTemplate_C:OnActive()
end

function UMG_LevelUpIconTemplate_C:OnDeactive()
end

function UMG_LevelUpIconTemplate_C:SetData(_data)
  Base.SetData(self, _data)
  self.uiData = _data
  Log.Dump(self.uiData, 2, "icon_template")
  self:UpdateInfo()
end

function UMG_LevelUpIconTemplate_C:UpdateInfo()
  self.widget:SetVisibility(UE4.ESlateVisibility.Visible)
  if 1 == self.uiData.type then
    if self.uiData.level < 10 then
      self.LevelUpTipsText:SetText("0" .. self.uiData.level)
      self.LevelUpTipsText_1:SetText("0" .. self.uiData.level)
    else
      self.LevelUpTipsText:SetText(self.uiData.level)
      self.LevelUpTipsText_1:SetText(self.uiData.level)
    end
    self.LevelUpTipsText_1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.LevelUpTipsText:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Image_Tupo_1:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Image_Tupo:SetVisibility(UE4.ESlateVisibility.Hidden)
    self:BGVisiblePlayerLevel(self.uiData.awardState)
  elseif 2 == self.uiData.type then
    self.LevelUpTipsText_1:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.LevelUpTipsText:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Image_Tupo_1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Image_Tupo:SetVisibility(UE4.ESlateVisibility.Visible)
    self:BGVisibleWorldLevel(self.uiData.awardState)
  else
    self:BGVisiblePlayerLevel(self.uiData.awardState)
  end
end

function UMG_LevelUpIconTemplate_C:BGVisiblePlayerLevel(state)
  if 0 == state or 5 == state then
    self:SetToColor(ColorType.Grey)
  elseif 1 == state then
    self:SetToColor(ColorType.Yellow)
  elseif 2 == state then
    self:SetToColor(ColorType.Green)
  elseif -1 == state then
    self.widget:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_LevelUpIconTemplate_C:BGVisibleWorldLevel(state)
  if 1 == state then
    self:SetToColor(ColorType.Grey)
  elseif 2 == state then
    self:SetToColor(ColorType.Yellow)
  elseif 3 == state then
    self:SetToColor(ColorType.Yellow)
  elseif 4 == state then
    self:SetToColor(ColorType.Green)
  elseif 5 == state then
    self:SetToColor(ColorType.Grey)
  end
end

function UMG_LevelUpIconTemplate_C:SetToColor(Color)
  if Color == ColorType.Grey then
    self.LevelUpIconBG_3:SetVisibility(UE4.ESlateVisibility.Visible)
    self.LevelUpIconBG_3_Normal:SetVisibility(UE4.ESlateVisibility.Visible)
    self.LevelUpIconBG_1:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.LevelUpIconBG_1_Normal:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.LevelUpIconBG_2:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.LevelUpIconBG_2_Normal:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif Color == ColorType.Yellow then
    self.LevelUpIconBG_1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.LevelUpIconBG_1_Normal:SetVisibility(UE4.ESlateVisibility.Visible)
    self.LevelUpIconBG_2:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.LevelUpIconBG_2_Normal:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.LevelUpIconBG_3:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.LevelUpIconBG_3_Normal:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif Color == ColorType.Green then
    self.LevelUpIconBG_2:SetVisibility(UE4.ESlateVisibility.Visible)
    self.LevelUpIconBG_2_Normal:SetVisibility(UE4.ESlateVisibility.Visible)
    self.LevelUpIconBG_1:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.LevelUpIconBG_1_Normal:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.LevelUpIconBG_3:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.LevelUpIconBG_3_Normal:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_LevelUpIconTemplate_C:OnSelectionChange(_bSelected)
  local scale = UE4.FVector2D(1, 1)
  if _bSelected then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1083, "UMG_LevelUpIconTemplate_C:OnSelectionChange")
    self.Canvas_Normal:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Canvas:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Canvas_Normal:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Canvas:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_LevelUpIconTemplate_C:Selected(_bSelected)
end

function UMG_LevelUpIconTemplate_C:SetScrollView(scrollView)
  Base.SetScrollView(self, scrollView)
  self.scrollView = scrollView
end

function UMG_LevelUpIconTemplate_C:SetIndex(index)
  Base.SetIndex(self, index)
end

return UMG_LevelUpIconTemplate_C
