local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local DialogueActionBase = require("NewRoco.Modules.System.Dialogue.Action.DialogueActionBase")
local Base = DialogueActionBase

local function MakeMoveData(Character, Anim, Location)
  return {
    Character = Character,
    Anim = Anim,
    Location = Location,
    bStartMoveSuccess = false,
    bTurnFinished = false
  }
end

local DialogueNPCMoveAction = Base:Extend("DialogueNPCMoveAction")
FsmUtils.MergeMembers(Base, DialogueNPCMoveAction, {
  {name = "TargetNPC", type = "var"},
  {
    name = "DialogueConf",
    type = "var"
  },
  {name = "NpcIDs", type = "var"}
})

function DialogueNPCMoveAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.MovingNPCs = {}
  self.Handler = -1
end

function DialogueNPCMoveAction:OnEnter()
  self:InjectProperties()
  if DialogueUtils.SkipDialogue then
    self:Finish()
    return
  end
  if not self.DialogueConf then
    self:Finish()
    return
  end
  local bInBattle = self:GetProperty("bInBattle")
  if bInBattle then
    Log.Warning("\230\136\152\230\150\151\228\184\173\228\184\141\230\148\175\230\140\129\231\167\187\229\138\168")
    self:Finish()
    return
  end
  table.clear(self.MovingNPCs)
  local Performs = self.DialogueConf.actor_perform
  if not Performs or 0 == #Performs then
    self:Finish()
    return
  end
  for _, Perform in ipairs(Performs) do
    self:ConsumeActorPerform(Perform)
  end
  if 0 == #self.MovingNPCs then
    self:Finish()
    return
  end
  self:TurnAll()
  if self.Handler > 0 then
    _G.DelayManager:CancelDelayById(self.Handler)
    self.Handler = -1
  end
  self.Handler = _G.DelayManager:DelaySeconds(0.6, self.MoveAll, self)
end

function DialogueNPCMoveAction:ConsumeActorPerform(Perform)
  if not Perform then
    return
  end
  if string.IsNilOrEmpty(Perform.transform) then
    return
  end
  local Actor = self:GetActor(Perform.actor)
  if not Actor then
    return
  end
  local Transform = self.fsm:GetProperty("BornTransform")
  if not Transform then
    Log.Error("\230\137\190\228\184\141\229\136\176\229\135\186\231\148\159\231\130\185Transform\239\188\140\230\151\160\230\179\149\232\174\161\231\174\151\231\167\187\229\138\168\228\191\161\230\129\175...")
    return
  end
  local RelativeTransform = SceneUtils.StringToTransform(Perform.transform)
  local Location = RelativeTransform * Transform
  DialogueUtils.ToggleAI(Actor, false)
  DialogueUtils.StopTurn(Actor)
  if Perform.move_action == Enum.MoveActionType.Moment then
    return
  end
  Location.Translation = SceneUtils.ConvertAbsoluteToRelative(Location.Translation)
  table.insert(self.MovingNPCs, MakeMoveData(Actor, Perform.move_action, Location.Translation))
end

function DialogueNPCMoveAction:TurnAll()
  for _, Data in ipairs(self.MovingNPCs) do
    self:TurnNPC(Data)
  end
end

function DialogueNPCMoveAction:TurnNPC(Data)
  local NPC = Data.Character
  local View = NPC and NPC.viewObj
  if not View or not Data.Location then
    return
  end
  Log.Error("Direct Turn", UE.UObject.GetName(NPC.viewObj))
  local Direction = Data.Location - View:K2_GetActorLocation()
  Direction.Z = 0
  if _G.GlobalConfig.DrawDebugLookAt then
    local Origin = View:K2_GetActorLocation()
    UE.UKismetSystemLibrary.DrawDebugArrow(View, Origin, Origin + View:GetActorForwardVector() * 100, 20, UE.FLinearColor(0, 1, 0, 1), 30, 3)
    UE.UKismetSystemLibrary.DrawDebugArrow(View, Origin, Origin + Direction * 100, 20, UE.FLinearColor(0, 0, 1, 1), 30, 3)
  end
  local Rotator = Direction:ToRotator()
  local TurnComp = NPC.TurnComponent
  if TurnComp then
    TurnComp:StartTurn_S(Rotator.Yaw, 0.5, true)
  else
    NPC:SetActorRotation(Rotator)
  end
end

function DialogueNPCMoveAction:MoveAll()
  for _, Data in ipairs(self.MovingNPCs) do
    Data.bStartMoveSuccess = self:MoveSinglePerson(Data)
  end
  self:CheckFinish()
end

function DialogueNPCMoveAction:OnMoveResult(NPC, bBlocked)
  local Found = -1
  for Index, Data in ipairs(self.MovingNPCs) do
    if NPC == Data.Character then
      Found = Index
      break
    end
  end
  if Found > 0 then
    if NPC.name ~= "SceneLocalPlayer" then
      NPC:StopAnim("Walk", 0.1, LinkTag)
    end
    table.remove(self.MovingNPCs, Found)
  end
  self:CheckFinish()
end

function DialogueNPCMoveAction:CheckFinish()
  local Count = 0
  for _, Data in ipairs(self.MovingNPCs) do
    if Data.bStartMoveSuccess then
      Count = Count + 1
    end
  end
  if 0 == Count then
    self:Finish()
  end
end

function DialogueNPCMoveAction:MoveSinglePerson(Data)
  local NPC = Data.Character
  local Action = Data.Anim
  local Location = Data.Location
  local View = NPC.viewObj
  if not View then
    return false
  end
  local ViewLocation = View:K2_GetActorLocation()
  if ViewLocation:DistSquared(Location) <= 400 then
    Log.Error("\229\183\178\231\187\143\229\136\176\232\190\190\230\140\135\229\174\154\228\189\141\231\189\174!", UE.UObject.GetName(View))
    return false
  end
  local MoveComp = View:GetComponentByClass(UE.UCharacterMovementComponentBase)
  if not MoveComp then
    return false
  end
  local Anim = "Walk"
  local Speed = 127.5
  local Rate = 1.0
  if Action == Enum.MoveActionType.Walk then
    Anim = "Walk"
  elseif Action == Enum.MoveActionType.Run then
    Anim = "Walk"
    Speed = 250
    Rate = 2
  end
  
  local function ArrivedCallback(Object, bHasBlock)
    self:OnMoveResult(NPC, bHasBlock)
  end
  
  if _G.GlobalConfig.DrawDebugLookAt then
    UE.UKismetSystemLibrary.DrawDebugSphere(View, View:K2_GetActorLocation(), 30, 8, UE.FLinearColor(0, 1, 0, 1), 30, 2)
    UE.UKismetSystemLibrary.DrawDebugSphere(View, Location, 30, 8, UE.FLinearColor(0, 0, 1, 1), 30, 2)
    UE.UKismetSystemLibrary.DrawDebugLine(View, View:K2_GetActorLocation(), Location, UE.FLinearColor(1, 1, 0, 1), 30, 4)
  end
  MoveComp:SetComponentTickEnabled(true)
  MoveComp.bRunPhysicsWithNoController = true
  MoveComp:SetMovementMode(UE.EMovementMode.MOVE_Walking)
  MoveComp.OnDirectGoalMoveFinish:Bind(View, ArrivedCallback)
  local Success = MoveComp:RequestDirectGoalMove(Speed, Location, 20)
  if not Success then
    Log.Warning("\231\167\187\229\138\168\231\187\132\228\187\182", UE.UObject.GetName(View), "\229\164\177\232\180\165")
    MoveComp.OnDirectGoalMoveFinish:Unbind(View, ArrivedCallback)
  else
    local AnimComp = View:GetComponentByClass(UE.URocoAnimComponent)
    if AnimComp and NPC.name ~= "SceneLocalPlayer" then
      AnimComp:PlayAnimByName(Anim, Rate, 0, 0.1, 0.1, -1, 1)
    end
  end
  return Success
end

function DialogueNPCMoveAction:OnExit()
  if self.Handler > 0 then
    _G.DelayManager:CancelDelayById(self.Handler)
    self.Handler = -1
  end
  table.clear(self.MovingNPCs)
end

return DialogueNPCMoveAction
