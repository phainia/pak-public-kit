local HomeDecoService = Class("HomeDecoService")

function HomeDecoService:Ctor()
end

function HomeDecoService:OnExitHome()
end

function HomeDecoService:StopLoadDeco()
end

function HomeDecoService:LoadHardDeco(HardDecoActor, RoomId)
  if not HardDecoActor:IsValid() then
    return
  end
  local TheRoomId = HardDecoActor:GetBelongRoomId()
  if TheRoomId == RoomId and 0 ~= TheRoomId then
    local WorldRoom = HomeIndoorSandbox.World:GetRoomById(RoomId)
    local RoomData = WorldRoom:GetRoomData()
    local MainType = HardDecoActor:GetConfigMainType()
    local DecoData = RoomData:GetDecoDataByMainType(MainType)
    if DecoData then
      HardDecoActor:ApplyInteriorFinish(DecoData.ConfId)
    else
      HomeIndoorSandbox:Ensure(false, "cannot found default interior finish conf by type", MainType)
      HardDecoActor:ApplyOriginalMeshTextures()
    end
  end
end

function HomeDecoService:LoadRoomDecoByMainType(RoomId, MainType)
  local WorldRoom = HomeIndoorSandbox.World:GetRoomById(RoomId)
  
  local function DoLoadHardDeco(Actor)
    return self:LoadHardDeco(Actor, RoomId)
  end
  
  WorldRoom:IterActorByMainType(MainType, DoLoadHardDeco)
end

function HomeDecoService:ReloadRoomDeco(RoomId)
  local WorldRoom = HomeIndoorSandbox.World:GetRoomById(RoomId)
  for Actor, _ in pairs(WorldRoom.AllDecoActors) do
    self:LoadHardDeco(Actor, RoomId)
  end
end

function HomeDecoService:SaveRoomDeco(RoomId)
  local WorldRoom = HomeIndoorSandbox.World:GetRoomById(RoomId)
  for i, Deco in ipairs(WorldRoom:GetRoomData():GetDecoDataList()) do
    Deco:Save()
  end
  local RoomData = WorldRoom:GetRoomData()
  local DecoDataList = RoomData:GetDecoDataList()
  local MainConfigTypes = {}
  for i = #DecoDataList, 1, -1 do
    local DecoData = DecoDataList[i]
    local MainConfigType = DecoData:GetConfigMainType()
    if MainConfigTypes[MainConfigType] then
      assert(MainConfigTypes[MainConfigType] ~= DecoData, "duplicate decorations")
      HomeIndoorSandbox.Module.data:OnEditingCancelApplyInterior(DecoData)
      RoomData:RemoveDecoDataByIndex(i)
    else
      MainConfigTypes[MainConfigType] = DecoData
    end
  end
end

function HomeDecoService:RecoverRoomDeco(RoomId)
  local MainConfigTypes = {}
  local MainConfigTypeSet = {}
  local WorldRoom = HomeIndoorSandbox.World:GetRoomById(RoomId)
  local RoomData = WorldRoom:GetRoomData()
  local DecoDataList = RoomData:GetDecoDataList()
  for i = #DecoDataList, 1, -1 do
    local DecoData = DecoDataList[i]
    if DecoData:IsNeedRecover() then
      RoomData:RemoveDecoDataByIndex(i)
      local MainConfigType = DecoData:GetConfigMainType()
      if not MainConfigTypeSet[MainConfigType] then
        MainConfigTypeSet[MainConfigType] = true
        table.insert(MainConfigTypes, MainConfigType)
      end
    end
  end
  for i, MainConfigType in pairs(MainConfigTypes) do
    self:LoadRoomDecoByMainType(RoomId, MainConfigType)
  end
  for i, MainConfigType in pairs(MainConfigTypes) do
    if MainConfigType ~= Enum.InteriorFinishType.IFT_FLOOR then
      for j = #DecoDataList, 1, -1 do
        local DecoData = DecoDataList[j]
        if DecoData:GetConfigMainType() == MainConfigType then
          HomeIndoorSandbox.HomeLightServ:ApplyRoomLightSettingsByConfig(RoomId, DecoData.ConfId)
          break
        end
      end
      break
    end
  end
end

return HomeDecoService
