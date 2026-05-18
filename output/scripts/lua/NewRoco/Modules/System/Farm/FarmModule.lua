local FarmModuleEnum = require("NewRoco.Modules.System.Farm.FarmModuleEnum")
local FarmConst = require("NewRoco.Modules.System.Farm.FarmConst")
local FarmModuleEvent = require("NewRoco.Modules.System.Farm.FarmModuleEvent")
local JsonUtils = require("Common.JsonUtils")
local StaticCircleArea = require("NewRoco.Modules.Core.Task.StaticCircleArea")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local PlayerDataEvent = require("Data.Global.PlayerDataEvent")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")
local PetHUDComponent = require("NewRoco.Modules.Core.Scene.Component.HUD.PetHUDComponent")
local LAND_MAX_NUM = 15
local LAND_NPC_ID = 700670
local FARM_RES_ID = 30002
local HOME_INDOOR_RES_ID = 30001
local HOME_MAP_ID = 301
local FarmModule = NRCModuleBase:Extend("FarmModule")

function FarmModule:OnConstruct()
  self.data = self:SetData("FarmModuleData", "NewRoco.Modules.System.Farm.FarmModuleData")
  self.landNPCs = nil
  self:AddEventListener()
end

function FarmModule:OnDestruct()
  self:RemoveEventListener()
  self.landNPCs = nil
end

function FarmModule:OnActive()
  self.FarmDetector = StaticCircleArea.MakePoint2D("FrameRange", 301, self.data.originLocation.X, self.data.originLocation.Y, FarmUtils.GetFarmVisibleDist(), 200, self, self.InitLands, self.ClearLands)
  self.FarmDetector:StartDetect()
end

function FarmModule:OnDeactive()
  self.FarmDetector:StopDetect()
end

function FarmModule:AddEventListener()
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, PlayerDataEvent.STORY_FLAG_ADDED, self.OnStoryFlagAdded)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, PlayerDataEvent.STORY_FLAG_REMOVED, self.OnStoryFlagRemoved)
  _G.NRCEventCenter:RegisterEvent("FarmModule", self, SceneEvent.OnEnterSceneFinishNtyAckEnd, self.OnEnterSceneFinishNtyAckEnd)
  _G.NRCEventCenter:RegisterEvent("FarmModule", self, SceneEvent.LoadMapFinish, self.OnMapLoaded)
  _G.NRCEventCenter:RegisterEvent("FarmModule", self, FarmModuleEvent.OnFarmSingleLandInfoChanged, self.OnFarmSingleLandInfoChanged)
end

function FarmModule:RemoveEventListener()
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, PlayerDataEvent.STORY_FLAG_ADDED, self.OnStoryFlagAdded)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, PlayerDataEvent.STORY_FLAG_REMOVED, self.OnStoryFlagRemoved)
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnEnterSceneFinishNtyAckEnd, self.OnEnterSceneFinishNtyAckEnd)
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.LoadMapFinish, self.OnMapLoaded)
  _G.NRCEventCenter:UnRegisterEvent(self, FarmModuleEvent.OnFarmSingleLandInfoChanged, self.OnFarmSingleLandInfoChanged)
end

function FarmModule:OnStoryFlagAdded(changeVal, bIsHomeOwner)
  if changeVal == _G.Enum.PlayerStoryFlagEnum.PSF_FUNC_UNLOCK_PLANT_LAND then
    local UseSelf = _G.DataModelMgr.PlayerDataModel:IsUseSelfStoryFlag(changeVal)
    if bIsHomeOwner == UseSelf then
    end
  end
end

function FarmModule:OnStoryFlagRemoved(changeVal, bIsHomeOwner)
  if changeVal == _G.Enum.PlayerStoryFlagEnum.PSF_FUNC_UNLOCK_PLANT_LAND then
    local UseSelf = _G.DataModelMgr.PlayerDataModel:IsUseSelfStoryFlag(changeVal)
    if bIsHomeOwner == UseSelf then
    end
  end
end

function FarmModule:OnEnterSceneFinishNtyAckEnd(notify, isReconnecting, isEnteringCell, preMapId, mapID)
  if self.FarmDetector:InArea() then
    self:InitLands()
  end
  local curSceneResId = _G.NRCModuleManager:DoCmd(SceneModuleCmd.GetCurrentMapResId)
  if mapID == HOME_MAP_ID and curSceneResId == FARM_RES_ID then
    self.data.isInFarm = true
    _G.NRCEventCenter:DispatchEvent(FarmModuleEvent.OnEnterFarmMap)
    self:RefreshFunctionBan(true)
    self:RefreshCurrentStandLandInfo()
    return
  end
end

function FarmModule:OnMapLoaded()
  if self.data.isInFarm then
    local curTeleportNotify = _G.NRCModuleManager:DoCmd(SceneModuleCmd.GetCurrentZoneSceneTeleportNotify)
    local bLeavingFarm = curTeleportNotify and (curTeleportNotify.from_scene_res_cfg_id == FARM_RES_ID or curTeleportNotify.to_scene_res_cfg_id ~= FARM_RES_ID)
    if bLeavingFarm then
      self.data.isInFarm = false
      _G.NRCEventCenter:DispatchEvent(FarmModuleEvent.OnExitFarmMap)
      self:RefreshFunctionBan(false)
      self:RefreshCurrentStandLandInfo()
      return
    end
  end
end

function FarmModule:InitLands()
  Log.Debug("Init lands!")
  for id = 1, LAND_MAX_NUM do
    if not (self.landNPCs and self.landNPCs[id]) or self.landNPCs[id] and self.landNPCs[id].isDestroy then
      self:InitSingleLand(id)
    end
  end
end

function FarmModule:ClearLands()
  Log.Debug("Clear lands!")
  if not self.landNPCs then
    return
  end
  for id = LAND_MAX_NUM, 1, -1 do
    self:ClearSingleLand(id)
  end
  self.landNPCs = nil
end

function FarmModule:InitSingleLand(id)
  local pos, rot = self:SolveLandPosAndRot(id)
  if not pos or not rot then
    Log.Error("FarmModule:InitSingleLand pos, rot nil!!!!!!")
    return
  end
  pos = SceneUtils.ClientPos2ServerPos(pos)
  local newNPC = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.CreateLocalNPC, LAND_NPC_ID + id, pos, rot.Yaw * 10, nil, PriorityEnum.Passive_World_NPC_Close_BP)
  if not self.landNPCs then
    self.landNPCs = {}
  end
  self.landNPCs[id] = newNPC
  newNPC.luaObj.landId = id
  newNPC:EnsureComponent(PetHUDComponent)
end

function FarmModule:ClearSingleLand(id)
  local landNPC = self.landNPCs[id]
  if landNPC then
    _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.DeleteLocalNPC, self.landNPCs[id])
    self.landNPCs[id] = nil
  end
end

function FarmModule:GetLandNPC(id)
  return self.landNPCs and self.landNPCs[id]
end

function FarmModule:SolveLandPosAndRot(id)
  if not self.data.vecForward or not self.data.vecRight then
    Log.Error("FarmModule:SolveLandPosAndRot vecForward or vecRight not found!!!!!!")
    return
  end
  local PlantLandCoordinateConf = _G.DataConfigManager:GetPlantLandCoordinateConf(id)
  if not PlantLandCoordinateConf then
    Log.Error("FarmModule:SolveLandPosAndRot PlantLandCoordinateConf not found!!!!!! ", id)
    return
  end
  local forward, right = PlantLandCoordinateConf.coordinate[1] - 1, PlantLandCoordinateConf.coordinate[2] - 1
  local pos = self.data.originLocation + self.data.vecForward * forward * self.data.length_side + self.data.vecRight * right * self.data.length_side
  local rot = self.data.originRotation
  local offset = pos - self.data.originLocation
  Log.Debug(id, "pos", offset.X, offset.Y, offset.Z)
  return pos, rot
end

function FarmModule:RefreshAllLandState()
end

function FarmModule:RefreshCurrentStandLandInfo()
  local localPlayer = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local currentLandId
  if self:IsLocalPlayerAllowStandOnLand() then
    local playerCheckPos = localPlayer:GetActorLocation()
    local halfHeight = localPlayer:GetControlPawnCapsuleSize()
    playerCheckPos = playerCheckPos - UE4.FVector(0, 0, halfHeight)
    currentLandId = self:GetCurrentLandId(playerCheckPos)
  end
  if self.data.currentLandId == currentLandId then
    return
  end
  if self.data.currentLandId then
    NRCEventCenter:DispatchEvent(FarmModuleEvent.OnPlayerStandFarmLandChanged, false, self.data.currentLandId)
    if self.landNPCs and self.landNPCs[self.data.currentLandId] and self.landNPCs[self.data.currentLandId].viewObj then
      self.landNPCs[self.data.currentLandId].viewObj:OnChangeStandSelectionState(false)
    end
  end
  self.data.currentLandId = currentLandId
  if self.data.currentLandId then
    NRCEventCenter:DispatchEvent(FarmModuleEvent.OnPlayerStandFarmLandChanged, true, self.data.currentLandId)
    if self.landNPCs and self.landNPCs[self.data.currentLandId] and self.landNPCs[self.data.currentLandId].viewObj then
      self.landNPCs[self.data.currentLandId].viewObj:OnChangeStandSelectionState(true)
    end
  end
end

function FarmModule:IsLocalPlayerAllowStandOnLand()
  local state = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetPlayerInteractStateCache)
  if state == Enum.LocationInteractionBanType.STA_BEGIN or state == Enum.LocationInteractionBanType.STA_LAND or state == Enum.LocationInteractionBanType.STA_LAND_RIDE then
    return true
  end
end

function FarmModule:GetCurrentLandId(pos)
  for id = 1, LAND_MAX_NUM do
    if self:IsInLand(pos, id) and FarmUtils.IsLandUnlock(id) then
      return id
    end
  end
  return nil
end

function FarmModule:IsInLand(pos, id)
  if not (self.landNPCs and self.landNPCs[id]) or not self.data.originRotation then
    return false
  end
  local landNPC = self.landNPCs[id]
  if not landNPC.viewObj or not UE4.UObject.IsValid(landNPC.viewObj) then
    return false
  end
  local landPos = landNPC.viewObj:Abs_K2_GetActorLocation()
  local posDir = UE4.FVector(pos.X - landPos.X, pos.Y - landPos.Y, 0)
  local lengthForward = math.abs(UE4.FVector.Dot(posDir, self.data.vecForward))
  local lengthRight = math.abs(UE4.FVector.Dot(posDir, self.data.vecRight))
  local lengthHeight = math.abs(pos.Z - landPos.Z)
  if lengthForward < self.data.role_select_length / 2 and lengthRight < self.data.role_select_length / 2 and lengthHeight < self.data.role_select_height then
    return true
  end
  return false
end

function FarmModule:GetHarvestIconPath()
  return self.data.harvestIconPath
end

function FarmModule:GetCurUnlockFarmLandNum()
  local unlockCount = 0
  for id = 1, LAND_MAX_NUM do
    if FarmUtils.IsLandUnlock(id) then
      unlockCount = unlockCount + 1
    end
  end
  return unlockCount
end

function FarmModule:GetCurMaxUnlockFarmLandNum(isSelf)
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not Player then
    Log.Error("FarmModule:GetCurRoomLevelMaxFarmLandNum Can't find local player")
    return
  end
  if not Player.serverData or not Player.serverData.home_basic_info then
    Log.Error("FarmModule:GetCurRoomLevelMaxFarmLandNum Can't find serverData or player home info")
    return 0
  end
  local home_info = Player:GetPlayerHomeInfo(isSelf)
  if not home_info or not home_info.home_level then
    Log.Error("FarmModule:GetCurRoomLevelMaxFarmLandNum fatal error!!!! home_info or level not found!! ")
    return
  end
  local homeLevel = home_info and home_info.home_level or 0
  local homeLevelConfig = _G.DataConfigManager:GetHomeLevelConf(homeLevel)
  if not homeLevelConfig then
    Log.Error("FarmModule:GetCurRoomLevelMaxFarmLandNum fatal error!!!! Invalid homeLevel: ", homeLevel)
    return
  end
  return homeLevelConfig.farmplan_num
end

function FarmModule:GetAvailableUnlockFarmLandNum()
  local curMaxNum = self:GetCurMaxUnlockFarmLandNum()
  if not curMaxNum then
    Log.Error("FarmModule:GetAvailableUnlockFarmLandNum, GetCurMaxUnlockFarmLandNum fail")
    return
  end
  local curNum = self:GetCurUnlockFarmLandNum()
  if not curNum then
    Log.Error("FarmModule:GetAvailableUnlockFarmLandNum, GetCurUnlockFarmLandNum fail")
    return
  end
  return curMaxNum - curNum
end

function FarmModule:ShowLandUnlockHighlight()
  local startId = self:GetCurUnlockFarmLandNum() + 1
  local maxId = self:GetCurMaxUnlockFarmLandNum()
  if not startId or not maxId then
    Log.Error("FarmModule:ShowLandUnlockHighlight Can't find startId or maxId")
    return
  end
  for id = startId, maxId do
    if self.landNPCs[id] and self.landNPCs[id].viewObj then
      self.landNPCs[id].viewObj:SetUnlockHighlightState(true)
      self.landNPCs[id].viewObj:SetActiveLandState(true)
    end
  end
end

function FarmModule:HideLandUnlockHighlight()
  local startId = self:GetCurUnlockFarmLandNum() + 1
  local maxId = self:GetCurMaxUnlockFarmLandNum()
  if not startId or not maxId then
    Log.Error("FarmModule:ShowLandUnlockHighlight Can't find startId or maxId")
    return
  end
  for id = startId, maxId do
    if self.landNPCs[id] and self.landNPCs[id].viewObj then
      self.landNPCs[id].viewObj:SetActiveLandState(false)
    end
  end
  for id = 1, LAND_MAX_NUM do
    if self.landNPCs[id] and self.landNPCs[id].viewObj then
      self.landNPCs[id].viewObj:SetUnlockHighlightState(false)
    end
  end
end

function FarmModule:OnHomePlantChangeNotify(action)
  local player = FarmUtils.GetPlayer()
  if not player then
    return
  end
  if action.home_plant_info.home_plant_land_list[1] and action.home_plant_info.home_plant_land_list[1].plant_list then
    for id = 1, LAND_MAX_NUM do
      local newData = action.home_plant_info.home_plant_land_list[1].plant_list[id]
      if self.landNPCs and self.landNPCs[id] and self.landNPCs[id].luaObj then
        self.landNPCs[id].luaObj:TryRefreshByNewInfo(newData)
      end
    end
  end
  if not player.serverData.home_plant_info then
    player.serverData.home_plant_info = ProtoMessage:newActorInfo_HomePlantInfo()
  end
  player.serverData.home_plant_info.cell_home_plant_info = action.home_plant_info
  self:RefreshCurrentStandLandInfo()
  NRCEventCenter:DispatchEvent(FarmModuleEvent.OnFarmLandInfoChanged)
end

function FarmModule:OnHomePlantPlantCrop(action)
end

function FarmModule:OnHomeBasicInfoChangeNotify(action)
end

function FarmModule:OnCmdGetCurrentStandingLandId()
  return self.data.currentLandId
end

function FarmModule:GetModuleData()
  return self.data
end

function FarmModule:OnCmdGetIsInFarm()
  return self.data.isInFarm
end

function FarmModule:HasMagicBanned(MagicType)
  if self:OnCmdGetIsInFarm() then
    local MagicBanTypes = (self.data or {}).MagicBanTypes
    return MagicType and MagicBanTypes and MagicBanTypes and MagicBanTypes[MagicType]
  end
  return false
end

function FarmModule:RefreshFunctionBan(bEnterFarm)
  local Key
  if FarmUtils.IsCurrentHomeOwner() then
    Key = Enum.PlayerConditionType.PCT_HOME_PLANT
  else
    Key = Enum.PlayerConditionType.PCT_VISIT_HOME_PLANT
  end
  if bEnterFarm then
    if Key ~= self.FunctionBanKey then
      if self.FunctionBanKey then
        Log.Debug("FarmModule:RefreshFunctionBan remove", self.FunctionBanKey)
        _G.FunctionBanManager:RemovePlayerConditionType(self.FunctionBanKey)
      end
      self.FunctionBanKey = Key
      if Key then
        Log.Debug("FarmModule:RefreshFunctionBan add", self.FunctionBanKey)
        _G.FunctionBanManager:AddPlayerConditionType(Key)
      end
    end
  elseif self.FunctionBanKey then
    Log.Debug("FarmModule:RefreshFunctionBan remove", self.FunctionBanKey)
    _G.FunctionBanManager:RemovePlayerConditionType(self.FunctionBanKey)
    self.FunctionBanKey = nil
  end
end

function FarmModule:OnCollectAllLandOptionStatus()
  local infos = {}
  for id = 1, LAND_MAX_NUM do
    local landNpc = self:GetLandNPC(id)
    local optionType = FarmModuleEnum.OptionType.None
    if landNpc and landNpc.viewObj and landNpc.viewObj.optionState then
      optionType = landNpc.viewObj.optionState
    else
      optionType = FarmUtils.GetLandOptionStatus(i)
    end
    if not infos[optionType] then
      infos[optionType] = 0
    end
    infos[optionType] = infos[optionType] + 1
  end
  return infos
end

function FarmModule:OnFarmSingleLandInfoChanged()
  local infos = self:OnCollectAllLandOptionStatus()
  _G.NRCEventCenter:DispatchEvent(FarmModuleEvent.OnUpdateLandOptionStatus, infos)
end

return FarmModule
