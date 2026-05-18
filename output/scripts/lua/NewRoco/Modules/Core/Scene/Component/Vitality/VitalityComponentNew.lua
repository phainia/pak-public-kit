local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local VitalityCostRegistry = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityCost.VitalityCostRegistry")
local Vitality = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityNew")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local StatusUtils = require("NewRoco.Modules.Core.Scene.Component.Status.StatusUtils")
local VitalityUtil = require("NewRoco.Modules.Core.Scene.Component.Vitality.VitalityUtil")
local Stat = require("NewRoco.Modules.Core.Scene.Component.Stat.Stat")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local VitalityComponentNew = Base:Extend("VitalityComponentNew")
local SYNC_INTERVAL = 1
local VITALITY_ID = 1
local MAX_DELTA_TIME = 1

function VitalityComponentNew:Ctor()
  Base.Ctor(self)
  self._vitalityCostTable = {}
  self._config = DataConfigManager:GetVitalityConf(VITALITY_ID)
  self._vitality = Vitality(self._config)
  self._decayThreshold = 0
  self._vitality_cost_ratio = 1
  self._cur_cost_vitality = false
  self._last_cost_vitality = false
end

function VitalityComponentNew:Attach(owner)
  Base.Attach(self, owner)
  owner:AddEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPlayerStatusChanged)
  owner:AddEventListener(self, PlayerModuleEvent.ON_PLAYER_REBORN, self.OnPlayerReborn)
  owner:AddEventListener(self, PlayerModuleEvent.ON_UPDATE_VITALITY_COST, self.OnUpdateVitalityCost)
  self._sync_time = SYNC_INTERVAL
  self:Init(self.owner.serverData)
  for k, v in pairs(VitalityCostRegistry) do
    self:_GetVitalityCost(k)
  end
  if not NRCEnv:IsLocalMode() then
    ZoneServer:AddProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_SCENE_STAMINA_CHANGE_NOTIFY, self.OnVitalityChangeNotify)
  end
  self.owner.statComponent:CreateStat(StatType.VITALITY_COST_RATIO, 1)
  self.owner.statComponent:CreateStat(StatType.VITALITY_COST_RATIO_TALENT, 1)
  self:UpdateRecoverStatus()
end

function VitalityComponentNew:OnUpdateVitalityCost(status, id, caller, callback)
  local result = false
  local costCategory = self:_GetVitalityCost(status)
  if costCategory then
    result = costCategory:SetID(id)
  end
  if callback then
    callback(caller, result)
  end
end

function VitalityComponentNew:DeAttach()
  if self.owner then
    self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPlayerStatusChanged)
    self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_PLAYER_REBORN, self.OnPlayerReborn)
    self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_UPDATE_VITALITY_COST, self.OnUpdateVitalityCost)
  end
  if not NRCEnv:IsLocalMode() then
    ZoneServer:RemoveProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_SCENE_STAMINA_CHANGE_NOTIFY, self.OnVitalityChangeNotify)
  end
  for k, v in pairs(self._vitalityCostTable) do
    v:Destroy()
  end
  self._vitalityCostTable = {}
  Base.DeAttach(self)
end

function VitalityComponentNew:Init(serverData)
  if serverData and serverData.attrs then
    local cur = serverData.attrs.stamina
    local max = serverData.attrs.stamina_max
    self._vitality:SyncVitality(cur)
    self._vitality:SyncMaxVitality(max)
    self:LogVitality(Log.LOG_LEVEL.ELogDebug, "\229\136\157\229\167\139\229\140\150\229\144\142\229\143\176\228\189\147\229\138\155,\229\189\147\229\137\141(%f),\230\156\128\229\164\167(%f)", cur or 0, max or 0)
  end
  Log.Debug("VitalityComponentNew:Init")
end

function VitalityComponentNew:SyncVitality(max, current)
  if max then
    self._vitality:SyncMaxVitality(max)
  end
  if current then
    self._vitality:SyncVitality(current)
  end
end

function VitalityComponentNew:SetVitalityCostRatio(ratio)
  self._vitality_cost_ratio = ratio
end

function VitalityComponentNew:GetVitalityCostRatio()
  local costRatio = self.owner.statComponent:GetValue(StatType.VITALITY_COST_RATIO) or 1
  local costRatio_Talent = self.owner.statComponent:GetValue(StatType.VITALITY_COST_RATIO_TALENT) or 1
  return costRatio * costRatio_Talent
end

function VitalityComponentNew:Update(deltaTime)
  if GlobalConfig.FreeVitality then
    return
  end
  deltaTime = math.min(deltaTime, MAX_DELTA_TIME)
  for k, v in pairs(self._vitalityCostTable) do
    if v and v:IsRunning() then
      v:OnUpdate(deltaTime)
    end
  end
  self._vitality:UpdateState(deltaTime)
  local isSwimOrSkyBattle = BattleManager and BattleManager:IsInBattle() and BattleManager.EnterBattleStateBit ~= BattleEnum.EnterBattleState.Default
  if not isSwimOrSkyBattle then
    local isRide = self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL)
    if not isRide then
      if self.owner.viewObj then
        local movementMode = self.owner.viewObj.CharacterMovement.MovementMode
        if movementMode ~= UE.EMovementMode.MOVE_None and movementMode ~= UE.EMovementMode.MOVE_Swimming then
          local isIdle = self.owner.ueController:IsIdle()
          self:RecoverVitality(deltaTime, isIdle)
        end
      else
        Log.Error("view obj is nil")
      end
    else
      local hasRidePet = self.owner.viewObj.RidePet ~= nil
      if hasRidePet then
        local isLandIdle = self.owner.ueController:IsLandIdle()
        if isLandIdle then
          self:RecoverVitality(deltaTime, true)
        elseif self.owner.viewObj.RidePet.CharacterMovement:IsMovingOnGround() then
          self:RecoverVitality(deltaTime, false)
        end
      end
    end
  else
  end
  self:UpdateFx()
  self:RecoverVitalityByBuff(deltaTime)
  if self._cur_cost_vitality then
    self._cur_cost_vitality = false
    self._last_cost_vitality = true
  else
    self._last_cost_vitality = false
  end
  if _G.ZoneServer:CanSendNetworkCmd() then
    self._sync_time = self._sync_time - deltaTime
    if self._sync_time <= 0 then
      self._sync_time = SYNC_INTERVAL
      self:ReportVitality()
    end
  end
end

function VitalityComponentNew:AddRecoverBuff(vitalityRecoverPercent, vitalityRecover)
  self.vitalityRecoverBuff = true
  self.vitalityRecoverPercent = vitalityRecoverPercent
  self.vitalityRecover = vitalityRecover
  Log.Trace("VitalityComponentNew:AddRecoverBuff")
end

function VitalityComponentNew:RemoveRecoverBuff()
  self.vitalityRecoverBuff = false
  self.vitalityRecoverPercent = 0
  self.vitalityRecover = 0
  Log.Debug("VitalityComponentNew:RemoveRecoverBuff")
end

function VitalityComponentNew:RecoverVitalityByBuff(deltaTime)
  if self.vitalityRecoverBuff then
    local recoverValue = ((self.vitalityRecoverPercent or 0) / 100 * self:GetMaxVitality() + self.vitalityRecover) * deltaTime
    self:RecoverVitalityByValue(recoverValue)
  end
end

function VitalityComponentNew:FetchSeverVitality()
  local req = ProtoMessage:newZoneSceneGetStaminaInfoReq()
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_GET_STAMINA_INFO_REQ, req, self, self.OnFetchSeverVitality, false, true)
end

function VitalityComponentNew:OnFetchSeverVitality(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    self:LogVitality(Log.LOG_LEVEL.ELogError, "VitalityComponentNew:OnFetchSeverVitality Error %f", rsp.ret_info.ret_code)
    return
  end
  self:LogVitality(Log.LOG_LEVEL.ELogDebug, "VitalityComponentNew:OnFetchSeverVitality (%.1f,%.1f))", rsp.server_stamina_max, rsp.server_stamina)
  self._serverMaxVitality = rsp.server_stamina_max
  self._serverVitality = rsp.server_stamina
  self:SyncVitality(rsp.server_stamina_max, rsp.server_stamina)
end

function VitalityComponentNew:ReportVitality()
  if NRCEnv:IsLocalMode() then
    return
  end
  local vitalityState = self._vitality:GetState()
  if vitalityState == VitalityUtil.VitalityState.Forbidden or vitalityState == VitalityUtil.VitalityState.Normal then
    self:LogVitality(Log.LOG_LEVEL.ELogDebug, "VitalityComponentNew:ReportVitality Skipped, VitalityState = %d", vitalityState)
    return
  end
  local req = ProtoMessage:newZoneSceneSyncStaminaReq()
  req.stamina = math.floor(self:GetCurVitality())
  req.time_stamp = ZoneServer:GetServerTime()
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_SYNC_STAMINA_REQ, req, self, self.OnReportVitality, false, true)
  self:LogVitality(Log.LOG_LEVEL.ELogDebug, "VitalityComponentNew:ReportVitality (%.1f,%.1f)", self:GetMaxVitality() or 0, self:GetCurVitality() or 0)
end

function VitalityComponentNew:OnReportVitality(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    self:LogVitality(Log.LOG_LEVEL.ELogWarn, "VitalityComponentNew:Vitality Sync Error")
  end
  self:LogVitality(Log.LOG_LEVEL.ELogDebug, "VitalityComponentNew:Vitality Sync, Server(%.1f,%.1f),Client(%.1f,%.1f)", rsp.server_stamina_max or 0, rsp.server_stamina or 0, self:GetMaxVitality() or 0, self:GetCurVitality() or 0)
  self:SyncVitality(rsp.server_stamina_max)
  self._serverMaxVitality = rsp.server_stamina_max
  self._serverVitality = rsp.server_stamina
end

function VitalityComponentNew:OnVitalityChangeNotify(notify)
  if notify.change_reason == ProtoEnum.STAMINA_CHANGE_REASON.SCR_DUGEON then
    local banVitality = notify.ban_stamina
    Log.Debug("VitalityComponentNew \230\148\182\229\136\176\229\144\142\229\143\176\229\137\175\230\156\172\231\166\129\231\148\168\228\189\147\229\138\155\233\128\154\231\159\165", banVitality)
    GlobalConfig.FreeVitality = banVitality
    return
  end
  local newVitalityValue = math.clamp(self:GetCurVitality() + notify.stamina_change, 0, self:GetMaxVitality())
  self:LogVitality(Log.LOG_LEVEL.ELogDebug, "reason(%d),value(%f),current(%f)", notify.change_reason, notify.stamina_change, newVitalityValue)
  self._vitality:SyncVitality(newVitalityValue)
end

function VitalityComponentNew:UpdateRecoverStatus()
  if self._config and self._config.forbid_status then
    for _, v in pairs(self._config.forbid_status) do
      local hasStatus = self.owner.statusComponent:HasStatus(v)
      if hasStatus then
        self._vitality:StopRecover()
        self.isForbid = true
        self:LogVitality(Log.LOG_LEVEL.ELogDebug, "Vitality:OnStatusChanged forbid by " .. StatusUtils.StatusToString(v))
        return
      end
    end
  end
  self._vitality:StartRecover()
  if self.isForbid then
    self.isForbid = false
    self:LogVitality(Log.LOG_LEVEL.ELogDebug, "Vitality:OnStatusChanged UnForbid")
  end
end

function VitalityComponentNew:OnPlayerStatusChanged(status, value)
  self:UpdateVitalityCost(status, value)
  self:UpdateRecoverStatus()
end

function VitalityComponentNew:UpdateVitalityCost(status, value)
  local vitalityCost = self._vitalityCostTable[status]
  if vitalityCost then
    local hasStatus = self.owner.statusComponent:HasStatus(status)
    vitalityCost:Pause(not hasStatus)
  end
end

function VitalityComponentNew:_GetVitalityCost(status)
  local vitalityCost = self._vitalityCostTable[status]
  if not vitalityCost then
    local klass = VitalityCostRegistry[status]
    if not klass then
      return nil
    end
    vitalityCost = klass(self)
    vitalityCost.tag = StatusUtils.StatusToString(status)
    self._vitalityCostTable[status] = vitalityCost
  end
  return self._vitalityCostTable[status]
end

function VitalityComponentNew:CostVitality(costValue, stillCostWhenNotEnough, costType, tag)
  if GlobalConfig.FreeVitality then
    return true
  end
  self._cur_cost_vitality = true
  local actualCostValue = costValue * self:GetVitalityCostRatio()
  local costSuccess = self._vitality:_CostVitality(actualCostValue, stillCostWhenNotEnough)
  self:LogVitality(Log.LOG_LEVEL.ELogDebug, string.format("%s cost %f %s", tag and tostring(tag) or "UnKnown", costValue, costSuccess and "true" or "failed"))
  if costSuccess then
    if self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_MAGIC) then
      self._last_magic_cost = true
    else
      self._last_magic_cost = false
    end
  end
  if not costSuccess then
    self.owner:SendEvent(PlayerModuleEvent.ON_VITALITY_OVER)
  end
  return costSuccess
end

function VitalityComponentNew:RecoverVitality(deltaTime, isIdle)
  if GlobalConfig.FreeVitality then
    return
  end
  self._vitality:RecoverVitality(deltaTime, isIdle)
end

function VitalityComponentNew:HasCostVitality()
  return self._cur_cost_vitality or self._last_cost_vitality
end

function VitalityComponentNew:OnPlayerReborn()
  self:FetchSeverVitality()
end

function VitalityComponentNew:OnDisConnect()
  Base.OnDisConnect(self)
end

function VitalityComponentNew:OnReConnect()
  self:FetchSeverVitality()
end

function VitalityComponentNew:UpdateFx()
  if self._vitality and self:GetCurVitality() <= self:GetMaxVitality() / 2 then
    if self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_CLIMB) then
      self:PlayOrStopFx(true, true)
    elseif (self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_LANDED) or self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_CROUCHING)) and not self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_SWIMMING) and not self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_MAGIC) and not self._last_magic_cost then
      self:PlayOrStopFx(true, false)
    else
      self:PlayOrStopFx(false, false)
    end
  else
    self:PlayOrStopFx(false, true)
    self:PlayOrStopFx(false, false)
  end
end

function VitalityComponentNew:PlayOrStopFx(isPlay, isClimb)
  if not UE.UObject.IsValid(self.owner.viewObj) then
    return
  end
  local isClimbTired = isPlay and isClimb
  local isGroundTired = isPlay and not isClimb
  if self._isGroundTired ~= isGroundTired then
    self._isGroundTired = isGroundTired
    self.owner.viewObj.MoveFXComponent:TryPlayOrStopTriedFx(self._isGroundTired)
  end
  if self._isClimbTired ~= isClimbTired then
    self._isClimbTired = isClimbTired
    self.owner.viewObj.MoveFXComponent:TryPlayOrStopClimbFx(self._isClimbTired)
  end
end

function VitalityComponentNew:TiredCheck()
  local curVitality = self:GetCurVitality()
  local maxVitality = self:GetMaxVitality()
  local bShouldTriggerTired = curVitality <= maxVitality * 0.25 and not self._last_magic_cost
  local bShouldStopTired = curVitality >= maxVitality * 0.99
  return bShouldTriggerTired, bShouldStopTired
end

function VitalityComponentNew:GetVitality(id)
  return self._vitality
end

function VitalityComponentNew:GetCurVitality()
  return self._vitality:GetVitality()
end

function VitalityComponentNew:GetMaxVitality()
  return self._vitality:GetMaxVitality()
end

function VitalityComponentNew:GetVitalityPercent()
  local curVitality = self:GetCurVitality()
  local maxVitality = self:GetMaxVitality()
  if curVitality and maxVitality and maxVitality > 0 then
    return curVitality / maxVitality
  end
  return 0
end

function VitalityComponentNew:GetBaseMaxVitality()
  return self._vitality._originBaseVitality
end

function VitalityComponentNew:RecoverVitalityByValue(value)
  return self._vitality:_RecoverVitalityByValue(value)
end

function VitalityComponentNew:GetConfig()
  return self._config
end

function VitalityComponentNew:GetDecayThreshold()
  return self._decayThreshold
end

function VitalityComponentNew:IsVitalityEnough(costValue, stillCostWhenNotEnough)
  local curVitality = self:GetCurVitality()
  local costSuccess = self._vitality:_CostVitality(costValue * self:GetVitalityCostRatio(), stillCostWhenNotEnough, true)
  self._vitality:SyncVitality(curVitality)
  return costSuccess
end

function VitalityComponentNew:LogVitality(logLevel, logStr, ...)
  if GlobalConfig.EnableVitalityLog then
    Log.LogWithLevel(logLevel, 3, string.format(logStr, ...))
  end
end

function VitalityComponentNew:GetServerVitality()
  local cur = self._serverVitality or 0
  local max = self._serverMaxVitality or 0
  return cur, max
end

return VitalityComponentNew
