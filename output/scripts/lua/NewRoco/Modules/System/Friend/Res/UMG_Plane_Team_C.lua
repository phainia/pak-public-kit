local LegendaryBattleModuleEnum = require("NewRoco.Modules.Activity.LegendaryBattle.LegendaryBattleModuleEnum")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")
local FriendModuleEvent = reload("NewRoco.Modules.System.Friend.FriendModuleEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local UMG_Plane_Team_C = _G.NRCPanelBase:Extend("UMG_Plane_Team_C")

function UMG_Plane_Team_C:OnActive(data)
  if _G.GlobalConfig.DebugOpenUI then
    self:OnAddEventListener()
    return
  end
  UE4Helper.SetDesiredShowCursor(true, "UMG_Plane_Team_C")
  _G.NRCAudioManager:PlaySound2DAuto(1072, "UMG_Plane_ExchangeVisits_C:OnActive")
  if data then
    self:SetPanelInfo(data)
  end
  self.FunctionVisible = false
  self:PlayAnimation(self.Pop_ups_In_1)
  self:OnAddEventListener()
  if self:IsPCMode() then
    local PCScale = UE4.FVector2D(0.88, 0.88)
    self.CanvasPanel_258:SetRenderScale(PCScale)
    local Padding = UE4.FMargin()
    Padding.Left = -194
    Padding.Top = -73
    Padding.Right = -261
    Padding.Bottom = -70
    self.CanvasPanel_258.Slot:SetOffsets(Padding)
    Padding.Left = 1053
    Padding.Top = 155
    Padding.Right = 458
    Padding.Bottom = 575.5
    self.Panel_Common.Slot:SetOffsets(Padding)
  end
  self.Panel_Common:SetVisibility(UE4.ESlateVisibility.Visible)
  local Pos = self.Panel_Common.Slot:GetPosition()
  if HomeIndoorSandbox:InHomeIndoor() or _G.FarmModuleCmd and _G.NRCModeManager:DoCmd(_G.FarmModuleCmd.OnCmdGetIsInFarm) then
    Pos.x = 698.0
    self:SendZoneGetHomeNetWorkReq()
  end
  self.Panel_Common.Slot:SetPosition(Pos)
  self.TextCountDown_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:BindInputAction()
end

function UMG_Plane_Team_C:OnDeactive()
  self:CancelDelay()
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.OnVisitPlaneClosed)
  UE4Helper.ReleaseDesiredShowCursor("UMG_Plane_Team_C")
  self.FriendFunction:PlayAnimation(self.FriendFunction.Out)
  self:UnBindInputAction()
  self:OnRemoveEventListener()
end

function UMG_Plane_Team_C:SendZoneGetHomeNetWorkReq()
  local req = _G.ProtoMessage:newZoneSceneHomeGetVisitorInfoReq()
  local home_owner_id = HomeIndoorSandbox.Server.MasterId
  if home_owner_id and home_owner_id > 0 then
  else
    local homeInfo = FarmUtils.GetCurrentWorldHomeInfo()
    if homeInfo then
      home_owner_id = homeInfo.home_owner_id
    end
  end
  req.home_owner_id = home_owner_id
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_HOME_GET_VISITOR_INFO_REQ, req, self, self.ZoneGetHomeNetWorkRsp, false, true)
end

function UMG_Plane_Team_C:ZoneGetHomeNetWorkRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    local homeVisitInfo = rsp.visitor_info
    local PlayerNetWorkList = {}
    if homeVisitInfo and #homeVisitInfo > 0 then
      for _, v in ipairs(homeVisitInfo) do
        local NetWorkItem = {
          uin = v.uin,
          network = v.network_latency_ms
        }
        table.insert(PlayerNetWorkList, NetWorkItem)
      end
      self:SetNetWork(PlayerNetWorkList)
    end
  end
  self:DelaySeconds(5, function()
    self:SendZoneGetHomeNetWorkReq()
  end)
end

function UMG_Plane_Team_C:BindInputAction()
  local imc = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_TeamUI")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperAddInputMappingContext, imc, self.depth)
  local ia = UE.UNRCEnhancedInputHelper.GetInputAction("IA_CloseTeamUI")
  UE.UNRCEnhancedInputHelper.BindAction(ia, UE.ETriggerEvent.Triggered, self, "OnPcClose")
end

function UMG_Plane_Team_C:UnBindInputAction()
  local ia = UE.UNRCEnhancedInputHelper.GetInputAction("IA_CloseTeamUI")
  UE.UNRCEnhancedInputHelper.UnBindAction(ia)
  local imc = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_TeamUI")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperRemoveInputMappingContext, imc)
end

function UMG_Plane_Team_C:OnPcClose()
  self:OnClose()
end

function UMG_Plane_Team_C:IsPCMode()
  return UE.UGameplayStatics.GetGameInstance(self):IsPCMode()
end

function UMG_Plane_Team_C:SetPanelInfo(data)
  self.data = data
  self:SetVisitListWorldPlayerStatus()
  if self.FunctionVisible then
    self.FriendFunction:PlayAnimation(self.FriendFunction.Out)
    self.FunctionVisible = false
  end
  self:InitList()
  self:SetNetWork(data)
  self:SetMatchInfo()
end

function UMG_Plane_Team_C:OnDoubleRideOrHandInHandChange()
  self:SetVisitListWorldPlayerStatus()
  self:InitList()
end

function UMG_Plane_Team_C:InitList()
  if not self.data then
    return
  end
  self.List:InitGridView(self.data)
end

function UMG_Plane_Team_C:SetVisitListWorldPlayerStatus()
  local visitorList = self.data
  local uin1 = 0
  local uin2 = 0
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local bInRide = player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL)
  local bInDoubleRide = bInRide and player.viewObj.BP_RideComponent:IsInDoubleRide()
  local IsInVisitHAND = false
  local PlayerUin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  if player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND) or player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND_2P) then
    IsInVisitHAND = true
    if player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND) then
      local HandInHandParam = player.statusComponent:GetCustomParams(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND)
      if HandInHandParam then
        uin2 = HandInHandParam.player_interact_param.player_uin2
        uin1 = HandInHandParam.player_interact_param.player_uin1
      end
    end
    if player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND_2P) then
      local HandInHandParam = player.statusComponent:GetCustomParams(ProtoEnum.WorldPlayerStatusType.WPST_HAND_IN_HAND_2P)
      if HandInHandParam then
        uin2 = HandInHandParam.player_interact_param.player_uin2
        uin1 = HandInHandParam.player_interact_param.player_uin1
      end
    end
  elseif bInDoubleRide then
    local customParams = player.statusComponent:GetCustomParams(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL)
    local uin_1p = customParams.ride_param.double_ride_1p_id
    local uin_2p = customParams.ride_param.double_ride_2p_id
    local player2P = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByServerID, uin_2p)
    uin2 = player2P.serverData.base.logic_id
    local player1P = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByServerID, uin_1p)
    uin1 = player1P.serverData.base.logic_id
  end
  if visitorList and #visitorList > 0 then
    for i, v in ipairs(visitorList) do
      visitorList[i].bInDoubleRide = false
      visitorList[i].IsInVisitHAND = false
      if v.uin == uin1 and PlayerUin ~= uin1 then
        visitorList[i].bInDoubleRide = bInDoubleRide
        visitorList[i].IsInVisitHAND = IsInVisitHAND
      end
      if v.uin == uin2 and PlayerUin ~= uin2 then
        visitorList[i].bInDoubleRide = bInDoubleRide
        visitorList[i].IsInVisitHAND = IsInVisitHAND
      end
    end
  end
end

function UMG_Plane_Team_C:SetMatchInfo()
  local curLBMatchStage, matchInfo = _G.NRCModuleManager:DoCmd(LegendaryBattleModuleCmd.GetCurMatchInfo)
  local visitorList = _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.GetOnlineVisitorList)
  if nil ~= curLBMatchStage and (curLBMatchStage == LegendaryBattleModuleEnum.CurStage.Matching or curLBMatchStage == LegendaryBattleModuleEnum.CurStage.Full) and matchInfo.battleId and matchInfo.battleId > 0 then
    self.Oneself:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if curLBMatchStage == LegendaryBattleModuleEnum.CurStage.Matching then
      self.ColourSwitcher:SetActiveWidgetIndex(0)
      self.TextMatchingState:SetText(_G.DataConfigManager:GetLocalizationConf("umg_pvp_matching_6").msg)
    elseif curLBMatchStage == LegendaryBattleModuleEnum.CurStage.Full then
      if 4 == #visitorList then
        self.ColourSwitcher:SetActiveWidgetIndex(1)
        self.TextMatchingState:SetText(LuaText.legendary_battle_text_7)
        local bOwner = _G.DataModelMgr.PlayerDataModel:IsVisitOwner()
        if bOwner then
          self.MiddleBtn3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        else
          self.MiddleBtn3:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      else
        self.Oneself:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  else
    self.Oneself:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if nil ~= matchInfo.battleId and 0 ~= matchInfo.battleId then
    local monsterConfId = _G.DataConfigManager:GetBattleConf(matchInfo.battleId).npc_battle_list[1].pos1_1st[1]
    local monsterConf = _G.DataConfigManager:GetMonsterConf(monsterConfId)
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(monsterConf.base_id)
    local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    self.PetIconImg:SetPath(NRCUtils:FormatConfIconPath(modelConf.icon, _G.UIIconPath.HeadIconPath))
  end
  if nil ~= matchInfo.starNum then
    self.Text_GradeOfDifficulty_1:SetText(matchInfo.starNum)
  end
  local numList = {
    false,
    false,
    false,
    false
  }
  for i = 1, 4 do
    if i > #visitorList then
      numList[i] = false
    else
      numList[i] = true
    end
  end
  self.NumberList:InitGridView(numList)
end

function UMG_Plane_Team_C:SetNetWork(NetWorkList)
  local OnLineGlobalConfig = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.ONLINE_GLOBAL_CONFIG):GetAllDatas()
  local NetWorkState = {}
  for i = 1, #OnLineGlobalConfig do
    if OnLineGlobalConfig[i].key == "wifi_sign_strength" then
      NetWorkState = OnLineGlobalConfig[i].numList
      break
    end
  end
  if self.data then
    for i = 1, #self.data do
      for j = 1, #NetWorkList do
        local NetWorkString = 0
        if self.data[i].uin == NetWorkList[j].uin then
          if NetWorkList[j].network then
            if NetWorkList[j].network <= NetWorkState[1] and NetWorkList[j].network >= 0 then
              NetWorkString = 0
            elseif NetWorkList[j].network > NetWorkState[1] and NetWorkList[j].network <= NetWorkState[2] then
              NetWorkString = 1
            elseif NetWorkList[j].network > NetWorkState[2] then
              NetWorkString = 2
            else
              NetWorkString = 2
            end
          end
          self:DispatchEvent(FriendModuleEvent.OnPlaneItemSetNetWork, i, NetWorkString)
        end
      end
    end
  end
end

function UMG_Plane_Team_C:SetFunctionInfo(ItemData, ItemIndex)
  if ItemData.uin ~= _G.DataModelMgr.PlayerDataModel:GetPlayerUin() then
    self.FunctionVisible = true
    local selectTab = FriendEnum.SELECT_TAB.VisitPanelList
    self.FriendFunction:SetVisibility(UE4.ESlateVisibility.Visible)
    local pos = self.FriendFunction.Slot:GetPosition()
    pos.y = (ItemIndex - 1) * 153 + 327
    self.FriendFunction.Slot:SetPosition(pos)
    self.FriendFunction:OnActive(ItemData, nil, selectTab)
  elseif self.FunctionVisible then
    self.FriendFunction:PlayAnimation(self.FriendFunction.Out)
    self.FunctionVisible = false
  end
end

function UMG_Plane_Team_C:OnAddEventListener()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    localPlayer:AddEventListener(self, PlayerModuleEvent.ON_DOUBLERIDE_SUCCEED, self.OnDoubleRideOrHandInHandChange)
    localPlayer:AddEventListener(self, PlayerModuleEvent.ON_HANDINHAND, self.OnDoubleRideOrHandInHandChange)
    localPlayer:AddEventListener(self, PlayerModuleEvent.ON_UPDATE_TOGETHER, self.OnDoubleRideOrHandInHandChange)
  end
  self:RegisterEvent(self, FriendModuleEvent.OnPlaneItemClick, self.OnClose)
  _G.NRCEventCenter:RegisterEvent("UMG_Plane_Team_C", self, FriendModuleEvent.AddOrRemoveBlackListUpdate, self.InitList)
  self:AddButtonListener(self.CloseBtn, self.OnClose)
  self:AddButtonListener(self.MiddleBtn3.btnLevelUp, self.StartMatchChallenge)
end

function UMG_Plane_Team_C:OnRemoveEventListener()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    localPlayer:RemoveEventListener(self, PlayerModuleEvent.ON_DOUBLERIDE_SUCCEED, self.OnDoubleRideOrHandInHandChange)
    localPlayer:RemoveEventListener(self, PlayerModuleEvent.ON_HANDINHAND, self.OnDoubleRideOrHandInHandChange)
    localPlayer:RemoveEventListener(self, PlayerModuleEvent.ON_UPDATE_TOGETHER, self.OnDoubleRideOrHandInHandChange)
  end
  self:UnRegisterEvent(self, FriendModuleEvent.OnPlaneItemClick)
  _G.NRCEventCenter:UnRegisterEvent(self, FriendModuleEvent.AddOrRemoveBlackListUpdate, self.InitList)
end

function UMG_Plane_Team_C:SetLegendaryMatchTime(time)
  if time > 0 and self.TextCountDown_1:GetVisibility() == UE4.ESlateVisibility.Collapsed then
    self.TextCountDown_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif 0 == time then
    self.TextCountDown_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local sec = math.floor(time % 60)
  local min = math.floor(time / 60)
  local timeText = string.format("%d:%d", min, sec)
  self.TextCountDown_1:SetText(timeText)
end

function UMG_Plane_Team_C:StartMatchChallenge()
  local curLBMatchStage, matchInfo = _G.NRCModuleManager:DoCmd(LegendaryBattleModuleCmd.GetCurMatchInfo)
  local enterCondition = _G.NRCModuleManager:DoCmd(TeamBattleModuleCmd.CheckEnterCondition, _G.ProtoEnum.TeamBattleChallengeType.TBCT_BEAST)
  local bOpenConfirm, tips = _G.NRCModuleManager:DoCmd(_G.LegendaryBattleModuleCmd.CheckCanStartLegendaryBattle, enterCondition)
  if true == bOpenConfirm then
    _G.NRCModuleManager:DoCmd(_G.TeamBattleModuleCmd.SendZoneTeamBattleChallengeReq, matchInfo.ActorId, matchInfo.LogicId, _G.ProtoEnum.TeamBattleChallengeType.TBCT_BEAST, {
      battleId = matchInfo.battleId,
      starNum = matchInfo.starNum
    })
  else
    _G.NRCModuleManager:DoCmd(_G.TeamBattleModuleCmd.OpenPreWarConfirm, _G.ProtoEnum.TeamBattleChallengeType.TBCT_BEAST, {
      actorId = matchInfo.ActorId,
      logicId = matchInfo.LogicId,
      battleId = matchInfo.battleId,
      starNum = matchInfo.starNum
    }, tips)
  end
  self:OnClose()
end

function UMG_Plane_Team_C:OnClose()
  if self.FunctionVisible then
    self.FriendFunction:PlayAnimation(self.FriendFunction.Out)
    self.FunctionVisible = false
    return
  end
  self:PlayAnimation(self.Pop_ups_Out_1)
end

function UMG_Plane_Team_C:OnAnimationFinished(anim)
  if anim == self.Pop_ups_Out_1 then
    self:DoClose()
  end
end

return UMG_Plane_Team_C
