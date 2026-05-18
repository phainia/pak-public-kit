local TipsModuleEvent = require("NewRoco.Modules.System.TipsModule.TipsModuleEvent")
local EventDispatcher = require("Common.EventDispatcher")
local DialogContext = NRCClass()
DialogContext.Mode = {
  OK = 1,
  OK_CANCEL = 2,
  NotBtn = 3,
  CANCEL = 4
}
DialogContext.OverrideMode = {
  Default = 1,
  ReplaceAndDiscard = 2,
  ReplaceAndKeep = 3
}
DialogContext.DialogType = {SystemNotice = 0, GeneralTip = 1}
DialogContext.DialogTag = {Common = 0, DifferentAccount = 1}
DialogContext.EAutoCloseOnWifiBtnHandlerType = {
  None = 0,
  OK = 1,
  CANCEL = 2
}

function DialogContext:Ctor()
  EventDispatcher():Attach(self)
  self.title = nil
  self.content = nil
  self.content1 = nil
  self.Content2 = nil
  self.contentBase = nil
  self.contentTextJustify = nil
  self.mode = DialogContext.Mode.OK
  self.okText = nil
  self.cancelText = nil
  self.debugInfo = nil
  self.autoCloseOnOk = true
  self.autoCloseOnCancel = true
  self.listener = nil
  self.listenHandler = nil
  self.listenerOk = nil
  self.listenHandlerOk = nil
  self.clickAnywhereClose = false
  self.bCancelAnyway = false
  self.timerData = nil
  self.ShowBtn = true
  self.okIcon = "PaperSprite'/Game/NewRoco/Modules/System/Common/Raw/Frames/img_queren_png.img_queren_png'"
  self.cancelIcon = "PaperSprite'/Game/NewRoco/Modules/System/Common/Raw/Frames/img_quxiao_png.img_quxiao_png'"
  self.toppingType = -1
  self.okConsumeItemType = nil
  self.okConsumeItemNum = nil
  self.okConsumeItemCost = nil
  self.countdownBtnMode = DialogContext.Mode.OK
  self.countdownTime = nil
  self.bReconnect = false
  self.bBlockPcEsc = false
  self.IsNoEffect = false
  self.AutoCloseOnWifiBtnHandlerType = DialogContext.EAutoCloseOnWifiBtnHandlerType.None
  self.priority = 0
  self.dialogTag = DialogContext.DialogTag.Common
  Log.Info("DialogContext:InitDialogTag ", self.dialogTag)
  self.RichTextListener = nil
  self.RichTextListenerHandler = nil
end

function DialogContext:BlockPcEsc()
  self.bBlockPcEsc = true
  return self
end

function DialogContext:SetTitle(title)
  self.title = title
  return self
end

function DialogContext:SetContent(content)
  self.content = content
  return self
end

function DialogContext:SetBtnShow(ShowBtn)
  self.ShowBtn = ShowBtn
  return self
end

function DialogContext:SetContentTextJustify(textJustify)
  self.contentTextJustify = textJustify
  return self
end

function DialogContext:SetDebugInfo(debugInfo)
  self.debugInfo = debugInfo
  return self
end

function DialogContext:SetMode(mode)
  self.mode = mode
  return self
end

function DialogContext:SetContent1(content1)
  self.content1 = content1
  return self
end

function DialogContext:SetContent2(content2)
  self.content2 = content2
  return self
end

function DialogContext:SetContentBase(ContentBase)
  self.contentBase = ContentBase
  return self
end

function DialogContext:SetCloseBtnNotDoCancel(bCloseBtnNotDoCancel)
  self.closeBtnNotDoCancel = bCloseBtnNotDoCancel
  return self
end

function DialogContext:SetCloseOnOK(boo)
  self.autoCloseOnOk = boo
  return self
end

function DialogContext:SetCloseOnCancel(boo)
  self.autoCloseOnCancel = boo
  return self
end

function DialogContext:SetClickAnywhereClose(boo)
  self.clickAnywhereClose = boo
  return self
end

function DialogContext:SetCancelAnyway(boo)
  self.bCancelAnyway = boo
  return self
end

function DialogContext:SetButtonText(okText, cancelText)
  self.okText = okText
  self.cancelText = cancelText
  return self
end

function DialogContext:SetCallback(listener, listenHandler)
  self.listener = listener
  self.listenHandler = listenHandler
  return self
end

function DialogContext:SetCallbackOkOnly(listener, listenHandler)
  self.listenerOk = listener
  self.listenHandlerOk = listenHandler
  return self
end

function DialogContext:SetContentText2OnRichTextClickHandler(listener, listenHandler)
  self.RichTextListener = listener
  self.RichTextListenerHandler = listenHandler
  return self
end

function DialogContext:SetButtonIcon(okIcon, cancelIcon)
  self.okIcon = okIcon
  self.cancelIcon = cancelIcon
  return self
end

function DialogContext:SetToppingIconType(typeIndex)
  self.toppingType = typeIndex
  return self
end

function DialogContext:Close()
  self:SendEvent(TipsModuleEvent.Tips_CloseDialogue)
end

function DialogContext:SetConsumeItem(okConsumeItemType, okConsumeItemCost)
  self.okConsumeItemType = okConsumeItemType
  self.okConsumeItemCost = okConsumeItemCost
end

function DialogContext:SetForceEnableFullScreenBtn()
  self.bForceEnableFullScreen = true
end

function DialogContext:SetBanFullScreenBtn()
  self.BanFullScreenBtn = true
end

function DialogContext:SetReOpenFunc(func)
  self.ReOpenFunc = func
end

function DialogContext:SetReconnect(bReconnect)
  self.bReconnect = bReconnect
  return self
end

function DialogContext:SetCloseFlagWhenPlayerDie()
  self.CloseFlag = true
end

function DialogContext:SetDialogType(type)
  return self:_SetPriority(type)
end

function DialogContext:_SetPriority(priority)
  self.priority = priority
  return self
end

function DialogContext:SetCountdown(mode, timer)
  self.countdownBtnMode = mode
  self.countdownTime = timer
  return self
end

function DialogContext:SetIsNoEffect(_IsNoEffect)
  self.IsNoEffect = _IsNoEffect
end

function DialogContext:GetIsNoEffect()
  return self.IsNoEffect
end

function DialogContext:SetIsOnlyForNetwork()
  self._isOnlyForNetwork = true
end

function DialogContext:IsOnlyForNetwork()
  return self._isOnlyForNetwork
end

function DialogContext:SetDialogTag(dialogTag)
  Log.Info("DialogContext:SetDialogTag ", dialogTag)
  self.dialogTag = dialogTag
end

function DialogContext:GetDialogTag()
  Log.Info("DialogContext:GetDialogTag ", self.dialogTag)
  return self.dialogTag
end

function DialogContext:SetCloseOnNetworkStatusTurnToWifi(BtnHandlerType)
  self.AutoCloseOnWifiBtnHandlerType = BtnHandlerType
  return self
end

function DialogContext:GetAutoCloseOnWifiBtnHandlerType()
  return self.AutoCloseOnWifiBtnHandlerType
end

function DialogContext:SetIfHideCloseBtn(Value)
  self.bIfHideCloseBtn = Value
  return self
end

return DialogContext
