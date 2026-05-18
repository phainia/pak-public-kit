require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewDropNPCBase")
local BP_NPCBloodItem_C = Base:Extend("BP_NPCBloodItem_C")

function BP_NPCBloodItem_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self.hited = false
  self.showed = false
end

function BP_NPCBloodItem_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_NPCBloodItem_C:OnHeartNear()
  Log.Debug("BP_NPCBloodItem_C:OnHeartNear", self:GetDebugInfo())
end

function BP_NPCBloodItem_C:ReceiveActorBeginOverlap(OtherActor)
end

function BP_NPCBloodItem_C:ReceiveActorEndOverlap(OtherActor)
end

function BP_NPCBloodItem_C:ReceiveHit(MyComp, Other, OtherComp, SelfMoved, HitLocation, HitNormal, NormalImpulse, Hit)
  if not self.hited then
    self:K2_GetRootComponent():SetSimulatePhysics(false)
    self.hited = true
  end
  Base.ReceiveHit(self, MyComp, Other, OtherComp, SelfMoved, HitLocation, HitNormal, NormalImpulse, Hit)
end

function BP_NPCBloodItem_C:OnVisible()
  Log.Debug("BP_NPCBloodItem_C:OnVisible", self:GetDebugInfo())
  Base.OnVisible(self)
end

return BP_NPCBloodItem_C
