local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local ABEnum = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEnum")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local LuaMathUtils = require("NewRoco.Utils.LuaMathUtils")
local InviteInteractAbility = Base:Extend("InviteInteractAbility")

function InviteInteractAbility:Start(onFinished, custom_params, interactType)
  Base.Start(self, onFinished)
  local player = self.caster
  local hasInviteStatus = player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_TWO_PLAYER_ANIM_INVITE)
  if hasInviteStatus then
    self.CurPlayer = player
    if not custom_params or not custom_params.player_interact_param then
      Log.Error("InviteInteractAbility:Start No Params")
      return
    end
    local Param = custom_params.player_interact_param
    local InteractId = Param.interact_id
    self.InteractId = InteractId
    self.TargetUin = Param.player_uin2
    if player.isLocal then
      if not self:IsCanRide(interactType) then
        player.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL)
        if not player.statusComponent:HasStatus(Enum.WorldPlayerStatusType.WPST_TWO_PLAYER_ANIM_INVITE) then
          return
        end
      end
      local InviteComponent = player:EnsureComponent(require("NewRoco.Modules.Core.Scene.Component.RolePlay.InviteComponent"))
      InviteComponent:OnInviteStatusChanged(true)
      self.InteractType = interactType
    end
    local Conf = InteractId and _G.DataConfigManager:GetRelationtreeAnimConf(InteractId)
    local AnimPath = Conf and Conf.invite_key
    if player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL) then
      AnimPath = nil
    end
    local bSelf2Self = Param.player_uin1 == Param.player_uin2
    if not string.IsNilOrEmpty(AnimPath) and not bSelf2Self then
      self:PlayAnim(AnimPath)
    else
      self.bTurn = nil
      Log.Debug("InviteInteractAbility No Anim", InteractId)
    end
    _G.UpdateManager:Register(self)
    player:AddEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPlayerStatusChanged)
    self.state = ABEnum.AbilityState.Casting
  else
    self:Recover(self.caster)
  end
end

function InviteInteractAbility:ReActive()
  local hasInviteStatus = self.caster.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_TWO_PLAYER_ANIM_INVITE)
  if not hasInviteStatus then
    self:Recover(self.caster)
    self:Finish(true)
  end
end

function InviteInteractAbility:Interrupt()
  self:Recover(self.caster)
  Base.Interrupt(self)
end

function InviteInteractAbility:Recover(owner, customParams)
  local player = self.caster
  if not player.isLocal and player.statusComponent:HasStatus(Enum.WorldPlayerStatusType.WPST_TWO_PLAYER_ANIM_INVITE, 1) then
    self:Start(nil, customParams)
    return
  end
  self:StopAnim()
  _G.UpdateManager:UnRegister(self)
  player:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPlayerStatusChanged)
  if player.isLocal then
    local InviteComponent = player:EnsureComponent(require("NewRoco.Modules.Core.Scene.Component.RolePlay.InviteComponent"))
    InviteComponent:OnInviteStatusChanged(false)
    if not player.statusComponent:HasStatus(Enum.WorldPlayerStatusType.WPST_TWO_PLAYER_ANIM, 1) then
      InviteComponent:InviteCancel()
    end
  else
  end
  self.CurPlayer = nil
  self.InteractType = nil
  self.TargetUin = nil
  self.bTurn = nil
  self.InteractId = nil
  self.state = ABEnum.AbilityState.Finished
end

function InviteInteractAbility:PlayAnim(AnimPath)
  local Player = self.caster or self.CurPlayer
  if string.find(AnimPath, "/Game") then
    local Characters = {
      [UE4.EBattleStaticActorType.Player_1] = Player and Player.viewObj
    }
    self:CastG6AbilityAsync(Characters, {}, AnimPath)
    self.AnimName = nil
  else
    Player:PlayAnim(AnimPath, 1, 0, 0.2, 0, -1)
    self.AnimName = AnimPath
  end
  if Player.isLocal then
    Player.movementComponent:SetSyncMove(false)
  end
  self.bTurn = true
end

function InviteInteractAbility:StopAnim()
  if self.AnimName then
    self.caster:StopAnim(self.AnimName, 0.2)
    self.AnimName = nil
  else
    self:CancelAsyncG6Ability()
    self:FinishG6Ability()
  end
  if self.bTurn then
    self.bTurn = nil
    local player = self.caster
    local turnComp = player.TurnComponent
    if turnComp and turnComp:IsTurning() then
      turnComp:StopTurn()
    end
    if player.isLocal then
      player.movementComponent:SetSyncMove(true)
    end
  end
end

function InviteInteractAbility:IsCanRide(interactType)
  return interactType == ProtoEnum.InteractInviteType.IIT_INVITE_TOGETHER or interactType == ProtoEnum.InteractInviteType.IIT_REQUEST_TOGETHER
end

function InviteInteractAbility:OnPlayerStatusChanged(status, value, opCode)
  local player = self.CurPlayer
  if not player then
    return
  end
  if status == Enum.WorldPlayerStatusType.WPST_RIDEALL then
    if opCode == Enum.WPST_OpCode.WPST_OPCODE_REMOVE or opCode == Enum.WPST_OpCode.WPST_OPCODE_SERVER_REMOVE then
      local Conf = self.InteractId and _G.DataConfigManager:GetRelationtreeAnimConf(self.InteractId)
      local AnimPath = Conf and Conf.invite_key
      if AnimPath then
        local caster = self.caster
        self.caster = player
        self:PlayAnim(AnimPath)
        self.caster = caster
      end
    elseif opCode == Enum.WPST_OpCode.WPST_OPCODE_ADD or opCode == Enum.WPST_OpCode.WPST_OPCODE_SERVER_ADD then
      if self:IsCanRide(self.InteractType) then
        self:StopAnim()
      elseif player.isLocal then
        player.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_TWO_PLAYER_ANIM_INVITE)
      elseif player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_TWO_PLAYER_ANIM_INVITE) then
        self:StopAnim()
      end
    end
  end
end

function InviteInteractAbility:OnTick(DeltaTime)
  if self.bTurn then
    local TargetPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByUin, self.TargetUin)
    local Player = self.CurPlayer
    if TargetPlayer and Player and TargetPlayer.viewObj and Player.viewObj and Player ~= TargetPlayer then
      local turnComp = Player.TurnComponent
      if turnComp and not turnComp:IsTurning() then
        local Rot = Player.viewObj:K2_GetActorRotation()
        local Yaw = UE4.UKismetMathLibrary.Conv_VectorToRotator(UE4.UKismetMathLibrary.Subtract_VectorVector(TargetPlayer.viewObj:Abs_K2_GetActorLocation(), Player.viewObj:Abs_K2_GetActorLocation())).Yaw
        local a, b, Delta = LuaMathUtils.DiffAngle(Rot.Yaw, Yaw)
        if math.abs(Delta) > 30 then
          turnComp:StartTurn_S(Yaw, 0.5, true, nil, nil, nil, nil, nil, true)
        end
      end
    end
  end
end

return InviteInteractAbility
