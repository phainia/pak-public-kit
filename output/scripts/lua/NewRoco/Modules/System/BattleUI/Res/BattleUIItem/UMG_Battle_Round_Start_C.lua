local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local UMG_Battle_Round_Start_C = _G.NRCPanelBase:Extend("UMG_Battle_Round_Start_C")
local OriginalDigitalTextColorHex = "#F4EEE1FF"
local CountDownTextColorHex = "#C7494AFF"
local CountDownTextChangeToRedSecondThreshold = 3

function UMG_Battle_Round_Start_C:Construct()
  self._timer = 0
  self._lastTimer = 0
  self:Hide()
  self.battleManager = _G.BattleManager
  self:AddListener()
  self.currentDisplayType = BattleEnum.UmgBattleRoundStartDisplayType.None
  if self.Digital then
    self.Digital:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.Text then
    self.Text:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self.Num1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Num2:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Battle_Round_Start_C:Destruct()
  self:RemoveListener()
end

function UMG_Battle_Round_Start_C:OnActive(contextData)
  self.contextData = contextData
  local displayType = contextData and contextData.displayType
  local arg1 = contextData and contextData.arg1
  local arg2 = contextData and contextData.arg2
  if displayType == BattleEnum.UmgBattleRoundStartDisplayType.CountDown then
    local curRestTime = arg1
    local _countdown = arg2
    self:SetCD(curRestTime)
    self:BurnTime(_countdown)
  elseif displayType == BattleEnum.UmgBattleRoundStartDisplayType.RestRound then
    local roundCount = arg1
    self:DisplayRestRound(roundCount)
  else
    self:Hide()
  end
  local callbackOwner = contextData and contextData.callbackOwner
  local onOpenCallback = contextData and contextData.onOpenCallback
  self:DelayFrames(1, onOpenCallback, callbackOwner)
end

function UMG_Battle_Round_Start_C:OnDeactive()
  local contextData = self.contextData
  local callbackOwner = contextData and contextData.callbackOwner
  local onCloseCallback = contextData and contextData.onCloseCallback
  tcall(callbackOwner, onCloseCallback)
  self.contextData = nil
end

function UMG_Battle_Round_Start_C:SetCD(cd)
  if cd <= 0 then
    return
  end
  self._timer = cd
end

function UMG_Battle_Round_Start_C:Show()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.IsShow = true
end

function UMG_Battle_Round_Start_C:Hide(resetLastTimer)
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.IsShow = false
  if resetLastTimer then
    self._lastTimer = 0
  end
end

function UMG_Battle_Round_Start_C:GetIsShow()
  return self.IsShow
end

function UMG_Battle_Round_Start_C:_Refresh()
  local leftSecond = math.ceil(self._timer)
  if leftSecond == self._lastTimer then
    return
  end
  self._lastTimer = leftSecond
  if self.currentDisplayType == BattleEnum.UmgBattleRoundStartDisplayType.RestRound then
    return
  end
  local digitalText = tostring(leftSecond)
  local digitalColorAndOpacity = UE4.UNRCStatics.HexToSlateColor(CountDownTextColorHex)
  if leftSecond <= CountDownTextChangeToRedSecondThreshold then
    digitalColorAndOpacity = UE4.UNRCStatics.HexToSlateColor(CountDownTextColorHex)
  else
    digitalColorAndOpacity = UE4.UNRCStatics.HexToSlateColor(OriginalDigitalTextColorHex)
  end
  if self.Digital then
    self.Digital:SetText(digitalText)
    self.Digital:SetColorAndOpacity(digitalColorAndOpacity)
  end
  if self.Text then
    self.Text:SetRenderOpacity(1)
  end
  local countDownTextConfig = _G.DataConfigManager:GetLocalizationConf("Battle_Countdown_Round")
  local countDownText = countDownTextConfig and countDownTextConfig.msg or ""
  if self.Text then
    self.Text:SetText(countDownText)
  end
  self:Show()
  self:PlayAnimation(self.Last10)
  self.currentDisplayType = BattleEnum.UmgBattleRoundStartDisplayType.CountDown
end

function UMG_Battle_Round_Start_C:BurnTime(deltaTime)
  if self._timer <= 0 then
    return
  end
  self._timer = self._timer - deltaTime
  if self._timer >= 0 then
    self:_Refresh()
  elseif self._lastTimer > 0 then
    self._timer = 0
    self:_Refresh()
  end
end

function UMG_Battle_Round_Start_C:OnAnimationFinished(Animation)
  if Animation == self.Last10 then
    if self._timer and self.currentDisplayType ~= BattleEnum.UmgBattleRoundStartDisplayType.RestRound then
      if self._timer < 0 then
        self:Hide()
        self.currentDisplayType = BattleEnum.UmgBattleRoundStartDisplayType.None
        if self.Digital then
          self.Digital:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(OriginalDigitalTextColorHex))
        end
      end
    else
      Log.Error("timer\229\173\151\230\174\181\228\184\186\231\169\186\232\175\183\230\159\165\231\156\139\229\142\159\229\155\160")
    end
  elseif Animation == self.level_3_in then
    self:PlayAnimation(self.level_3_shake)
  elseif Animation == self.Word_out then
    self:Hide(false)
    self.currentDisplayType = BattleEnum.UmgBattleRoundStartDisplayType.None
  end
end

function UMG_Battle_Round_Start_C:DisplayRestRound(restRoundCount)
  if self.Digital then
    self.Digital:SetText(tostring(restRoundCount))
  end
  if self.Digital then
    self.Digital:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(OriginalDigitalTextColorHex))
  end
  local remainRoundTextConf = _G.DataConfigManager:GetLocalizationConf("Battle_Remaining_Round")
  local remainRoundText = remainRoundTextConf and remainRoundTextConf.msg or ""
  if self.Text then
    self.Text:SetText(remainRoundText)
  end
  self.currentDisplayType = BattleEnum.UmgBattleRoundStartDisplayType.RestRound
  self:Show()
  if restRoundCount <= 3 then
    self:PlayAnimation(self.level_3_in)
  elseif restRoundCount <= 5 then
    self:PlayAnimation(self.level_2_in)
  else
    self:PlayAnimation(self.level_1_in)
  end
  self:DelaySeconds(3, function()
    self:PlayAnimation(self.Word_out)
  end)
end

function UMG_Battle_Round_Start_C:AddListener()
end

function UMG_Battle_Round_Start_C:RemoveListener()
end

return UMG_Battle_Round_Start_C
