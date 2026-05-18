require("UnLuaEx")
local NRCHomePOIRuntimeComponent_C = Class("NRCHomePOIRuntimeComponent_C")

function NRCHomePOIRuntimeComponent_C:OnPoiRegister()
  self.Overridden.ReceiveBeginPlay(self)
  if not _G.HomeIndoorSandbox or not _G.HomeIndoorSandbox:InHomeIndoor() then
    self.MasterId = nil
    return
  end
  self.MasterId = _G.HomeIndoorSandbox.Server.MasterId
  _G.HomeIndoorSandbox.HomeAIServ.PoiRefreshDelegate:Add(self, self.OnRefreshPOI)
  local ownerActor = self:GetOwner()
  ownerActor.hasPoi = true
end

function NRCHomePOIRuntimeComponent_C:OnPoiUnregister(EndPlayReason)
  _G.HomeIndoorSandbox.HomeAIServ.PoiRefreshDelegate:Remove(self, self.OnRefreshPOI)
  self:DestroyPOIEntity()
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
end

function NRCHomePOIRuntimeComponent_C:OnPostLoad(PropData)
  if PropData then
    self.belongToRoom = PropData.RoomId
    if PropData.Conf then
      self.Classify = PropData.Conf.tab_type
    end
  end
  self:RespawnPOIEntity()
end

function NRCHomePOIRuntimeComponent_C:OnRefreshPOI(RoomData)
  if RoomData and RoomData.RoomId == self.belongToRoom then
    self:RespawnPOIEntity()
  end
end

function NRCHomePOIRuntimeComponent_C:RespawnPOIEntity()
  if UE.UHomeAIHelper then
    UE.UHomeAIHelper.DestroyPOIEntity(self, self.MasterId)
    UE.UHomeAIHelper.CreatePOIEntity(self, self.MasterId)
  end
end

function NRCHomePOIRuntimeComponent_C:SpawnPOIEntity()
  if UE.UHomeAIHelper then
    Log.DebugFormat("SpawnPOIEntity class=%d master=%d", self.Classify)
    UE.UHomeAIHelper.CreatePOIEntity(self, self.MasterId)
  end
end

function NRCHomePOIRuntimeComponent_C:DestroyPOIEntity()
  if UE.UHomeAIHelper then
    UE.UHomeAIHelper.DestroyPOIEntity(self, self.MasterId)
  end
end

return NRCHomePOIRuntimeComponent_C
