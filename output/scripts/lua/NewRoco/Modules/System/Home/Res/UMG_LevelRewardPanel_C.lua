local UMG_LevelRewardPanel_C = _G.NRCPanelBase:Extend("UMG_LevelRewardPanel_C")

function UMG_LevelRewardPanel_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_LevelRewardPanel_C:OnActive(protoData)
  if protoData then
    self.protoData = protoData
    self:Init()
  end
  _G.NRCAudioManager:PlaySound2DAuto(1220002052, "UMG_LevelRewardPanel_C:OnActive")
end

function UMG_LevelRewardPanel_C:OnDeactive()
  if _G.GlobalConfig.DebugOpenUI then
    _G.NRCModuleManager:DoCmd(MainUIModuleCmd.OpenPanelLobbyMain)
    return
  end
end

function UMG_LevelRewardPanel_C:OnReqClose()
  if self.bPendingClose then
    return
  end
  self.bPendingClose = true
  _G.NRCAudioManager:PlaySound2DAuto(41401010, "UMG_LevelRewardPanel_C:OnReqClose")
  self:PlayAnimation(self.Out)
end

function UMG_LevelRewardPanel_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    self:OnClose()
  end
end

function UMG_LevelRewardPanel_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnReqClose)
  self:AddButtonListener(self.Storage.btnLevelUp, self.OnGotoExpand)
  self:RegisterEvent(self, HomeIndoorSandbox.Event.OnExitRoomExpandPanel, self.OnExitRoomExpandPanel)
  self:RegisterEvent(self, HomeIndoorSandbox.Event.OnEnterRoomExpandPanel, self.OnEnterRoomExpandPanel)
end

function UMG_LevelRewardPanel_C:OnEnterRoomExpandPanel()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function UMG_LevelRewardPanel_C:OnExitRoomExpandPanel()
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_LevelRewardPanel_C:OnGotoExpand()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_LevelRewardPanel_C:OnGotoExpand")
  if not _G.DataConfigManager:GetRoomConf(_G.HomeIndoorSandbox.Server.WorldData.RoomLevel + 1, true) then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.room_expend_max)
    return
  end
  NRCModuleManager:DoCmd(HomeModuleCmd.OpenHomeExpandPanel)
end

function UMG_LevelRewardPanel_C:Init()
  local HOME_LEVEL_CONF = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.HOME_LEVEL_CONF):GetAllDatas()
  local ConfList = {}
  for k, v in pairs(HOME_LEVEL_CONF) do
    table.insert(ConfList, v)
  end
  table.sort(ConfList, function(a, b)
    return a.id < b.id
  end)
  local LevelState = {}
  for i, v in ipairs(self.protoData and self.protoData.state or {}) do
    LevelState[v.id] = v
  end
  local HomeLevelToRoomLevel = {}
  local ROOM_CONF = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.ROOM_CONF):GetAllDatas()
  for k, v in pairs(ROOM_CONF) do
    HomeLevelToRoomLevel[v.home_level] = v.id
  end
  local RoomLevel = HomeIndoorSandbox.Server.WorldData.RoomLevel or 0
  local LevelRewardInfoList = {}
  for i, Conf in ipairs(ConfList) do
    if 0 ~= (Conf.reward_id or 0) then
      table.insert(LevelRewardInfoList, {
        Conf = Conf,
        State = LevelState[Conf.id] or {
          id = Conf.id,
          state = ProtoEnum.RewardState.RewardStateType.REWARD_STATE_TYPE_NONE
        },
        bCanExpandThisHomeLevel = HomeLevelToRoomLevel[Conf.id] and RoomLevel < HomeLevelToRoomLevel[Conf.id]
      })
    end
  end
  local HomeLevel = HomeIndoorSandbox.Server.WorldData.HomeLevel or 0
  self.NRCScrollView_173:InitList(LevelRewardInfoList)
  self:DelayFrames(3, function()
    self.NRCScrollView_173:ScrollToIndex(math.max(0, HomeLevel - 2), true)
  end)
  self.Text_Level:SetText(HomeLevel)
  self.Text_Level_1:SetText(LuaText.home_level_name)
  self.NRCText_6:SetText(LuaText.goto_room_expend_tui)
  local BaseConf = DataConfigManager:GetHomeLevelConf(HomeLevel)
  if not BaseConf then
    Log.Error("UMG_LevelRewardPanel_C:Init BaseConf is nil")
    return
  end
  local Exp = HomeIndoorSandbox.Server.WorldData.HomeExp
  local NextLevelConf = DataConfigManager:GetHomeLevelConf(HomeLevel + 1, true)
  local NeedExp = 0
  if NextLevelConf then
    Exp = Exp - BaseConf.need_exp
    NeedExp = NextLevelConf.need_exp - BaseConf.need_exp
    local P = NeedExp > 0 and Exp / NeedExp or 1
    self.ProgressBar1:SetPercent(math.clamp(P, 0, 1))
    self.Text_Level2:SetText(string.format("%s/%s", Exp, NeedExp > 0 and NeedExp or Exp))
  else
    self.ProgressBar1:SetPercent(1)
    self.Text_Level2:SetText("")
  end
  self.Storage:SetRedDot(346)
  local bHasStoryFlag = _G.Enum.PlayerStoryFlagEnum.PSF_FUNC_UNLOCK_REWARD_TO_EXPANSION and _G.DataModelMgr.PlayerDataModel:HasStoryFlag(_G.Enum.PlayerStoryFlagEnum.PSF_FUNC_UNLOCK_REWARD_TO_EXPANSION)
  local bCanGotoExpand = bHasStoryFlag
  local Visibility = bCanGotoExpand and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed
  if self.NRCImage_67 then
    self.NRCImage_67:SetVisibility(Visibility)
  end
  self.Storage:SetVisibility(Visibility)
  self.NRCText_6:SetVisibility(Visibility)
end

return UMG_LevelRewardPanel_C
