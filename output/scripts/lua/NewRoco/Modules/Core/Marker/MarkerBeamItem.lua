local Class = _G.MakeSimpleClass
local ResObject = require("NewRoco.Utils.ResObject")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local BP_NPCBox_PetType_C = require("NewRoco.Modules.Core.NPC.Box.BP_NPCBox_PetType_C")
local MarkerEnum = require("NewRoco.Modules.Core.Marker.MarkerEnum")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BeamAssets = {
  Default = "/Game/ArtRes/Effects/Particle/Res/Scene/BP_TaskTrackBeam.BP_TaskTrackBeam_C",
  Boss = "/Game/NewRoco/Modules/System/Marker/Res/BP_MarkerBoss.BP_MarkerBoss_C",
  Player = "/Game/NewRoco/Modules/System/Marker/Res/BP_CommonBeam.BP_CommonBeam_C"
}
local TaskLimit = _G.DataConfigManager:GetTaskGlobalConfig("light_scale_mark").numList or {}
local ScaleLimit = {
  min = TaskLimit[1] or 100,
  max = TaskLimit[2] or 1000,
  mult = TaskLimit[3] or 10
}
local BossVisibleRange = _G.DataConfigManager:GetMapGlobalConfig("boss_light_show_distance").numList
local BossVisibleMin = BossVisibleRange[1] * BossVisibleRange[1]
local BossVisibleMax = BossVisibleRange[2] * BossVisibleRange[2]
local MarkerBeamItem = Class("MarkerBeamItem")

function MarkerBeamItem:Ctor(Type, ID, Point, NPC, ActorID)
  self.Type = Type
  self.ID = ID
  self.Point = Point
  self.NPC = NPC
  self.ActorID = ActorID
  self.Beam = nil
  self.BeamRef = nil
  self.CachedIndex = -1
  self.bRegistered = false
  self.bShouldRemove = false
  self.bWasInRange = nil
  self.LastZFixTime = -1
  self.LastCachedPos = UE.FVector()
  self.Point.x = self.Point.x or 0
  self.Point.y = self.Point.y or 0
  self.Point.z = self.Point.z or 0
  self:MakePetColor()
  self:UpdateBeam()
end

function MarkerBeamItem:UpdateInfo(Point)
  Point.x = Point.x or 0
  Point.y = Point.y or 0
  Point.z = Point.z or 0
  self.Point = Point
  self.LastZFixTime = -1
  self:UpdateBeam()
end

function MarkerBeamItem:Destroy()
  self:RemoveBeam()
end

function MarkerBeamItem:GetNPC()
  if self.ActorID then
    local NPC = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, self.ActorID)
    if NPC and not self.bRegistered then
      self.bRegistered = true
      NPC:AddEventListener(self, NPCModuleEvent.On_NPC_LEAVE, self.OnNPCLeave)
    end
    return NPC
  end
  return nil
end

function MarkerBeamItem:UpdateBeamPosition()
  if not self.Beam then
    return
  end
  if not UE.UObject.IsValid(self.Beam) then
    return
  end
  self.Beam:Abs_K2_SetActorLocation_WithoutHit(self:GetPosition(), false, true)
end

function MarkerBeamItem:GetPosition()
  if self.ActorID then
    local NPC = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, self.ActorID)
    if NPC then
      if not self.bRegistered then
        self.bRegistered = true
        NPC:AddEventListener(self, NPCModuleEvent.On_NPC_LEAVE, self.OnNPCLeave)
      end
      if NPC.viewObj then
        return NPC.viewObj:Abs_K2_GetActorLocation()
      else
        return NPC.serverPos
      end
    end
  else
    local Now = os.msTime()
    if Now - self.LastZFixTime > 5000 then
      self.LastZFixTime = Now
      local World = _G.UE4Helper.GetCurrentWorld()
      local Start = UE.FVector(self.Point.x, self.Point.y, self.Point.z + 100000)
      local End = UE.FVector(self.Point.x, self.Point.y, self.Point.z - 100000)
      local Hit, Success = UE.UKismetSystemLibrary.Abs_LineTraceSingle(World, Start, End, UE.ETraceTypeQuery.Visibility)
      if Success and Hit then
        self.LastCachedPos:Set(Hit.ImpactPoint.X, Hit.ImpactPoint.Y, Hit.ImpactPoint.Z + 50)
        return self.LastCachedPos
      end
    else
      return self.LastCachedPos
    end
  end
  return SceneUtils.Pos2Vec(self.Point)
end

function MarkerBeamItem:OnNPCLeave()
  self.bRegistered = false
  self.bShouldRemove = true
end

function MarkerBeamItem:MakePetColor()
  if self.Type ~= MarkerEnum.SourceType.Boss then
    return
  end
  if -1 ~= self.CachedIndex then
    return
  end
  if not self.NPC or 0 == self.NPC then
    return
  end
  local Conf = _G.DataConfigManager:GetNpcConf(self.NPC)
  if not Conf then
    return
  end
  local PetBaseConf
  if Conf.traverse_data_type == Enum.Traverse_Data_Type.TDT_PETBASE then
    PetBaseConf = _G.DataConfigManager:GetPetbaseConf(Conf.traverse_data_param[1] or 0)
  end
  if not PetBaseConf then
    return
  end
  self.CachedIndex = BP_NPCBox_PetType_C:ToPetType(PetBaseConf.unit_type[1] or 0)
end

function MarkerBeamItem:SetColor()
  if not self.Beam then
    return
  end
  if -1 == self.CachedIndex then
    return
  end
  self.Beam:SetPetType(self.CachedIndex)
  self.Beam.NS_Scene_Box_TypeLock:SetActive(true, true)
end

function MarkerBeamItem:GetClass()
  if self.Type == MarkerEnum.SourceType.Boss then
    return BeamAssets.Boss
  elseif self.Type == MarkerEnum.SourceType.PlayerCustom then
    return BeamAssets.Player
  else
    return BeamAssets.Default
  end
end

function MarkerBeamItem:UpdateBeam()
  local HasBeam = self.Beam and self.Beam:IsValid()
  if not HasBeam then
    if self.Res then
      self:SpawnBeam()
    else
      self.Res = ResObject.MakeUClass(self:GetClass())
      self.Res:StartLoad(self, self.SpawnBeam)
    end
  end
  self:UpdateBeamPosition()
end

function MarkerBeamItem:SpawnBeam()
  if not self.Res then
    return
  end
  local BeamClass = self.Res:Get()
  if not BeamClass then
    return
  end
  local ScaleParam
  if self.Type == MarkerEnum.SourceType.PlayerCustom then
    ScaleParam = ScaleLimit
  end
  self.Beam = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActor(BeamClass, UE4.FTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil, nil, ScaleParam)
  self.BeamRef = self.Beam and UnLua.Ref(self.Beam)
  self.Res:Release()
  self.Res = nil
  self:SetColor()
end

function MarkerBeamItem:OnTick(bIsInBattle)
  if not self.Beam then
    return
  end
  if not UE.UObject.IsValid(self.Beam) then
    self.bShouldRemove = true
    return
  end
  if self.bShouldRemove then
    self.Beam:SetActorHiddenInGame(true)
    return
  end
  if bIsInBattle then
    self.Beam:SetActorHiddenInGame(true)
  else
    local NPC = self:GetNPC()
    local Position
    if NPC then
      if NPC.viewObj then
        Position = NPC:GetActorLocation()
        self.Beam:Abs_K2_SetActorLocation_WithoutHit(Position, false, true)
      else
        Position = NPC.serverPos
        self.Beam:Abs_K2_SetActorLocation_WithoutHit(Position, false, true)
      end
    else
      Position = self.Beam:Abs_K2_GetActorLocation()
    end
    if self.Type == MarkerEnum.SourceType.Boss then
      local DistanceToPlayer
      local Player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
      if Player then
        local PlayerPos = Player:GetActorLocation()
        if PlayerPos and Position then
          DistanceToPlayer = Position:DistSquared(PlayerPos)
        else
          DistanceToPlayer = -1
        end
      else
        DistanceToPlayer = -1
      end
      if DistanceToPlayer < 0 then
        self.Beam:SetActorHiddenInGame(false)
        return
      end
      local View = NPC and NPC.viewObj
      local Hidden = View and View.bHidden or false
      local VisibleNow = DistanceToPlayer > BossVisibleMin and DistanceToPlayer < BossVisibleMax and not Hidden
      if VisibleNow == self.Beam.bHidden then
        self.Beam:SetActorHiddenInGame(not VisibleNow)
      end
    elseif self.Type == MarkerEnum.SourceType.PlayerCustom then
      self.Beam:SetActorHiddenInGame(false)
      self:UpdateBeamPosition()
    else
      self.Beam:SetActorHiddenInGame(false)
    end
  end
end

function MarkerBeamItem:RemoveBeam()
  if self.Res then
    self.Res:Release()
    self.Res = nil
  end
  if not UE4.UObject.IsValid(self.Beam) then
    return
  end
  self.Beam:K2_DestroyActor()
  self.Beam = nil
  self.BeamRef = nil
end

return MarkerBeamItem
