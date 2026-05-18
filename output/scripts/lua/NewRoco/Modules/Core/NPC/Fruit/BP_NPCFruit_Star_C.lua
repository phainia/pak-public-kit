local ViewDropNPCBase = require("NewRoco.Modules.Core.NPC.ViewDropNPCBase")
local Base = ViewDropNPCBase
local BP_NPCFruit_Star_C = Base:Extend("BP_NPCFruit_Star")

function BP_NPCFruit_Star_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCFruit_Star_C:LuaBeginPlay(DropParticle)
  Base.LuaBeginPlay(self)
end

function BP_NPCFruit_Star_C:Init()
  Base.Init(self)
  local Root = self:K2_GetRootComponent()
  if Root and UE.UObject.IsValid(Root) then
    if Root.SetLinearDamping then
      Root:SetLinearDamping(0.01)
    else
      Log.Error("\228\187\128\228\185\136\233\172\188\239\188\140\230\178\161\230\156\137LinearDamping", UE.UObject.GetFullName(Root))
    end
    if Root.SetAngularDamping then
      Root:SetAngularDamping(1)
    else
      Log.Error("\228\187\128\228\185\136\233\172\188\239\188\140\230\178\161\230\156\137LinearDamping", UE.UObject.GetFullName(Root))
    end
  end
end

function BP_NPCFruit_Star_C:PlayOptTimesOverEffect(Operator)
  self:SetActorEnableCollision(false)
  local actor = self.ChildActor:GetChildActor()
  if actor then
    if actor.Show then
      self.sceneCharacter:SetNotDestroyFlag(true)
      actor:Show(Operator and Operator.viewObj or nil)
      _G.DelayManager:DelaySeconds(4, self.CleanUp, self)
    else
      Log.Error("\231\190\142\230\156\175\229\136\182\228\189\156\231\154\132\232\147\157\229\155\190\230\178\161\230\156\137Show\229\135\189\230\149\176\239\188\140\232\175\183\230\163\128\230\159\165")
    end
  else
    Log.Error("\230\151\160\230\179\149\232\142\183\229\143\150ChildActor", UE.UObject.GetName(self))
  end
end

function BP_NPCFruit_Star_C:CleanUp()
  if self.sceneCharacter then
    self.sceneCharacter:SetNotDestroyFlag(false)
  end
end

function BP_NPCFruit_Star_C:PlayPickUpByPlayer(Player, Caller, Callback)
  self:PlayOptTimesOverEffect(Player)
  _G.DelayManager:DelaySeconds(3, Callback, Caller)
end

local NPCLuaUtils = require("NewRoco.Modules.Core.NPC.NPCLuaUtils")

function BP_NPCFruit_Star_C:SetCustomDepth(Depth)
  local Child = self.ChildActor:GetChildActor()
  if not Child then
    return
  end
  local Comps = Child:K2_GetComponentsByClass(UE.UMeshComponent)
  for _, Comp in tpairs(Comps) do
    NPCLuaUtils.SetCompCustomDepth(Comp, Depth)
  end
end

function BP_NPCFruit_Star_C:ReceiveTick(DeltaSeconds)
  Base.ReceiveTick(self, DeltaSeconds)
end

function BP_NPCFruit_Star_C:ReceiveHit(MyComp, Other, OtherComp, SelfMoved, HitLocation, HitNormal, NormalImpulse, Hit)
  Base.ReceiveHit(self, MyComp, Other, OtherComp, SelfMoved, HitLocation, HitNormal, NormalImpulse, Hit)
end

function BP_NPCFruit_Star_C:OnDropStop()
  local Comp = self:K2_GetRootComponent()
  if Comp then
    Comp:SetSimulatePhysics(false)
  end
end

return BP_NPCFruit_Star_C
