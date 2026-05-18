local UMG_ChatGvoice_C = _G.NRCPanelBase:Extend("UMG_ChatGvoice_C")
local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")
local RecordingCountDown = _G.DataConfigManager:GetGlobalConfigByKeyType("govice_startreconding_count_down_num", _G.DataConfigManager.ConfigTableId.GLOBAL_CONFIG).num

function UMG_ChatGvoice_C:OnActive()
end

function UMG_ChatGvoice_C:OnInitialize(PlayerUin)
  self.PlayerUin = PlayerUin and PlayerUin or nil
  self.Progress:SetPercent(0)
  self:OnAddEventListener(true)
  self:ChangeRegisterVoiceEvent(true)
  self.Switcher:SetActiveWidgetIndex(1)
  self.Text1:SetText("")
  self:OnTimerUpdate(RecordingCountDown)
  self.Btn_Send.Title_1:SetText(LuaText.chat_gvoice_record_complete)
end

function UMG_ChatGvoice_C:ChangeRegisterVoiceEvent(isRegister)
  if isRegister then
    _G.NRCEventCenter:RegisterEvent("UMG_ChatGvoice_C", self, FriendModuleEvent.VoiceStreamSpeechToTextHandle, self.OnVoiceStreamSpeechToTextHandle)
  else
    _G.NRCEventCenter:UnRegisterEvent(self, FriendModuleEvent.VoiceStreamSpeechToTextHandle, self.OnVoiceStreamSpeechToTextHandle)
  end
end

function UMG_ChatGvoice_C:OnAddEventListener(isAdd)
  if isAdd then
    self:AddButtonListener(self.Btn_Send.btnLevelUp, self.ChangeButtonState)
    self:AddButtonListener(self.Btn_Cancel.btnLevelUp, self.CloseVisibility)
  else
    self:RemoveButtonListener(self.Btn_Send.btnLevelUp)
    self:RemoveButtonListener(self.Btn_Cancel.btnLevelUp)
  end
end

function UMG_ChatGvoice_C:ChangeButtonState()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_ChatGvoice_C:CloseVisibility")
  if not self.IsWaitSpeech then
    if self.IsRecording then
      local Result = _G.GVoiceManager:StopRecording(true)
      self:RestChatGvoiceState()
      self.IsWaitSpeech = true
    else
      if self.GvoiceText and self.GvoiceText ~= "" then
        if self.PlayerUin then
          _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.SendChatMessage, self.PlayerUin, self.GvoiceText)
        end
      else
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.chat_gvoice_record_not_have_text)
      end
      self:CloseVisibility(true)
    end
  end
end

function UMG_ChatGvoice_C:UpdateSendButtonUI()
  if self.IsRecording then
    self.Switcher:SetActiveWidgetIndex(1)
    self.Btn_Send.Title_1:SetText(LuaText.chat_gvoice_record_complete)
  else
    self.Switcher:SetActiveWidgetIndex(0)
    self.Btn_Send.Title_1:SetText(LuaText.chat_gvoice_record_speech_text_send)
  end
end

function UMG_ChatGvoice_C:StartActive()
  self:AddRecordingTimer()
end

function UMG_ChatGvoice_C:OnTick()
  if self.IsRecording then
    local Level = _G.GVoiceManager:GetMicLevel()
    self.Progress:SetPercent(Level * 2)
  else
    self.Progress:SetPercent(0)
  end
end

function UMG_ChatGvoice_C:AddRecordingTimer()
  if RocoEnv.PLATFORM == "PLATFORM_OPENHARMONY" then
    local InternalStart = function(RetryCount)
      local Result = _G.GVoiceManager:StartRecording("", true)
      Log.Debug(string.format("[GVoice] Harmony Attempt %d, Result: %s", RetryCount + 1, tostring(Result)))
      if 0 == Result then
        self.GvoiceText = ""
        self:RemoveRecordingTimer()
        self.CurCountDown = RecordingCountDown
        self.IsRecording = true
        self.BeginRecordingTimer = _G.TimerManager:CreateTimer(self, "StartRecordingTimer", RecordingCountDown, self.OnTimerUpdate, self.OnTimerComplete, 1)
        self:UpdateSendButtonUI()
      elseif (12291 == Result or 12289 == Result) and RetryCount < 5 then
        self.RetryTimer = _G.TimerManager:CreateTimer(self, "GVoiceRetry", 0.3, nil, function()
          InternalStart(RetryCount + 1)
        end, 1)
      elseif 0 ~= Result then
        Log.Error("[GVoice] Harmony Final Failure. Code:", Result)
        self:CloseVisibility(true)
      end
    end
    InternalStart(0)
  else
    local Result = _G.GVoiceManager:StartRecording("", true)
    if 0 == Result then
      self.GvoiceText = ""
      self:RemoveRecordingTimer()
      self.CurCountDown = RecordingCountDown
      self.IsRecording = true
      self.BeginRecordingTimer = _G.TimerManager:CreateTimer(self, "StartRecordingTimer", RecordingCountDown, self.OnTimerUpdate, self.OnTimerComplete, 1)
      self:UpdateSendButtonUI()
    else
      self:CloseVisibility(true)
    end
  end
end

function UMG_ChatGvoice_C:OnTimerUpdate(Time)
  self.CurCountDown = Time and Time or self.CurCountDown - 1
  local CountDownText = string.format(LuaText.chat_gvoice_count_down_time, tostring(self.CurCountDown))
  self.Text2:SetText(CountDownText)
end

function UMG_ChatGvoice_C:OnTimerComplete()
  local Result = _G.GVoiceManager:StopRecording(true)
  self:RestChatGvoiceState()
  self.IsWaitSpeech = true
end

function UMG_ChatGvoice_C:RestChatGvoiceState()
  self.IsRecording = false
  self:RemoveRecordingTimer()
end

function UMG_ChatGvoice_C:CloseVisibility(IsNotSound)
  if not IsNotSound then
    _G.NRCAudioManager:PlaySound2DAuto(41401015, "UMG_ChatGvoice_C:CloseVisibility")
  end
  self:RestChatGvoiceState()
  self:OnAddEventListener(false)
  self:ChangeRegisterVoiceEvent(false)
  self:PlayAnimation(self.Out)
end

function UMG_ChatGvoice_C:RemoveRecordingTimer()
  if self.BeginRecordingTimer then
    _G.TimerManager:RemoveTimer(self.BeginRecordingTimer)
    self.BeginRecordingTimer = nil
  end
end

function UMG_ChatGvoice_C:IsWaitSpeechFalse()
  self.IsWaitSpeech = false
end

function UMG_ChatGvoice_C:OnVoiceStreamSpeechToTextHandle(Code, Error, Result, VoicePath)
  if self.IsWaitSpeech then
    self:IsWaitSpeechFalse()
    if 4096 == Code or 20481 == Code then
      if Result and "" ~= Result then
        self:UpdateText(Result)
        self:UpdateSendButtonUI()
      else
        self:CloseVisibility(true)
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.chat_gvoice_stream_speech_to_text_empty)
      end
    else
      self:CloseVisibility(true)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.chat_gvoice_stream_speech_to_text_empty)
    end
  end
end

function UMG_ChatGvoice_C:UpdateText(Result)
  local maxLength = _G.DataConfigManager:GetFriendGlobalConfig("friend_message_num_max").num
  local textLen = string.StringGetTotalNum(Result)
  if maxLength < textLen then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.chat_gvoice_speech_to_text_exceeding_limit, nil, nil, 1.0)
  end
  local ResultContent = string.GetSubStr(Result, maxLength)
  self.GvoiceText = ResultContent
  self.Text1:SetText(ResultContent)
end

function UMG_ChatGvoice_C:PlayerAnimIn()
  self:PlayAnimation(self.In)
end

function UMG_ChatGvoice_C:OnAnimationFinished(anim)
  if anim == self.Out then
    _G.NRCEventCenter:DispatchEvent(FriendModuleEvent.ChangeChatGvoiceVisibility, false)
  end
end

function UMG_ChatGvoice_C:OnDeactive()
  self:RemoveRecordingTimer()
end

return UMG_ChatGvoice_C
