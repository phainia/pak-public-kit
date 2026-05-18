local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_FruitTree_C = Base:Extend("BP_FruitTree_C")

function BP_FruitTree_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  if self.BurstNiagara then
    self.BurstNiagara:SetHiddenInGame(true, false)
  end
  self:UpdateState(self.sceneCharacter.luaObj.bGrown)
end

function BP_FruitTree_C:UpdateState(bGrown)
  self.NRCStaticMesh:SetHiddenInGame(bGrown, false)
  self.NRCStaticMesh:SetCollisionEnabled(bGrown and UE.ECollisionEnabled.NoCollision or UE.ECollisionEnabled.QueryAndPhysics)
  self.NRCStaticMesh1:SetHiddenInGame(not bGrown, false)
  self.NRCStaticMesh1:SetCollisionEnabled(bGrown and UE.ECollisionEnabled.QueryAndPhysics or UE.ECollisionEnabled.NoCollision)
  if self.FruitNiagara then
    self.FruitNiagara:SetHiddenInGame(not bGrown, false)
  end
  self.NRCStaticMeshVat:SetHiddenInGame(true, false)
  self.NRCStaticMeshVat:SetCollisionEnabled(UE.ECollisionEnabled.NoCollision)
  self.LoopNiagara:SetHiddenInGame(bGrown, false)
end

function BP_FruitTree_C:HideFruit()
  if self.FruitNiagara then
    self.FruitNiagara:SetHiddenInGame(true, false)
  end
end

function BP_FruitTree_C:SetVatMesh(bUsed)
  if self.sceneCharacter.luaObj.bGrown then
    return
  end
  self.NRCStaticMesh:SetHiddenInGame(bUsed, false)
  self.NRCStaticMesh:SetCollisionEnabled(bUsed and UE.ECollisionEnabled.NoCollision or UE.ECollisionEnabled.QueryAndPhysics)
  self.NRCStaticMesh1:SetHiddenInGame(true, false)
  self.NRCStaticMesh1:SetCollisionEnabled(UE.ECollisionEnabled.NoCollision)
  if self.FruitNiagara then
    self.FruitNiagara:SetHiddenInGame(true, false)
  end
  self.NRCStaticMeshVat:SetHiddenInGame(not bUsed, false)
  self.NRCStaticMeshVat:SetCollisionEnabled(bUsed and UE.ECollisionEnabled.QueryAndPhysics or UE.ECollisionEnabled.NoCollision)
  self.LoopNiagara:SetHiddenInGame(true, false)
  self.BurstNiagara:SetHiddenInGame(true, false)
end

function BP_FruitTree_C:HiddenBurstNiagara(bHidden)
  if self.BurstNiagara then
    self.BurstNiagara:SetHiddenInGame(bHidden, false)
  end
end

return BP_FruitTree_C
