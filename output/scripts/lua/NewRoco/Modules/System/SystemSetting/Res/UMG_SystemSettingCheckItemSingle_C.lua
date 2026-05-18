local SystemSettingModuleEvent = require("NewRoco.Modules.System.SystemSetting.SystemSettingModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SystemSettingCheckItemSingle_C = Base:Extend("UMG_SystemSettingCheckItemSingle_C")

function UMG_SystemSettingCheckItemSingle_C:OnConstruct()
end

function UMG_SystemSettingCheckItemSingle_C:OnDestruct()
end

function UMG_SystemSettingCheckItemSingle_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.FirstClick = false
  self.text:SetText(self.data.Name)
  self:StopAllAnimations()
  self.bHasSelected = self.data.Value > 0
  if self.bHasSelected then
    local endTime = self.Click:GetEndTime()
    self:PlayAnimationTimeRange(self.Click, endTime - 0.01, endTime, 1)
  else
    local endTime = self.Click_out:GetEndTime()
    self:PlayAnimationTimeRange(self.Click_out, endTime - 0.01, endTime, 1)
  end
  self:RefreshTextColorAndOpacity()
end

function UMG_SystemSettingCheckItemSingle_C:RefreshTextColorAndOpacity()
  self.text:SetColorAndOpacity(self.bHasSelected and UE4.UNRCStatics.HexToSlateColor("F4EEE0FF") or UE4.UNRCStatics.HexToSlateColor("62605EFF"))
end

function UMG_SystemSettingCheckItemSingle_C:OnItemSelected(_bSelected)
  if self.data and self.data.bIsJoystickOption then
    local joystickMode = _G.NRCModuleManager:DoCmd(MainUIModuleCmd.GetMoveJoystickMode)
    if _bSelected then
      if 1 == self.index then
        if joystickMode then
          self:ChangeJoystickMode(false)
        else
          return
        end
      elseif 2 == self.index then
        if joystickMode then
          return
        else
          self:ChangeJoystickMode(true)
        end
      end
    end
  end
  self.ShouldWaitFormAnimEnd = false
  if self.data and self.data.OnClickAnimationStartCallback then
    if self.data.OnClickAnimationStartCallbackOwner then
      self.data.OnClickAnimationStartCallback(self.data.OnClickAnimationStartCallbackOwner, self)
    else
      self.data.OnClickAnimationStartCallback(self)
    end
  end
  if not self.bHasSelected then
    self:StopAllAnimations()
    local startTime = self.Click:GetStartTime()
    local endTime = self.Click:GetEndTime()
    self:PlayAnimationTimeRange(self.Click, startTime, endTime, 1)
    _G.NRCAudioManager:PlaySound2DAuto(40007001, "UMG_SystemSettingCheckItemSingle_C:OnItemSelected")
  else
    self:StopAllAnimations()
    local startTime = self.Click_out:GetStartTime()
    local endTime = self.Click_out:GetEndTime()
    self:PlayAnimationTimeRange(self.Click_out, startTime, endTime, 1)
    _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_SystemSettingCheckItemSingle_C:OnItemSelected")
  end
  self.FirstClick = false
  self.bHasSelected = not self.bHasSelected
  if self.data and self.data.OnItemSelectedCallback then
    if self.data.OnItemSelectedCallbackOwner then
      self.data.OnItemSelectedCallback(self.data.OnItemSelectedCallbackOwner, self, self.bHasSelected)
    else
      self.data.OnItemSelectedCallback(self, self.bHasSelected)
    end
  end
  self:RefreshTextColorAndOpacity()
  self.ShouldWaitFormAnimEnd = true
end

function UMG_SystemSettingCheckItemSingle_C:OnAnimationFinished(anim)
  if not self.ShouldWaitFormAnimEnd then
    return
  end
  if (anim == self.Click and self.bHasSelected or anim == self.Click_out and not self.bHasSelected) and self.data and self.data.OnClickAnimationFinishCallback then
    if self.data.OnClickAnimationFinishCallbackOwner then
      self.data.OnClickAnimationFinishCallback(self.data.OnClickAnimationFinishCallbackOwner, self)
    else
      self.data.OnClickAnimationFinishCallback(self)
    end
  end
  self.ShouldWaitFormAnimEnd = false
end

function UMG_SystemSettingCheckItemSingle_C:OnDeactive()
  self.data = nil
end

function UMG_SystemSettingCheckItemSingle_C:ChangeJoystickMode(_bSelected)
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.ChangeMoveJoystickMode, _bSelected)
end

return UMG_SystemSettingCheckItemSingle_C
