local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local AuraObject = require("NewRoco.Modules.Core.Scene.Component.Aura.AuraObject")
local FieldTagManager = require("NewRoco.Modules.Core.Scene.Common.FieldTagManager")
local NightmareCheckAura = 10007
local Base = ActorComponent
local AuraSyncCheckComponent = Base:Extend("AuraSyncCheckComponent")

function AuraSyncCheckComponent:Attach(owner)
  Base.Attach(self, owner)
  local aura_ids = self.owner.config.aura_id
  self.Configs = {}
  for _, id in pairs(aura_ids) do
    local conf = _G.DataConfigManager:GetNpcAuraConf(id)
    if conf then
      self.Configs[id] = conf
    end
  end
  if self.owner:IsLogicStatus(_G.ProtoEnum.SpaceActorLogicStatus.SALS_NIGHTMARE_ELITE) then
    local conf = _G.DataConfigManager:GetNpcAuraConf(NightmareCheckAura)
    if conf then
      self.Configs[NightmareCheckAura] = conf
    end
  end
  self.Player = _G.NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
end

function AuraSyncCheckComponent:DeAttach()
  self.Configs = {}
  self.Player = nil
  Base.DeAttach(self)
end

function AuraSyncCheckComponent:Destroy()
  Base.Destroy(self)
end

function AuraSyncCheckComponent:OnDistanceOptimize(distance)
  if not (self.owner and self.owner.viewObj) or not self.owner.serverData then
    return
  end
  if self.owner.serverData.npc_base and self.owner.serverData.npc_base.is_server_ai then
    return
  end
  self.pos = self.owner.viewObj:Abs_K2_GetActorLocation()
  local DebugModule = _G.NRCModuleManager:GetModule("DebugModule")
  if DebugModule and DebugModule.EnableDebugDrawSyncAura then
    for _, config in pairs(self.Configs) do
      self:DebugDrawAura(config)
    end
  end
  if distance > 2500000 then
    if self.isLocalPlayerEffected then
      self.isLocalPlayerEffected = false
      self:ReportPosInfo(true)
    end
    return
  end
  local isEffected = self:IsLocalPlayerEffected()
  if distance < 2100000 and isEffected then
    self.owner:ScheduleNextTick(0.4)
  end
  if isEffected then
    self:ReportPosInfo(true)
    self.isLocalPlayerEffected = isEffected
  elseif self.isLocalPlayerEffected ~= isEffected then
    self:ReportPosInfo(true)
    self.isLocalPlayerEffected = isEffected
  end
end

function AuraSyncCheckComponent:DebugDrawAura(aura_config)
  if not aura_config or not aura_config.aura_area_type then
    return
  end
  local debugDrawNotify = ProtoMessage:newSceneGmDebugDrawCall()
  if aura_config.aura_area_type == Enum.AuraAreaType.AURA_AREA_TYPE_SPHERE then
    debugDrawNotify.type = ProtoEnum.DEBUG_DRAW_CALL_TYPE.SPHERE
    debugDrawNotify.sphere_data = ProtoMessage:newDebugDrawSphereData()
    debugDrawNotify.sphere_data.center = {
      x = self.pos.X,
      y = self.pos.Y,
      z = self.pos.Z
    }
    debugDrawNotify.sphere_data.color = {
      R = 255,
      G = 0,
      B = 0,
      A = 255
    }
    debugDrawNotify.sphere_data.radius = aura_config.aura_distance[1]
    debugDrawNotify.sphere_data.segments = 10
    debugDrawNotify.sphere_data.show_time = 2
    debugDrawNotify.sphere_data.thickness = 1
  elseif aura_config.aura_area_type == Enum.AuraAreaType.AURA_AREA_TYPE_CYLINDER then
    debugDrawNotify.type = ProtoEnum.DEBUG_DRAW_CALL_TYPE.CYLINDER
    debugDrawNotify.cylinder_data = ProtoMessage:newDebugDrawCylinderData()
    debugDrawNotify.cylinder_data.center_pos = {
      x = self.pos.X,
      y = self.pos.Y,
      z = self.pos.Z
    }
    debugDrawNotify.cylinder_data.color = {
      R = 255,
      G = 0,
      B = 0,
      A = 255
    }
    debugDrawNotify.cylinder_data.radius = aura_config.aura_distance[1]
    debugDrawNotify.cylinder_data.half_height = aura_config.aura_distance[2] / 2
    debugDrawNotify.cylinder_data.segments = 10
    debugDrawNotify.cylinder_data.show_time = 2
    debugDrawNotify.cylinder_data.thickness = 1
  else
    return
  end
  if _G.AppMain:HasDebug() then
    _G.NRCModeManager:DoCmd(_G.DebugModuleCmd.ClientSceneDebugDrawCall, debugDrawNotify)
  end
end

function AuraSyncCheckComponent:ReportPosInfo(isOnlyNpc)
  if not isOnlyNpc and self.Player.movementComponent then
    self.Player.movementComponent:SendMoveReq(true)
  end
  if self.owner.ReportPosition then
    self.owner:ReportPosition()
  end
end

function AuraSyncCheckComponent:IsLocalPlayerEffected()
  if self.Player and self.Player.viewObj then
    for _, config in pairs(self.Configs) do
      if self:InRange(self.Player, config) then
        return true
      end
    end
  end
  return false
end

function AuraSyncCheckComponent:InRange(Player, Config)
  local Type = Config.aura_area_type
  if Type == Enum.AuraAreaType.AURA_AREA_TYPE_NONE then
    return true
  elseif Type == Enum.AuraAreaType.AURA_AREA_TYPE_SPHERE then
    if not Player then
      return false
    end
    local Radius = Config.aura_distance[1]
    local Location = Player:GetActorLocation()
    if not Radius then
      return false
    end
    if not Location then
      return false
    end
    Radius = Radius * Radius
    local DX, DY, DZ = Location.X - self.pos.X, Location.Y - self.pos.Y, Location.Z - self.pos.Z
    DX = DX * DX
    DY = DY * DY
    DZ = DZ * DZ
    return Radius >= DX + DY + DZ
  elseif Type == Enum.AuraAreaType.AURA_AREA_ELLIPTIC_CYLINDER then
    if not Player then
      return false
    end
    local A = Config.aura_distance[1]
    local B = Config.aura_distance[2]
    local Height = Config.aura_distance[3]
    local Location = Player:GetActorLocation()
    if not A then
      return false
    end
    if not B then
      return false
    end
    if not Height then
      return false
    end
    if not Location then
      return false
    end
    A = A / 2
    B = B / 2
    A = A * A
    B = B * B
    local DX, DY, DZ = Location.X - self.pos.X, Location.Y - self.pos.Y, Location.Z - self.pos.Z
    if math.abs(DZ) > Height / 2 then
      return false
    end
    DX = DX * DX
    DY = DY * DY
    return A >= DX and B >= DY
  elseif Type == Enum.AuraAreaType.AURA_AREA_TYPE_CYLINDER then
    if not Player then
      return false
    end
    local Radius = Config.aura_distance[1]
    local Height = Config.aura_distance[2]
    local Location = Player:GetActorLocation()
    if not Radius then
      return false
    end
    if not Height then
      return false
    end
    if not Location then
      return false
    end
    Radius = Radius * Radius
    local DX, DY, DZ = Location.X - self.pos.X, Location.Y - self.pos.Y, Location.Z - self.pos.Z
    if math.abs(DZ) > Height / 2 then
      return false
    end
    DX = DX * DX
    DY = DY * DY
    return Radius >= DX + DY
  elseif Type == Enum.AuraAreaType.AURA_AREA_TYPE_MODEL then
    if not Player then
      return false
    end
    if not self.owner.serverData or not self.owner.serverData.aura_infos then
      return
    end
    local aura_info
    for _, info in pairs(self.owner.serverData.aura_infos) do
      if info.aura_conf_id == Config.id then
        aura_info = info
      end
    end
    if not aura_info then
      return
    end
    local Radius = aura_info.radius / 1000
    local Location = Player:GetActorLocation()
    if not Radius then
      return false
    end
    if not Location then
      return false
    end
    Radius = Radius * Radius
    local DX, DY = Location.X - self.pos.X, Location.Y - self.pos.Y
    DX = DX * DX
    DY = DY * DY
    return Radius >= DX + DY
  else
    Log.Error("\230\156\170\229\174\158\231\142\176\231\154\132\230\158\154\228\184\190", table.getKeyName(Enum.AuraAreaType, Type))
    return false
  end
end

return AuraSyncCheckComponent
