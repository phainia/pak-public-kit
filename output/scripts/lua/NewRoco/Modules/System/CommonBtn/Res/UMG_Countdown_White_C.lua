local UMG_Countdown_White_C = _G.NRCViewBase:Extend("UMG_Countdown_White_C")

function UMG_Countdown_White_C:OnConstruct()
  self.Timestamp = nil
  self.TextPrompt = nil
  self.IsShowDay = false
  self.Call = nil
  self.Handler = nil
end

function UMG_Countdown_White_C:InitializeData(_Timestamp, _TextPrompt, _IsShowDay, _Call, _Handler)
  self.Timestamp = _Timestamp
  self.TextPrompt = _TextPrompt
  self.IsShowDay = _IsShowDay
  self.Call = _Call
  self.Handler = _Handler
end

function UMG_Countdown_White_C:OnDestruct()
  self:ClearCountDown()
end

function UMG_Countdown_White_C:OnActive()
end

function UMG_Countdown_White_C:OnDeactive()
end

function UMG_Countdown_White_C:OnAddEventListener()
end

function UMG_Countdown_White_C:ShowCountDown()
  self.TimeRemaining:SetText(self:FormatTime(self.Timestamp))
  self:ClearCountDown()
  self:DelaySeconds(1, function()
    self:OnDownTime()
  end)
end

function UMG_Countdown_White_C:OnDownTime()
  self.Timestamp = self.Timestamp - 1
  self.TimeRemaining:SetText(self:FormatTime(self.Timestamp))
  self.DelayId = self:DelaySeconds(1, function()
    self:OnDownTime()
  end)
  if self.Timestamp <= 0 then
    self:ClearCountDown()
    if self.Call and self.Handler then
      self.Handler(self.Call)
    end
  end
end

function UMG_Countdown_White_C:ClearCountDown()
  self:CancelDelay()
end

function UMG_Countdown_White_C:FormatTime(time)
  if not time then
    Log.Debug("\230\178\161\230\156\137\230\151\182\233\151\180\230\149\176\230\141\174\232\175\183\230\159\165\231\156\139\229\142\159\229\155\160")
    return ""
  end
  local hour, min, day
  if self.IsShowDay then
    day = time // 86400
    hour = (time - 86400 * day) // 3600
  else
    hour = time // 3600
    min = (time - 3600 * hour) // 60
  end
  local timeStr
  if self.TextPrompt then
    if self.IsShowDay then
      timeStr = string.format(LuaText.common_countdown_display_1, self.TextPrompt, day, hour)
    else
      timeStr = string.format(LuaText.common_countdown_display_2, self.TextPrompt, hour, min)
    end
  elseif self.IsShowDay then
    timeStr = string.format(LuaText.common_countdown_display_3, day, hour)
  else
    timeStr = string.format(LuaText.common_countdown_display_4, hour, min)
  end
  return timeStr
end

return UMG_Countdown_White_C
