local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local ColorType = {
  Grey = 1,
  Yellow = 2,
  Green = 3
}
local UMG_LevelUpIconTemplateTest_C = Base:Extend("UMG_LevelUpIconTemplateTest_C")

function UMG_LevelUpIconTemplateTest_C:OnConstruct()
end

function UMG_LevelUpIconTemplateTest_C:OnDestruct()
end

function UMG_LevelUpIconTemplateTest_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  Log.Dump(self.uiData, 2, "icon_template_scroll")
  self:UpdateInfo()
  local size = UE4.FVector2D()
  size = self:GetDesiredSize()
end

function UMG_LevelUpIconTemplateTest_C:UpdateInfo()
  self:PlayAnimation(self.Circle_out)
  self.widget:SetVisibility(UE4.ESlateVisibility.Visible)
  self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:ChangeState(true)
  if 1 == self.uiData.type then
    local level = string.format("%d", self.uiData.level)
    self.NrcRedPoint:SetupKey(31, level)
    if self.uiData.level < 10 then
      self.LevelUpTipsText:SetText("0" .. self.uiData.level)
    else
      self.LevelUpTipsText:SetText(self.uiData.level)
    end
    self.LevelUpTipsText:SetVisibility(UE4.ESlateVisibility.Visible)
    self.LevelUpIconBG_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.LevelUpIconBG_4:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:BGVisiblePlayerLevel(self.uiData.awardState)
  elseif 2 == self.uiData.type then
    local level = string.format("%d", self.uiData.data.update_grade_level)
    self.NrcRedPoint:SetupKey(32, level)
    self.LevelUpTipsText:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.LevelUpIconBG_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.LevelUpIconBG_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:BGVisibleWorldLevel(self.uiData.awardState)
  else
    self.LevelUpIconBG_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.LevelUpIconBG_4:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:BGVisiblePlayerLevel(self.uiData.awardState)
  end
end

function UMG_LevelUpIconTemplateTest_C:BGVisiblePlayerLevel(state)
  if 0 == state or 5 == state then
    self.LevelUpIconBG_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.LevelUpIconBG_3:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif 1 == state then
    self.LevelUpIconBG_1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.LevelUpIconBG_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif 2 == state then
    self.AlreadyReceived:SetVisibility(UE4.ESlateVisibility.Visible)
    self.LevelUpIconBG_1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.LevelUpIconBG_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif -1 == state then
    self.widget:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_LevelUpIconTemplateTest_C:BGVisibleWorldLevel(state)
  if 1 == state then
    self.LevelUpIconBG_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.LevelUpIconBG_4:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif 2 == state then
    self.LevelUpIconBG_2:SetVisibility(UE4.ESlateVisibility.Visible)
    self.LevelUpIconBG_4:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif 3 == state then
    self.LevelUpIconBG_2:SetVisibility(UE4.ESlateVisibility.Visible)
    self.LevelUpIconBG_4:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif 4 == state then
    self.LevelUpIconBG_2:SetVisibility(UE4.ESlateVisibility.Visible)
    self.LevelUpIconBG_4:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif 5 == state then
    self.LevelUpIconBG_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.LevelUpIconBG_4:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif 6 == state then
    self.LevelUpIconBG_2:SetVisibility(UE4.ESlateVisibility.Visible)
    self.LevelUpIconBG_4:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_LevelUpIconTemplateTest_C:OnItemSelected(_bSelected, _bClick)
  local scale = UE4.FVector2D(1, 1)
  if _bSelected then
    if not _bClick then
    end
    local canScroll, ScrollIndex = _G.NRCModuleManager:DoCmd(LevelUpUIModuleCmd.CheckCanSetItemSelect, self.index)
    if self.ParentView and canScroll then
      self.ParentView:ScrollToIndex(self.index - 2, false)
      _G.NRCModuleManager:DoCmd(LevelUpUIModuleCmd.ChangeLevelListSelected, self.index)
    elseif self.ParentView and ScrollIndex then
      self.ParentView:ScrollToIndex(ScrollIndex - 2, false)
      _G.NRCModuleManager:DoCmd(LevelUpUIModuleCmd.ChangeLevelListSelected, ScrollIndex)
    end
  else
  end
end

function UMG_LevelUpIconTemplateTest_C:ChangeState(bBig)
  if bBig then
    self.Canvas:SetVisibility(UE4.ESlateVisibility.Visible)
    self:SetRenderOpacity(0.5)
    self:SetRenderScale(UE4.FVector2D(0.9, 0.9))
  else
    self.Canvas:SetVisibility(UE4.ESlateVisibility.Visible)
    self:SetRenderOpacity(1)
    self:SetRenderScale(UE4.FVector2D(1, 1))
  end
end

function UMG_LevelUpIconTemplateTest_C:SetScaleAndOpacity(percent)
  Log.Error(percent)
  local opacity = 0.09999999999999998 * percent + 0.9
  self.widget:SetRenderOpacity(opacity)
  local scale = 0.5 * percent + 0.5
  self.widget:SetRenderTransformScale(scale)
end

function UMG_LevelUpIconTemplateTest_C:OnDeactive()
end

return UMG_LevelUpIconTemplateTest_C
