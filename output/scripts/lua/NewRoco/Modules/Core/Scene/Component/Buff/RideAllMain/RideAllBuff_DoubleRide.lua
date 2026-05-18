local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.RideAllMain.RideAllBuff_SkillBase")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local RidePetEvent = require("NewRoco.Modules.Core.Scene.Component.RidePet.RidePetEvent")
local RideAllBuff_DoubleRide = Base:Extend("RideAllBuff_DoubleRide")

function RideAllBuff_DoubleRide:OnBuffBegin(Owner, SkillConf)
  Base.OnBuffBegin(self, Owner, SkillConf)
  self.isInDoubleRide = false
  if self.RideComp.RidePet.Mesh:GetAnimInstance().bIsInDoubleRide then
    local Id = ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL
    local customParams = self.owner.statusComponent:GetCustomParams(Id)
    customParams = customParams or ProtoMessage:newPlayerStatusCustomParams()
    local uin_2p = customParams.ride_param.double_ride_2p_id
    customParams.ride_param.double_ride_2p_id = 0
    self.owner.statusComponent:RefreshStatus(Id, 1, ProtoEnum.WPST_OpCode.WPST_OPCODE_REFRESH, customParams)
    self.owner:SendEvent(PlayerModuleEvent.ON_STATUS_REFRESH, Id, 1, ProtoEnum.WPST_OpCode.WPST_OPCODE_REFRESH)
    local player_2p = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByServerID, uin_2p)
    if player_2p and player_2p.viewObj.BP_RideComponent.bIsDoubleRide2p then
      player_2p.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_RIDEALL, ProtoEnum.WPST_OpCode.WPST_OPCODE_SERVER_REMOVE)
    end
    self:StartFail()
  else
    local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
    if not UE4Helper.IsPCMode() then
      _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(MainUIModuleEvent.UI_SHOW_ABILITY_AIM_JOYSTICK, true)
    else
      _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(MainUIModuleEvent.ChangePCCancelChargeBtnVisibility, true)
    end
    self.owner:AddEventListener(self, PlayerModuleEvent.ON_AIM_JOYSTICK_RELEASED, self.OnAimJoystickReleased)
    self.owner:AddEventListener(self, MainUIModuleEvent.PCCancelChargeBtnClicked, self.OnCancel)
    self.TickTime = 0.1
    self.LockedPlayer = nil
    self.LockedScore = 0
    _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(MainUIModuleEvent.TandemRidingStart, self)
  end
end

function RideAllBuff_DoubleRide:OnBuffUpdate(deltaTime)
  if not self.isInDoubleRide and self.TickTime then
    self.TickTime = self.TickTime - deltaTime
    if self.TickTime > 0 or self.waitCasting then
      return
    end
    self.TickTime = 0.3
    self.LockedPlayer = nil
    self.LockedScore = 0
    local PlayerLocation = self.owner:GetUEController().PlayerCameraManager:GetCameraLocation()
    local PlayerForward = UE.UKismetMathLibrary.GetForwardVector(self.owner:GetUEController().PlayerCameraManager:GetCameraRotation())
    local PlayerList = _G.NRCModeManager:DoCmd(PlayerModuleCmd.GET_ALL_PLAYER)
    if PlayerList then
      for _, Player in pairs(PlayerList) do
        if Player and Player.viewObj and Player.viewObj:WasRecentlyRendered(0.2) and Player ~= self.owner then
          local OtherPlayerLocation = Player.viewObj:K2_GetActorLocation()
          local Dir = {
            X = OtherPlayerLocation.X - PlayerLocation.X,
            Y = OtherPlayerLocation.Y - PlayerLocation.Y,
            Z = OtherPlayerLocation.Z - PlayerLocation.Z
          }
          local Distance = math.sqrt(Dir.X * Dir.X + Dir.Y * Dir.Y + Dir.Z * Dir.Z)
          local maxDis = _G.DataConfigManager:GetGlobalConfig("aim_player_max_distance").num or 2000
          if Distance <= maxDis then
            local Dot = (Dir.X * PlayerForward.X + Dir.Y * PlayerForward.Y + Dir.Z * PlayerForward.Z) / Distance
            if Dot > self.LockedScore then
              local ignoreActors = UE4.TArray(UE.AActor)
              ignoreActors:Add(self.owner.viewObj)
              ignoreActors:Add(self.owner.viewObj.BP_RideComponent.RidePet)
              local Hit, Success = UE.UKismetSystemLibrary.LineTraceSingle(self.owner.viewObj, PlayerLocation, OtherPlayerLocation, UE.ETraceTypeQuery.Visibility, false, ignoreActors, 0, nil, true)
              if not Success or Hit.Actor == Player.viewObj or Player.viewObj == Hit.Actor.Rider then
                self.LockedPlayer = Player
                self.LockedScore = Dot
              end
            end
          end
        end
      end
    end
  end
end

function RideAllBuff_DoubleRide:OnMainAbilityReleased()
  if UE4Helper.IsPCMode() then
    self:SendInteract()
    self:StartFail()
  end
end

function RideAllBuff_DoubleRide:OnAimJoystickReleased(Success)
  if Success then
    self:SendInteract()
  else
    self:OnCancel()
  end
  self:StartFail()
end

function RideAllBuff_DoubleRide:SendInteract()
  if self.LockedPlayer then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZonePlayerInteract, self.LockedPlayer.serverData.base.logic_id, ProtoEnum.PlayerInteractType.DoubleRide)
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.ride_invitation_fail)
  end
end

function RideAllBuff_DoubleRide:OnCancel()
  _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(MainUIModuleEvent.ChangePCCancelChargeBtnVisibility, false)
  self:StartFail()
end

function RideAllBuff_DoubleRide:OnBuffFinish(param)
  if not self.isInDoubleRide then
    _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(MainUIModuleEvent.ChangePCCancelChargeBtnVisibility, false)
    self.owner:RemoveEventListener(self, PlayerModuleEvent.ON_AIM_JOYSTICK_RELEASED, self.OnAimJoystickReleased)
    self.owner:RemoveEventListener(self, MainUIModuleEvent.PCCancelChargeBtnClicked, self.OnCancel)
    _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(MainUIModuleEvent.TandemRidingEnd)
  end
  Base.OnBuffFinish(self, param)
end

return RideAllBuff_DoubleRide
