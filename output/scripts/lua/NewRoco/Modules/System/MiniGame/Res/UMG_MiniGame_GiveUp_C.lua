local UMG_MiniGame_GiveUp_C = _G.NRCPanelBase:Extend("UMG_MiniGame_GiveUp_C")
local MiniGameModuleEvent = reload("NewRoco.Modules.System.MiniGame.MiniGameModuleEvent")

function UMG_MiniGame_GiveUp_C:OnActive()
  UE4Helper.SetDesiredShowCursor(true, "UMG_MiniGame_GiveUp_C")
  self:OnAddEventListener()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1291, "UMG_MiniGame_GiveUp_C:OnActive")
  self.Module = NRCModuleManager:GetModule("MiniGameModule")
  self:SetCommonPopUpInfo(self.PopUp3)
  self.PopUp3:SetBtnLeftText(LuaText.umg_minigame_giveup_2)
  self.PopUp3:SetBtnRightText(LuaText.umg_minigame_giveup_4)
  self:DisableControl()
end

function UMG_MiniGame_GiveUp_C:OnEnable()
end

function UMG_MiniGame_GiveUp_C:OnDeactive()
  UE4Helper.ReleaseDesiredShowCursor("UMG_MiniGame_GiveUp_C")
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_CloseDialog)
end

function UMG_MiniGame_GiveUp_C:AddPcInputBlock()
end

function UMG_MiniGame_GiveUp_C:RemovePcInputBlock()
end

function UMG_MiniGame_GiveUp_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnBigBtn
  CommonPopUpData.Btn_RightHandler = self.OnExit
  CommonPopUpData.ClosePanelHandler = self.OnBigBtn
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_MiniGame_GiveUp_C:OnPcClose()
  self:OnBigBtn()
end

function UMG_MiniGame_GiveUp_C:EnableControl()
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  Player.inputComponent:SetCameraControlEnable(self, true)
  Player.inputComponent:SetInputEnable(self, true)
  self:RemovePcInputBlock()
end

function UMG_MiniGame_GiveUp_C:DisableControl()
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  Player.inputComponent:SetCameraControlEnable(self, false)
  Player.inputComponent:SetInputEnable(self, false)
  Player:Stop()
  self:AddPcInputBlock()
end

function UMG_MiniGame_GiveUp_C:OnTimeOut()
end

function UMG_MiniGame_GiveUp_C:OnAddEventListener()
end

function UMG_MiniGame_GiveUp_C:OnExit()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1006, "UMG_MiniGame_GiveUp_C:OnExit")
  local Module = self.Module or _G.NRCModuleManager:GetModule("MiniGameModule")
  if not Module then
    Log.Error("\230\151\160\230\179\149\232\142\183\229\143\150\229\176\143\230\184\184\230\136\143\230\168\161\229\157\151!")
    return
  end
  local ExitReq = ProtoMessage:newZoneSceneExitMinigameReq()
  ExitReq.minigame_cfg_id = Module.ConfigId
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_EXIT_MINIGAME_REQ, ExitReq, self, self.OnExitRsp)
end

function UMG_MiniGame_GiveUp_C:OnExitRsp(rsp)
  NRCEventCenter:DispatchEvent(MiniGameModuleEvent.OnMiniGameExit)
  self:DoClose()
end

function UMG_MiniGame_GiveUp_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
end

function UMG_MiniGame_GiveUp_C:OnDisable()
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_CloseDialog)
  self:EnableControl()
end

function UMG_MiniGame_GiveUp_C:OnDestruct()
end

function UMG_MiniGame_GiveUp_C:OnAnimationFinished(anim)
end

function UMG_MiniGame_GiveUp_C:OnBigBtn()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_MiniGame_GiveUp_C:OnBigBtn")
  self:DoClose()
end

return UMG_MiniGame_GiveUp_C
