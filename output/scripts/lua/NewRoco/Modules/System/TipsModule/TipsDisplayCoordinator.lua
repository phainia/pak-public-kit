local EventDispatcher = require("Common.EventDispatcher")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local LoadingUIModuleEvent = require("NewRoco.Modules.System.LoadingUIModule.LoadingUIModuleEvent")
local UILayerEvent = require("Core.NRCPanelLayer.UILayerEvent")
local PriorityQueue = require("Utils.PriorityQueue")
local TipsModuleEvent = require("NewRoco.Modules.System.TipsModule.TipsModuleEvent")
local TipsDisplayDistributor = require("NewRoco.Modules.System.TipsModule.TipsDisplayDistributor")
local TipUtils = require("NewRoco.Modules.System.TipsModule.Utils.TipUtils")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local RolePlayModuleEvent = require("NewRoco.Modules.System.RolePlay.RolePlayModuleEvent")
local RelationTreeEvent = require("NewRoco.Modules.System.RelationTree.RelationTreeEvent")
local TeamBattleModuleEvent = require("NewRoco.Modules.System.TeamBattle.TeamBattleModuleEvent")

local function CreateAreaData()
  return {
    blockingTipCnt = 0,
    blockingTips = not RocoEnv.IS_SHIPPING and _G.MakeWeakTable() or nil,
    blockingFlags = {}
  }
end

local function IsMainPanelVisible()
  local IsVisible = false
  local MainUIModule = _G.NRCModuleManager:GetModule("MainUIModule")
  if MainUIModule and MainUIModule:HasPanel("LobbyMain") then
    local panel = MainUIModule:GetPanel("LobbyMain")
    if panel and panel.enableView then
      IsVisible = true
    end
  end
  return IsVisible
end

local function TipCompareImpl(tip1, tip2)
  if tip1.tipBatch ~= tip2.tipBatch then
    return tip1.tipBatch < tip2.tipBatch
  end
  if tip1.tipPriority ~= tip2.tipPriority then
    return tip1.tipPriority < tip2.tipPriority
  end
  if tip1.tipPass ~= tip2.tipPass then
    return tip1.tipPass < tip2.tipPass
  end
  return tip1.tipSeq < tip2.tipSeq
end

local function CreateTipsCache()
  local queue = PriorityQueue()
  queue:SetCmpFunction(TipCompareImpl)
  return queue
end

local TipsDisplayCoordinator = Class("TipsDisplayCoordinator")

function TipsDisplayCoordinator:Ctor()
  EventDispatcher():Attach(self)
  self.IsTicking = false
  self.TickDelayCumulativeTime = 0
  self.PausedStatus = not IsMainPanelVisible() and TipEnum.TipsPauseReason.MainUIClose or 0
  self.TipsCache = CreateTipsCache()
  self.NoDependencyTipsCache = CreateTipsCache()
  self.NoPassMutexRequiredTipCache = CreateTipsCache()
  self.EnableMergedTipCache = {}
  self.RegisteredTipsDistributor = {}
  self.EffectingTipAreaMutex = {}
  self.CurTipBatch = 1
  self.CurTipBatchStartTime = _G.UpdateManager.Timestamp
  self.TipBatchInterval = 0
  _G.NRCEventCenter:RegisterEvent("TipsDisplayCoordinator", self, MainUIModuleEvent.MAINUIOPEN, self.OnLobbyMainReady)
  _G.NRCEventCenter:RegisterEvent("TipsDisplayCoordinator", self, MainUIModuleEvent.MAINUICLOSE, self.OnLobbyMainClosed)
  _G.NRCEventCenter:RegisterEvent("TipsDisplayCoordinator", self, LoadingUIModuleEvent.LOADING_UI_OPENED, self.OnLoadingUIOpen)
  _G.NRCEventCenter:RegisterEvent("TipsDisplayCoordinator", self, LoadingUIModuleEvent.LOADING_UI_CLOSED, self.OnLoadingUIClosed)
  _G.NRCEventCenter:RegisterEvent("TipsDisplayCoordinator", self, RolePlayModuleEvent.RolePlayMainPanelOpen, self.OnRolePlayMainPanelOpen)
  _G.NRCEventCenter:RegisterEvent("TipsDisplayCoordinator", self, RolePlayModuleEvent.RolePlayMainPanelClosed, self.OnRolePlayMainPanelClosed)
  _G.NRCEventCenter:RegisterEvent("TipsDisplayCoordinator", self, RelationTreeEvent.RELATION_TREE_PANEL_CLOSE, self.OnRelationTreeMainPanelClosed)
  _G.NRCEventCenter:RegisterEvent("TipsDisplayCoordinator", self, RelationTreeEvent.RELATION_TREE_PANEL_OPEN, self.OnRelationTreeMainPanelOpen)
  _G.NRCEventCenter:RegisterEvent("TipsDisplayCoordinator", self, TeamBattleModuleEvent.PreparationPanelOpen, self.OnPreparationPanelOpen)
  _G.NRCEventCenter:RegisterEvent("TipsDisplayCoordinator", self, TeamBattleModuleEvent.PreparationPanelClose, self.OnPreparationPanelClosed)
  _G.NRCPanelManager.layerCenter:AddEventListener(self, UILayerEvent.FULLSCREEN_LAYER_OPENWINDOW, self.OnFullScreenOpen)
  _G.NRCPanelManager.layerCenter:AddEventListener(self, UILayerEvent.FULLSCREEN_LAYER_CLOSEWINDOW, self.OnFullScreenClosed)
end

function TipsDisplayCoordinator:Free()
  _G.NRCEventCenter:UnRegisterEvent(self, MainUIModuleEvent.MAINUIOPEN, self.OnLobbyMainReady)
  _G.NRCEventCenter:UnRegisterEvent(self, MainUIModuleEvent.MAINUICLOSE, self.OnLobbyMainClosed)
  _G.NRCEventCenter:UnRegisterEvent(self, LoadingUIModuleEvent.LOADING_UI_OPENED, self.OnLoadingUIOpen)
  _G.NRCEventCenter:UnRegisterEvent(self, LoadingUIModuleEvent.LOADING_UI_CLOSED, self.OnLoadingUIClosed)
  _G.NRCEventCenter:UnRegisterEvent(self, RolePlayModuleEvent.RolePlayMainPanelOpen, self.OnRolePlayMainPanelOpen)
  _G.NRCEventCenter:UnRegisterEvent(self, RolePlayModuleEvent.RolePlayMainPanelClosed, self.OnRolePlayMainPanelClosed)
  _G.NRCPanelManager.layerCenter:RemoveEventListener(self, UILayerEvent.FULLSCREEN_LAYER_OPENWINDOW, self.OnFullScreenOpen)
  _G.NRCPanelManager.layerCenter:RemoveEventListener(self, UILayerEvent.FULLSCREEN_LAYER_CLOSEWINDOW, self.OnFullScreenClosed)
end

function TipsDisplayCoordinator:OnLobbyMainReady()
  self:TryResume(TipEnum.TipsPauseReason.MainUIClose)
end

function TipsDisplayCoordinator:OnLobbyMainClosed()
  self:DoPause(TipEnum.TipsPauseReason.MainUIClose)
end

function TipsDisplayCoordinator:OnFullScreenClosed()
  local FullScreenWindowCount = _G.NRCPanelManager:GetLayerWindowCount(Enum.UILayerType.UI_LAYER_FULLSCREEN)
  if FullScreenWindowCount > 0 then
    return
  end
  self:TryResume(TipEnum.TipsPauseReason.HasFullWindow)
end

function TipsDisplayCoordinator:OnFullScreenOpen()
  self:DoPause(TipEnum.TipsPauseReason.HasFullWindow)
end

function TipsDisplayCoordinator:OnLoadingUIOpen()
  self:DoPause(TipEnum.TipsPauseReason.LoadingUIOpen)
end

function TipsDisplayCoordinator:OnLoadingUIClosed()
  self:TryResume(TipEnum.TipsPauseReason.LoadingUIOpen)
end

function TipsDisplayCoordinator:OnRolePlayMainPanelOpen()
  self:DoPause(TipEnum.TipsPauseReason.RolePlayUIOpen)
end

function TipsDisplayCoordinator:OnRolePlayMainPanelClosed()
  self:TryResume(TipEnum.TipsPauseReason.RolePlayUIOpen)
end

function TipsDisplayCoordinator:OnRelationTreeMainPanelOpen()
  self:DoPause(TipEnum.TipsPauseReason.RelationTreeUIOpen)
end

function TipsDisplayCoordinator:OnRelationTreeMainPanelClosed()
  self:TryResume(TipEnum.TipsPauseReason.RelationTreeUIOpen)
end

function TipsDisplayCoordinator:OnPreparationPanelOpen()
  self:DoPause(TipEnum.TipsPauseReason.PreparationPanel)
end

function TipsDisplayCoordinator:OnPreparationPanelClosed()
  self:TryResume(TipEnum.TipsPauseReason.PreparationPanel)
end

function TipsDisplayCoordinator:AddTip(tip, cmdId)
  if not tip then
    return
  end
  TipUtils.DebugTipFlow("[AddTip]", tip)
  if self:MergeTip(tip) then
    return
  end
  local inNormalMode = self:CanDisplay()
  local distributionConf = TipUtils.GetTipDistributionConf(tip, inNormalMode)
  tip.tipPass = distributionConf.dispatchPass
  tip.tipPriority = TipUtils.GetTipPriority(tip, distributionConf)
  tip.tipDisplayAreas = TipUtils.GetTipDisplayAreas(tip)
  local addCacheFlag = true
  if inNormalMode then
    if self.TipBatchInterval and self.TipBatchInterval > 0 and _G.UpdateManager.Timestamp - self.CurTipBatchStartTime >= self.TipBatchInterval then
      self.CurTipBatch = self.CurTipBatch + 1
      self.CurTipBatchStartTime = _G.UpdateManager.Timestamp
    end
    if distributionConf.immediatelyDispatch and self:TipDistribution(tip) then
      addCacheFlag = false
    end
    self:SetTickStatus(true)
  end
  if addCacheFlag then
    tip.tipBatch = self.CurTipBatch
    tip:SetTipStatus(TipEnum.TipStatus.Caching)
    if distributionConf.immediatelyDispatch and (not tip.tipDisplayAreas or next(tip.tipDisplayAreas) == nil) then
      self.NoDependencyTipsCache:EnQueue(tip)
    elseif not TipUtils.IsMutexRequiredTipPass(tip.tipPass) then
      self.NoPassMutexRequiredTipCache:EnQueue(tip)
    else
      self.TipsCache:EnQueue(tip)
    end
    TipUtils.DebugTipFlow("[CacheTip]", tip)
  end
end

function TipsDisplayCoordinator:Pause(reason)
  self:DoPause(reason or TipEnum.TipsPauseReason.UserSetting)
end

function TipsDisplayCoordinator:Resume(reason)
  self:TryResume(reason or TipEnum.TipsPauseReason.UserSetting)
end

function TipsDisplayCoordinator:HasDisplayingTip(area)
  local mutexData = self.EffectingTipAreaMutex[area]
  if not mutexData then
    return false
  end
  return mutexData.blockingTipCnt and mutexData.blockingTipCnt > 0 or mutexData.blockingFlags and #mutexData.blockingFlags > 0
end

function TipsDisplayCoordinator:SetTipAreaBlock(area, block, flag)
  if not flag then
    return
  end
  TipUtils.DebugLog("SetTipAreaBlock: area=%d, block=%d, flag=%s", area, block and 1 or 0, flag)
  local mutexData = self.EffectingTipAreaMutex[area]
  if not mutexData then
    mutexData = CreateAreaData()
    self.EffectingTipAreaMutex[area] = mutexData
  end
  if block then
    if not table.contains(mutexData.blockingFlags, flag) then
      table.insert(mutexData.blockingFlags, flag)
      if 1 == #mutexData.blockingFlags then
        _G.NRCEventCenter:DispatchEvent(TipsModuleEvent.Tips_DisplayCoordinatorAreaBlock, area, true)
      end
    end
  elseif table.removeValue(mutexData.blockingFlags, flag) and #mutexData.blockingFlags <= 0 then
    _G.NRCEventCenter:DispatchEvent(TipsModuleEvent.Tips_DisplayCoordinatorAreaBlock, area, false)
    if self:CanDisplay() then
      self:SetTickStatus(true)
    end
  end
end

function TipsDisplayCoordinator:IsTipDisplayAreaBlock(tip)
  local displayAreas = tip and tip.tipDisplayAreas
  if displayAreas then
    for _, area in ipairs(displayAreas) do
      local mutexData = self.EffectingTipAreaMutex[area]
      if mutexData and mutexData.blockingFlags and #mutexData.blockingFlags > 0 then
        return true
      end
    end
  end
  return false
end

function TipsDisplayCoordinator:AddMutexArea(tip)
  local addResult = false
  local tipAreas = tip and tip.tipDisplayAreas
  if tipAreas and #tipAreas > 0 then
    TipUtils.DebugTipFlow("[AddMutexArea]", tip)
    for _, tipArea in ipairs(tipAreas) do
      local areaData = self.EffectingTipAreaMutex[tipArea]
      if not areaData then
        addResult = true
      elseif not areaData.blockingTipCnt or areaData.blockingTipCnt <= 0 then
        addResult = true
      elseif areaData.blockingFlags and #areaData.blockingFlags > 0 then
        addResult = false
      elseif TipUtils.IsMutexRequiredTipPass(areaData.tipPass) then
        addResult = areaData.tipPass == tip.tipPass
      else
        addResult = areaData.tipType == tip.tipType and areaData.tipCustomType == tip.tipCustomType
      end
      if not addResult then
        break
      end
    end
    if addResult then
      for _, tipArea in ipairs(tipAreas) do
        local areaData = self.EffectingTipAreaMutex[tipArea]
        if not areaData then
          areaData = CreateAreaData()
          self.EffectingTipAreaMutex[tipArea] = areaData
        end
        areaData.tipPass = tip.tipPass
        areaData.tipType = tip.tipType
        areaData.tipCustomType = tip.tipCustomType
        areaData.blockingTipCnt = areaData.blockingTipCnt and areaData.blockingTipCnt + 1 or 0
        if areaData.blockingTips then
          areaData.blockingTips[tip.tipSeq] = tip
        end
      end
    end
  end
  return addResult
end

function TipsDisplayCoordinator:OnTipDisplayFinished(tip)
  local tipAreas = tip and tip.tipDisplayAreas
  if tipAreas and #tipAreas > 0 then
    TipUtils.DebugTipFlow("[RemoveMutexArea]", tip)
    local shouldTriggerTick = false
    for _, tipArea in ipairs(tipAreas) do
      local areaData = self.EffectingTipAreaMutex[tipArea]
      if areaData then
        areaData.blockingTipCnt = areaData.blockingTipCnt - 1
        if areaData.blockingTipCnt <= 0 then
          areaData.blockingTipCnt = 0
          shouldTriggerTick = true
        end
        if areaData.blockingTips then
          areaData.blockingTips[tip.tipSeq] = nil
        end
      end
    end
    if shouldTriggerTick and self:CanDisplay() then
      self:SetTickStatus(true)
    end
  end
end

function TipsDisplayCoordinator:MergeTip(tipSrcNew)
  local mergeHandler = TipUtils.GetTipMergeHandler(tipSrcNew)
  if mergeHandler then
    local cachedMergeTips = self.EnableMergedTipCache[mergeHandler]
    if cachedMergeTips and #cachedMergeTips > 0 then
      local processIndex = #cachedMergeTips
      while processIndex > 0 do
        local processTip = cachedMergeTips[processIndex]
        if not processTip or processTip:GetTipStatus() >= TipEnum.TipStatus.OnDisplay then
          table.remove(cachedMergeTips, processIndex)
        end
        processIndex = processIndex - 1
      end
      for mergeDstIndex = 1, #cachedMergeTips do
        local dstTip = cachedMergeTips[mergeDstIndex]
        if dstTip and mergeHandler(dstTip, tipSrcNew) then
          TipUtils.DebugTipFlow("[MergeTip] success.", tipSrcNew)
          return true
        end
      end
    end
    if not self.EnableMergedTipCache[mergeHandler] then
      self.EnableMergedTipCache[mergeHandler] = {}
    end
    table.insert(self.EnableMergedTipCache[mergeHandler], tipSrcNew)
    TipUtils.DebugTipFlow("[MergeTip] cache to merge.", tipSrcNew)
  end
end

function TipsDisplayCoordinator:DoTipDistribution(cache)
  while cache:Size() > 0 do
    local tip = cache:GetTop()
    if tip and not self:TipDistribution(tip) then
      TipUtils.DebugTipFlow("[OnTick] TipDistribution failed.", tip)
      break
    end
    cache:DeQueue()
  end
end

function TipsDisplayCoordinator:OnTick(deltaTime)
  self.TickDelayCumulativeTime = self.TickDelayCumulativeTime + deltaTime
  if self.TickDelayCumulativeTime < 0.2 then
    self:DoTipDistribution(self.NoDependencyTipsCache)
    return
  end
  self:SetTickStatus(false)
  if self:CanDisplay() then
    self:DoTipDistribution(self.NoDependencyTipsCache)
    self:DoTipDistribution(self.NoPassMutexRequiredTipCache)
    self:DoTipDistribution(self.TipsCache)
    for _, _distributor in pairs(self.RegisteredTipsDistributor) do
      _distributor:SetDispatchBatchFinished()
    end
  end
end

function TipsDisplayCoordinator:TipDistribution(tip, forceDistribution)
  local IsCanDistribution = true
  if not forceDistribution and TipUtils.IsMutexRequiredTipPass(tip.tipPass) then
    for _tipPass, _distributor in pairs(self.RegisteredTipsDistributor) do
      if _distributor:ShouldWaitDispatchFinished() and tip.tipPass ~= _tipPass then
        IsCanDistribution = false
        break
      end
    end
  end
  if not forceDistribution and IsCanDistribution and tip.tipDisplayAreas and #tip.tipDisplayAreas > 0 then
    if self:AddMutexArea(tip) then
      tip:RegisterStatusChangeHandle(TipEnum.TipStatus.Expired, self, self.OnTipDisplayFinished)
    else
      IsCanDistribution = false
    end
  end
  if IsCanDistribution then
    local distributor = self.RegisteredTipsDistributor[tip.tipPass]
    if not distributor then
      distributor = TipsDisplayDistributor(tip.tipPass)
      distributor:RegisterCompleteDistributionEvent(self, self.OnCompleteDistributionHandle)
      self.RegisteredTipsDistributor[tip.tipPass] = distributor
    end
    distributor:Dispatch(tip)
  end
  return IsCanDistribution
end

function TipsDisplayCoordinator:CanDisplay()
  if 0 ~= self.PausedStatus then
    return false
  end
  return true
end

function TipsDisplayCoordinator:DoPause(reason)
  local InPausingStatus = 0 ~= self.PausedStatus
  self.PausedStatus = self.PausedStatus | reason
  TipUtils.DebugLog("Tip pause. add reason=%d, PausedStatus=%d", reason, self.PausedStatus)
  self:SetTickStatus(false)
  if not InPausingStatus then
    _G.NRCEventCenter:DispatchEvent(TipsModuleEvent.Tips_DisplayCoordinatorPaused)
  end
end

function TipsDisplayCoordinator:TryResume(reason)
  self.PausedStatus = self.PausedStatus & ~reason
  TipUtils.DebugLog("Tip resume. remove reason=%d, PausedStatus=%d", reason, self.PausedStatus)
  if self:CanDisplay() then
    _G.NRCEventCenter:DispatchEvent(TipsModuleEvent.Tips_DisplayCoordinatorResumed)
    self:SetTickStatus(true)
  end
end

function TipsDisplayCoordinator:SetTickStatus(enableTick)
  TipUtils.DebugLog("Tip SetTickStatus. enableTick=%d, IsTicking=%d", enableTick and 1 or 0, self.IsTicking and 1 or 0)
  if enableTick then
    if not self.IsTicking then
      _G.UpdateManager:Register(self, true)
      self.IsTicking = true
      self.TickDelayCumulativeTime = 0
    end
  elseif self.IsTicking then
    _G.UpdateManager:UnRegister(self)
    self.IsTicking = false
  end
end

function TipsDisplayCoordinator:OnCompleteDistributionHandle(distributor)
  local hasAnyBlockingDispatch = false
  for _, _distributor in pairs(self.RegisteredTipsDistributor) do
    if _distributor:ShouldWaitDispatchFinished() then
      hasAnyBlockingDispatch = true
      break
    end
  end
  if not hasAnyBlockingDispatch then
    self:SetTickStatus(true)
  end
end

return TipsDisplayCoordinator
