local Class = _G.MakeSimpleClass
local AuraEffectRegistry = require("NewRoco.Modules.Core.Scene.Component.Aura.AuraEffectRegistry")
local AuraObject = Class("AuraObject")
AuraObject:SetMemberCount(8)

function AuraObject:Ctor(Owner, Info)
  self.Owner = Owner
  if not Info then
    return nil
  end
  if 0 == Info.id then
    return nil
  end
  self.Info = Info
  self.ID = Info.id
  self.ConfID = self.Info.aura_conf_id
  self.Config = _G.DataConfigManager:GetNpcAuraConf(self.ConfID)
  self.bRestored = false
  self.bAuraViewCreated = false
  self:InitEffects()
end

function AuraObject:InitEffects()
  self.Effects = {}
  if not self.Config then
    return
  end
  for Index, Effect in ipairs(self.Config.aura_effect) do
    local EffectObject = AuraEffectRegistry.Get(self, Index, Effect)
    if EffectObject then
      table.insert(self.Effects, EffectObject)
    end
  end
end

function AuraObject:CheckNeedView()
  if not self.Effects or 0 == #self.Effects then
    return false
  end
  for _, Effect in ipairs(self.Effects) do
    if Effect:CheckNeedView() then
      return true
    end
  end
  return false
end

function AuraObject:CreateView()
  if self.bAuraViewCreated then
    return
  end
  if self.AuraView then
    return
  end
  if not self:CheckNeedView() then
    self.bAuraViewCreated = true
    self:OnViewReady()
    return
  end
  local Quat = self:GetRotation()
  local Transform = UE4.FTransform(Quat, self:GetLocation())
  local Klass = _G.NRCBigWorldPreloader:Get("AuraObject")
  self.AuraView = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActorEx(Klass, Transform, self)
  if RocoEnv.IS_EDITOR then
    self.AuraView:SetActorLabelNoFlush(string.format("Aura_%d_%d", self.ID, self.ConfID), false)
  end
  self.bAuraViewCreated = true
end

function AuraObject:OnViewReady(View)
  for _, Effect in ipairs(self.Effects) do
    Effect:OnViewReady(View)
  end
end

function AuraObject:OnAdd()
  self:CreateView()
end

function AuraObject:UpdateInfo(Info)
  self.Info = Info
  self:CreateView()
end

function AuraObject:OnRemove(Killer, RemoveInfo)
  if RemoveInfo.reason == ProtoEnum.RemoveAuraReason.DAR_MUTEX then
    for _, Effect in ipairs(self.Effects) do
      Effect:OnRemove(Killer, RemoveInfo)
    end
  else
    self:Destroy()
  end
  if self.AuraView then
    self.AuraView:K2_DestroyActor()
    self.AuraView = nil
  end
  self.bAuraViewCreated = false
end

function AuraObject:OnRemoveOther(Victim, RemoveInfo)
  for _, Effect in ipairs(self.Effects) do
    Effect:OnRemoveOther(Victim, RemoveInfo)
  end
end

function AuraObject:Destroy()
  for _, Effect in ipairs(self.Effects) do
    Effect:Destroy()
  end
  table.clear(self.Effects)
end

function AuraObject:EnableByClient()
  if self.bRestored then
    return
  end
  if self.Info.enabled then
    return
  end
  self.Info.enabled = true
  local req = _G.ProtoMessage:newZoneSceneNtyAuraEnableStReq()
  req.aura_id = self.Info.id
  req.is_enabled = true
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_NTY_AURA_ENABLE_ST_REQ, req, self, self.OnAuraEnableStRsp, false, false)
end

function AuraObject:DisableByClient()
  if self.bRestored then
    return
  end
  self.Info.enabled = false
  local req = _G.ProtoMessage:newZoneSceneNtyAuraEnableStReq()
  req.aura_id = self.Info.id
  req.is_enabled = false
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_NTY_AURA_ENABLE_ST_REQ, req, self, self.OnAuraEnableStRsp, false, false)
end

function AuraObject:OnAuraEnableStRsp(rsp)
end

function AuraObject:OnBeginOverlapPlayer(player)
  for _, Effect in ipairs(self.Effects) do
    Effect:OnBeginOverlapPlayer(player)
  end
end

function AuraObject:OnEndOverlapPlayer(player)
  for _, Effect in ipairs(self.Effects) do
    Effect:OnEndOverlapPlayer(player)
  end
end

function AuraObject:GetLocation()
  local Pos = self.Info.pos
  local FVec = UE4.FVector(Pos.x, Pos.y, Pos.z)
  return FVec
end

function AuraObject:GetRotation()
  return UE4.FQuat.FromAxisAndAngle(_G.UE4Helper.UpVector, self.Info.dir / 10)
end

function AuraObject:GetRotator()
  local Quat = self:GetRotation()
  return Quat:ToRotator()
end

function AuraObject:GetRange(DefaultValue)
  local Type = self.Config.aura_area_type
  if Type == Enum.AuraAreaType.AURA_AREA_TYPE_NONE then
    return 0
  elseif Type == Enum.AuraAreaType.AURA_AREA_TYPE_SPHERE then
    return self.Config.aura_distance[1] or DefaultValue
  elseif Type == Enum.AuraAreaType.AURA_AREA_ELLIPTIC_CYLINDER then
    if not Player then
      return false
    end
    local A = self.Config.aura_distance[1] or DefaultValue
    local B = self.Config.aura_distance[2] or DefaultValue
    return (A + B) * 0.5
  elseif Type == Enum.AuraAreaType.AURA_AREA_TYPE_CYLINDER then
    return self.Config.aura_distance[1] or DefaultValue
  elseif Type == Enum.AuraAreaType.AURA_AREA_TYPE_MODEL then
    return self.Info.radius / 1000 or DefaultValue
  else
    Log.Error("\230\156\170\229\174\158\231\142\176\231\154\132\230\158\154\228\184\190", table.getKeyName(Enum.AuraAreaType, Type))
    return -1
  end
end

function AuraObject:InRange(Player)
  local Type = self.Config.aura_area_type
  if Type == Enum.AuraAreaType.AURA_AREA_TYPE_NONE then
    return true
  elseif Type == Enum.AuraAreaType.AURA_AREA_TYPE_SPHERE then
    if not Player then
      return false
    end
    local Radius = self.Config.aura_distance[1]
    local Location = Player:GetActorLocation()
    if not Radius then
      return false
    end
    if not Location then
      return false
    end
    Radius = Radius * Radius
    local DX, DY, DZ = Location.X - self.Info.pos.x, Location.Y - self.Info.pos.y, Location.Z - self.Info.pos.z
    DX = DX * DX
    DY = DY * DY
    DZ = DZ * DZ
    return Radius >= DX + DY + DZ
  elseif Type == Enum.AuraAreaType.AURA_AREA_ELLIPTIC_CYLINDER then
    if not Player then
      return false
    end
    local A = self.Config.aura_distance[1]
    local B = self.Config.aura_distance[2]
    local Height = self.Config.aura_distance[3]
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
    local DX, DY, DZ = Location.X - self.Info.pos.x, Location.Y - self.Info.pos.y, Location.Z - self.Info.pos.z
    if DZ < 0 or Height < DZ then
      return false
    end
    DX = DX * DX
    DY = DY * DY
    return A >= DX and B >= DY
  elseif Type == Enum.AuraAreaType.AURA_AREA_TYPE_CYLINDER then
    if not Player then
      return false
    end
    local Radius = self.Config.aura_distance[1]
    local Height = self.Config.aura_distance[2]
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
    local DX, DY, DZ = Location.X - self.Info.pos.x, Location.Y - self.Info.pos.y, Location.Z - self.Info.pos.z
    if DZ < 0 or Height < DZ then
      return false
    end
    DX = DX * DX
    DY = DY * DY
    return Radius >= DX + DY
  elseif Type == Enum.AuraAreaType.AURA_AREA_TYPE_MODEL then
    if not Player then
      return false
    end
    local Radius = self.Info.radius / 1000
    local Location = Player:GetActorLocation()
    if not Radius then
      return false
    end
    if not Location then
      return false
    end
    Radius = Radius * Radius
    local DX, DY = Location.X - self.Info.pos.x, Location.Y - self.Info.pos.y
    DX = DX * DX
    DY = DY * DY
    return Radius >= DX + DY
  else
    Log.Error("\230\156\170\229\174\158\231\142\176\231\154\132\230\158\154\228\184\190", table.getKeyName(Enum.AuraAreaType, Type))
    return false
  end
end

function AuraObject:GetEffectParams(EffectType)
  for _, Effect in ipairs(self.Config.aura_effect) do
    if EffectType == Effect.aura_effect_type then
      return Effect.params
    end
  end
  return nil
end

function AuraObject:GetBindNPC()
  return _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, self.Info.create_actor_id)
end

function AuraObject:HasEffect(EffectEnum)
  for _, Effect in ipairs(self.Config.aura_effect) do
    if Effect.aura_effect_type == EffectEnum then
      return true
    end
  end
  return false
end

function AuraObject:GetEffectObject(EffectEnum)
  for _, Effect in ipairs(self.Effects) do
    if Effect.Type == EffectEnum then
      return Effect
    end
  end
  return nil
end

return AuraObject
