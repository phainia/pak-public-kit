local Base = require("NewRoco.Modules.System.Home.Res.NRCHomePlacementActor_C")
local HomeEnum = require("NewRoco.Modules.System.Home.HomeEnum")
local NPCBaseCommon = UE.NPCBaseCommon
require("UnLua")
local BP_HomeInteractBase_C = Base:Extend("BP_HomeInteractBase_C")

function BP_HomeInteractBase_C:Ctor()
  self.HomeSceneNPC = nil
end

function BP_HomeInteractBase_C:OnPostLoad(Data)
  self.Data = Data
  if not self.HomeSceneNPC then
    _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.OnFurnitureViewEnter, Data.Id, self)
  else
    self.HomeSceneNPC:InitInteractGrid()
  end
end

function BP_HomeInteractBase_C:BindSceneVirtualNPC(HomeSceneNPC)
  self.HomeSceneNPC = HomeSceneNPC
  if self.HomeSceneNPC then
    _G.NRCModuleManager:DoCmd(HomeModuleCmd.InteractiveFurnitureEnter, self.HomeSceneNPC.FurnitureID, HomeSceneNPC)
  end
end

function BP_HomeInteractBase_C:ReceiveEndPlay()
  if self.OtherActor then
    self:ReceiveActorEndOverlap(self.OtherActor)
  end
  if self.HomeSceneNPC then
    _G.NRCModuleManager:DoCmd(HomeModuleCmd.InteractiveFurnitureLeave, self.HomeSceneNPC.FurnitureID, self.HomeSceneNPC)
    _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.OnFurnitureViewLeave, self.HomeSceneNPC.FurnitureID)
  end
end

function BP_HomeInteractBase_C:OnNavInterFinish(Success)
end

function BP_HomeInteractBase_C:SetCollisionEnable(CollisionEnable)
  self:SetCollisionEnableInternal(CollisionEnable)
end

function BP_HomeInteractBase_C:SetCollisionEnableInternal(Flag)
  if not UE4.UObject.IsValid(self) then
    Log.Error("BP_HomeInteractBase_C:SetCollisionEnableInternal for invalid view")
    return
  end
  if self.bSimulatePhysics == nil then
    local rootComponent = self:K2_GetRootComponent()
    self.bSimulatePhysics = false
    if rootComponent and UE.UObject.IsValid(rootComponent) and rootComponent:IsAnySimulatingPhysics() then
      self.bSimulatePhysics = true
    end
  end
  if not self.bSimulatePhysics then
    self:SetActorEnableCollision(Flag)
  end
end

function BP_HomeInteractBase_C:UpdateData(ServerData, bIsReconnect)
end

return BP_HomeInteractBase_C
