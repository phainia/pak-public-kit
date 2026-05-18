local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BP_AuraBase_C = Class()

function BP_AuraBase_C:Ctor()
end

function BP_AuraBase_C:Initialize(AuraObject)
  self.Aura = AuraObject
end

function BP_AuraBase_C:ReceiveBeginPlay()
  if not self.Aura then
    return
  end
  self.Aura:OnViewReady(self)
  local Size = self.Aura:GetRange(50) - 34
  self.Capsule:SetCapsuleHalfHeight(Size, false)
  self.Capsule:SetCapsuleRadius(Size, false)
end

function BP_AuraBase_C:ReceiveActorBeginOverlap(OtherActor)
  if not self.Aura then
    return
  end
  local Player = SceneUtils.GetPlayer()
  if not Player then
    return
  end
  if not Player.viewObj then
    return
  end
  if Player.viewObj == OtherActor then
    self.Aura:OnBeginOverlapPlayer(Player)
  end
end

function BP_AuraBase_C:ReceiveActorEndOverlap(OtherActor)
  if not self.Aura then
    return
  end
  local Player = SceneUtils.GetPlayer()
  if not Player then
    return
  end
  if not Player.viewObj then
    return
  end
  if Player.viewObj == OtherActor then
    self.Aura:OnEndOverlapPlayer(Player)
  end
end

return BP_AuraBase_C
