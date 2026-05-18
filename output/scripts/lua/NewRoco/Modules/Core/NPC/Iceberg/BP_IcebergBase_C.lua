local Delegate = require("Utils.Delegate")
local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_IcebergBase_C = Base:Extend("BP_IcebergBase_C")

function BP_IcebergBase_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self.MeltDelegate = Delegate()
end

function BP_IcebergBase_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

local StandingOnActors = UE.TArray(UE.ANPCBaseCharacter)

function BP_IcebergBase_C:ReceiveEndPlay(EndPlayReason)
  Log.PrintScreenMsg("BP_IcebergBase_C:ReceiveEndPlay")
  local Origin, Extend = self:GetActorBounds(true)
  Origin.Z = Origin.Z + 20
  Extend.Z = Extend.Z + 40
  local success = UE.UKismetSystemLibrary.BoxOverlapActors(self, Origin, Extend, nil, UE.ANPCBaseCharacter, nil, StandingOnActors)
  if success then
    for _, Actor in tpairs(StandingOnActors) do
      local MoveComp = Actor.CharacterMovement
      if MoveComp then
        if MoveComp:IsMovingOnGround() then
          MoveComp:SetMovementMode(UE.EMovementMode.MOVE_Falling)
          Log.PrintScreenMsg("BP_IcebergBase_C:ReceiveEndPlay : setting falling")
        else
          Log.PrintScreenMsg("BP_IcebergBase_C:ReceiveEndPlay : not moving on ground")
        end
      end
    end
  end
end

function BP_IcebergBase_C:Init()
  Base.Init(self)
end

function BP_IcebergBase_C:Recycle()
  self:RemoveMat()
  self:StopTimeline()
  self.MeltDelegate:Clear()
  Base.Recycle(self)
end

function BP_IcebergBase_C:OnVisible()
  Base.OnVisible(self)
end

function BP_IcebergBase_C:OnInVisible()
  Base.OnInVisible(self)
end

function BP_IcebergBase_C:PreChangeTick_OnFirstVisible()
end

function BP_IcebergBase_C:PlayDisappearPerform()
  self:Melt()
end

function BP_IcebergBase_C:OnMelt()
  self.MeltDelegate:Invoke(self)
  self.sceneCharacter:Destroy()
  self:LetStandersFall()
  self.Aura = nil
  self:QueryPassengers()
  if self.DungeonWater then
    self.DungeonWater:UnregisterIceBerg(self)
    self.DungeonWater = nil
  end
end

local PawnType = {
  UE.EObjectTypeQuery.Pawn,
  UE.EObjectTypeQuery.Character
}
local ActorsStandingOn = UE.TArray(UE.AActor)

function BP_IcebergBase_C:LetStandersFall()
  ActorsStandingOn:Clear()
  self.SteppingOnDetector:GetOverlappingActors(ActorsStandingOn, UE.ANPCBaseCharacter)
  for _, Actor in tpairs(ActorsStandingOn) do
    UE.UNRCCharacterUtils.RequestCharacterMove(Actor, FVectorDown, false, false)
  end
  ActorsStandingOn:Clear()
end

function BP_IcebergBase_C:RecycleStandingActors()
  ActorsStandingOn:Clear()
  self.SteppingOnDetector:GetOverlappingActors(ActorsStandingOn, UE.ANPCBaseCharacter)
  for _, Actor in tpairs(ActorsStandingOn) do
    if Actor:IsValid() and Actor.sceneCharacter and Actor.sceneCharacter.ThrowSession then
      Actor.sceneCharacter.ThrowSession:Recycle()
    end
  end
  ActorsStandingOn:Clear()
end

function BP_IcebergBase_C:QueryPassengers()
end

function BP_IcebergBase_C:Query()
  local World = _G.UE4Helper.GetCurrentWorld()
  local ResultArray = UE4.TArray(UE.AActor)
  local Scale3D = self:GetActorScale3D()
  UE.UNRCStatics.SphereOverlapActors(World, self:K2_GetActorLocation(), 200 * Scale3D.X, PawnType, nil, ResultArray)
  return ResultArray:ToTable(), ResultArray
end

return BP_IcebergBase_C
