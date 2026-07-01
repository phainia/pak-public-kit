local UMG_AIChatGvoice_C = _G.NRCPanelBase:Extend("UMG_AIChatGvoice_C")
local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")

function UMG_AIChatGvoice_C:OnConstruct()
  self:OnAddEventListener()
  self.Text1:SetHintText(_G.LuaText.ai_coach_20)
end

function UMG_AIChatGvoice_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_AIChatGvoice_C:OnInitialize()
  self.GvoiceText = self.Text1:GetHintText()
  self.Text1:SetText("")
  self:PlayAnimation(self.In)
end

function UMG_AIChatGvoice_C:OnAddEventListener()
  self:AddDelegateListener(self.Text1.OnTextChanged, self.OnTextChanged)
  self:AddButtonListener(self.Btn_Gvoice, self.OpenChatGvoice)
  self:AddButtonListener(self.Btn_Cancel.btnLevelUp, self.ClickCancel)
  self:AddButtonListener(self.Btn_Send.btnLevelUp, self.SendAIText)
end

function UMG_AIChatGvoice_C:OnRemoveEventListener()
  self:RemoveDelegateListener(self.Text1.OnTextChanged)
  self:RemoveButtonListener(self.Btn_Gvoice)
  self:RemoveButtonListener(self.Btn_Cancel.btnLevelUp)
  self:RemoveButtonListener(self.Btn_Send.btnLevelUp)
end

function UMG_AIChatGvoice_C:OnTextChanged(text)
  if text ~= self.GvoiceText then
    local outPutText = string.SafeGsubLiteral(text, "\r\n", "")
    outPutText = string.SafeGsubLiteral(outPutText, "\n", "")
    local len = string.StringGetTotalNum(outPutText)
    if len > _G.DataConfigManager:GetGlobalConfig("share_pet_search_word_limit").num then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.chat_message_send_empty_tips2)
      self.Text1:SetText(self.GvoiceText or "")
      return
    end
    if outPutText ~= text then
      self.Text1:SetText(outPutText)
    end
    self.GvoiceText = "" == outPutText and self.Text1:GetHintText() or outPutText
  end
end

function UMG_AIChatGvoice_C:OpenChatGvoice()
  _G.NRCAudioManager:PlaySound2DAuto(40002013, "UMG_AIChatGvoice_C:OpenChatGvoice")
  self.bOpenChatGvoice = true
  self:PlayAnimation(self.Out)
end

function UMG_AIChatGvoice_C:ClickCancel()
  _G.NRCAudioManager:PlaySound2DAuto(41401015, "UMG_AIChatGvoice_C:ClickCancel")
  self:PlayAnimation(self.Out)
end

function UMG_AIChatGvoice_C:SendAIText()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_AIChatGvoice_C:SendAIText")
  if self.GvoiceText and self.GvoiceText ~= "" then
    local outPutText = string.SafeGsubLiteral(self.GvoiceText, "\r\n", "")
    outPutText = string.SafeGsubLiteral(outPutText, "\n", "")
    local textLen = string.StringGetTotalNum(outPutText)
    local noSpaceText = string.SafeGsubLiteral(outPutText, " ", "")
    if 0 == #noSpaceText or textLen > _G.DataConfigManager:GetGlobalConfig("share_pet_search_word_limit").num then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.chat_message_send_empty_tips2)
      return
    end
    _G.NRCModuleManager:DoCmd(_G.AICoachModuleCmd.SendAICoachQuestion, outPutText)
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.chat_gvoice_record_not_have_text)
  end
  self:PlayAnimation(self.Out)
end

function UMG_AIChatGvoice_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    if self.bOpenChatGvoice then
      _G.NRCEventCenter:DispatchEvent(FriendModuleEvent.OpenChatGvoicePanel)
      self.bOpenChatGvoice = nil
    end
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_AIChatGvoice_C
