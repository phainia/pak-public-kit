local UMG_WatchVideoToolbar_C = _G.NRCPanelBase:Extend("UMG_WatchVideoToolbar_C")
local MagicReplayModuleEvent = require("NewRoco.Modules.System.MagicReplay.MagicReplayModuleEvent")
local MagicReplayModuleEnum = require("NewRoco.Modules.System.MagicReplay.MagicReplayModuleEnum")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")

function UMG_WatchVideoToolbar_C:OnActive(feedDetail)
  self.feedDetail = feedDetail
  self.feedInfo = self.feedDetail.feed_info
  if self.feedInfo == nil then
    return
  end
  self.bPlaying = false
  self:InitUI()
  self:UpdateLikeState()
  self:RefreshVisibility()
end

function UMG_WatchVideoToolbar_C:InitUI()
  self:BindInputAction()
  local fsmState = _G.NRCModuleManager:DoCmd(_G.MagicReplayModuleCmd.GetCurrentFsmState)
  if fsmState == MagicReplayModuleEnum.FsmStateType.ReplayPrepare then
    self.NRCSwitcher_State:SetActiveWidgetIndex(0)
    self:PlayAnimation(self.Loading, 0, 0)
  elseif fsmState == MagicReplayModuleEnum.FsmStateType.ReplayProcess then
    self.NRCSwitcher_State:SetActiveWidgetIndex(1)
    self:OnStartReplay()
  elseif fsmState == MagicReplayModuleEnum.FsmStateType.ReplayIdle or fsmState == MagicReplayModuleEnum.FsmStateType.Other then
    self.NRCSwitcher_State:SetActiveWidgetIndex(1)
    self:OnStopReplay()
  end
end

function UMG_WatchVideoToolbar_C:OnConstruct()
  self:OnAddEventListener()
  self:PCKeySetting()
end

function UMG_WatchVideoToolbar_C:OnAddEventListener()
  _G.NRCEventCenter:RegisterEvent(self.name, self, MagicReplayModuleEvent.OnStartReplayProcess, self.OnStartReplay)
  _G.NRCEventCenter:RegisterEvent(self.name, self, MagicReplayModuleEvent.OnStopReplayProcess, self.OnStopReplay)
  self:AddButtonListener(self.StartBtn.btnLevelUp, self.OnClickPlayBtn)
  self:AddButtonListener(self.StopBtn.btnLevelUp, self.OnClickPlayBtn)
  self:AddButtonListener(self.MessageBtn.btnLevelUp, self.OnClickMessageBtn)
  self:AddButtonListener(self.LikeBtn.btnLevelUp, self.OnClickLikeBtn)
  self:AddButtonListener(self.CloseBtn.btnLevelUp, self.OnClickCloseBtn)
end

function UMG_WatchVideoToolbar_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_MagicReplay_WatchVideo")
  if mappingContext then
    mappingContext:BindAction("IA_MagicReplay_WatchVideo_Play", self, "OnClickPlayBtn")
    mappingContext:BindAction("IA_MagicReplay_WatchVideo_Message", self, "OnClickMessageBtn")
    mappingContext:BindAction("IA_MagicReplay_WatchVideo_Like", self, "OnClickLikeBtn")
    mappingContext:BindAction("IA_MagicReplay_WatchVideo_Close", self, "OnClickCloseBtn")
  end
end

function UMG_WatchVideoToolbar_C:PCKeySetting()
  self.StartBtn:SetPCKey("IA_MagicReplay_WatchVideo_Play")
  self.StopBtn:SetPCKey("IA_MagicReplay_WatchVideo_Play")
  self.MessageBtn:SetPCKey("IA_MagicReplay_WatchVideo_Message")
  self.LikeBtn:SetPCKey("IA_MagicReplay_WatchVideo_Like")
  self.CloseBtn:SetPCKey("IA_MagicReplay_WatchVideo_Close")
end

function UMG_WatchVideoToolbar_C:OnDeactive()
end

function UMG_WatchVideoToolbar_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, MagicReplayModuleEvent.OnStartReplayProcess, self.OnStartReplay)
  _G.NRCEventCenter:UnRegisterEvent(self, MagicReplayModuleEvent.OnStopReplayProcess, self.OnStopReplay)
  local mappingContext = self:GetInputMappingContext("IMC_MagicReplay_WatchVideo")
  if mappingContext then
    mappingContext:UnBindAction("IA_MagicReplay_WatchVideo_Play")
    mappingContext:UnBindAction("IA_MagicReplay_WatchVideo_Message")
    mappingContext:UnBindAction("IA_MagicReplay_WatchVideo_Like")
    mappingContext:UnBindAction("IA_MagicReplay_WatchVideo_Close")
  end
  if self.playingTimer then
    _G.TimerManager:RemoveTimer(self.playingTimer)
  end
end

function UMG_WatchVideoToolbar_C:OnAnimationFinished(anim)
end

function UMG_WatchVideoToolbar_C:OnTick()
  self:RefreshVisibility()
end

function UMG_WatchVideoToolbar_C:RefreshVisibility()
  local bHasBottomTips = _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.HasDisplayingTip, TipEnum.TipDisplayArea.Bottom)
  if self.module:IsPanelEnabled("ReplayPanel") and not bHasBottomTips then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_WatchVideoToolbar_C:OnStartReplay()
  Log.Info("UMG_WatchVideoToolbar_C:OnStartReplay")
  self.NRCSwitcher_State:SetActiveWidgetIndex(1)
  self.NRCSwitcher_Play:SetActiveWidgetIndex(1)
  self.PlayingProgress:SetFillAmount(0)
  self.PlayingProgress:SetFillStartPercent(0.5)
  if self.playingTimer then
    _G.TimerManager:RemoveTimer(self.playingTimer)
  end
  local seqInfo = _G.NRCModuleManager:DoCmd(_G.MagicReplayModuleCmd.GetReplaySeqInfo)
  self.totalSec = seqInfo and seqInfo.time or 0
  if self.totalSec > 0 then
    self.playSec = _G.NRCModuleManager:DoCmd(_G.MagicReplayModuleCmd.GetReplaySeqCurrentTime)
    self.playingTimer = _G.TimerManager:CreateTimer(self, "UMG_WatchVideoToolbar_C:OnStartReplay", self.totalSec - self.playSec, self.OnTimerUpdate, self.OnTimerEnd, 0.1)
    self.bPlaying = true
  end
end

function UMG_WatchVideoToolbar_C:OnTimerUpdate()
  self.playSec = _G.NRCModuleManager:DoCmd(_G.MagicReplayModuleCmd.GetReplaySeqCurrentTime)
  local progress = self.playSec / self.totalSec
  self.PlayingProgress:SetFillAmount(progress)
end

function UMG_WatchVideoToolbar_C:OnTimerEnd()
  self.NRCSwitcher_Play:SetActiveWidgetIndex(0)
  if self.playingTimer then
    _G.TimerManager:RemoveTimer(self.playingTimer)
  end
end

function UMG_WatchVideoToolbar_C:OnStopReplay()
  Log.Info("UMG_WatchVideoToolbar_C:OnStartReplay")
  self.bPlaying = false
  self.NRCSwitcher_Play:SetActiveWidgetIndex(0)
  if self.playingTimer then
    _G.TimerManager:RemoveTimer(self.playingTimer)
  end
end

function UMG_WatchVideoToolbar_C:OnClickPlayBtn()
  if self.bPlaying then
    _G.NRCModuleManager:DoCmd(_G.MagicReplayModuleCmd.StopReplayProcess)
  else
    _G.NRCModuleManager:DoCmd(_G.MagicReplayModuleCmd.StartReplayProcess)
  end
end

function UMG_WatchVideoToolbar_C:OnClickMessageBtn()
  self.feedDetail.feed_info = self.feedInfo
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.OpenShowMagicMessage, self.feedDetail)
  _G.NRCModuleManager:DoCmd(_G.MagicReplayModuleCmd.CloseReplayPanel)
end

function UMG_WatchVideoToolbar_C:UpdateLikeState()
  local iconPath
  if self.feedInfo and self.feedInfo.attitude == ProtoEnum.FeedAttitudeType.FEED_ATTITUDE_TYPE_LIKE then
    self.LikeBtn.btnLevelUp:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    iconPath = "PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUIStatic/Frames/img_Upvote2_png.img_Upvote2_png"
  else
    self.LikeBtn.btnLevelUp:SetVisibility(UE4.ESlateVisibility.Visible)
    iconPath = "PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUIStatic/Frames/img_Upvote_png.img_Upvote_png"
  end
  self.LikeBtn:SetPath(iconPath, iconPath, iconPath)
end

function UMG_WatchVideoToolbar_C:OnClickLikeBtn()
  if not self.bPlaying then
    return
  end
  if self.feedInfo and self.feedInfo.attitude == ProtoEnum.FeedAttitudeType.FEED_ATTITUDE_TYPE_LIKE then
    return
  end
  if self.bReqAttitude then
    return
  end
  self.bReqAttitude = true
  local reqMsg = _G.ProtoMessage:newZoneFeedMagicAttitudeReq()
  reqMsg.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  reqMsg.feed_id = self.feedInfo.feed_id
  reqMsg.attitude = ProtoEnum.FeedAttitudeType.FEED_ATTITUDE_TYPE_LIKE
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_FEED_MAGIC_ATTITUDE_REQ, reqMsg, self, self.OnFeedMagicAttitudeRsp, nil, false)
  self:DelaySeconds(2, function()
    self.bReqAttitude = false
  end)
end

function UMG_WatchVideoToolbar_C:OnFeedMagicAttitudeRsp(rsp)
  self.bReqAttitude = false
  if 0 == rsp.ret_info.ret_code then
    self.feedInfo = rsp.feed
    self:UpdateLikeState()
    _G.NRCModuleManager:DoCmd(_G.MagicMessageModuleCmd.UpdateNpcByGridAndFeedId, self.feedInfo.grid_id, self.feedInfo.feed_id, self.feedInfo)
  end
end

function UMG_WatchVideoToolbar_C:OnClickCloseBtn()
  if not self.bPlaying then
    _G.NRCModuleManager:DoCmd(_G.MagicReplayModuleCmd.StopMagicReplay)
  end
end

return UMG_WatchVideoToolbar_C
