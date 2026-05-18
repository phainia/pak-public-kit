local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local PendantComponent = require("NewRoco.Modules.Core.Scene.Component.Pendant.PendantComponent")
local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_NPCOwlBase_C = Base:Extend("BP_NPCOwlBase_C")

function BP_NPCOwlBase_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self.bIsEnabled = false
  self.bCollected = false
end

function BP_NPCOwlBase_C:ReceiveBeginPlay()
  Base.ReceiveBeginPlay(self)
  self.Track:SetCollisionEnabled(UE4.ECollisionEnabled.NoCollision)
end

function BP_NPCOwlBase_C:ReceiveEndPlay()
  Base.ReceiveEndPlay(self)
end

function BP_NPCOwlBase_C:SetSceneCharacter(sceneCharacter)
  if sceneCharacter then
    Base.SetSceneCharacter(self, sceneCharacter)
    if self.sceneCharacter then
      self.sceneCharacter:AddEventListener(self, NPCModuleEvent.PendantGroupStateChanged, self.OnPendantStateChange)
      self.sceneCharacter:AddEventListener(self, NPCModuleEvent.UnlockSleepingOwl, self.OnUnlockOwl)
    end
  else
    if self.sceneCharacter then
      self.sceneCharacter:RemoveEventListener(self, NPCModuleEvent.PendantGroupStateChanged, self.OnPendantStateChange)
      self.sceneCharacter:RemoveEventListener(self, NPCModuleEvent.UnlockSleepingOwl, self.OnUnlockOwl)
    end
    Base.SetSceneCharacter(self, sceneCharacter)
  end
end

function BP_NPCOwlBase_C:OnPendantStateChange(Comp)
  local Enabled = Comp:HasGroupEnabled()
  local AllCollected = Comp:IsAllCollected()
  if Enabled == self.bIsEnabled then
    self:SetCollected(AllCollected, Enabled)
  elseif Enabled and not self.bIsEnabled then
    self.Track:ClearSplinePoints()
    self.Track:AddSplineWorldPoint(self:K2_GetActorLocation())
    local Group = Comp.pendantGroups[1]
    for _, Info in ipairs(Group.info.pendant_item_infos) do
      local Pos = Info.point.pos
      self.Track:AddSplineWorldPoint(SceneUtils.ConvertAbsoluteToRelative(UE.FVector(Pos.x, Pos.y, Pos.z)))
    end
    self.Track:UpdateSpline()
    self:AllAppear()
  elseif AllCollected then
    self:Close()
  else
    self:Reset()
  end
  Log.Debug(UE.UObject.GetName(self), AllCollected, self.bIsEnabled, Enabled)
  self.bIsEnabled = Enabled
  self.bCollected = AllCollected
end

function BP_NPCOwlBase_C:TryUpdateView()
  self:OnPendantStateChange(self.sceneCharacter:EnsureComponent(PendantComponent))
end

function BP_NPCOwlBase_C:OnResourceLoadFinish()
  Base.OnResourceLoadFinish(self)
  local Root = self:K2_GetRootComponent()
  if Root and UE.UObject.IsValid(Root) then
    Root:SetMobility(UE.EComponentMobility.Static)
  end
  if self.StaticMesh and UE.UObject.IsValid(self.StaticMesh) then
    self.StaticMesh:SetMobility(UE.EComponentMobility.Static)
  end
end

function BP_NPCOwlBase_C:OnFirstVisible()
  if not self.resourceLoaded then
    return
  end
  if not self.sceneCharacter then
    return
  end
  self:TryUpdateView()
end

function BP_NPCOwlBase_C:OnUnlockOwl(action)
  Log.Warning("On Unlock!!")
  if self.bDontFly then
    return
  end
  local Conf = _G.DataConfigManager:GetOwlSanctuaryConf(action.refuge_cfg_id)
  local Area = Conf and _G.DataConfigManager:GetAreaConf(Conf.owl_area_id)
  if Area then
    local Pos = Area.pos[1].position_xyz
    local ABSPos = SceneUtils.ConvertAbsoluteToRelative(UE.FVector(Pos[1], Pos[2], Pos[3]))
    self:TurnAndOpen(ABSPos)
  else
    Log.Error("\232\167\163\233\148\129\231\140\171\229\164\180\233\185\176\233\155\149\229\131\143\230\151\182\230\178\161\230\156\137\229\144\136\230\179\149\231\154\132\229\140\186\229\159\159ID")
  end
end

function BP_NPCOwlBase_C:TurnAndOpen(TargetLocation)
  self:RotateComponent(self.Fx1, TargetLocation)
  self:RotateComponent(self.Fx2, TargetLocation)
end

function BP_NPCOwlBase_C:RotateComponent(SceneComp, TargetLocation)
  local Location = SceneComp:K2_GetComponentLocation()
  local Delta = TargetLocation - Location
  Delta.Z = 0
  local Rotation = Delta:ToRotator():Clamp()
  SceneComp:K2_SetWorldRotation(Rotation, false, nil, false)
end

function BP_NPCOwlBase_C:CanEnterThrowInter(OtherComp)
  return OtherComp == self.StaticMesh
end

return BP_NPCOwlBase_C
