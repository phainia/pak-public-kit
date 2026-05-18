local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local blendTime = 0.2
local BattleSpectatorObserveInfo = _G.MakeSimpleClass("BattleSpectatorObserveInfo")

function BattleSpectatorObserveInfo:Ctor(playerId, player)
  self.playerId = playerId
  self.player = player
  self.bIsObserving = false
  self.cheerAnimList = {
    "RolePlayCheer"
  }
  local animationNames = _G.DataConfigManager:GetBattleGlobalConfig("around_player_animation_name", true)
  if animationNames and animationNames.str then
    local animNameArray = {}
    for word in string.gmatch(animationNames.str, "[^;]+") do
      table.insert(animNameArray, word)
    end
    self.cheerAnimList = animNameArray
  end
  self:RegisterStatusListener()
end

function BattleSpectatorObserveInfo:OnDestroyed()
  self:UnregisterStatusListener()
  self:StopAnim()
  if self.AnimCompleteDelayHandle then
    _G.DelayManager:CancelDelayById(self.AnimCompleteDelayHandle)
    self.AnimCompleteDelayHandle = nil
  end
end

function BattleSpectatorObserveInfo:GetDebugInfo()
  if not self.player then
    return string.format("%d", self.playerId)
  end
  return string.format("%d - %d", self.playerId, self.player:GetUin())
end

function BattleSpectatorObserveInfo:RegisterStatusListener()
  if not self.player then
    return
  end
  self.player:AddEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnNetPlayerLogicStatusChanged)
  self:InitWithPlayerStatus(self.player)
end

function BattleSpectatorObserveInfo:UnregisterStatusListener()
  if not self.player then
    return
  end
  if self.player:HasListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnNetPlayerLogicStatusChanged) then
    self.player:RemoveEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnNetPlayerLogicStatusChanged)
  end
end

function BattleSpectatorObserveInfo:InitWithPlayerStatus(player)
  if not player then
    return
  end
  if player:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_OBSERVING) then
    self:OnPlayerEnterObserving(player)
  end
end

function BattleSpectatorObserveInfo:OnNetPlayerLogicStatusChanged(player, changeInfo)
  if not player then
    return
  end
  if not changeInfo then
    return
  end
  local changedStatus = changeInfo.changed_status
  if not changedStatus then
    return
  end
  local status = changedStatus.status
  local opType = changeInfo.op_type
  if status ~= ProtoEnum.SpaceActorLogicStatus.SALS_OBSERVING then
    return
  end
  if opType == ProtoEnum.LogicStatusOpType.LSOT_ADD then
    self:OnPlayerEnterObserving(player)
  elseif opType == ProtoEnum.LogicStatusOpType.LSOT_REMOVE then
    self:OnPlayerLeaveObserving(player)
  end
  Log.Debug("BattleSpectatorObserveInfo:OnNetPlayerLogicStatusChanged", self:GetDebugInfo(), status, opType)
end

function BattleSpectatorObserveInfo:OnPlayerEnterObserving(player)
  if self.bIsObserving then
    return
  end
  Log.Debug("BattleSpectatorObserveInfo:OnPlayerEnterObserving", self:GetDebugInfo())
  self.bIsObserving = true
  self:UpdatePlayerInteract(player)
  self:DoCheerPlay(player)
end

function BattleSpectatorObserveInfo:OnPlayerLeaveObserving()
  if not self.bIsObserving then
    return
  end
  Log.Debug("BattleSpectatorObserveInfo:OnPlayerLeaveObserving", self:GetDebugInfo())
  self.bIsObserving = false
  self:StopAnim()
end

function BattleSpectatorObserveInfo:UpdatePlayerInteract(player)
  if not player then
    return
  end
  local playerUID = _G.NRCModuleManager:DoCmd(RelationTreeCmd.GetCurPlayerUID)
  if playerUID == player:GetLogicId() then
    _G.NRCModuleManager:DoCmd(RelationTreeCmd.CloseRelationCover, playerUID)
  end
  local localPlayer = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    local interComp = localPlayer.Player2PlayerInteractionComponent
    if interComp and interComp.OptionMap then
      local option = interComp.OptionMap[player]
      if option then
        option:RemoveFromInteractUI()
      end
    end
  end
end

function BattleSpectatorObserveInfo:DoCheerPlay(player)
  self:StopAnim()
  local showTimeIntervalConfig = _G.DataConfigManager:GetBattleGlobalConfig("around_player_animation_time interval", true)
  local showTimeInterval = showTimeIntervalConfig and showTimeIntervalConfig.num or 0
  local showTimeIntervalRandomDeviationConfig = _G.DataConfigManager:GetBattleGlobalConfig("around_player_animation interval_random_deviation", true)
  local showTimeIntervalRandomDeviation = showTimeIntervalRandomDeviationConfig and showTimeIntervalRandomDeviationConfig.num or 0
  local min = showTimeInterval - showTimeIntervalRandomDeviation
  local max = showTimeInterval + showTimeIntervalRandomDeviation
  local nextPlayDelay = min + math.random() * 2 * showTimeIntervalRandomDeviation
  local currentAnimIndex = math.random(#self.cheerAnimList)
  self.currentCheerAnimName = self.cheerAnimList[currentAnimIndex]
  player:PlayAnim(self.currentCheerAnimName, 1.0, 0.0, blendTime, blendTime, 1)
  self.AnimCompleteDelayHandle = _G.DelayManager:DelaySeconds(nextPlayDelay, self.OnPlayCheerAnimComplete, self)
  Log.Debug("BattleSpectatorObserveInfo:DoCheerPlay", self:GetDebugInfo(), nextPlayDelay, self.currentCheerAnimName)
end

function BattleSpectatorObserveInfo:OnPlayCheerAnimComplete()
  if not self.player then
    return
  end
  if not self.bIsObserving then
    return
  end
  self:DoCheerPlay(self.player)
end

function BattleSpectatorObserveInfo:StopAnim()
  if not self.player then
    return
  end
  if self.currentCheerAnimName then
    self.player:StopAnim(self.currentCheerAnimName, blendTime)
  end
end

function BattleSpectatorObserveInfo:OnReconnect()
  self:StopAnim()
  self:InitWithPlayerStatus()
end

return BattleSpectatorObserveInfo
