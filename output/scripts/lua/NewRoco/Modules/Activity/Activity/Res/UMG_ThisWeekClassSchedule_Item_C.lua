local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_ItemBase_C")
local UMG_ThisWeekClassSchedule_Item_C = Base:Extend("UMG_ThisWeekClassSchedule_Item_C")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local FormatType = {Rounding = 1, Truncate = 2}

local function FormatProgressValue(value, formatType)
  if value < 10000 then
    return value
  end
  if formatType == FormatType.Rounding then
    return string.safeFormat(_G.LuaText.activity_task_million, math.floor(value / 10000 + 0.5))
  elseif formatType == FormatType.Truncate then
    return string.safeFormat(_G.LuaText.activity_task_million, math.floor(value / 10000))
  end
end

function UMG_ThisWeekClassSchedule_Item_C:OnConstruct()
  Base.OnConstruct(self)
  self:AddButtonListener(self.ClaimBtn.btnLevelUp, self.OnRewardBtnClick)
  self:AddButtonListener(self.RefreshBtn.btnLevelUp, self.OnRefreshBtnClick)
  self:AddButtonListener(self.GoBtn.btnLevelUp, self.OnJumpBtnClick)
end

function UMG_ThisWeekClassSchedule_Item_C:OnDestruct()
  Base.OnDestruct(self)
  self:RemoveButtonListener(self.ClaimBtn.btnLevelUp)
  self:RemoveButtonListener(self.RefreshBtn.btnLevelUp)
  self:RemoveButtonListener(self.GoBtn.btnLevelUp)
end

function UMG_ThisWeekClassSchedule_Item_C:SetDesc(desc)
  self.Text_Describe:SetText(desc or "")
end

function UMG_ThisWeekClassSchedule_Item_C:SetProgress(cur, total)
  cur = cur or 0
  total = total or 0
  self.ProgressText:SetText(FormatProgressValue(cur, FormatType.Truncate) .. "/" .. FormatProgressValue(total, FormatType.Rounding))
end

function UMG_ThisWeekClassSchedule_Item_C:SetCurrencyIconAndCnt(iconPath, count)
  self.CurrencyIcon:SetPath(iconPath)
  self.QuantityText:SetText("x" .. (count or 0))
end

function UMG_ThisWeekClassSchedule_Item_C:SetBtnSwitcher(index)
  self.BtnSwitcher:SetActiveWidgetIndex(index)
  self:ShowHideRefreshBtn(index)
end

function UMG_ThisWeekClassSchedule_Item_C:SetCompleted(completed)
  if completed then
    self:TryStopAnimation(self.Reward_ready_loop, true)
  end
end

function UMG_ThisWeekClassSchedule_Item_C:SetRedPoint(key, extraKey)
  self.ClaimBtn:SetRedDotExtraKey(key, extraKey)
end

function UMG_ThisWeekClassSchedule_Item_C:SetHideRefreshBtn(hideRefreshBtn)
  self.hideRefreshBtn = hideRefreshBtn
  self:ShowHideRefreshBtn(self.BtnSwitcher:GetActiveWidgetIndex())
end

function UMG_ThisWeekClassSchedule_Item_C:ShowHideRefreshBtn(btnIndex)
  if not self.hideRefreshBtn and (0 == btnIndex or 1 == btnIndex) then
    self.RefreshBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.RefreshBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ThisWeekClassSchedule_Item_C:OnRefreshBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_ThisWeekClassSchedule_C:OnRefreshBtnClick")
  local Ctx = DialogContext()
  Ctx:SetTitle(_G.LuaText.Activity_weekly_task_refresh_title):SetContent(_G.LuaText.Activity_CollegeGlory_weekly_task_refresh):SetContentTextJustify(UE4.ETextJustify.Center):SetMode(DialogContext.Mode.OK_CANCEL):SetButtonText(_G.LuaText.YES, _G.LuaText.NO):SetClickAnywhereClose(true):SetCloseOnCancel(true):SetCallbackOkOnly(self, self.OnConfirmRefreshScheduleItem)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function UMG_ThisWeekClassSchedule_Item_C:OnConfirmRefreshScheduleItem()
  self:InvokeParentFunc("OnRefreshBtnClick")
end

function UMG_ThisWeekClassSchedule_Item_C:OnJumpBtnClick()
  self:InvokeParentFunc("OnJumpBtnClick")
end

function UMG_ThisWeekClassSchedule_Item_C:OnRewardBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_ThisWeekClassSchedule_C:OnRewardBtnClick")
  self:InvokeParentFunc("OnRewardBtnClick")
end

function UMG_ThisWeekClassSchedule_Item_C:PlayInAnimation()
end

function UMG_ThisWeekClassSchedule_Item_C:PlayRewardGetAnimation()
  self:TryPlayAnimation(self.Stamp, false, 10)
end

function UMG_ThisWeekClassSchedule_Item_C:PlayRewardUnAvailableAnimation()
end

function UMG_ThisWeekClassSchedule_Item_C:PlayRewardAvailableAnimation()
end

function UMG_ThisWeekClassSchedule_Item_C:PlayRewardReceivedAnimation()
end

return UMG_ThisWeekClassSchedule_Item_C
