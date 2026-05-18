local ResObject = require("NewRoco.Utils.ResObject")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local MarkerModuleCmd = require("NewRoco.Modules.Core.Marker.MarkerModuleCmd")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Base = ActorComponent
local LockIndicatorComponent = Base:Extend("LockIndicatorComponent")
local LockPath = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Res/Scene/NS_Puzzle_Line01.NS_Puzzle_Line01'"
LockIndicatorComponent:SetMemberCount(16)

function LockIndicatorComponent:PreCtor()
  Base.PreCtor(self)
  self.isLocked = false
  self.LockerInfos = nil
  self.LockerRes = {}
  self.ResObjects = {}
  self.MyOrigin = UE.FVector(0, 0, 0)
  self.MyExtent = UE.FVector(0, 0, 0)
  self.AbsNPCOrigin = UE.FVector(0, 0, 0)
  self.NPCOrigin = UE.FVector(0, 0, 0)
  self.NPCExtent = UE.FVector(0, 0, 0)
end

function LockIndicatorComponent:Attach(owner)
  Base.Attach(self, owner)
  self:UpdateCombineLockInfo(self.owner.serverData.combine_lock)
  self.isLocked = self.owner:IsLogicStatus(_G.ProtoEnum.SpaceActorLogicStatus.SALS_LOCKED)
  self.owner:AddEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnLogicStatusUpdated)
end

function LockIndicatorComponent:OnLogicStatusUpdated()
  local NewLocked = self.owner:IsLogicStatus(_G.ProtoEnum.SpaceActorLogicStatus.SALS_LOCKED)
  local OldLocked = self.isLocked
  self.isLocked = NewLocked
  local View = self:GetOwnerView()
  if not View then
    return
  end
  if not View.resourceLoaded then
    return
  end
  if OldLocked and not NewLocked then
    View:PlayUnlockEffect(0)
  end
end

function LockIndicatorComponent:UpdateData(ServerData, isReconnect)
  Base.UpdateData(self, ServerData, isReconnect)
  local View = self:GetOwnerView()
  if not View then
    return
  end
  if not View.resourceLoaded then
    return
  end
  self:OnResourceLoaded()
end

function LockIndicatorComponent:UpdateCombineLockInfo(Info)
  if Info then
    self.LockerInfos = Info.cond_npc_infos
  else
    self.LockerInfos = nil
  end
end

function LockIndicatorComponent:UpdateWithAction(Action)
  if not Action then
    return
  end
  self.LockerInfos = Action.cond_npc_infos
  self:OnDistanceOptimize(0, 0, 0, 0)
  local serverData = self.owner.serverData
  local combine_lock = serverData.combine_lock
  if combine_lock and combine_lock.unlocked_num and combine_lock.tot_lock_num then
    local unlock_change_num = Action.unlocked_num - combine_lock.unlocked_num
    combine_lock.tot_lock_num = Action.tot_lock_num
    combine_lock.unlocked_num = Action.unlocked_num
    if 0 ~= unlock_change_num then
      local View = self:GetOwnerView()
      if not View then
        return
      end
      if not View.bActorVisible then
        return
      end
      if unlock_change_num < 0 then
        View:ResetLockNum(self:GetLockTime())
      else
        local finalLockNum = Action.tot_lock_num - Action.unlocked_num
        for i = 1, unlock_change_num do
          View:PlayUnlockEffect(finalLockNum + unlock_change_num - i)
        end
      end
    end
  else
    serverData.combine_lock = Action
  end
end

function LockIndicatorComponent:PreResourceUnload()
  self:ReleaseAll()
  self:SetEnable(false)
end

function LockIndicatorComponent:OnResourceLoaded()
  self:SetEnable(true)
  self:UpdateRays()
  local View = self:GetOwnerView()
  if View then
    View:ResetLockNum(self:GetLockTime())
  end
end

function LockIndicatorComponent:OnDistanceOptimize(distance, viewDotValue, bulkyVisible, distanceRatio)
  if not self.enabled then
    return
  end
  if not self.owner.viewObj then
    return
  end
  if not self.owner.viewObj.resourceLoaded then
    return
  end
  self:UpdateRays()
end

function LockIndicatorComponent:TryGetNPC(ID)
  return _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByRefreshPoint, ID)
end

function LockIndicatorComponent:UpdateRays()
  if self.LockerInfos then
    for _, Info in ipairs(self.LockerInfos) do
      local ID = Info.npc_refresh_pt
      if ID and ID > 0 then
        local NPC = self:TryGetNPC(ID)
        local Ray = self.LockerRes[ID]
        local Res = self.ResObjects[ID]
        if Ray then
          self:UpdateRay(Ray, NPC, Info)
        elseif not Res then
          Log.Error("Create Ray", self.owner:DebugNPCNameAndID(), ID, Info.npc_obj_id)
          self:CreateRay(ID, NPC, Info)
        end
      end
    end
  end
  for ID, Ray in pairs(self.LockerRes) do
    local FoundInfo
    if self.LockerInfos then
      for _, Info in ipairs(self.LockerInfos) do
        if Info.npc_refresh_pt == ID then
          FoundInfo = Info
          break
        end
      end
    end
    if not FoundInfo and Ray then
      Log.Error("Remove Ray", self.owner:DebugNPCNameAndID(), ID)
      Ray:DetachFromParent(false, true)
      Ray:ReleaseToPool()
      self.LockerRes[ID] = false
    end
  end
  for ID, Object in pairs(self.ResObjects) do
    local FoundInfo
    if self.LockerInfos then
      for _, Info in ipairs(self.LockerInfos) do
        if Info.npc_refresh_pt == ID then
          FoundInfo = Info
          break
        end
      end
    end
    if not FoundInfo and Object then
      Object:Release()
      self.ResObjects[ID] = false
    end
  end
end

function LockIndicatorComponent:UpdateNPCPos(NPC, Info)
  local View = NPC and NPC.viewObj
  local ViewReady = View and View.resourceLoaded
  if ViewReady then
    View:GetActorBounds(true, self.NPCOrigin, self.NPCExtent, false)
  elseif Info.npc_pos then
    self.AbsNPCOrigin.X = Info.npc_pos.x
    self.AbsNPCOrigin.Y = Info.npc_pos.y
    self.AbsNPCOrigin.Z = Info.npc_pos.z + 50
    SceneUtils.ConvertAbsoluteToRelativeInPlace(self.AbsNPCOrigin, self.NPCOrigin)
  else
    Log.Error("\229\144\142\229\143\176\228\184\139\229\143\145\231\154\132CombineCondNpcInfo\230\178\161\230\156\137NPC\231\154\132\228\189\141\231\189\174\228\191\161\230\129\175", self.owner:DebugNPCNameAndID(), Info.npc_obj_id)
  end
  return self.NPCOrigin
end

function LockIndicatorComponent:UpdateRay(Ray, NPC, Info)
  self.owner.viewObj:GetActorBounds(true, self.MyOrigin, self.MyExtent, false)
  self:UpdateNPCPos(NPC, Info)
  local Rotation = self:GetDirection(self.MyOrigin, self.NPCOrigin)
  Ray:K2_SetWorldLocationAndRotation(self.MyOrigin, Rotation, false, nil, true)
end

function LockIndicatorComponent:CreateRay(ID, NPC, Info)
  self.owner.viewObj:GetActorBounds(true, self.MyOrigin, self.MyExtent, false)
  self:UpdateNPCPos(NPC, Info)
  local Object = self.ResObjects[ID]
  if Object then
    Object:Release()
  else
    Object = ResObject.MakeUObject(LockPath)
    self.ResObjects[ID] = Object
  end
  Object:StartLoad(self, self.OnLockLoaded)
end

function LockIndicatorComponent:OnLockLoaded(Object, Success)
  if not Success then
    return
  end
  for ID, Res in pairs(self.ResObjects) do
    if Res == Object then
      self:SpawnLock(Res:Get(), ID)
      break
    end
  end
end

function LockIndicatorComponent:SpawnLock(Template, ID)
  local Rotation = self:GetDirection(self.MyOrigin, self.NPCOrigin)
  local Root = self.owner.viewObj:K2_GetRootComponent()
  local LocationType = UE.EAttachLocation.SnapToTarget
  local Pooling = UE.ENCPoolMethod.ManualRelease
  local System = UE.UNiagaraFunctionLibrary.SpawnSystemAttached(Template, Root, "Root", self.MyOrigin, Rotation, LocationType, false, true, Pooling, true)
  self.LockerRes[ID] = System
end

function LockIndicatorComponent:ReleaseAll()
  if self.LockerRes then
    for _, Ray in pairs(self.LockerRes) do
      if Ray then
        Ray:DetachFromParent(false, true)
        Ray:ReleaseToPool()
      end
    end
    table.clear(self.LockerRes)
  end
  if self.ResObjects then
    for _, Res in pairs(self.ResObjects) do
      if Res then
        Res:Release()
      end
    end
    table.clear(self.ResObjects)
  end
end

function LockIndicatorComponent:GetDirection(a, b, ignoreZ)
  if not a or not b then
    return nil
  end
  local aPos = a
  local bPos = b
  local dir = bPos - aPos
  if ignoreZ then
    dir.Z = 0
  end
  return dir:ToRotator():Clamp()
end

function LockIndicatorComponent:GetLockTime()
  local serverData = self.owner.serverData
  local combine_lock = serverData and serverData.combine_lock
  local lockTime
  if nil == combine_lock or nil == combine_lock.tot_lock_num or nil == combine_lock.unlocked_num then
    lockTime = 0
  else
    lockTime = combine_lock.tot_lock_num - combine_lock.unlocked_num
  end
  return lockTime
end

function LockIndicatorComponent:DeAttach()
  self:ReleaseAll()
  self.LockerInfos = nil
  self.owner:RemoveEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnLogicStatusUpdated)
  Base.DeAttach(self)
end

function LockIndicatorComponent:Destroy()
  self:ReleaseAll()
  self.LockerInfos = nil
  self.owner:RemoveEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnLogicStatusUpdated)
  Base.Destroy(self)
end

return LockIndicatorComponent
