local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local VitalityRecoverBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerVitalityRecoverBuff")
local RelationTreeEvent = reload("NewRoco.Modules.System.RelationTree.RelationTreeEvent")
local SocialComponent = Base:Extend("SocialComponent")
local VitalityRecoverStage = {
  Search = 1,
  ClientTrigger = 2,
  ServerRepetitionFailed = 3,
  ServerBuffPreAdd = 4,
  ServerAckSucceed = 5,
  ClientCancel = 6,
  ServerBuffPreRemove = 7,
  ServerCancelSucceed = 8
}

function SocialComponent:Ctor()
  Base.Ctor(self)
  self:SetCurVitalityRecoverStage(VitalityRecoverStage.Search)
  self.FriendList = {}
  self.StrangerList = {}
  self.Vitality_recover_distance = _G.DataConfigManager:GetGlobalConfigNumByKeyType("vitality_recover_distance", _G.DataConfigManager.ConfigTableId.GLOBAL_CONFIG, 1)
  self.BuffDelayMaxTime = _G.DataConfigManager:GetGlobalConfigNumByKeyType("vitality_recover_disappear_time", _G.DataConfigManager.ConfigTableId.GLOBAL_CONFIG, 1000) / 1000
  self.BuffDelayTime = 0
  self.IsMater = false
  self.TriggerFriendID = 0
  self.SendReqMaxTime = 2
  self.CurFlickerState = false
  self.Buffs = {}
  self.TickIntervalNums = 1
  self.DeltaTimeCache = 0
  self.LastSearchReqTime = 0
end

function SocialComponent:Attach(owner)
  Base.Attach(self, owner)
  self.BuffComponent = self.owner.buffComponent
  _G.NRCEventCenter:RegisterEvent("SocialComponent", self, SceneEvent.OnNetPlayerSpawn, self.OnNetPlayerSpawn)
  _G.NRCEventCenter:RegisterEvent("SocialComponent", self, SceneEvent.OnNetPlayerDespawn, self.OnNetPlayerDeSpawn)
  _G.NRCEventCenter:RegisterEvent("SocialComponent", self, RelationTreeEvent.RELATION_STATE_LOCK, self.LockRecoverNode)
  _G.NRCEventCenter:RegisterEvent("SocialComponent", self, RelationTreeEvent.RELATION_STATE_UNLOCK, self.UnLockRecoverNode)
  self.owner:AddEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPlayerStatusChanged)
end

function SocialComponent:DeAttach()
  if self.owner then
    self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPlayerStatusChanged)
  end
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnNetPlayerSpawn, self.OnNetPlayerSpawn)
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnNetPlayerDespawn, self.OnNetPlayerDeSpawn)
  _G.NRCEventCenter:UnRegisterEvent(self, RelationTreeEvent.RELATION_STATE_LOCK, self.LockRecoverNode)
  _G.NRCEventCenter:UnRegisterEvent(self, RelationTreeEvent.RELATION_STATE_UNLOCK, self.UnLockRecoverNode)
  Base.DeAttach(self)
end

function SocialComponent:OnPlayerStatusChanged(status, value)
  if self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_DEATH) then
    Log.Debug("[SocialComponent] OnPlayerStatusChanged ")
    if self.CurVitalityRecoverStage == VitalityRecoverStage.ServerAckSucceed and self.IsMater then
      self:ClientCancelFunc()
    end
  end
end

function SocialComponent:OnTriggerPlayerStatusChanged(status, value)
  local triggerPlayer = self.FriendList[self.TriggerFriendID]
  if triggerPlayer and triggerPlayer.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_DEATH) then
    Log.Debug("[SocialComponent] OnTriggerPlayerStatusChanged  uin = " .. self.TriggerFriendID)
    if self.CurVitalityRecoverStage == VitalityRecoverStage.ServerAckSucceed and self.IsMater then
      self:ClientCancelFunc()
    end
  end
end

function SocialComponent:LockRecoverNode(uin, type)
  if type == Enum.RelationTreeType.RLTT_RECOVER or type == Enum.RelationTreeType.RLTT_ADDFRIEND then
    Log.Debug("[SocialComponent] LockRecoverNode  uin = " .. uin)
    local player = self.FriendList[uin]
    if player then
      self.FriendList[uin] = nil
      self.StrangerList[uin] = player
    end
    if self.TriggerFriendID == uin then
      self:ClientCancelFunc()
    end
  end
end

function SocialComponent:UnLockRecoverNode(uin, type)
  if type == Enum.RelationTreeType.RLTT_RECOVER or type == Enum.RelationTreeType.RLTT_ADDFRIEND then
    Log.Debug("[SocialComponent] UnLockRecoverNode  uin = " .. uin)
    local player = self.StrangerList[uin]
    if player then
      self.StrangerList[uin] = nil
      self.FriendList[uin] = player
    end
  end
end

function SocialComponent:Update(deltaTime)
  if self.TickIntervalNums > 0 then
    self.TickIntervalNums = self.TickIntervalNums - 1
    self.DeltaTimeCache = self.DeltaTimeCache + deltaTime
    return
  else
    self.TickIntervalNums = 1
    deltaTime = deltaTime + self.DeltaTimeCache
    self.DeltaTimeCache = 0
  end
  if self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_DEATH) then
    return
  end
  if self.CurVitalityRecoverStage == VitalityRecoverStage.Search then
    if self.LastSearchReqTime > 0 then
      self.LastSearchReqTime = self.LastSearchReqTime - deltaTime
    end
    if self.LastSearchReqTime <= 0 then
      local localPlayerPos = self.owner:GetActorLocation()
      for id, v in pairs(self.FriendList) do
        local otherPlayerPos = v:GetActorLocation()
        local distance = UE.UKismetMathLibrary.Subtract_VectorVector(localPlayerPos, otherPlayerPos):Size()
        if distance < self.Vitality_recover_distance and not v.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_DEATH) then
          self:ClientSearchSucceedFunc(id)
          break
        end
      end
    end
  elseif self.CurVitalityRecoverStage == VitalityRecoverStage.ServerAckSucceed and self.IsMater then
    local triggerPlayer = self.FriendList[self.TriggerFriendID]
    if triggerPlayer then
      local localPlayerPos = self.owner:GetActorLocation()
      local otherPlayerPos = triggerPlayer:GetActorLocation()
      local distance = UE.UKismetMathLibrary.Subtract_VectorVector(localPlayerPos, otherPlayerPos):Size()
      self:DelaySendReq(deltaTime)
      if distance < self.Vitality_recover_distance then
        if 0 ~= self.BuffDelayTime then
          self:LeaveFlicker()
        end
        self.BuffDelayTime = 0
      else
        if 0 == self.BuffDelayTime then
          self:EnterFlicker()
        end
        self.BuffDelayTime = self.BuffDelayTime + deltaTime
        if self.BuffDelayTime >= self.BuffDelayMaxTime then
          self:ClientCancelFunc()
        end
      end
    end
  end
end

function SocialComponent:DelaySendReq(delayTime)
  if self.SendReqTime then
    self.SendReqTime = self.SendReqTime + delayTime
    if self.SendReqTime > self.SendReqMaxTime and self.LastFlickerState ~= self.CurFlickerState then
      local reqMsg = ProtoMessage:newZoneSceneRelationRecoverModifyBuffReq()
      self.SendReqTime = 0
      reqMsg.buff_val = self.CurFlickerState and 1 or 0
      self.LastFlickerState = self.CurFlickerState
      Log.Debug("[SocialComponent] DelaySendReq Flicker Value =  " .. reqMsg.buff_val)
      _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_RELATION_RECOVER_MODIFY_BUFF_REQ, reqMsg, self, self.ServerBuffModifyCallBack, false, true)
    end
  end
end

function SocialComponent:ServerBuffModifyCallBack(rsp)
  Log.Debug("[SocialComponent] ServerBuffModifyCallBack code = " .. rsp.ret_info.ret_code)
end

function SocialComponent:EnterFlicker()
  self.CurFlickerState = true
  self.owner:SendEvent(PlayerModuleEvent.ON_VITALITY_BUFF_RANGE_STATE_UPDATE, true)
end

function SocialComponent:LeaveFlicker()
  self.CurFlickerState = false
  self.owner:SendEvent(PlayerModuleEvent.ON_VITALITY_BUFF_RANGE_STATE_UPDATE, false)
end

function SocialComponent:ClientSearchSucceedFunc(id)
  local player = self.FriendList[id]
  local name = player and player.serverData and player.serverData.base.name or player.name or "Unknown"
  Log.Debug("[SocialComponent] ClientSearchSucceedFunc id = " .. id .. " name = " .. name)
  self:SetCurVitalityRecoverStage(VitalityRecoverStage.ClientTrigger)
  self.TriggerFriendID = id
  local reqMsg = ProtoMessage:newZoneSceneRelationRecoverBeginReq()
  reqMsg.recover_mate_uin = id
  self.recover_mate_uin_record = id
  local succeed = _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_RELATION_RECOVER_BEGIN_REQ, reqMsg, self, self.ServerSearchCallBack, false, true)
  if not succeed then
    self:ServerCancelSucceedFunc()
  else
    self.LastSearchReqTime = 0.5
  end
end

function SocialComponent:ServerSearchCallBack(rsp)
  Log.Debug("[SocialComponent] ServerSearchCallBack code = " .. rsp.ret_info.ret_code)
  local recover_mate_uin_record = self.recover_mate_uin_record
  self.recover_mate_uin_record = nil
  if 0 ~= rsp.ret_info.ret_code then
    if self.CurVitalityRecoverStage ~= VitalityRecoverStage.ClientTrigger then
      Log.Debug("[SocialComponent] ServerSearchCallBack Invalid CurStage: ", self:GetCurVitalityRecoverStageName())
      return
    end
    if rsp.ret_info.ret_code == _G.ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_RELATIONSHIP_UNLOCK then
      local player = self.FriendList[self.TriggerFriendID]
      if player then
        self.FriendList[self.TriggerFriendID] = nil
        self.StrangerList[self.TriggerFriendID] = player
      end
      self:ServerCancelSucceedFunc()
      return
    end
    if self.CurVitalityRecoverStage == VitalityRecoverStage.ServerBuffPreAdd then
      self.TriggerFriendID = 0
      self.IsMater = false
      self:ServerAckSucceedFunc()
    else
      if rsp.ret_info.ret_code == _G.ProtoEnum.MOBA_RET.SceneErr.ERR_SCENE_RELATION_RECOVER_REPEATED then
        if self.CurVitalityRecoverStage == VitalityRecoverStage.ClientTrigger then
          self:SetCurVitalityRecoverStage(VitalityRecoverStage.ServerRepetitionFailed)
        end
        return
      end
      self:ServerCancelSucceedFunc()
    end
  else
    local triggerPlayer = self.FriendList[self.TriggerFriendID]
    if not triggerPlayer then
      self:ClientCancelFunc()
      return
    end
    if triggerPlayer.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_DEATH) or self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_DEATH) then
      self:ClientCancelFunc()
      return
    end
    if recover_mate_uin_record and not self.FriendList[recover_mate_uin_record] then
      self:ClientCancelFunc()
      return
    end
    if triggerPlayer then
      triggerPlayer:AddEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnTriggerPlayerStatusChanged)
    end
    self.IsMater = true
    self:ServerAckSucceedFunc()
  end
end

function SocialComponent:ServerAckSucceedFunc()
  Log.Debug("[SocialComponent] ServerAckSucceedFunc", self:GetCurVitalityRecoverStageName())
  self.LastFlickerState = false
  self.CurFlickerState = false
  self.SendReqTime = self.SendReqMaxTime
  self:SetCurVitalityRecoverStage(VitalityRecoverStage.ServerAckSucceed)
  self.BuffDelayTime = 0
  if not self.BuffComponent:HasBuff("VitalityRecoverBuff") then
    Log.Debug("[SocialComponent] Add VitalityRecoverBuff  VitalityID = " .. self.VitalityID)
    self.BuffComponent:AddBuff("VitalityRecoverBuff", VitalityRecoverBuff, self.owner, self.VitalityID)
  end
end

function SocialComponent:ClientCancelFunc()
  Log.Debug("[SocialComponent] ClientCancelFunc", self:GetCurVitalityRecoverStageName())
  self.BuffDelayTime = 0
  self.SendReqTime = nil
  local reqMsg = ProtoMessage:newZoneSceneRelationRecoverEndReq()
  self:SetCurVitalityRecoverStage(VitalityRecoverStage.ClientCancel)
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_RELATION_RECOVER_END_REQ, reqMsg, self, self.ServerCancelCallBack, false, true)
end

function SocialComponent:ServerCancelCallBack(rsp)
  Log.Debug("[SocialComponent]  ServerCancelCallBack code = " .. rsp.ret_info.ret_code, self:GetCurVitalityRecoverStageName())
  if 0 == rsp.ret_info.ret_code or self.CurVitalityRecoverStage == VitalityRecoverStage.ServerBuffPreRemove then
  else
    if self.CurVitalityRecoverStage == VitalityRecoverStage.Search then
      return
    end
    self:SetCurVitalityRecoverStage(VitalityRecoverStage.ServerAckSucceed)
    goto lbl_28
  end
  ::lbl_28::
end

function SocialComponent:UpdateData(ServerData, isReconnect)
  Base.UpdateData(self, ServerData)
  self:ServerCancelSucceedFunc()
end

function SocialComponent:ServerCancelSucceedFunc()
  Log.Debug("[SocialComponent] ServerCancelSucceedFunc", self:GetCurVitalityRecoverStageName())
  local triggerPlayer = self.FriendList[self.TriggerFriendID]
  if triggerPlayer then
    triggerPlayer:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnTriggerPlayerStatusChanged)
  end
  self.IsMater = false
  self:SetCurVitalityRecoverStage(VitalityRecoverStage.Search)
  self.TriggerFriendID = 0
  if self.BuffComponent:HasBuff("VitalityRecoverBuff") then
    self.BuffComponent:RemoveBuff("VitalityRecoverBuff")
  end
end

function SocialComponent:OnBuffChange(Change)
  Log.Debug("[SocialComponent] OnBuffChange", Change and Change.removed_buff_id, Change and Change.changed_buff_info and Change.changed_buff_info.buff_cfg_id, self:GetCurVitalityRecoverStageName())
  if not Change then
    return
  end
  local RemoveID = Change and Change.removed_buff_id
  if RemoveID and 0 ~= RemoveID then
    Log.Debug("[SocialComponent] OnBuffChange RemoveID = " .. RemoveID)
    Log.Debug("[SocialComponent] -------------------------------------- ID = " .. RemoveID)
    if self.Buffs[RemoveID] then
      local conf_id = self.Buffs[RemoveID]
      self.Buffs[RemoveID] = nil
      local Conf = _G.DataConfigManager:GetWorldBuffConf(conf_id)
      if Conf and Conf.buff_effect_type == Enum.WorldBuffEffect.WBE_RECOVER_STAMINA then
        Log.Debug("[SocialComponent]  OnBuffChange Remove")
        if self.CurVitalityRecoverStage ~= VitalityRecoverStage.ClientCancel then
          self:ServerCancelSucceedFunc()
        else
          self:SetCurVitalityRecoverStage(VitalityRecoverStage.ServerBuffPreRemove)
          self:ServerCancelSucceedFunc()
        end
        return
      end
    end
  end
  local ChangeInfo = Change and Change.changed_buff_info
  if not ChangeInfo and Change and Change.buff_info and #Change.buff_info > 0 then
    ChangeInfo = Change.buff_info[1]
  end
  if ChangeInfo then
    local ID = ChangeInfo.buff_cfg_id
    if ID and 0 ~= ID then
      local Conf = _G.DataConfigManager:GetWorldBuffConf(ID)
      if Conf and Conf.buff_effect_type == Enum.WorldBuffEffect.WBE_RECOVER_STAMINA then
        Log.Debug("[SocialComponent] BuffChange Stage = " .. self:GetCurVitalityRecoverStageName())
        Log.Debug("[SocialComponent] +++++++++++++++++++++++++++++++++++++++++++ ID = " .. ChangeInfo.id)
        self.Buffs[ChangeInfo.id] = ID
        self.VitalityID = Conf.params[1]
        if ChangeInfo.add_buff_caster_id > 0 and ChangeInfo.add_buff_caster_id ~= self.owner.serverData.base.actor_id or self.CurVitalityRecoverStage == VitalityRecoverStage.ServerRepetitionFailed or self.CurVitalityRecoverStage == VitalityRecoverStage.Search then
          Log.Debug("[SocialComponent] OnBuffChange  Search/ServerRepetitionFailed to ServerAckSucceed, casterid: " .. ChangeInfo.add_buff_caster_id or "nil" .. "owner actor_id: " .. self.owner.serverData.base.actor_id or "nil" .. "ChangeInfo.buff_val" .. ChangeInfo.buff_val or "nil")
          if self.CurVitalityRecoverStage == VitalityRecoverStage.ServerAckSucceed and self.IsMater == false then
            if 0 == ChangeInfo.buff_val then
              Log.Debug("[SocialComponent] OnBuffChange  Add buffValue = 0")
              self.owner:SendEvent(PlayerModuleEvent.ON_VITALITY_BUFF_RANGE_STATE_UPDATE, false)
            else
              Log.Debug("[SocialComponent] OnBuffChange  Add buffValue = 1")
              self.owner:SendEvent(PlayerModuleEvent.ON_VITALITY_BUFF_RANGE_STATE_UPDATE, true)
            end
          else
            self.IsMater = false
            self:ServerAckSucceedFunc()
          end
        elseif self.CurVitalityRecoverStage == VitalityRecoverStage.ClientTrigger then
          Log.Debug("[SocialComponent] OnBuffChange  ClientTrigger to ServerBuffPreAdd")
          self.IsMater = false
          self:SetCurVitalityRecoverStage(VitalityRecoverStage.ServerBuffPreAdd)
        end
      end
    end
  end
end

function SocialComponent:GetVitalityRecoverStageName(stage)
  if not self.stageNameTable then
    self.stageNameTable = {}
    for k, v in pairs(VitalityRecoverStage) do
      self.stageNameTable[v] = k
    end
  end
  if not self.stageNameTable[stage] then
    return "Unknown id: " .. stage or "nil"
  end
  return self.stageNameTable[stage]
end

function SocialComponent:GetCurVitalityRecoverStageName()
  return self:GetVitalityRecoverStageName(self.CurVitalityRecoverStage)
end

function SocialComponent:SetCurVitalityRecoverStage(stage)
  Log.Trace("[SocialComponent] SetCurVitalityRecoverStage " .. self:GetCurVitalityRecoverStageName() .. " to " .. self:GetVitalityRecoverStageName(stage))
  self.CurVitalityRecoverStage = stage
end

function SocialComponent:ClientBreak()
  Base.OnConnect(self)
end

function SocialComponent:OnDisConnect()
  Base.OnDisConnect(self)
end

function SocialComponent:OnReConnect()
end

function SocialComponent:OnNetPlayerSpawn(player)
  if player then
    local id = player.serverData.base.logic_id
    local isUnLock = false
    if _G.RelationTreeCmd ~= nil then
      isUnLock = _G.NRCModeManager:DoCmd(_G.RelationTreeCmd.GetPeerRelationTreeNodeState, id, Enum.RelationTreeType.RLTT_RECOVER)
    end
    if isUnLock or nil == isUnLock then
      self.FriendList[id] = player
    else
      self.StrangerList[id] = player
    end
  end
end

function SocialComponent:OnNetPlayerDeSpawn(player)
  if player then
    local id = player.serverData.base.logic_id
    if id == self.TriggerFriendID then
      local triggerPlayer = self.FriendList[self.TriggerFriendID]
      if triggerPlayer then
        triggerPlayer:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnTriggerPlayerStatusChanged)
      end
      self:ClientCancelFunc()
    end
    self.FriendList[id] = nil
    self.StrangerList[id] = nil
    Log.Debug("[SocialComponent]  OnNetPlayerDeSpawn ID = " .. id)
  end
end

function SocialComponent:GetCurVitalityRecoverStageName()
  for k, v in pairs(VitalityRecoverStage) do
    if v == self.CurVitalityRecoverStage then
      return k
    end
  end
  return "Unknown"
end

return SocialComponent
