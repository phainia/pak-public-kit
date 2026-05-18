local Base = require("NewRoco.Modules.System.MainUI.Res.UMG_Hud_Base")
local RealtimeDialogModuleCmd = require("NewRoco.Modules.System.RealtimeDialog.RealtimeDialogModuleCmd")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local DeviceUtils = require("NewRoco.Modules.Core.App.DeviceUtils")
local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local ShowID = RocoEnv.IS_EDITOR or not RocoEnv.IS_SHIPPING and _G.AppMain:HasLaunchParams()
local UMG_Hud_OpenDialogue_C = Base:Extend("UMG_Hud_OpenDialogue_C")

function UMG_Hud_OpenDialogue_C:OnConstruct()
  _G.NRCEventCenter:RegisterEvent(self.name, self, MainUIModuleEvent.MAINUIOPEN, self.OnLobbyMainReady)
  _G.NRCEventCenter:RegisterEvent(self.name, self, MainUIModuleEvent.MAINUICLOSE, self.OnLobbyMainClosed)
end

function UMG_Hud_OpenDialogue_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, MainUIModuleEvent.MAINUIOPEN, self.OnLobbyMainReady)
  _G.NRCEventCenter:UnRegisterEvent(self, MainUIModuleEvent.MAINUICLOSE, self.OnLobbyMainClosed)
end

function UMG_Hud_OpenDialogue_C:OnEnable(hudLoad, DialogKey, DialogConf, Actor, OptionID)
  if hudLoad then
    self:ShowDialogPanel(DialogKey, DialogConf, Actor, OptionID)
  end
end

function UMG_Hud_OpenDialogue_C:OnDisable()
  print("==amonsu=====RealtimeDialogModule===OnDisable=", self.DialogKey, self.DialogConf.id)
  if self.DelayHandler then
    _G.DelayManager:CancelDelayById(self.DelayHandler)
    self.DelayHandler = nil
  end
  if self.bIsVisible then
    _G.NRCModuleManager:DoCmd(RealtimeDialogModuleCmd.UpdateDialogList, self.DialogKey, self.OptionID, false, self.DialogConf)
    self.bIsVisible = false
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Hud_OpenDialogue_C:OnAddEventListener()
end

function UMG_Hud_OpenDialogue_C:ShowDialogPanel(DialogKey, DialogConf, Actor, OptionID)
  if DeviceUtils:OptimizeNameLabel() then
    self.CanvasPanel_0:SetRenderOpacity(1)
  else
    self:PlayAnimation(self.In)
  end
  self:SetDialogInfo(DialogKey, DialogConf, Actor, OptionID)
end

function UMG_Hud_OpenDialogue_C:SetDialogInfo(DialogKey, DialogConf, Actor, OptionID)
  self.DialogKey = DialogKey
  self.DialogConf = DialogConf
  self.Actor = Actor
  self.OptionID = OptionID
  self.bIsVisible = true
  if DialogConf.text then
    self.DialogText = DialogConf.text:split("///")
  else
    Log.Error("amonsu======UMG_Hud_OpenDialogue_C======SetDialogInfo====DialogConf.text is nil!!!", DialogConf.id)
    return
  end
  self.AudioTime = 5
  if DialogConf.dialogue_sound then
    _G.NRCAudioManager:PlaySound3DWithActorByEventNameAuto(DialogConf.dialogue_sound, Actor.viewObj)
    local AudioTime = _G.NRCAudioManager:GetMaxTimeFromEventName(DialogConf.dialogue_sound)
    if AudioTime and 0 ~= AudioTime then
      self.AudioTime = AudioTime / #self.DialogText
    end
  end
  self:UpdateDialogText()
end

function UMG_Hud_OpenDialogue_C:OnDialogFinished()
  print("==amonsu=====RealtimeDialogModule===OnDialogFinished=", self.AudioTime, self.DialogConf.id, self.bIsVisible)
  table.remove(self.DialogText, 1)
  if #self.DialogText > 0 then
    self:UpdateDialogText()
  else
    local HasNextDialog = false
    local NextDialogID = self.DialogConf.next_dialog_id
    if NextDialogID and 0 ~= NextDialogID then
      local NextDialogConf = _G.DataConfigManager:GetDialogueConf(NextDialogID)
      if NextDialogConf then
        local NextSpeaker = NextDialogConf.speaker
        if NextSpeaker and NextSpeaker == self.DialogConf.speaker then
          HasNextDialog = true
          self:SetDialogInfo(self.DialogKey, NextDialogConf, self.Actor, self.OptionID)
        else
          local NextSpeakerActor = DialogueUtils.FindNPC(NextSpeaker)
          if NextSpeakerActor then
            _G.NRCModuleManager:DoCmd(RealtimeDialogModuleCmd.StartRealtimeDialog, NextSpeakerActor.config.id, NextDialogConf, NextSpeakerActor, self.OptionID)
          end
        end
      end
    end
    if not HasNextDialog then
      print("==amonsu=====RealtimeDialogModule===PlayAnimationOut=", self.AudioTime, self.DialogConf.id)
      if not DeviceUtils:OptimizeNameLabel() then
        self:PlayAnimation(self.Out)
      end
    end
  end
end

function UMG_Hud_OpenDialogue_C:UpdateDialogText()
  if #self.DialogText > 0 then
    self.NRCText:SetText(self.DialogText[1])
    self.NRCText_1:SetText(self.DialogConf.id)
    if ShowID then
      self.NRCText_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.NRCText_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    print("==amonsu=====RealtimeDialogModule===UpdateDialogText=", self.AudioTime, self.DialogConf.id, self.bIsVisible, self.OnDialogFinished)
    if self.DelayHandler then
      _G.DelayManager:CancelDelayById(self.DelayHandler)
      self.DelayHandler = nil
    end
    self.DelayHandler = _G.DelayManager:DelaySeconds(self.AudioTime, self.OnDialogFinished, self)
    local View = self.Actor.viewObj
    if View and UE.UObject.IsValid(View) then
      local HeadWidget = View.HeadWidget
      if HeadWidget and UE.UObject.IsValid(View) then
        local HUD = HeadWidget:GetUserWidgetObject()
        if HUD then
          HUD:SubmitChange()
        end
      end
    end
  end
end

function UMG_Hud_OpenDialogue_C:OnLobbyMainReady()
  if self.bIsVisible then
    table.remove(self.DialogText, 1)
    if #self.DialogText > 0 then
      self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self:UpdateDialogText()
    else
      local HasNextDialog = false
      local NextDialogID = self.DialogConf.next_dialog_id
      if NextDialogID and 0 ~= NextDialogID then
        local NextDialogConf = _G.DataConfigManager:GetDialogueConf(NextDialogID)
        if NextDialogConf then
          local NextSpeaker = NextDialogConf.speaker
          if NextSpeaker and NextSpeaker == self.DialogConf.speaker then
            self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
            HasNextDialog = true
            self:SetDialogInfo(self.DialogKey, NextDialogConf, self.Actor, self.OptionID)
          else
            local NextSpeakerActor = DialogueUtils.FindNPC(NextSpeaker)
            if NextSpeakerActor then
              _G.NRCModuleManager:DoCmd(RealtimeDialogModuleCmd.StartRealtimeDialog, NextSpeakerActor.config.id, NextDialogConf, NextSpeakerActor, self.OptionID)
            end
          end
        end
      end
      _G.NRCModuleManager:DoCmd(RealtimeDialogModuleCmd.CloseDialogPanel, self.Actor, self.DialogConf)
    end
  end
end

function UMG_Hud_OpenDialogue_C:OnLobbyMainClosed()
  if self.bIsVisible then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local View = self.Actor.viewObj
    if View and UE.UObject.IsValid(View) then
      local HeadWidget = View.HeadWidget
      if HeadWidget and UE.UObject.IsValid(HeadWidget) then
        HeadWidget:ForceDrawWidgetToRenderTarget()
      end
    end
    if self.DelayHandler then
      _G.DelayManager:CancelDelayById(self.DelayHandler)
      self.DelayHandler = nil
    end
  end
end

function UMG_Hud_OpenDialogue_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    _G.NRCModuleManager:DoCmd(RealtimeDialogModuleCmd.CloseDialogPanel, self.Actor, self.DialogConf)
  end
end

return UMG_Hud_OpenDialogue_C
