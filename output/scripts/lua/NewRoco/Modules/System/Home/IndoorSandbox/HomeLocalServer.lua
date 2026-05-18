local Super = require("NewRoco/Modules/System/Home/IndoorSandbox/HomeServer")
local JsonUtils = require("Common.JsonUtils")
local HomeLocalServer = Super:Extend("HomeLocalServer")

function HomeLocalServer:OnNotifyHomeInfo(HomeInfo)
  self.MasterId = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  local Data = JsonUtils.LoadSaved("HomeIndoor_" .. self.MasterId, {})
  self.WorldData:Deserialize(Data)
end

function HomeLocalServer:ReqExitHome(Callback)
  Callback(true)
  return true
end

function HomeLocalServer:ReqUpgradeHome(Callback)
  self.WorldData.RoomExpansionInfo = {}
  if self.WorldData.RoomLevel < 5 and self:IsLocalMaster() then
    self.WorldData.RoomLevel = self.WorldData.RoomLevel + 1
    local Data = JsonUtils.LoadSaved("HomeIndoor_" .. self.MasterId, {})
    Data.room_level = self.WorldData.RoomLevel
    JsonUtils.DumpSaved("HomeIndoor_" .. self.MasterId, Data, 128)
    Callback(true)
  end
  Callback(false)
  return true
end

function HomeLocalServer:ReqEnterEditMode(Callback)
  Callback(true)
  return true
end

function HomeLocalServer:ReqUploadRooms(Callback, RoomIdList)
  if self:IsLocalMaster() then
    local OldRoomDataMap = {}
    for i, RoomId in ipairs(RoomIdList) do
      local RoomData = self.WorldData:GetRoomData(RoomId)
      OldRoomDataMap[RoomId] = RoomData
    end
    local WorldDataSerialized = self.WorldData:Serialize()
    local bUploadSuccess = JsonUtils.DumpSaved("HomeIndoor_" .. self.MasterId, WorldDataSerialized, 128)
    for i, RoomId in ipairs(RoomIdList) do
      local RoomData = OldRoomDataMap[RoomId]
      local RoomDataSerialized = WorldDataSerialized.room_layout.rooms[RoomId]
      if bUploadSuccess then
        self:InternalSaveRoomData(RoomData, RoomDataSerialized)
      else
        self:InternalRecoverRoomData(RoomData)
      end
    end
  end
  Callback(true)
  return true
end

function HomeLocalServer:ReqStartUpgradeHome(Callback)
  if self.WorldData:GetExpansionStatus() ~= HomeIndoorSandbox.Enum.EnmExpandStatus.None then
    return Callback(false)
  end
  local RoomConf = DataConfigManager:GetRoomConf(self.WorldData.RoomLevel + 1)
  if not RoomConf then
    return Callback(false)
  end
  self.WorldData.RoomExpansionInfo.room_level = self.WorldData.RoomLevel + 1
  self.WorldData.RoomExpansionInfo.expansion_start_timestamp = _G.ZoneServer:GetServerTime() / 1000
  Callback(true)
end

function HomeLocalServer:ReqFurnitureCreationList(Callback)
  Callback(true, ProtoMessage:newZoneHomeWarehouseGetBuildListRsp())
end

function HomeLocalServer:InternalSaveRoomData(RoomData, Serialize)
  RoomData:OnServerSaveConfirm(Serialize)
end

function HomeLocalServer:InternalRecoverRoomData(RoomData)
  if HomeIndoorSandbox:InLocalMasterIndoor() then
    RoomData:OnServerRecoverConfirm()
    HomeIndoorSandbox.HomePropsServ:ReloadRoomProps(RoomData.RoomId)
    HomeIndoorSandbox.HomeDecoServ:ReloadRoomDeco(RoomData.RoomId)
  end
end

return HomeLocalServer
