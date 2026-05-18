local EQSResObject = require("NewRoco.Modules.Core.NPC.EQSResObject")
local ResQueue = require("NewRoco.Utils.ResQueue")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local AuraEffectObject = require("NewRoco.Modules.Core.Scene.Component.Aura.AuraEffectObject")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local EnvSystemModuleCmd = require("NewRoco.Modules.System.EnvSystem.EnvSystemModuleCmd")
local LineTraceUtils = require("NewRoco.Modules.Core.Battle.Common.LineTraceUtils")
local Base = AuraEffectObject
local ICEBERG_SIZE = 200
local ICE_NPC_ID = 60281
local AuraEffectIce = Base:Extend("AuraEffectIce")

function AuraEffectIce:Ctor(Owner, Index, Effect)
  Base.Ctor(self, Owner, Index, Effect)
  self.Iceberg = nil
  self.KillerNPC = nil
  self.AudioID = 1264
  self.LoadQueue = nil
end

function AuraEffectIce:CheckNeedView()
  return true
end

function AuraEffectIce:OnViewReady(View)
  Base.OnViewReady(self)
  if self.LoadQueue then
    self.LoadQueue:Release()
  else
    self.LoadQueue = ResQueue(30, ResQueue.RunMode.Concurrent, PriorityEnum.Active_Aura_Ice)
  end
  local Query = self:GetEQS()
  Log.Debug("Show Aura View Rotation", tostring(View:K2_GetActorRotation():ToEuler()), self.Owner.Info.dir / 10)
  local NPC = self.Owner:GetBindNPC()
  local NPCView = NPC and NPC.viewObj
  local QueryView = NPCView or View
  self.LoadQueue:InsertResObject("EQS", EQSResObject.MakeRawQuery(Query, UE.EEnvQueryRunMode.SingleResult, nil, QueryView))
  self.LoadQueue:InsertNPC("NPC", ICE_NPC_ID)
  self.LoadQueue:StartLoad(self, self.CreateIce)
end

function AuraEffectIce:CreateIce(Queue, Success)
  self:AddBound(self.Owner:GetRange(), self.Owner:GetLocation())
  local NPC = Queue:Get("NPC")
  if not Success then
    if NPC then
      NPC:Destroy()
    end
    return
  end
  local EQS = Queue:GetResObject("EQS")
  local First = EQS.AbsoluteLocations[1]
  NPC:SetActorLocation(First)
  local Creator = self:GetBindNPC()
  if Creator and Creator.viewObj then
    if Creator.viewObj.GetHalfHeight then
      local Location = Creator.viewObj:K2_GetActorLocation()
      local NewZ = First.Z + Creator.viewObj:GetHalfHeight()
      Location.Z = NewZ
      Creator.viewObj:K2_SetActorLocation(Location, false, nil, true)
    end
    if Creator.config.genre ~= Enum.ClientNpcType.CNT_PETBOSS and Creator.AIComponent then
      Creator.AIComponent:ForceLockForReason(true, false, AIDefines.LockReason.ICE)
    end
  elseif Creator then
    Creator.serverPos = First
    if Creator.config.genre ~= Enum.ClientNpcType.CNT_PETBOSS and Creator.AIComponent then
      Creator.AIComponent:ForceLockForReason(true, false, AIDefines.LockReason.ICE)
    end
  else
    Log.Error("\229\133\137\231\142\175ViewObject\232\191\152\230\178\161\230\156\137\229\135\186\231\142\176")
  end
  local IceView = NPC.viewObj
  local Passengers, RawArray = IceView:Query()
  for _, Actor in ipairs(Passengers) do
    if Actor.GetHalfHeight then
      local Location = Actor:K2_GetActorLocation()
      local NewZ = First.Z + Actor:GetHalfHeight() + 2
      Location.Z = NewZ
      Actor:K2_SetActorLocation(Location, false, nil, true)
      local CharacterMovement = Actor.CharacterMovement
      if CharacterMovement and CharacterMovement:IsA(UE.UCharacterNavMovementComponent) then
        CharacterMovement:OverrideNextDefaultMovementMode(UE.EMovementMode.MOVE_Falling)
        if CharacterMovement:IsSwimming() then
          CharacterMovement:SetMovementMode(UE.EMovementMode.MOVE_Walking, 0)
        end
      end
    end
  end
  UE.UNRCStatics.RequestEnvInfoUpdate(RawArray)
  local Size = self.Owner:GetRange(ICEBERG_SIZE)
  local Scale = math.max(1, Size * 2.0 / ICEBERG_SIZE)
  IceView:SetActorScale3D(_G.FVectorOne * Scale)
  IceView.Aura = self.Owner
  IceView.StaticMesh:SetCollisionProfileName("BlockAll", true)
  IceView:SetVisible(true)
  IceView:Freeze()
  IceView.MeltDelegate:Add(self, self.OnIceMelt)
  self:StartAudio()
  self.Iceberg = NPC
  self.LoadQueue:Release()
  self:OnCreateIceCheckNPCWater(IceView, First)
end

function AuraEffectIce:OnCreateIceCheckNPCWater(IceView, startPos)
  local pos = startPos
  local lineBegin = pos + UE4.FVector(0, 0, 100)
  local lineEnd = pos - UE4.FVector(0, 0, 1000)
  local ObjectTypes = {
    UE4.UNRCStatics.ConvertToObjectType(UE4.ECollisionChannel.ECC_GameTraceChannel13)
  }
  local hitResults, isHit = UE4.UKismetSystemLibrary.Abs_LineTraceMultiForObjects(UE4Helper.GetCurrentWorld(), lineBegin, lineEnd, ObjectTypes, false, nil, 0, nil, true)
  if isHit then
    for i = hitResults:Length(), 1, -1 do
      local Hit = hitResults:Get(i)
      local hitActor = Hit.Actor
      local name = UE.UKismetSystemLibrary.GetObjectName(hitActor)
      if string.find(name, "BP_NPCWater") then
        Log.Debug("OnCreateIceCheckNPCWater \229\176\132\231\186\191\229\135\187\228\184\173", name)
        hitActor:RegisterIceBerg(IceView)
        IceView.DungeonWater = hitActor
        return
      end
    end
  end
end

function AuraEffectIce:AddBound(Extent, Location)
end

function AuraEffectIce:RemoveBound()
end

function AuraEffectIce:Destroy()
  self:RemoveBound()
  if not self.Iceberg then
    return
  end
  self.Iceberg.bDisappearPerform = true
  self.Iceberg:Disappear(true)
  self.Iceberg = nil
  self:StopAudio()
  if self.LoadQueue then
    self.LoadQueue:Release()
  end
  local Creator = self:GetBindNPC()
  if Creator and Creator.AIComponent then
    Creator.AIComponent:ForceLockForReason(false, false, AIDefines.LockReason.ICE)
    Creator:ScheduleNextTick(0)
  end
  Base.Destroy(self)
end

function AuraEffectIce:GetEQS()
  local Module = _G.NRCModuleManager:GetModule("NPCModule")
  return Module.EQSManager:Get("Iceberg")
end

function AuraEffectIce:OnRemove(Killer, RemoveInfo)
  if not Killer:HasEffect(Enum.AuraEffect.AE_FIRE_LIGHTING) then
    self:Destroy()
    return
  end
  local Caster = Killer:GetBindNPC()
  if not Caster.bPlayingReleaseSkill then
    self:Destroy()
    return
  end
  self.KillerNPC = Caster
  Caster:AddEventListener(self, NPCModuleEvent.ON_HARVEST, self.OnRemoveIce)
end

function AuraEffectIce:OnRemoveIce(Caster)
  Caster:RemoveEventListener(self, NPCModuleEvent.ON_HARVEST, self.OnRemoveIce)
  local KillerView = Caster.viewObj
  local SkillComp = KillerView.RocoSkill
  local Victim = self:GetBindNPC()
  local VictimView = Victim and Victim.viewObj
  local IcebergView = self.Iceberg.viewObj
  local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Tempreture_melt", SkillComp, PriorityEnum.Active_Aura_Ice)
  if not Skill then
    return
  end
  Skill:SetCaster(KillerView)
  if VictimView then
    Skill:SetTargets({VictimView, IcebergView})
    Skill:SetAdditions("Victim", VictimView)
  else
    Skill:SetTargets({IcebergView, IcebergView})
  end
  Skill:SetAdditions("Killer", KillerView)
  Skill:RegisterEventCallback("Head", self, self.SetHeadLookAt)
  Skill:RegisterEventCallback("End", self, self.OnSkillEnd)
  Skill:RegisterEventCallback("PreEnd", self, self.OnSkillEnd)
  Skill:RegisterEventCallback("PreEndAnim", self, self.OnSkillEnd)
  Skill:RegisterEventCallback("IceMelt", self, self.OnMeltIce)
  Skill:SetPassive(true)
  Skill:PlaySkill()
end

function AuraEffectIce:OnMeltIce(Name, Skill)
  self:Destroy()
end

function AuraEffectIce:OnSkillEnd(Name, Skill)
end

function AuraEffectIce:SetHeadLookAt(Name, Skill)
end

function AuraEffectIce:OnIceMelt(Iceberg)
  if Iceberg then
    Iceberg.MeltDelegate:Remove(self, self.OnIceMelt)
  end
end

return AuraEffectIce
