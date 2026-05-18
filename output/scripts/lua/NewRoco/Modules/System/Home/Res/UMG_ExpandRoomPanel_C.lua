local UMG_ExpandRoomPanel_C = _G.NRCPanelBase:Extend("UMG_ExpandRoomPanel_C")

function UMG_ExpandRoomPanel_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_ExpandRoomPanel_C:OnActive()
  if _G.GlobalConfig.DebugOpenUI then
    return
  end
  self:SetCommonTitle()
  self:Init()
  self.LogTickTimer = TimerManager:CreateTimer(self, "UMG_ExpandRoomPanel_C", math.maxinteger, self.OnLowTick, nil, 0.1)
  _G.NRCEventCenter:RegisterEvent("UMG_ExpandRoomPanel_C", self, _G.TaskModuleEvent.TaskChangeNotify, self.OnTaskChangeNotify)
  HomeIndoorSandbox:RegisterEvent(HomeIndoorSandbox.Event.OnRspPlayExpandStartSkill, self, self.OnRspPerform)
  HomeIndoorSandbox:DispatchEvent(HomeIndoorSandbox.Event.OnEnterRoomExpandPanel)
  _G.NRCAudioManager:PlaySound2DAuto(1237, "UMG_ExpandRoomPanel_C:OnActive")
end

function UMG_ExpandRoomPanel_C:OnDeactive()
  if _G.GlobalConfig.DebugOpenUI then
    return
  end
  TimerManager:RemoveTimer(self.LogTickTimer)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.TaskModuleEvent.TaskChangeNotify, self.OnTaskChangeNotify)
  HomeIndoorSandbox:UnRegisterEvent(HomeIndoorSandbox.Event.OnRspPlayExpandStartSkill, self)
  HomeIndoorSandbox:DispatchEvent(HomeIndoorSandbox.Event.OnExitRoomExpandPanel)
end

function UMG_ExpandRoomPanel_C:OnAddEventListener()
  self:AddButtonListener(self.Btn6.btnLevelUp, self.OnBtnExpand)
  if self.BtnGray then
    self:AddButtonListener(self.BtnGray.btnLevelUp, self.OnBtnExpand)
  end
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnReqClose)
end

function UMG_ExpandRoomPanel_C:OnReqClose()
  if self.bPendingClose then
    return
  end
  self.bPendingClose = true
  _G.NRCAudioManager:PlaySound2DAuto(41401010, "UMG_ExpandRoomPanel_C:OnReqClose")
  self:PlayAnimation(self.Out)
end

function UMG_ExpandRoomPanel_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    self:OnClose()
  end
end

function UMG_ExpandRoomPanel_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  if self.titleConf.title then
    self.Title1:Set_MainTitle(self.titleConf.title)
  end
  if self.titleConf.head_icon then
    self.Title1:SetBg(self.titleConf.head_icon)
  end
  if self.titleConf.subtitle then
    self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
  end
end

function UMG_ExpandRoomPanel_C:JudgeIfCanExpand()
  if not self.RoomLevelConf then
    return false
  end
  if ENABLE_LOCAL_HOME_SERVER then
    return true
  end
  if self.ExpandTasks then
    local HomeData = HomeIndoorSandbox.Module:GetData()
    for i, task in pairs(self.ExpandTasks) do
      local bFinish = HomeData:IfExpandParagraphTaskCompleted(task)
      if not bFinish then
        return false
      end
    end
  end
  return true
end

function UMG_ExpandRoomPanel_C:ResolveRoomConf(RoomLevelConf)
  self.RoomLevelConf = RoomLevelConf
  self.ExpandTasks = self.module:GetData():GetExpandParagraphTasks(RoomLevelConf) or {}
  self:InitUnlocks()
end

function UMG_ExpandRoomPanel_C:GetTimeDisplayString(Time)
  local Days = Time // 86400
  Time = Time - Days * 86400
  local Hours = Time // 3600
  Time = Time - Hours * 3600
  local Minus = Time // 60
  local Desc = ""
  if Days > 0 then
    Desc = Desc .. string.format(LuaText.room_expend_need_time_day, Days)
  end
  if Hours > 0 then
    Desc = Desc .. string.format(LuaText.room_expend_need_time_hour, Hours)
  end
  if Minus > 0 then
    Desc = Desc .. string.format(LuaText.room_expend_need_time_min, Minus)
  end
  if "" == Desc then
    Desc = string.format(LuaText.room_expend_need_time_min, 1)
  end
  return Desc
end

function UMG_ExpandRoomPanel_C:Init()
  local Status, Arg1, Arg2, Arg3 = HomeIndoorSandbox.Server.WorldData:GetExpansionStatus()
  self.Status = Status
  if Status == HomeIndoorSandbox.Enum.EnmExpandStatus.None then
    local RoomLevelConf = DataConfigManager:GetRoomConf(HomeIndoorSandbox.Server.WorldData.RoomLevel + 1)
    self:ResolveRoomConf(RoomLevelConf)
    if not RoomLevelConf then
      self.NRCSwitcher_0:SetVisibility(UE.ESlateVisibility.Collapsed)
    else
      self.NRCSwitcher_0:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.NRCSwitcher_0:SetActiveWidgetIndex(0)
      self.NRCText_3:SetText(self:GetTimeDisplayString(RoomLevelConf.expend_cost_time))
      self.NRCText_4:SetText(string.format("%s", RoomLevelConf.expend_vitem_num))
      local ItemConf = DataConfigManager:GetVisualItemConf(RoomLevelConf.expend_vitem_type)
      self.NRCImage_6:SetPath(ItemConf.iconPath or "")
      if self.BtnGray then
        if self:JudgeIfCanExpand() then
          self.Btn6:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
          self.BtnGray:SetVisibility(UE.ESlateVisibility.Collapsed)
        else
          self.Btn6:SetVisibility(UE.ESlateVisibility.Collapsed)
          self.BtnGray:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        end
      end
    end
  elseif Status == HomeIndoorSandbox.Enum.EnmExpandStatus.Expanding then
    local RemainTime = Arg1
    local CostTime = Arg2
    local RoomLevelConf = Arg3
    self:ResolveRoomConf(RoomLevelConf)
    self.NRCSwitcher_0:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.NRCSwitcher_0:SetActiveWidgetIndex(1)
    self:RefreshProgress(RemainTime, CostTime)
  elseif Status == HomeIndoorSandbox.Enum.EnmExpandStatus.ExpandEstablished then
    HomeIndoorSandbox.UpgradeServ:StartReplaceSelectView()
  end
  local ROOM_CONF = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.ROOM_CONF):GetAllDatas()
  local Types = {}
  local TypeSet = {}
  local RoomLevel = HomeIndoorSandbox.Server.WorldData.RoomLevel
  for i, v in pairs(ROOM_CONF) do
    if v.expend_vitem_type and v.id <= RoomLevel + 1 and not TypeSet[v.expend_vitem_type] then
      TypeSet[v.expend_vitem_type] = true
      local Data = {
        moneyType = v.expend_vitem_type,
        sum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(v.expend_vitem_type),
        IsShowBuyIcon = false
      }
      table.insert(Types, Data)
    end
  end
  table.sort(Types, function(a, b)
    return a.moneyType < b.moneyType
  end)
  Types = {
    {
      moneyType = Enum.VisualItem.VI_FURNITURE_COIN,
      sum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(Enum.VisualItem.VI_FURNITURE_COIN),
      IsShowBuyIcon = false
    }
  }
  self.MoneyBtn:InitGridView(Types)
end

function UMG_ExpandRoomPanel_C:InitUnlocks()
  local RoomLevelConf = self.RoomLevelConf
  local Prev = DataConfigManager:GetRoomConf(HomeIndoorSandbox.Server.WorldData.RoomLevel)
  self.HomePhotos1:SetPath(Prev and Prev.look or "")
  self.Text_HomeName1:SetText(Prev and Prev.name or "")
  self.HomePhotos2:SetPath(RoomLevelConf.look or "")
  self.Text_HomeName2:SetText(RoomLevelConf and RoomLevelConf.name or "")
  self.NRCGridView_62:InitGridView(RoomLevelConf.desc or {})
  self:RefreshConditions()
end

function UMG_ExpandRoomPanel_C:RefreshConditions()
  local StatusList = {}
  local HomeData = HomeIndoorSandbox.Module:GetData()
  for i, Task in ipairs(self.ExpandTasks or {}) do
    local bFinish, TaskInfo = HomeData:IfExpandParagraphTaskCompleted(Task)
    for j, condition in pairs(Task.task_condition) do
      local DoneCount = TaskInfo and TaskInfo.task_target_list[j] or 0
      local Data = {
        Desc = string.format("%s(%d/%d)", condition.text, DoneCount, condition.count),
        bFinish = bFinish,
        Task = Task,
        TaskInfo = TaskInfo
      }
      table.insert(StatusList, Data)
    end
  end
  self.NRCGridView_127:InitGridView(StatusList)
end

function UMG_ExpandRoomPanel_C:OnTaskChangeNotify()
  self:Init()
end

function UMG_ExpandRoomPanel_C:RefreshProgress(Remaining, CostTime)
  if Remaining < 0 then
    HomeIndoorSandbox:Ensure(false, "logical error timestamp, current", ZoneServer:GetServerTime(), "expand start from", HomeIndoorSandbox.Server.WorldData.RoomExpansionInfo.expansion_start_timestamp, "remaining", Remaining, "cost", CostTime)
    Remaining = 0
  end
  if Remaining > CostTime + 5 then
    HomeIndoorSandbox:Ensure(false, "logical error timestamp, current", ZoneServer:GetServerTime(), "expand start from", HomeIndoorSandbox.Server.WorldData.RoomExpansionInfo.expansion_start_timestamp, "remaining", Remaining, "cost", CostTime)
    Remaining = CostTime
  end
  local InRemaining = math.min(Remaining, CostTime)
  Remaining = math.floor(Remaining)
  local Hour = Remaining // 3600
  Remaining = Remaining - Hour * 3600
  local Minus = Remaining // 60
  Remaining = Remaining - Minus * 60
  self.NRCText_7:SetText(string.format("%02d:%02d:%02d", Hour, Minus, Remaining))
  local p = 1 - InRemaining / CostTime
  self.ProgressBar1:SetPercent(math.clamp(p, 0, 1))
end

function UMG_ExpandRoomPanel_C:OnLowTick()
  self:OnRefresh()
end

function UMG_ExpandRoomPanel_C:OnRefresh()
  local Status, Arg1, Arg2 = HomeIndoorSandbox.Server.WorldData:GetExpansionStatus()
  if Status ~= self.Status then
    self:Init()
  elseif Status == HomeIndoorSandbox.Enum.EnmExpandStatus.Expanding then
    local RemainTime = Arg1
    local CostTime = Arg2
    self:RefreshProgress(RemainTime, CostTime)
  end
end

function UMG_ExpandRoomPanel_C:OnBtnExpand()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_ExpandRoomPanel_C:OnBtnExpand")
  if self.bRequesting then
    return
  end
  self.bRequesting = true
  HomeIndoorSandbox.Server:ReqStartUpgradeHome(function(bSuccess)
    self.bRequesting = false
    if not self.panelData then
      return
    end
    if bSuccess then
      self:Init()
      self:OnReqPerform()
    end
  end)
end

function UMG_ExpandRoomPanel_C:OnReqPerform()
  HomeIndoorSandbox:DispatchEvent(HomeIndoorSandbox.Event.OnReqPlayExpandStartSkill)
end

function UMG_ExpandRoomPanel_C:OnRspPerform(bStart)
  if bStart then
    HomeIndoorSandbox.Module:DisablePanel(self.panelName)
  else
    HomeIndoorSandbox.Module:ClosePanel(self.panelName)
  end
end

return UMG_ExpandRoomPanel_C
