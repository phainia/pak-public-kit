local Delegate = require("Utils.Delegate")
local HomeAIService = Class("HomeAIService")

function HomeAIService:Ctor()
  self.CurrentBoundedRooms = {}
  self.CurrentRoomId = 0
  self.InHome = false
  self.InMyHome = false
  self.InFriendsHome = false
  self.MasterUid = 0
  self.PoiRefreshDelegate = Delegate()
end

function HomeAIService:OnExitHome()
  UE.UCellAIHelper.ClearRelationship(_G.UE4Helper.GetCurrentWorld(), 1, 0)
  self.PoiRefreshDelegate:Clear()
  self.InHome = false
  self.InMyHome = false
  self.InFriendsHome = false
  self.MasterUid = 0
end

function HomeAIService:OnEnterHome(bReload)
  self.InHome = true
  self.MasterUid = HomeIndoorSandbox.Server.MasterId
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.InMyHome = localPlayer:GetLogicId() == self.MasterUid
  self.InFriendsHome = _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.GetFriendByUin, self.MasterUid) and true or false
  if not bReload then
    self:RefreshPairRelationship(HomeIndoorSandbox.Server.WorldData.LayEggCouple)
  end
end

function HomeAIService:OnReloadHome()
  self:OnExitHome()
  self:OnEnterHome(true)
end

function HomeAIService:OnLocalPlayerEnterRoom(Room)
  table.insert(self.CurrentBoundedRooms, Room.RoomId)
  self:UpdatePlayerRoom()
end

function HomeAIService:OnLocalPlayerLeaveRoom(Room)
  table.removeValue(self.CurrentBoundedRooms, Room.RoomId)
  self:UpdatePlayerRoom()
end

function HomeAIService:UpdatePlayerRoom()
  if 1 == #self.CurrentBoundedRooms and self.CurrentRoomId ~= self.CurrentBoundedRooms[1] then
    self.CurrentRoomId = self.CurrentBoundedRooms[1]
    HomeIndoorSandbox:LogInfo("Dispatch room entering event (DAWET_HOME_PLAYER_ENTER_ROOM) :", self.CurrentRoomId)
    self:SendWorldEventInRoom(self.CurrentRoomId, Enum.DotsAIWorldEventType.DAWET_HOME_PLAYER_ENTER_ROOM, self.CurrentRoomId)
  end
end

local CachedResults = UE.TArray(UE.AActor)
local QueryTypes = {
  UE.EObjectTypeQuery.Pawn
}

function HomeAIService:SendWorldEventInRoom(RoomId, Event, Param)
  local _HomeIndoorSandbox = _G.HomeIndoorSandbox
  local CurrentRoom = _HomeIndoorSandbox.World.Rooms[RoomId]
  local World = _HomeIndoorSandbox.World.UEWorld
  if not World or not CurrentRoom then
    return
  end
  local QueryPos = CurrentRoom.Bounds.Center
  local QueryExtent = CurrentRoom.Bounds.Extent
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not localPlayer then
    return
  end
  local Success = UE.UKismetSystemLibrary.Abs_BoxOverlapActors(World, QueryPos, QueryExtent, QueryTypes, UE.ANPCBaseCharacter, nil, CachedResults)
  if Success then
    for _, Actor in tpairs(CachedResults) do
      local npc = Actor.sceneCharacter
      if npc and npc.AIComponent and npc.AIComponent:IsActive() then
        npc.AIComponent.AIController:NotifyDotsWorldEvent(Event, Param or RoomId, localPlayer:GetActorLocation())
      end
    end
    CachedResults:Clear()
  end
end

function HomeAIService:UpdatePOIs(RoomData)
  self.PoiRefreshDelegate:Invoke(RoomData)
end

function HomeAIService:RefreshPairRelationship(CoupleInfo)
  Log.PrintScreenMsg("HomeAIService:RefreshPairRelationship UPDATE")
  local NPCModule = NRCModuleManager:GetModule("NPCModule")
  local AIManager = NPCModule and NPCModule.SceneAIManager
  if not AIManager then
    return
  end
  AIManager:ClearRelationship(1, 0)
  if not CoupleInfo or not CoupleInfo.female_couple then
    return
  end
  local count = 1
  for _, v in ipairs(CoupleInfo.female_couple) do
    if v.male_obj_id then
      for _, male_id in ipairs(v.male_obj_id) do
        AIManager:ApplyRelationship(1, count, 1, male_id, v.female_obj_id)
        count = count + 1
      end
    end
  end
end

return HomeAIService
