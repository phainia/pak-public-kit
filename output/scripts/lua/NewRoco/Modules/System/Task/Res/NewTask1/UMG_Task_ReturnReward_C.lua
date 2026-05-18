local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local UMG_Task_ReturnReward_C = _G.NRCPanelBase:Extend("UMG_Task_ReturnReward_C")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")

function UMG_Task_ReturnReward_C:OnActive()
  local curModule = self.module
  self.tipsDisplayController = curModule and curModule.getReturnRewardTipsController
  if self.tipsDisplayController then
    self.tipsDisplayController:BindView(self)
    self.tipsDisplayController:GetExecutor():StartTipDispatchStateListener()
  end
  _G.NRCAudioManager:PlaySound2DAuto(40008044, "UMG_Task_ReturnReward_C:OnActive")
  self.isCollect = false
  self.bNormalClose = false
  self.rewardList = {}
  self:SetInfo()
  self:OnAddEventListener()
  self:PlayAnimation(self.In)
  self:AddPcInputBlock()
  UE4Helper.SetDesiredShowCursor(true, "UMG_Task_ReturnReward_C")
end

function UMG_Task_ReturnReward_C:OnDeactive()
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnRelogin, self.OnReLoginUpdate)
  if self.tipsDisplayController then
    self.tipsDisplayController:UnBindView()
  end
  self:RemovePcInputBlock()
  UE4Helper.ReleaseDesiredShowCursor("UMG_Task_ReturnReward_C")
end

function UMG_Task_ReturnReward_C:SetInfo()
  local recallEventConf = _G.DataConfigManager:GetActivityConf(15)
  local activityConf = _G.DataConfigManager:GetActivityRewardByStageConf(recallEventConf.base_id[1])
  local disposable_reward_id = activityConf.disposable_reward_id
  local rewardConf = _G.DataConfigManager:GetRewardConf(disposable_reward_id)
  self.rewardList = self:SetRewards(rewardConf.RewardItem)
  self.AwardList:InitGridView(self.rewardList)
  self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local recallText = _G.DataConfigManager:GetLocalizationConf("Recall_Postcard_Text").msg
  if recallText then
    self.TextDescribe:SetText(recallText)
  end
  self.TextName:SetText(LuaText.recall_mail_sender)
end

function UMG_Task_ReturnReward_C:PlayInAnim()
  if self._playInAnimTimerId then
    _G.DelayManager:CancelDelayById(self._playInAnimTimerId)
    self._playInAnimTimerId = nil
  end
  self:SetRenderOpacity(0)
  self._playInAnimTimerId = _G.DelayManager:DelaySeconds(1, function()
    self._playInAnimTimerId = nil
    self:SetRenderOpacity(1)
    self:PlayAnimation(self.In)
  end)
end

function UMG_Task_ReturnReward_C:SetRewards(itemInfo)
  local rewardsTable = {}
  for k, v in ipairs(itemInfo) do
    local rewards = _G.NRCCommonItemIconData()
    rewards.itemType = v.Type
    rewards.itemId = v.Id
    rewards.itemNum = v.Count
    rewards.bShowNum = true
    rewards.bShowTip = true
    table.insert(rewardsTable, rewards)
  end
  return rewardsTable
end

function UMG_Task_ReturnReward_C:AddPcInputBlock()
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.AddBlockIMC, self, self.depth)
end

function UMG_Task_ReturnReward_C:RemovePcInputBlock()
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.RemoveBlockIMC, self)
end

function UMG_Task_ReturnReward_C:OnAddEventListener()
  NRCEventCenter:RegisterEvent("UMG_Task_ReturnReward_C", self, SceneEvent.OnRelogin, self.OnReLogin)
  self:AddButtonListener(self.CollectButton, self.CollectReward)
  self:AddButtonListener(self.BtnLeaveFor.btnLevelUp, self.GoToRecallEventInActivityPanel)
end

function UMG_Task_ReturnReward_C:OnReLogin()
  self.isCollect = false
end

function UMG_Task_ReturnReward_C:CollectReward()
  if _G.GlobalConfig.DebugOpenUI then
    self.tipsDisplayController:GetExecutor():Clear()
    self:OnClose()
    return
  end
  if not self.isCollect then
    local req = _G.ProtoMessage:newZoneReceivePlayerActivityDisposableRewardReq()
    local recallEventConf = _G.DataConfigManager:GetActivityConf(15)
    req.activity_id = recallEventConf.id
    req.activity_stage_id = recallEventConf.base_id[1]
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_RECEIVE_PLAYER_ACTIVITY_DISPOSABLE_REWARD_REQ, req, self, self.OnZoneGetPlayerActivityInfoRsp, true, true)
  end
end

function UMG_Task_ReturnReward_C:OnZoneGetPlayerActivityInfoRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    self:PlayAnimation(self.Receive)
    self.Switcher:SetVisibility(UE4.ESlateVisibility.Visible)
    self.isCollect = true
    self.CanvasPanel_52:SetVisibility(UE4.ESlateVisibility.Collapsed)
    for i = 1, self.AwardList:GetItemCount() do
      local item = self.AwardList:GetItemByIndex(i - 1)
      item:SetAlreadyReceived(true)
      item.NRCImage_1:SetBrushTintColor(UE4.UNRCStatics.HexToSlateColor("#00000066"))
    end
  else
    self:ReqGetPlayerActivityData(true)
  end
end

function UMG_Task_ReturnReward_C:GoToRecallEventInActivityPanel()
  self:ReqGetPlayerActivityData()
  self:PlayAnimation(self.Out)
end

function UMG_Task_ReturnReward_C:ClosePanel()
  self.tipsDisplayController:GetExecutor():Clear()
  self:DoClose()
end

function UMG_Task_ReturnReward_C:OnAnimationFinished(anim)
  if anim == self.Out then
    if not self.bNormalClose then
      _G.NRCModuleManager:DoCmd(ActivityModuleCmd.OpenMainPanel, nil, 15)
    end
    self:ClosePanel()
  end
end

function UMG_Task_ReturnReward_C:ReqGetPlayerActivityData(bNeedRsp)
  local recallEventConf = _G.DataConfigManager:GetActivityConf(15)
  local req = _G.ProtoMessage:newZoneGetPlayerActivityDataReq()
  req.activity_id = recallEventConf.id
  if bNeedRsp then
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_REQ, req, self, self.GetPlayerActivityDataRsp, false, false)
  else
    _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_REQ, req)
  end
end

function UMG_Task_ReturnReward_C:GetPlayerActivityDataRsp(rsp)
  local stageData = rsp.activity_data and rsp.activity_data.stage_data
  local subStageData = stageData.sub_stage_data and stageData.sub_stage_data[1]
  local isActive = false
  local isRewardTaken = false
  if subStageData then
    isActive = subStageData.active
    isRewardTaken = subStageData.is_disposable_reward_taken
  end
  if not isActive then
    self.bNormalClose = true
    self:PlayAnimation(self.Out)
  end
  if isRewardTaken and self and UE4.UObject.IsValid(self) then
    self.bNormalClose = true
    self:PlayAnimation(self.Out)
  end
end

function UMG_Task_ReturnReward_C:OnDestruct()
  if self._playInAnimTimerId then
    _G.DelayManager:CancelDelayById(self._playInAnimTimerId)
    self._playInAnimTimerId = nil
  end
end

return UMG_Task_ReturnReward_C
