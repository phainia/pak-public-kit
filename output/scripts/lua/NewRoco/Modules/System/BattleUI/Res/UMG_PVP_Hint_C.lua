local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleModuleCmd = require("NewRoco.Modules.Core.Battle.BattleModuleCmd")
local UMG_PVP_Hint_C = _G.NRCPanelBase:Extend("UMG_PVP_Hint_C")

function UMG_PVP_Hint_C:OnActive(matchNum)
  self:OnAddEventListener()
  self.NRCText_10:SetText(LuaText.umg_pvp_matching_6)
  self.Text_CountDown:SetText(self:TransformTime(0))
  if matchNum then
    self:ShowMatch(matchNum)
  else
    self:ShowMatch(1)
  end
  _G.FunctionBanManager:AddPlayerConditionType(Enum.PlayerConditionType.PCT_MATCHING)
end

function UMG_PVP_Hint_C:ShowMatch(matchNum)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1291, "UMG_PVP_Hint_C:ShowMatch")
  self:PlayAnimation(self.In)
  self.matchState = math.min(matchNum, 2)
  self.matchTime = 0
  self.dTime = 0
  self.startServerTime = _G.ZoneServer:GetServerTime() / 1000
end

function UMG_PVP_Hint_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_Quit, self.OnClickBtn_Quit)
  _G.FunctionBanManager:AddFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_FUNCTIONAL_AREA_UI, self, self.OnChangeAreaUi)
  _G.FunctionBanManager:AddFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_WORLD_MAP_UI, self, self.OnChangeCompass)
  _G.FunctionBanManager:AddFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_WORLD_TASK_UI, self, self.OnChangeTaskUi)
  _G.NRCEventCenter:RegisterEvent("UMG_PVP_Hint_C", self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnected)
  _G.NRCEventCenter:RegisterEvent("UMG_PVP_Hint_C", self, _G.NRCGlobalEvent.ON_CONNECTED, self.OnConnected)
end

function UMG_PVP_Hint_C:OnDeactive()
  _G.FunctionBanManager:RemovePlayerConditionType(Enum.PlayerConditionType.PCT_MATCHING)
  self:RemoveButtonListener(self.Btn_Quit, self.OnClickBtn_Quit)
  _G.FunctionBanManager:RemoveFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_FUNCTIONAL_AREA_UI, self, self.OnChangeAreaUi)
  _G.FunctionBanManager:RemoveFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_WORLD_MAP_UI, self, self.OnChangeCompass)
  _G.FunctionBanManager:RemoveFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_WORLD_TASK_UI, self, self.OnChangeTaskUi)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnected)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_CONNECTED, self.OnConnected)
end

function UMG_PVP_Hint_C:OnChangeAreaUi(State, FunctionBanType, ConditionType)
  _G.NRCModuleManager:DoCmd(MainUIModuleCmd.ChangeCompassByFunctionBan, not State)
end

function UMG_PVP_Hint_C:OnChangeCompass(State, FunctionBanType, ConditionType)
  _G.NRCModuleManager:DoCmd(MainUIModuleCmd.ChangeCompassIconByFunctionBan, not State)
end

function UMG_PVP_Hint_C:OnChangeMagicUi(State, FunctionBanType, ConditionType)
  _G.NRCModuleManager:DoCmd(MainUIModuleCmd.ChangeHUDMagicByFunctionBan, not State)
end

function UMG_PVP_Hint_C:OnChangeTaskUi(State, FunctionBanType, ConditionType)
  _G.NRCModuleManager:DoCmd(MainUIModuleCmd.ChangeTaskTrackByFunctionBan, not State)
end

function UMG_PVP_Hint_C:OnTick(deltaTime)
  if self:IsMatching() then
    self.dTime = self.dTime + deltaTime
    if self.dTime > 1 then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1273, "UMG_PVP_Matching_C:OnTick")
      self.matchTime = self.matchTime + 1
      self.dTime = 0
      local curServerTime = _G.ZoneServer:GetServerTime() / 1000
      local serverMatchTime = math.floor(curServerTime - self.startServerTime)
      self.matchTime = math.max(serverMatchTime, self.matchTime)
      self.Text_CountDown:SetText(self:TransformTime(self.matchTime))
    end
  end
  self.tipTime = self.tipTime + deltaTime
  if self.tipTime > 5 then
    self:showRandomTip()
    self.tipTime = 0
  end
end

function UMG_PVP_Hint_C:OnLogin()
end

function UMG_PVP_Hint_C:OnConstruct()
  self.tipTime = 0
end

function UMG_PVP_Hint_C:OnDestruct()
end

function UMG_PVP_Hint_C:OnAnimationFinished(anim)
  if anim == self.Out then
    self:OnCloseMatch()
  end
end

function UMG_PVP_Hint_C:IsMatching()
  return 1 == self.matchState or 2 == self.matchState
end

function UMG_PVP_Hint_C:OnClickBtn_Quit()
  if self:IsMatching() then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1006, "UMG_PVP_Matching_C:OnClickCancel")
    local req = ProtoMessage:newZoneSceneMatchCancelReq()
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_MATCH_CANCEL_REQ, req, self, self.CancelRsp)
  end
  if self:CheckIsPvpRank() then
    local tempObj = {}
    
    function tempObj.OpenPVPCuttoCallBack()
      Log.Debug("SeasonOpen Progress: UMG_PVP_Hint_C:tempObj.OpenPVPCuttoCallBack")
      _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.TransferToRankMatchTutor)
      _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.ClosePVPCutto)
    end
    
    _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.OpenPVPCutto, "UMG_PVP_Hint_C", tempObj, tempObj.OpenPVPCuttoCallBack, true)
  end
end

function UMG_PVP_Hint_C:CheckIsPvpRank()
  local pvpQualifierMatchPvpConfIdList = {}
  for _, battleType in pairs(BattleConst.PvpQualifierOpenRankCheckValueToBattleType) do
    local battlePvpConf = _G.NRCModuleManager:DoCmd(BattleModuleCmd.GetPvpConfByBattleType, battleType)
    local matchPvpId = battlePvpConf and battlePvpConf.id
    table.insert(pvpQualifierMatchPvpConfIdList, matchPvpId)
  end
  local currentMatchPvpId = _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.GetCurMatchPvpId)
  local isPvpRankBattleType = table.contains(pvpQualifierMatchPvpConfIdList, currentMatchPvpId)
  return isPvpRankBattleType
end

function UMG_PVP_Hint_C:TryCloseHintPanel()
  if self:IsMatching() then
    self.matchState = 0
    self:PlayAnimation(self.Out)
  end
end

function UMG_PVP_Hint_C:CancelRsp(rsp)
  _G.NRCModeManager:DoCmd(_G.BattleUIModuleCmd.CloseBattlePvpState)
end

function UMG_PVP_Hint_C:OnConnected()
  _G.NRCModeManager:DoCmd(_G.BattleUIModuleCmd.CloseBattlePvpState)
end

function UMG_PVP_Hint_C:OnDisconnected()
  _G.NRCModeManager:DoCmd(_G.BattleUIModuleCmd.CloseBattlePvpState)
end

function UMG_PVP_Hint_C:OnCloseMatch()
  self:OnClose()
end

function UMG_PVP_Hint_C:MatchSuccess()
  self.matchState = 3
  self.isClick = true
  self.Text_CountDown:SetText("")
  self.NRCText_10:SetText(_G.LuaText.pvp_match_success_desc)
  self.Btn_Quit:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Text_CountDown:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_PVP_Hint_C:TransformTime(time)
  local minute = math.floor(time / 60)
  time = math.floor(time % 60)
  if minute < 10 then
    minute = "0" .. minute
  end
  if time < 10 then
    time = "0" .. time
  end
  return minute .. ":" .. time
end

function UMG_PVP_Hint_C:OnTick(deltaTime)
  if self:IsMatching() then
    self.dTime = self.dTime + deltaTime
    if self.dTime > 1 then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1273, "UMG_PVP_Matching_C:OnTick")
      self.matchTime = self.matchTime + 1
      self.dTime = 0
      local curServerTime = _G.ZoneServer:GetServerTime() / 1000
      local serverMatchTime = math.floor(curServerTime - self.startServerTime)
      self.matchTime = math.max(serverMatchTime, self.matchTime)
      self.Text_CountDown:SetText(self:TransformTime(self.matchTime))
    end
  end
end

return UMG_PVP_Hint_C
