local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local HomeNPCOption = require("NewRoco.Modules.System.Home.HomePetFeed.HomeNPCOption")
local HomeEnum = require("NewRoco.Modules.System.Home.HomeEnum")
local NPCLuaUtils = require("NewRoco.Modules.Core.NPC.NPCLuaUtils")
local ThrowUtils = require("NewRoco.Modules.Core.NPC.ThrowUtils")
local HomeModuleEvent = require("NewRoco/Modules/System/Home/HomeModuleEvent")
local PlayerModuleCmd = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleCmd")
local HomeInteractComponent = Base:Extend("HomeInteractComponent")
local interactOptTable = {
  [HomeEnum.FURNITURE_NPC_STATE.Free] = 720000011,
  [HomeEnum.FURNITURE_NPC_STATE.OccupiedWithPet] = 720000012
}

function HomeInteractComponent:Attach(owner)
  Base.Attach(self, owner)
  self._options = {}
  self.needStatusNotify = false
  self.isInOverlapArea = false
  self.Valid3DOptions = nil
  self.ValidSenseOptions = nil
  self:InitOptions()
  self.bOccupied = false
  self.petNum = 0
  self.bActiveInteract = false
  FunctionBanManager:AddFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_OPTION, self, self.OnFunctionStateChanged)
end

function HomeInteractComponent:OnFunctionStateChanged(newState, functionType)
end

function HomeInteractComponent:GetAndResetHighestPriorityOptions(options)
  local ans = {}
  local highestPriority = -1
  for _, v in pairs(options) do
    if v:IsOptionEnable() then
      if highestPriority < v:GetPriority() then
        for _, lower in pairs(ans) do
          if lower.inActionArea then
            lower.inActionArea = false
            lower:OnPlayerLeaveActionArea()
          end
        end
        ans = {v}
        highestPriority = v:GetPriority()
      elseif v:GetPriority() == highestPriority then
        table.insert(ans, v)
      end
    end
  end
  return ans
end

function HomeInteractComponent:CalcCheckOpts()
  local manualOpts = {}
  for _, v in pairs(self._options) do
    if v:IsOptionEnable() then
      local interactType = v.config.npc_interact_type
      if v:IsManual() then
        table.insert(manualOpts, v)
        self._highestManualPriority = math.max(self._highestManualPriority, v:GetPriority())
      elseif v:IsAuto() then
        self._checkOptions[v.optionInfo.option_id] = v
      elseif interactType == _G.Enum.InteractType.IT_COMPASS then
        self._checkOptions[v.optionInfo.option_id] = v
      elseif interactType == _G.Enum.InteractType.IT_EMOTE then
        self._checkOptions[v.optionInfo.option_id] = v
      end
    end
  end
  local validManualOpts = self:GetAndResetHighestPriorityOptions(manualOpts)
  for _, v in pairs(validManualOpts) do
    self._checkOptions[v.optionInfo.option_id] = v
  end
  local ID, Option = next(self._options)
  if not ID and not Option then
    self._highestManualPriority = -1
  end
end

function HomeInteractComponent:OnHighPriorityOptionActive(id, option)
  for id, v in pairs(self._checkOptions) do
    if v:IsManual() then
      if self._checkOptions[id].inActionArea then
        self._checkOptions[id].inActionArea = false
        self._checkOptions[id]:OnPlayerLeaveActionArea()
      end
      self._checkOptions[id] = nil
    end
  end
  self._checkOptions[id] = option
  self._highestManualPriority = option:GetPriority()
end

function HomeInteractComponent:InterRemoveOption(id)
  local option = self._options[id]
  if not option then
    return
  end
  self:BroadcastOptionChanged(option)
  local priority = option:GetPriority()
  option:Destroy()
  self._options[id] = nil
  self._checkOptions[id] = nil
  if option:IsManual() and priority == self._highestManualPriority then
    self:CalcCheckOpts()
  end
  if 0 == table.len(self._options) then
    self._highestManualPriority = -1
  end
end

function HomeInteractComponent:BroadcastOptionChanged(option)
  local luaObj = self.owner.luaObj
  if luaObj and luaObj.OnNpcOptionChange then
    luaObj:OnNpcOptionChange(option)
  end
end

function HomeInteractComponent:InterOptionEnableChange(oldEnable, newEnable, option)
  local interactType = option.config.npc_interact_type
  if oldEnable and not newEnable then
    self._checkOptions[option.optionInfo.option_id] = nil
    option.inActionArea = false
    if option:GetPriority() >= self._highestManualPriority and option:IsManual() then
      self:CalcCheckOpts()
    end
  elseif not oldEnable and newEnable then
    if option:IsAuto() or interactType == Enum.InteractType.IT_COMPASS or interactType == Enum.InteractType.IT_EMOTE then
      self._checkOptions[option.optionInfo.option_id] = option
    elseif option:IsManual() then
      if option:GetPriority() == self._highestManualPriority then
        self._checkOptions[option.optionInfo.option_id] = option
      elseif option:GetPriority() > self._highestManualPriority then
        self:OnHighPriorityOptionActive(option.optionInfo.option_id, option)
      end
    end
  end
end

local combinedInfosCache = {}

local function GetCombinedInfos(serverData)
  table.clear(combinedInfosCache)
  local interactionData = serverData and serverData.npc_interact
  if not interactionData then
    return nil
  end
  local playerID = _G.NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_UIN)
  local shareInfo = interactionData.option_infos
  local otherInfo = interactionData.visitor_only_option_infos
  local myInfo
  if otherInfo then
    for _, visitorInfo in ipairs(otherInfo) do
      if visitorInfo.visitor_id == playerID then
        myInfo = visitorInfo.option_infos
        break
      end
    end
  end
  if shareInfo then
    for _, info in ipairs(shareInfo) do
      combinedInfosCache[info.option_id] = info
    end
  end
  if myInfo then
    for _, info in ipairs(myInfo) do
      combinedInfosCache[info.option_id] = info
    end
  end
  return combinedInfosCache
end

function HomeInteractComponent:UpdateData(serverData, isReconnect)
  Base.UpdateData(self, serverData)
  local totalInfo = GetCombinedInfos(serverData)
  if not totalInfo then
  end
  local newOptions = {}
  for optionID, optionInfo in pairs(totalInfo) do
    local option = self._options[optionID]
    if option then
      local oldEnable = option:IsOptionEnable()
      option:UpdateData(optionInfo, isReconnect)
      local newEnable = option:IsOptionEnable()
      self:InterOptionEnableChange(oldEnable, newEnable, option)
    else
      self:InterAddOption(optionID, optionInfo)
    end
    newOptions[optionID] = true
  end
  local needRemove = {}
  for id, option in pairs(self._options) do
    if not newOptions[id] then
      table.insert(needRemove, id)
    end
  end
  for _, id in pairs(needRemove) do
    self:InterRemoveOption(id)
  end
  if isReconnect then
    self.DisableFlagTemp = 0
  else
  end
end

function HomeInteractComponent:InterAddOption(optionID, optionInfo)
  Log.Debug("HomeInteractComponent InterAddOption", optionID)
end

function HomeInteractComponent:InitOptions()
  if self.owner.viewObj and self.owner.viewObj.bIsFurnitureInHome then
    self._options[self.owner.currentStatus] = HomeNPCOption(self.owner, interactOptTable[self.owner.currentStatus])
  end
end

function HomeInteractComponent:UpdateOptions()
  if self.owner.viewObj and self.owner.viewObj.bIsFurnitureInHome then
    for _, v in pairs(self._options) do
      v:Destroy()
    end
    table.clear(self._options)
    self._options[self.owner.currentStatus] = HomeNPCOption(self.owner, interactOptTable[self.owner.currentStatus])
  end
end

function HomeInteractComponent:OnPlayerEnterActionArea()
  if self.isInOverlapArea then
    return
  end
  self.isInOverlapArea = true
  if not self.owner.canTriggerInteraction then
    return
  end
  self:UpdateByDistance(0)
end

function HomeInteractComponent:UpdateByDistance(deltaTime)
  self:InnerUpdateByDistance(deltaTime)
end

function HomeInteractComponent:InnerUpdateByDistance(deltaTime)
  if self.owner.canInteract and not self.owner:canInteract() then
    return
  end
  if not self.owner.canTriggerInteraction then
    return
  end
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local playerRadiusDiff = NPCModule:GetPlayerRadiusDiff()
  local playerInteractStateCache = NPCModule:GetPlayerInteractStateCache()
  local rolePlayerBehaviorID = NPCModule:GetRolePlayBehaviorID()
  local player2NpcHeightDiff = self.owner.playerHeightDiff
  local requestEarlyTick = false
  if not self._options then
    return
  end
  if self.owner.UpdateDisForOption then
    self.owner:UpdateDisForOption()
  end
  for _, v in pairs(self._options) do
    local interactType = v.config.npc_interact_type
    local bInActionArea = false
    local playerDis = self.owner.squaredDis2Local
    local playerSquareDis = self.owner.squaredDis2LocalIgnoreZ
    local configSquareDis, configDis = v:GetSquaredDistance()
    local PlayerRadiusDiff = _G.NRCModuleManager:GetModule("NPCModule"):GetPlayerRadiusDiff()
    if PlayerRadiusDiff > 0 then
      configDis = configDis + PlayerRadiusDiff
      configSquareDis = configSquareDis + PlayerRadiusDiff
    end
    local maxUpdateDistance = 0
    if interactType == _G.Enum.InteractType.IT_AUTO or interactType == _G.Enum.InteractType.IT_MANUAL or interactType == _G.Enum.InteractType.IT_EMOTE then
      maxUpdateDistance = math.max(maxUpdateDistance, configSquareDis)
    elseif interactType == _G.Enum.InteractType.IT_COMPASS then
      local maxDistance, _ = NPCLuaUtils.GetSenseInfo(v)
      requestEarlyTick = true
      maxUpdateDistance = math.max(maxUpdateDistance, maxDistance)
    end
    if playerSquareDis < maxUpdateDistance then
      requestEarlyTick = true
    end
    local isInnerArea = playerSquareDis < configSquareDis
    local isNotOuterArea = playerSquareDis > v:GetSquaredLeaveDistance()
    local isPlayerInNpcView = self:InSpecificAngleValid(v)
    local isPlayerInOptionArea = self:IsInOptionArea(v)
    local isNpcInPlayerView = self:IsInPlayerForward(v)
    local isManualInteractType = interactType == Enum.InteractType.IT_MANUAL
    local isInHeightArea = true
    local optionHeight = v.config.option_hight
    if optionHeight and 0 ~= optionHeight then
      isInHeightArea = player2NpcHeightDiff < optionHeight
    else
      isInHeightArea = player2NpcHeightDiff < configDis
    end
    local RequestEarlyTick = false
    if isInnerArea and isInHeightArea then
      if not self:IsInteractBanState(playerInteractStateCache) and isPlayerInNpcView and isPlayerInOptionArea and isNpcInPlayerView then
        bInActionArea = true
        if v.inActionArea then
          if isManualInteractType then
            RequestEarlyTick = true
          end
        elseif interactType == Enum.InteractType.IT_AUTO then
          if not v:needStatusNotify() then
            v.inActionArea = true
            v:OnOptionAction()
            self:NotifyDisToPlayerChanged(true, playerDis)
          end
        elseif interactType == Enum.InteractType.IT_MANUAL then
          v.inActionArea = true
          v:OnPlayerEnterActionArea()
          self:NotifyDisToPlayerChanged(true, playerDis)
          requestEarlyTick = true
        end
      end
    elseif v.inActionArea and isManualInteractType then
      v.inActionArea = false
      v:OnPlayerLeaveActionArea()
      self:NotifyDisToPlayerChanged(false, playerDis)
      requestEarlyTick = true
    end
    self.isInOverlapArea = bInActionArea
    if not bInActionArea and v.inActionArea then
      if not (not isNotOuterArea and isPlayerInNpcView and isNpcInPlayerView and isInHeightArea) or not isPlayerInOptionArea then
        v.inActionArea = false
        v:OnPlayerLeaveActionArea()
        self:NotifyDisToPlayerChanged(false, playerDis)
      else
        requestEarlyTick = true
      end
    end
  end
  if requestEarlyTick and self.owner and self.owner.ScheduleNextTick then
    self.owner:ScheduleNextTick(0.1)
  end
end

function HomeInteractComponent:NotifyDisToPlayerChanged(bEnter, dis)
  self.owner:SendEvent(HomeModuleEvent.OnPlayerNestDistanceChanged, bEnter, dis)
end

function HomeInteractComponent:IsInteractBanState(playerState)
  if playerState == Enum.LocationInteractionBanType.STA_BEGIN then
    return false
  end
  if self.owner.serverData then
    local NpcTag
    local NpcBase = self.owner.serverData.npc_base
    if NpcBase.npc_content_cfg_id and 0 ~= NpcBase.npc_content_cfg_id then
      local RefreshContentConf = _G.DataConfigManager:GetNpcRefreshContentConf(NpcBase.npc_content_cfg_id)
      if RefreshContentConf and RefreshContentConf.LocationTag and 0 ~= RefreshContentConf.LocationTag then
        NpcTag = RefreshContentConf.LocationTag
      end
    end
    if not NpcTag and NpcBase.npc_cfg_id and 0 ~= NpcBase.npc_cfg_id then
      local NpcConf = _G.DataConfigManager:GetNpcConf(NpcBase.npc_cfg_id)
      if NpcConf and NpcConf.LocationTag and 0 ~= NpcConf.LocationTag then
        NpcTag = NpcConf.LocationTag
      end
    end
    local InteractBanConf = _G.DataConfigManager:GetLocationInteractBan(NpcTag or Enum.LocationTag.LC_LAND)
    if InteractBanConf and InteractBanConf.locaion_interact_ban_list then
      local BanList = InteractBanConf.locaion_interact_ban_list[PlayerState + 1]
      if BanList then
        return BanList.location_interact_ban
      end
    end
  end
  return false
end

function HomeInteractComponent:IsInFurnitureSpecificAngle(option)
  if self.owner.bIsFurnitureInHome then
    local playerLocation = self.owner.PlayerPosCache
    local option_effective_angle = option.config.option_effective_angle
    if option_effective_angle and #option_effective_angle >= 2 then
      local minAngle = option_effective_angle[1]
      local maxAngle = option_effective_angle[2]
      local furnitureMesh = self.owner.viewObj:GetComponentByClass(UE.UStaticMeshComponent)
      if not furnitureMesh then
        return false
      end
      local runnerLocation = furnitureMesh:GetSocketLocation("PetCreatePos")
      if minAngle > 180 or minAngle < -180 or maxAngle > 180 or maxAngle < -180 then
        return true
      end
      if minAngle == maxAngle then
        return true
      end
      local runnerToHitVec = playerLocation - runnerLocation
      runnerToHitVec.Z = 0
      runnerToHitVec:Normalize()
      local forwardVec = self.owner.viewObj:GetActorForwardVector()
      forwardVec.Z = 0
      forwardVec:Normalize()
    end
  end
end

function HomeInteractComponent:InSpecificAngleValid(option)
  local option_effective_angle = option.config.option_effective_angle
  if option_effective_angle and #option_effective_angle >= 2 then
    local minAngle = option_effective_angle[1]
    local maxAngle = option_effective_angle[2]
    if self.owner.CheckOptionInAngeleForward then
      self.owner:CheckOptionInAngeleForward(minAngle, maxAngle)
    else
      return true
    end
  end
  local option_Z_effective_angle = option.config.option_Z_effective_angle
  if option_Z_effective_angle and 0 ~= option_Z_effective_angle then
    local ZAngle = option_Z_effective_angle
    return ThrowUtils.CheckActionEffectInAnglesVertical(self.owner, playerLocation, ZAngle)
  end
  return true
end

function HomeInteractComponent:IsInPlayerForward(option)
  return true
end

function HomeInteractComponent:IsInOptionArea(option)
  if option.config.option_area and 0 ~= option.config.option_area then
    local regionArea = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetMapRegionArea, option.config.option_area)
    if regionArea then
      return regionArea:InnerContainsPoint(SceneUtils.ConvertRelativeToAbsolute(self.owner.PlayerPosCache))
    end
  end
  return true
end

function HomeInteractComponent:OnPlayerLeaveActionArea()
  if not self.isInOverlapArea then
    return
  end
  self.isInOverlapArea = false
  for _, v in pairs(self._options) do
    v.inActionArea = false
    v:OnPlayerLeaveActionArea()
  end
  self.owner:SendEvent(HomeModuleEvent.OnPlayerNestDistanceChanged, false, 200)
end

function HomeInteractComponent:DeAttach()
  FunctionBanManager:RemoveFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_OPTION, self, self.OnFunctionStateChanged)
end

function HomeInteractComponent:Destroy()
  for _, v in pairs(self._options) do
    v:Destroy()
  end
  table.clear(self._options)
  Base.Destroy(self)
end

function HomeInteractComponent:ChangeInteractEnable(bEnable)
  self.owner.canTriggerInteraction = bEnable
  if not bEnable and self.isInOverlapArea then
    self:OnPlayerLeaveActionArea()
  end
end

return HomeInteractComponent
