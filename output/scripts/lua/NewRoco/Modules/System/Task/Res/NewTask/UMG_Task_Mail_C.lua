local TaskEnum = require("NewRoco.Modules.Core.Battle.Common.TaskEnum")
local UMG_Task_Mail_C = _G.NRCPanelBase:Extend("UMG_Task_Mail_C")

function UMG_Task_Mail_C:OnActive(messageId, Action)
  if _G.GlobalConfig.DebugOpenUI then
    self:OnAddEventListener()
    return
  end
  self.Action = Action
  self.data = self.module:GetData("TaskModuleData")
  self.messageId = messageId
  self.FirstOnClick = true
  self.IsCanClick = true
  self:SetPanelInfo()
  self:SetBtnInfo()
  self.Btn_Envelope:SetIsEnabled(false)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1331, "UMG_Task_Mail_C:OnActive")
  self:PlayAnimation(self.In)
  self.localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.localPlayer.inputComponent:SetInputEnable(self, false)
  self.localPlayer.inputComponent:SetCameraControlEnable(self, false)
  self:AddPcInputBlock()
  self:OnAddEventListener()
  self:BindInputAction()
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.SetLockOpenSubUI, false)
  UE4Helper.SetDesiredShowCursor(true, "UMG_Task_Mail_C")
end

function UMG_Task_Mail_C:OnDeactive()
  if self.localPlayer then
    self.localPlayer.inputComponent:SetInputEnable(self, true)
    self.localPlayer.inputComponent:SetCameraControlEnable(self, true)
    self.localPlayer = nil
  end
  if self.data then
    self.data:SetIsOpenTips(false)
  end
  if self.Action then
    self.Action:Finish(true)
    self.Action = nil
  end
  self.IsCanClick = true
  self:RemovePcInputBlock()
  UE4Helper.ReleaseDesiredShowCursor("UMG_Task_Mail_C")
end

function UMG_Task_Mail_C:AddPcInputBlock()
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.AddBlockIMC, self, self.depth)
end

function UMG_Task_Mail_C:RemovePcInputBlock()
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.RemoveBlockIMC, self)
end

function UMG_Task_Mail_C:OnAddEventListener()
  self:AddButtonListener(self.Btn3.btnLevelUp, self.OnClickReadBtn)
  self:AddButtonListener(self.Btn_Envelope, self.OnEnvelope)
end

function UMG_Task_Mail_C:SetPanelInfo()
  if not self.messageId or 0 == self.messageId then
    self.messageId = 10000
    Log.Error("message_id\233\133\141\231\189\174\230\154\130\230\151\182\230\178\161\230\149\176\230\141\174,\230\173\164\229\164\132\233\187\152\232\174\164\228\184\18610000")
  end
  local MessageConf = _G.DataConfigManager:GetMessageConf(self.messageId)
  self:SetEnvelope(MessageConf.envelop_style)
  self:SetLetterPaper(MessageConf.page_style)
  self:SetPostmark(MessageConf.receive_style)
  self.Name:SetText(MessageConf.myname)
  self.Content:SetText(MessageConf.text)
  if MessageConf.icon then
    self.NRCImage_89:SetPath(MessageConf.icon)
  end
  if MessageConf.envelop_icon then
    self.NRCSwitcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCSwitcher_0:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_57:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.envelope1_9:SetPath(MessageConf.envelop_icon)
    self.envelope1_2:SetPath(MessageConf.envelop_icon)
    self.envelope1_2_2:SetPath(MessageConf.envelop_icon)
    self.envelope1_1:SetPath(MessageConf.envelop_icon)
    self:LoadPanelRes(MessageConf.envelop_icon, -1, self.LoadSucceed, nil, nil)
  else
    self.NRCSwitcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCSwitcher_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasPanel_57:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  Log.Debug(self.messageId, MessageConf.letter_icon, MessageConf.sender, "UMG_Task_Mail_C:SetPanelInfo")
  if MessageConf.letter_icon then
    self.Stamp:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Stamp:SetPath(MessageConf.letter_icon)
  else
    self.Stamp:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if MessageConf.sender then
    self.Name_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Name_1:SetText(MessageConf.sender)
  else
    self.Name_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Task_Mail_C:LoadSucceed(resRequest, asset)
  local Material = self.envelope1_10:GetDynamicMaterial()
  Material:SetTextureParameterValue("Maintex", asset)
  Material:SetTextureParameterValue("Mask_Texture", asset)
  local Material2 = self.envelope1_3:GetDynamicMaterial()
  Material2:SetTextureParameterValue("Maintex", asset)
  Material2:SetTextureParameterValue("Mask_Texture", asset)
end

function UMG_Task_Mail_C:OnEnvelope()
  if _G.GlobalConfig.DebugOpenUI then
    self:OnClose()
    return
  end
  if self.FirstOnClick == true then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1332, "UMG_Task_Mail_C:OnEnvelope")
    self:PlayAnimation(self.OpenAnimation)
  end
  self.FirstOnClick = false
end

function UMG_Task_Mail_C:SetBtnInfo()
  self.Btn3:SetBtnText(LuaText.umg_task_mail_1)
end

function UMG_Task_Mail_C:OnClickReadBtn()
  if not self.IsCanClick then
    return
  end
  self.IsCanClick = false
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_Task_Mail_C:OnClickReadBtn")
  self:PlayAnimation(self.Out)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1333, "UMG_Task_Mail_C:OnClickReadBtn")
end

function UMG_Task_Mail_C:OnAnimationFinished(anim)
  if anim == self.Out then
    _G.NRCModeManager:DoCmd(TaskModuleCmd.ZoneReportTaskReq, self.messageId)
    self:DoClose()
  elseif anim == self.In then
    self.Btn_Envelope:SetIsEnabled(true)
  elseif anim == self.OpenAnimation then
  end
end

function UMG_Task_Mail_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_TaskMail")
  if mappingContext then
    mappingContext:BindAction("IA_CloseTaskMail", self, "OnPcClose2")
  end
end

function UMG_Task_Mail_C:OnPcClose2()
end

function UMG_Task_Mail_C:SetEnvelope(type)
  if type == _G.Enum.LetterSkin.LETTER_ACADEMY_SKIN then
    self.envelope1_5:SetPath("Texture2D'/Game/NewRoco/Modules/System/Task/Raw/NewTask/img_InvitationLetter2.img_InvitationLetter2'")
    self.envelope1:SetPath("Texture2D'/Game/NewRoco/Modules/System/Task/Raw/NewTask/img_InvitationLetter3.img_InvitationLetter3'")
    self.Open_2:SetPath("Texture2D'/Game/NewRoco/Modules/System/Task/Raw/NewTask/img_InvitationLetter1.img_InvitationLetter1'")
    self.Open_4:SetPath("Texture2D'/Game/NewRoco/Modules/System/Task/Raw/NewTask/img_InvitationLetter4.img_InvitationLetter4'")
    self.Open_3:SetPath("Texture2D'/Game/NewRoco/Modules/System/Task/Raw/NewTask/img_InvitationLetter2.img_InvitationLetter2'")
    self.envelope1_8:SetPath("Texture2D'/Game/NewRoco/Modules/System/Task/Raw/NewTask/img_InvitationLetter3.img_InvitationLetter3'")
  else
    self.envelope1_5:SetPath("Texture2D'/Game/NewRoco/Modules/System/Task/Raw/NewTask/img_xinfeng2.img_xinfeng2'")
    self.envelope1:SetPath("Texture2D'/Game/NewRoco/Modules/System/Task/Raw/NewTask/img_xinfeng3.img_xinfeng3'")
    self.Open_2:SetPath("Texture2D'/Game/NewRoco/Modules/System/Task/Raw/NewTask/img_xinfeng1.img_xinfeng1'")
    self.Open_4:SetPath("Texture2D'/Game/NewRoco/Modules/System/Task/Raw/NewTask/img_xinfeng4.img_xinfeng4'")
    self.Open_3:SetPath("Texture2D'/Game/NewRoco/Modules/System/Task/Raw/NewTask/img_xinfeng2.img_xinfeng2'")
    self.envelope1_8:SetPath("Texture2D'/Game/NewRoco/Modules/System/Task/Raw/NewTask/img_xinfeng3.img_xinfeng3'")
  end
end

function UMG_Task_Mail_C:SetLetterPaper(type)
  local pos = self.VerticalBox_0.Slot:GetPosition()
  if type == _G.Enum.LetterPaper.LP_ACADEMY_PAPER then
    self.Open_9:SetPath("Texture2D'/Game/NewRoco/Modules/System/Task/Raw/NewTask/img_InvitationLetter5.img_InvitationLetter5'")
    self.Open_11:SetPath("Texture2D'/Game/NewRoco/Modules/System/Task/Raw/NewTask/img_InvitationLetter6.img_InvitationLetter6'")
    pos.Y = -183
  else
    self.Open_9:SetPath("Texture2D'/Game/NewRoco/Modules/System/Task/Raw/NewTask/img_xinfeng5.img_xinfeng5'")
    self.Open_11:SetPath("Texture2D'/Game/NewRoco/Modules/System/Task/Raw/NewTask/img_xinfeng6.img_xinfeng6'")
    pos.Y = -304
  end
  self.VerticalBox_0.Slot:SetPosition(pos)
end

function UMG_Task_Mail_C:SetPostmark(type)
  if type == _G.Enum.LetterReceiveStyle.LRS_LETTER_BIGPOST then
    self.NRCSwitcher:SetActiveWidgetIndex(1)
    self.NRCSwitcher_0:SetActiveWidgetIndex(1)
  else
    self.NRCSwitcher:SetActiveWidgetIndex(0)
    self.NRCSwitcher_0:SetActiveWidgetIndex(0)
  end
end

return UMG_Task_Mail_C
