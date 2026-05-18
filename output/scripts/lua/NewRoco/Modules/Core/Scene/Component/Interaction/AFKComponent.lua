local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local MainUIModuleEnum = require("NewRoco.Modules.System.MainUI.MainUIModuleEnum")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local AFKComponent = Base:Extend("AFKComponent")
AFKComponent:SetMemberCount(8)

function AFKComponent:Attach(owner)
  Base.Attach(self, owner)
  self.owner:AddEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnLogicStatusUpdated)
  self.owner:AddEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPlayerStatusUpdated)
  self.owner:AddEventListener(self, PlayerModuleEvent.ON_PLAYER_STATUS_RECOVER_FINISH, self.OnPlayerRecover)
  self.LastAFK = false
  self.WaitAFK = false
  self.HasMoving = false
  self.MinSendTime = 20000
  self.CurrentSendTime = 0
  self:BuildStatusWhiteList()
end

function AFKComponent:DeAttach()
  Base.DeAttach(self)
  self.owner:RemoveEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnLogicStatusUpdated)
  self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPlayerStatusUpdated)
  self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_PLAYER_STATUS_RECOVER_FINISH, self.OnPlayerRecover)
end

function AFKComponent:BuildStatusWhiteList()
  if not self.StatusWhiteList then
    self.StatusWhiteList = {}
  end
  local status_conf = DataConfigManager:GetTable(DataConfigManager.ConfigTableId.SCENE_STATUS_WPST_CONF):GetAllDatas()
  for id, conf in pairs(status_conf) do
    if conf.is_afk_wpst then
      self.StatusWhiteList[id] = true
    end
  end
  if not self.LogicStatusWhiteList then
    self.LogicStatusWhiteList = {}
  end
  local logic_status_conf = DataConfigManager:GetTable(DataConfigManager.ConfigTableId.SCENE_STATUS_SALS_CONF):GetAllDatas()
  for id, conf in pairs(logic_status_conf) do
    if conf.is_afk_sals then
      self.LogicStatusWhiteList[id] = true
    end
  end
  if not self.LogicStatusWhiteList[ProtoEnum.SpaceActorLogicStatus.SALS_PLAYER_AFK] then
    self.LogicStatusWhiteList[ProtoEnum.SpaceActorLogicStatus.SALS_PLAYER_AFK] = true
  end
end

function AFKComponent:Update(deltaTime)
  if not self.owner.isLocal then
    return
  end
  local LastMoving = self.owner.ueController and self.owner.ueController.BP_RocoCameraControlComponent._isControllingView or self.owner.viewObj.bIsMoving
  if LastMoving then
    if self.LastAFK then
      self:SendAFKInterrupt()
    else
      self.HasMoving = LastMoving
    end
  end
  if self.HasMoving then
    self.CurrentSendTime = self.CurrentSendTime + deltaTime
    if self.CurrentSendTime >= self.MinSendTime then
      self:SendAFKInterrupt()
    end
  end
end

function AFKComponent:OnAFKChange(bInAFK)
  if bInAFK == self.LastAFK then
    return
  end
  if not UE.UObject.IsValid(self.owner.viewObj) then
    Log.Debug("AFKComponent:OnAFKChange viewObj is invalid")
    return
  end
  self.LastAFK = bInAFK
  self.owner.viewObj.bAFK = bInAFK
  Log.Debug("AFKComponent:OnAFKChange", bInAFK)
  if self.owner.hudComponent then
    self.owner.hudComponent:SetState(MainUIModuleEnum.PlayerHudState.AFK, bInAFK)
  else
    local HeadWidget = self.owner.viewObj.LocalHeadWidget:GetUserWidgetObject()
    if bInAFK then
      HeadWidget:ShowPanelByType("AFK")
    else
      HeadWidget:CloseType("AFK")
    end
  end
end

function AFKComponent:CheckLogicStatusCanAFK()
  local bInAFK = self.owner:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_PLAYER_AFK)
  bInAFK = self.owner.isLocal and bInAFK and not self.owner:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_INTERACTING) and not self.owner:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_PLAY_CG)
  return bInAFK
end

function AFKComponent:OnLogicStatusUpdated(ChangeInfo)
  local bInAFK = self:CheckLogicStatusCanAFK()
  if not bInAFK then
    self.WaitAFK = false
  end
  if bInAFK ~= self.LastAFK then
    if bInAFK and self.owner.statusComponent and self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_IDLE_RELAX) then
      Log.Debug("AFKComponent:OnLogicStatusUpdated WaitAFK")
      self.WaitAFK = true
      return
    end
    self:OnAFKChange(bInAFK)
  end
  if self.owner.isLocal and self.LastAFK and ChangeInfo and ChangeInfo.op_type == ProtoEnum.LogicStatusOpType.LSOT_ADD and not self.LogicStatusWhiteList[ChangeInfo.status] then
    self:SendAFKInterrupt()
  end
end

function AFKComponent:OnPlayerStatusUpdated(status, statusValue, opCode)
  if self.WaitAFK and not self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_IDLE_RELAX) then
    self.WaitAFK = false
    local bInAFK = self.owner:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_PLAYER_AFK)
    self:OnAFKChange(bInAFK)
  end
  if self.owner.isLocal and self.LastAFK and (opCode == ProtoEnum.WPST_OpCode.WPST_OPCODE_ADD or opCode == ProtoEnum.WPST_OpCode.WPST_OPCODE_SERVER_ADD) and not self.StatusWhiteList[status] then
    self:SendAFKInterrupt()
  end
end

function AFKComponent:OnPlayerRecover()
  self:OnLogicStatusUpdated()
end

function AFKComponent:OnDistanceUpdate(canShow)
  if not self.owner.isLocal then
    local bInAFK = self.owner:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_PLAYER_AFK)
    if self.owner.hudComponent then
      self.owner.hudComponent:SetState(MainUIModuleEnum.PlayerHudState.AFK, bInAFK and canShow)
    end
  end
end

function AFKComponent:SendAFKInterrupt()
  self:OnAFKChange(false)
  Log.Debug("AFKComponent:SendAFKInterrupt")
  local req = _G.ProtoMessage:newZoneClientOperationReq()
  req.operation.operator_id = self.owner.serverData.base.actor_id
  req.operation.operator_type = ProtoEnum.ClientOperationType.COT_TAP_SCREEN
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_CLIENT_OPERATION_REQ, req)
  self.HasMoving = false
  self.CurrentSendTime = 0
end

return AFKComponent
