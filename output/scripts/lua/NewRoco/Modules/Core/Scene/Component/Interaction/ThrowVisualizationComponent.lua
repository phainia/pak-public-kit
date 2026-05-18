local ThrowSessionStatusEnum = require("NewRoco.Modules.Core.NPC.ThrowSessionStatusEnum")
local ThrowSessionEvent = require("NewRoco.Modules.Core.NPC.ThrowSessionEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Base = ActorComponent
local PhaseCount = 5
local CapsuleExtend = UE4.FVector(50, 0, 90)
local CapsuleOffset = UE4.FVector(0, 0, 0)
local CapsuleColor = UE4.FLinearColor(0, 1, 1, 1)
local CurrentWorld = _G.UE4Helper.GetCurrentWorld()
local Identity = UE4.FRotator(0, 0, 0)
local ThrowVisualizationComponent = Base:Extend("ThrowVisualizationComponent")
ThrowVisualizationComponent.CloseEQ = "/Game/NewRoco/Modules/Core/NPC/EQS/EQ_PetRelease.EQ_PetRelease"
ThrowVisualizationComponent.ActualEQ = ThrowVisualizationComponent.CloseEQ

function ThrowVisualizationComponent:Attach(owner)
  Base.Attach(self, owner)
  Log.Error("EQS\230\181\139\232\175\149\229\188\128\229\144\175")
  self.counter = 0
  self.TraceChannel = UE4.UNRCStatics.ConvertToTraceChannel(UE4.ECollisionChannel.ECC_GameTraceChannel9)
  self.World = _G.UE4Helper.GetCurrentWorld()
  self.HitResult = _G.UE4.FHitResult()
  self.HeightOffset = _G.UE4.FVector(0, 0, 150)
  self.Positions = {}
  self.Destination = _G.UE4.FVector(0, 0, 0)
  self.FakeDir = _G.UE4.FVector(200, 200, 200)
  self.controller = self.owner:GetUEController()
  self.ImpactPoint = _G.UE4.FVector(0, 0, 0)
  if not self.eqsActor then
    self.eqsActor = self.World:Abs_SpawnActor(UE4.UClass.Load("/Game/NewRoco/Modules/Core/NPC/EQS/BP_EQSTestingPawn"), self.owner.viewObj:Abs_GetTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
    self.eqsActorRef = UnLua.Ref(self.eqsActor)
    local EQ = UE4.UObject.Load(ThrowVisualizationComponent.ActualEQ)
    self.eqsActor.QueryTemplate = EQ
  end
  Log.Error(ThrowVisualizationComponent.ActualEQ)
end

function ThrowVisualizationComponent:Destroy()
  self:SetEnable(false)
end

function ThrowVisualizationComponent:OnEnable()
  _G.UpdateManager:Register(self)
  _G.NRCEventCenter:RegisterEvent("ThrowVisualizationComponent", self, NPCModuleEvent.ADD_THROW_SESSION_PET, self.OnPetCreate)
end

function ThrowVisualizationComponent:OnDisable()
  _G.UpdateManager:UnRegister(self)
  _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.ADD_THROW_SESSION_PET, self.OnPetCreate)
end

function ThrowVisualizationComponent:OnPetCreate(Session)
  Session:AddEventListener(self, ThrowSessionEvent.OnStatusChanged, self.OnSessionStatusChange)
end

function ThrowVisualizationComponent:OnSessionStatusChange(Session, Status)
  Log.Error(Session.petData.gid, "Throw Session Status Change", table.getKeyName(ThrowSessionStatusEnum, Status))
end

function ThrowVisualizationComponent:OnTick(DeltaTime)
  self.counter = self.counter + 1
  if 0 ~= self.counter % PhaseCount then
    return
  end
  UE4.UGameplayStatics.Abs_Blueprint_PredictProjectilePath_ByTraceChannel(self.World, self.HitResult, self.Positions, self.Destination, self.owner:GetActorLocation() + self.HeightOffset, self.owner:GetForwardVector() * 2000, true, 15, self.TraceChannel, true, nil, UE4.EDrawDebugTrace.ForDuration, DeltaTime * PhaseCount, 10, 1280, 0)
  if not self.HitResult.bBlockingHit then
    return
  end
  self.ImpactPoint.X = self.HitResult.ImpactPoint.X
  self.ImpactPoint.Y = self.HitResult.ImpactPoint.Y
  self.ImpactPoint.Z = self.HitResult.ImpactPoint.Z
  self.eqsActor:Abs_K2_SetActorLocation_WithoutHit(self.ImpactPoint)
  self.eqsActor:RunEQSQuery()
end

function ThrowVisualizationComponent:DrawCapsule(Center, Extend, Offset)
  UE4.UKismetSystemLibrary.Abs_DrawDebugCapsule(CurrentWorld, Center + Offset, Extend.Z, Extend.X, Identity, CapsuleColor, PhaseCount * 0.033, 3)
end

return ThrowVisualizationComponent
