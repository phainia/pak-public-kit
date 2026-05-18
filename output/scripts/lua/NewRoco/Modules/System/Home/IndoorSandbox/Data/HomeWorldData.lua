local HomeRoomData = require("NewRoco/Modules/System/Home/IndoorSandbox/Data/HomeRoomData")
local HomeWorldData = Class("HomeWorldData")

function HomeWorldData:Ctor()
  self.RoomLevel = 1
  self.RoomDataMap = {}
  self.HomeFurnitureGuidSet = {}
end

function HomeWorldData:GetRoomData(Id)
  return self.RoomDataMap[Id]
end

function HomeWorldData:GetOrCreateRoomData(RoomId)
  local Room = self.RoomDataMap[RoomId]
  if not Room then
    Room = HomeRoomData(RoomId)
    Room:Deserialize({
      room_id = RoomId,
      furniture_list = {},
      decoration_list = {}
    })
    self.RoomDataMap[RoomId] = Room
    return Room
  end
  return Room
end

function HomeWorldData:Serialize()
  local Table = {
    room_level = self.RoomLevel,
    room_layout = {
      rooms = {}
    }
  }
  for k, r in pairs(self.RoomDataMap) do
    local Out = r:Serialize()
    if Out then
      table.insert(Table.room_layout.rooms, Out)
    end
  end
  return Table
end

function HomeWorldData:BuildFurnitureGuidSet()
  self.HomeFurnitureGuidSet = {}
  for i, room in pairs(self.RoomDataMap) do
    for k, v in pairs(room.PropsDataMap) do
      if self.HomeFurnitureGuidSet[k] then
        HomeIndoorSandbox:Ensure(false, "logical error, duplicate furniture:", k)
      end
      self.HomeFurnitureGuidSet[k] = v
    end
  end
end

function HomeWorldData:IsBanned()
  local BanInfo = self.HomeAccessInfo.ban_info or {}
  if (BanInfo.is_banned or false) and BanInfo.end_time > ZoneServer:GetServerTime() / 1000 then
    return true
  end
end

function HomeWorldData:IsViolation()
  return (self.HomeAccessInfo.violation_info or {}).is_violation or false
end

function HomeWorldData:DeserializeBasic(Table)
  self.RoomLevel = Table.room_level or 1
  self.HomeName = string.format(LuaText.home_name, Table.home_name or "")
  self.HomeZoneName = string.format(LuaText.home_name_enter, Table.home_name or "")
  self.MasterName = Table.home_name or ""
  self.HomeLevel = Table.home_level or 1
  self.HomeExp = Table.home_experience or 0
  self.HomeComfortLevel = Table.home_comfort_level or 0
  self.RawRoomLayoutInfo = Table.room_layout or {}
  self.LayEggCouple = Table.lay_egg_couple or {}
  self.HomeAccessInfo = Table.access_info or {
    ban_info = {is_banned = false},
    violation_info = {is_violation = false}
  }
  self.RoomExpansionInfo = Table.room_expansion_info or {}
  self.HomeVisitHistoryInfo = Table.visit_history or {}
end

function HomeWorldData:Deserialize(Table)
  local OldRoomLevel = self.RoomLevel
  self.RoomDataMap = {}
  self:DeserializeBasic(Table)
  local Rooms = self.RawRoomLayoutInfo.rooms or {}
  for _, RoomData in ipairs(Rooms) do
    local RoomId = RoomData.room_id or 0
    if HomeIndoorSandbox:Ensure(0 ~= RoomId, "invalid room id") then
      local Room = HomeRoomData(RoomId)
      self.RoomDataMap[RoomId] = Room
      Room:Deserialize(RoomData)
    end
  end
  self:BuildFurnitureGuidSet()
  if OldRoomLevel ~= self.RoomLevel then
    HomeIndoorSandbox:DispatchEvent(HomeIndoorSandbox.Event.OnVisitingRoomLevelChanged, self.RoomLevel)
  end
end

function HomeWorldData:RefreshComfortValue()
  local ComfortValue = 0
  for i, Room in pairs(self.RoomDataMap) do
    local Val = Room:CalcComfortValue()
    HomeIndoorSandbox:LogDebug("room comfort value=", i, Val)
    ComfortValue = ComfortValue + Val
  end
  self.HomeComfortLevel = ComfortValue
end

function HomeWorldData:CompareUpdateLayout(RoomLayoutInfo)
  self.RawRoomLayoutInfo = RoomLayoutInfo
  local RoomProtoList = (RoomLayoutInfo or {}).rooms or {}
  local RemoveRooms = {}
  local AddRooms = {}
  local RoomProtoMap = {}
  local ChangeRoomMap = {}
  local ChangeRoomList = {}
  for _, RoomProto in ipairs(RoomProtoList) do
    local RoomId = RoomProto.room_id or 0
    if not self.RoomDataMap[RoomId] then
      table.insert(AddRooms, RoomProto)
    end
    RoomProtoMap[RoomId] = RoomProto
  end
  for RoomId, RoomData in pairs(self.RoomDataMap) do
    local RoomProto = RoomProtoMap[RoomId]
    if not RoomProto then
      table.insert(RemoveRooms, RoomData)
    end
  end
  for _, RemoveRoomData in ipairs(RemoveRooms) do
    local RoomId = RemoveRoomData.RoomId
    RemoveRoomData:Deserialize({})
    self.RoomDataMap[RoomId] = nil
    if not HomeIndoorSandbox:Ensure(not ChangeRoomMap[RoomId], "logical error") then
      ChangeRoomMap[RoomId] = true
      table.insert(ChangeRoomList, RemoveRoomData)
    end
  end
  for _, AddRoomProto in ipairs(AddRooms) do
    local RoomId = AddRoomProto.room_id or 0
    local Room = HomeRoomData(RoomId)
    Room:Deserialize(AddRoomProto)
    self.RoomDataMap[RoomId] = Room
    if not HomeIndoorSandbox:Ensure(not ChangeRoomMap[RoomId], "logical error") then
      ChangeRoomMap[RoomId] = true
      table.insert(ChangeRoomList, Room)
    end
  end
  for _, RoomProto in ipairs(RoomProtoList) do
    local RoomId = RoomProto.room_id or 0
    if not ChangeRoomMap[RoomId] then
      local RoomData = self.RoomDataMap[RoomId]
      if RoomData then
        local bChanged = RoomData:CompareUpdateRoomInfo(RoomProto)
        if bChanged then
          ChangeRoomMap[RoomId] = true
          table.insert(ChangeRoomList, RoomData)
        end
      end
    end
  end
  self:BuildFurnitureGuidSet()
  return ChangeRoomList
end

function HomeWorldData:CompareUpdateHomeInfo(Table)
  self:DeserializeBasic(Table)
  local RoomLayoutInfo = Table.room_layout
  return self:CompareUpdateLayout(RoomLayoutInfo)
end

function HomeWorldData:GetExpansionStatus()
  return HomeIndoorSandbox.Server:GetExpansionStatus(self.RoomExpansionInfo, self.RoomLevel)
end

return HomeWorldData
