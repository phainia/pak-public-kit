local AICoachModuleUtils = require("NewRoco.Modules.System.AICoachModule.AICoachModuleUtils")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local AICoachModuleEvent = require("NewRoco.Modules.System.AICoachModule.AICoachModuleEvent")
local UMG_AICoachGvoice_C = _G.NRCPanelBase:Extend("UMG_AICoachGvoice_C")

function UMG_AICoachGvoice_C:OnActive()
  self.currSceneType = nil
  self.AIEmotionType = nil
  self.timerID = nil
  self.isNeedEnterAnim = false
  self.caller = nil
  self.callback = nil
  self.dotAnimTimerID = nil
  self.dotAnimIndex = 0
  self.dotAnimBaseText = ""
  self.isDotAnimPlaying = false
  self.NRCText_166:SetText(LuaText.ai_coach_18)
  self.AIChat:SetText(LuaText.ai_coach_19)
  self:OnAddEventListener()
end

function UMG_AICoachGvoice_C:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, AICoachModuleEvent.OnNotifyAICoachNarrationTextUpdate, self.OnNotifyAICoachNarrationTextUpdate)
  _G.NRCEventCenter:UnRegisterEvent(self, AICoachModuleEvent.OnNotifyAICoachTextUpdate, self.OnNotifyAICoachTextUpdate)
  _G.NRCEventCenter:UnRegisterEvent(self, AICoachModuleEvent.OnNotifyAICoachEmotionChange, self.OnNotifyAICoachEmotionChange)
  _G.NRCEventCenter:UnRegisterEvent(self, AICoachModuleEvent.OnNotifyAICoachRequestFinish, self.OnNotifyAICoachRequestFinish)
  if self.timerID then
    _G.DelayManager:CancelDelayById(self.timerID)
    self.timerID = nil
  end
  self:StopDotAnimation()
  self:CancelDelay()
  UpdateManager:UnRegister(self)
  self:RemoveAllButtonListener()
end

function UMG_AICoachGvoice_C:OnAddEventListener()
  _G.NRCEventCenter:RegisterEvent("UMG_AICoachGvoice_C", self, AICoachModuleEvent.OnNotifyAICoachNarrationTextUpdate, self.OnNotifyAICoachNarrationTextUpdate)
  _G.NRCEventCenter:RegisterEvent("UMG_AICoachGvoice_C", self, AICoachModuleEvent.OnNotifyAICoachTextUpdate, self.OnNotifyAICoachTextUpdate)
  _G.NRCEventCenter:RegisterEvent("UMG_AICoachGvoice_C", self, AICoachModuleEvent.OnNotifyAICoachEmotionChange, self.OnNotifyAICoachEmotionChange)
  _G.NRCEventCenter:RegisterEvent("UMG_AICoachGvoice_C", self, AICoachModuleEvent.OnNotifyAICoachRequestFinish, self.OnNotifyAICoachRequestFinish)
  self:AddButtonListener(self.btnClose.btnClose, self.OnCloseTips)
  self:AddButtonListener(self.BtnTimePet, self.OnAICoachClick)
end

function UMG_AICoachGvoice_C:OnOpenAICoach(sceneType, needShowTip)
  self.currSceneType = sceneType
  self.AIEmotionType = AICoachModuleUtils.EnumAICoachEmotion.Idle
  self.isNeedEnterAnim = true
  self:OnPlayAICoachEmotion(self.AIEmotionType)
  self.Progress:SetPercent(0)
  self.TextPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ChatContent:SetText("")
  if needShowTip then
    self.TipstPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.Text1_In)
    local delayTime = _G.DataConfigManager:GetGlobalConfig("ai_coach_tips_time").num or 5
    self:CancelDelay()
    self:DelaySeconds(delayTime, self.OnCloseTips, self)
  end
  UpdateManager:Register(self)
end

function UMG_AICoachGvoice_C:SetAICoachClickCallback(caller, callback)
  self.caller = caller
  self.callback = callback
end

function UMG_AICoachGvoice_C:IsCurrentSceneMatch()
  local sceneType = _G.NRCModuleManager:DoCmd(_G.AICoachModuleCmd.GetCurrAICoachScene)
  return self.currSceneType == sceneType
end

function UMG_AICoachGvoice_C:OnPlayAICoachEmotion(emotionType)
  if self.AIEmotionType and self.AIEmotionType == emotionType then
    return
  end
  self:StopAnimation(self.AICoach_cut_1_loop)
  if self.AIEmotionType == AICoachModuleUtils.EnumAICoachEmotion.Idle and emotionType == AICoachModuleUtils.EnumAICoachEmotion.Think then
    self:PlayAnimation(self.AICoach_cut_1)
    self:StartDotAnimation()
  elseif (self.AIEmotionType == AICoachModuleUtils.EnumAICoachEmotion.Think or self.AIEmotionType == AICoachModuleUtils.EnumAICoachEmotion.Idle) and emotionType == AICoachModuleUtils.EnumAICoachEmotion.Answer then
    self:PlayAnimation(self.AICoach_cut_2)
    self:StopDotAnimation()
  elseif self.AIEmotionType == AICoachModuleUtils.EnumAICoachEmotion.Answer and emotionType == AICoachModuleUtils.EnumAICoachEmotion.Idle then
    self:PlayAnimation(self.AICoach_cut_3)
  elseif self.AIEmotionType == AICoachModuleUtils.EnumAICoachEmotion.Think and emotionType == AICoachModuleUtils.EnumAICoachEmotion.Idle then
    self:PlayAnimation(self.AICoach_cut_4)
  end
  self.AIEmotionType = emotionType
end

function UMG_AICoachGvoice_C:OnNotifyAICoachEmotionChange(emotionType)
  if not self:IsCurrentSceneMatch() then
    return
  end
  self:OnPlayAICoachEmotion(emotionType)
end

function UMG_AICoachGvoice_C:OnNotifyAICoachTextUpdate(answerStr)
  if not self:IsCurrentSceneMatch() then
    return
  end
  if self.isDotAnimPlaying then
    self:StopDotAnimation()
  end
  self:UpdataChatContent(answerStr)
end

function UMG_AICoachGvoice_C:UpdataChatContent(text)
  if self.isNeedEnterAnim then
    if not self:IsAnimationPlaying(self.Text2_In) then
      self:PlayAnimation(self.Text2_In)
    end
    self.TextPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.isNeedEnterAnim = false
  end
  self.ChatContent:SetText(text)
end

function UMG_AICoachGvoice_C:OnNotifyAICoachNarrationTextUpdate(answerStr)
  if not self:IsCurrentSceneMatch() then
    return
  end
  self:StopDotAnimation()
  self:UpdataChatContent(answerStr)
  self:StartDotAnimation()
end

function UMG_AICoachGvoice_C:OnNotifyAICoachRequestFinish()
  if not self:IsCurrentSceneMatch() then
    return
  end
  if self.timerID then
    _G.DelayManager:CancelDelayById(self.timerID)
    self.timerID = nil
  end
  self.timerID = _G.DelayManager:DelaySeconds(5, function()
    if self and self:IsValid() then
      self.isNeedEnterAnim = true
      self.timerID = nil
      self:PlayAnimation(self.Text2_Out)
      self.ChatContent:SetText("")
    else
      Log.Warning("UMG_AICoachGvoice_C:OnNotifyAICoachRequestFinish - UMG_AICoachGvoice_C is no longer valid")
    end
  end)
end

function UMG_AICoachGvoice_C:SetAICoachText(text)
  self.isNeedEnterAnim = true
  self:OnNotifyAICoachTextUpdate(text)
end

function UMG_AICoachGvoice_C:OnCloseTips()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_FriendTeamPanel_C:OnCloseTips")
  self:PlayAnimation(self.Text1_Out)
end

function UMG_AICoachGvoice_C:OnAICoachClick()
  if self.caller and self.callback then
    self.callback(self.caller)
  end
  if self.TipstPanel:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
    self:OnCloseTips()
  end
end

function UMG_AICoachGvoice_C:OnTick()
  local isVoicePlaying = _G.NRCModuleManager:DoCmd(_G.AICoachModuleCmd.GetIsVoicePlaying)
  if isVoicePlaying then
    local voiceLevel = _G.GVoiceManager:GetSpeakerLevel()
    self.Progress:SetPercent(voiceLevel * 2)
  end
end

function UMG_AICoachGvoice_C:RecoverSceneAICoachState()
  self:OnPlayAICoachEmotion(AICoachModuleUtils.EnumAICoachEmotion.Idle)
  self:StopDotAnimation()
  self:PlayAnimation(self.Text2_Out)
  self.ChatContent:SetText("")
  self.TextPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.isNeedEnterAnim = true
end

function UMG_AICoachGvoice_C:OnAnimationFinished(anim)
  if anim == self.Text1_Out then
    self.TipstPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif anim == self.AICoach_cut_1 then
    self:PlayAnimation(self.AICoach_cut_1_loop, 0, 0)
  end
end

function UMG_AICoachGvoice_C:StartDotAnimation(baseText)
  if self.isDotAnimPlaying then
    self:StopDotAnimation()
  end
  self.isDotAnimPlaying = true
  self.dotAnimIndex = 0
  self.dotAnimBaseText = baseText or self.ChatContent:GetText() or ""
  self:UpdateDotAnimation()
end

function UMG_AICoachGvoice_C:StopDotAnimation()
  if self.dotAnimTimerID then
    _G.DelayManager:CancelDelayById(self.dotAnimTimerID)
    self.dotAnimTimerID = nil
  end
  if self.isDotAnimPlaying then
    self.isDotAnimPlaying = false
  end
end

function UMG_AICoachGvoice_C:UpdateDotAnimation()
  if not self.isDotAnimPlaying then
    return
  end
  self.dotAnimTimerID = _G.DelayManager:DelaySeconds(0.5, function()
    if self and self:IsValid() and self.isDotAnimPlaying then
      self.dotAnimIndex = self.dotAnimIndex % 3 + 1
      local dots = string.rep("\194\183", self.dotAnimIndex)
      self:UpdataChatContent(self.dotAnimBaseText .. dots)
      self:UpdateDotAnimation()
    end
  end)
end

return UMG_AICoachGvoice_C
