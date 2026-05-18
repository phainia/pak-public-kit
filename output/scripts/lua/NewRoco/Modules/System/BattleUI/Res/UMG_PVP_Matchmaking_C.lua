local UMG_PVP_Matchmaking_C = _G.NRCPanelBase:Extend("UMG_PVP_Matchmaking_C")
UMG_PVP_Matchmaking_C.MatchType = {
  ONE_PVP = 1,
  TWO_PVP = 2,
  PRACTICE_PVP = 3
}

function UMG_PVP_Matchmaking_C:OnConstruct()
  self:OnAddEventListener()
  self.tipConfigs = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.PVP_MATCH_TIPS_CONF):GetAllDatas()
  self.tipTime = 0
  self.lastIndex = 0
end

function UMG_PVP_Matchmaking_C:OnActive(matchNum)
  self.UMG_Btn2.Title_1:SetText(LuaText.umg_pvp_matching_5)
  self.UMG_Btn2.Title_2:SetText(LuaText.umg_pvp_matching_5)
  self.InTheMatch:SetText(LuaText.umg_pvp_matching_6)
  self.TimeTitle:SetText(self:TransformTime(0))
  self:PlayAnimation(self.Loop, nil, 99999)
  self:showRandomTip()
  if matchNum then
    self:ShowMatch(matchNum)
  else
    self:ShowMatch(1)
  end
end

function UMG_PVP_Matchmaking_C:OnDeactive()
end

function UMG_PVP_Matchmaking_C:OnAddEventListener()
  self:AddButtonListener(self.UMG_Btn2.btnLevelUp, self.OnClickCancel)
end

function UMG_PVP_Matchmaking_C:ShowMatch(matchNum)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1291, "UMG_PVP_Matching_C:ShowMatch")
  self.MatchCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.UMG_Btn2.Title_1:SetText(LuaText.umg_pvp_matching_5)
  self.UMG_Btn2.Title_2:SetText(LuaText.umg_pvp_matching_5)
  self.InTheMatch:SetText(LuaText.umg_pvp_matching_6)
  self.TimeTitle:SetText(self:TransformTime(0))
  self.matchState = math.min(matchNum, 2)
  self.matchTime = 0
  self.dTime = 0
  self.startServerTime = _G.ZoneServer:GetServerTime() / 1000
end

function UMG_PVP_Matchmaking_C:OnTick(deltaTime)
  if self:IsMatching() then
    self.dTime = self.dTime + deltaTime
    if self.dTime > 1 then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1273, "UMG_PVP_Matching_C:OnTick")
      self.matchTime = self.matchTime + 1
      self.dTime = 0
      local curServerTime = _G.ZoneServer:GetServerTime() / 1000
      local serverMatchTime = math.floor(curServerTime - self.startServerTime)
      self.matchTime = math.max(serverMatchTime, self.matchTime)
      self.TimeTitle:SetText(self:TransformTime(self.matchTime))
    end
  end
  self.tipTime = self.tipTime + deltaTime
  if self.tipTime > 5 then
    self:showRandomTip()
    self.tipTime = 0
  end
end

function UMG_PVP_Matchmaking_C:IsMatching()
  return 1 == self.matchState or 2 == self.matchState
end

function UMG_PVP_Matchmaking_C:MatchSuccess()
  self.matchState = 3
  self.isClick = true
  self.TimeTitle:SetText("")
  self.InTheMatch:SetText(_G.LuaText.pvp_match_success_desc)
  self.UMG_Btn2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TimeTitle:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:StopAnimation(self.Loop)
  self.MatchSuccIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.MatchAnimIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_PVP_Matchmaking_C:TransformTime(time)
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

function UMG_PVP_Matchmaking_C:OnClickCancel()
  if self:IsMatching() then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1006, "UMG_PVP_Matching_C:OnClickCancel")
    local req = ProtoMessage:newZoneSceneMatchCancelReq()
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_MATCH_CANCEL_REQ, req, self, self.CancelRsp)
  end
end

function UMG_PVP_Matchmaking_C:CancelRsp(rsp)
  self:CloseMatch()
end

function UMG_PVP_Matchmaking_C:CloseMatch()
  if self:IsMatching() then
    self.matchState = 0
    self:OnCloseMatch()
  end
end

function UMG_PVP_Matchmaking_C:OnCloseMatch()
  self:OnClose()
end

function UMG_PVP_Matchmaking_C:MatchSuccClosePanel()
end

function UMG_PVP_Matchmaking_C:showRandomTip()
  if not self.tipConfigs then
    Log.Error("tipConfigs\233\133\141\231\189\174\228\184\141\229\173\152\229\156\168")
    return
  end
  if 1 == #self.tipConfigs then
    self.lastIndex = 1
    self.Text_particulars:SetText(self.tipConfigs[1].pvp_match_tips_text)
    return
  end
  local index = math.random(1, #self.tipConfigs)
  if index == self.lastIndex then
    if index + 1 <= #self.tipConfigs then
      index = index + 1
    else
      index = index - 1
    end
  end
  self.lastIndex = index
  self.Text_particulars:SetText(self.tipConfigs[index].pvp_match_tips_text)
end

return UMG_PVP_Matchmaking_C
