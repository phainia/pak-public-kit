local HomeInteractComponent = require("NewRoco.Modules.System.Home.HomePetFeed.HomeInteractComponent")
local Base = require("NewRoco.Modules.Core.Scene.Actor.SceneCharacter")
local HomeEnum = require("NewRoco.Modules.System.Home.HomeEnum")
local HomeModuleEvent = require("NewRoco/Modules/System/Home/HomeModuleEvent")
local HomeModuleCmd = require("NewRoco.Modules.System.Home.HomeModuleCmd")
local HomeUtils = require("NewRoco/Modules/System/Home/IndoorSandbox/HomeUtils")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local FurnitureNPC = Base:Extend("FurnitureNPC")

function FurnitureNPC:Ctor(viewObj, module)
  Base.Ctor(self, module)
  self.squaredDis2LocalIgnoreZ = 200000000
  self.squaredDis2Local = 200000000
  self.forwardDotValue = 0
  self.PlayerForwardDotCache = nil
  if viewObj then
    self.viewObj = viewObj
  end
  self:CalSquaredDis2Local()
  self.currentStatus = HomeEnum.FURNITURE_NPC_STATE.Free
  self.furnitureId = nil
  if self.PropsData and self.PropsData.id then
    self.furnitureId = self.PropsData.id
  end
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player then
    player:EnsureComponent(require("NewRoco.Modules.Core.Scene.Component.Home.Pet.HomePetSenseComponent"))
  end
  self:OnAddEventListener()
end

function FurnitureNPC:OnAddEventListener()
  self.module:RegisterEvent(self, HomeModuleEvent.HomePetStatusChanged, self.OnHomePetChanged)
  self.module:RegisterEvent(self, HomeModuleEvent.SwitchDetailPanelData, self.OnHomePetPreview)
  self.module:RegisterEvent(self, HomeModuleEvent.ClosePetLivePanel, self.OnCloseHomePetPreview)
  self.module:RegisterEvent(self, HomeModuleEvent.OnEnterHomeEditMode, self.OnEnterHomeEditMode)
  self.module:RegisterEvent(self, HomeModuleEvent.OnExitHomeEditMode, self.OnExitHomeEditMode)
  self.module:RegisterEvent(self, HomeModuleEvent.OnActiveFurnitureChange, self.OnActiveFurnitureChange)
  FunctionBanManager:AddFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_HOME_PET_PROMPTION, self, self.OnFunctionBan)
  _G.NRCEventCenter:RegisterEvent("UMG_Ability_Slot_PetCare_C", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnectFinish)
  self:UpdateEventListerOnPet()
end

function FurnitureNPC:RemoveEventListener()
  self.module:UnRegisterEvent(self, HomeModuleEvent.HomePetStatusChanged)
  self.module:UnRegisterEvent(self, HomeModuleEvent.SwitchDetailPanelData)
  self.module:UnRegisterEvent(self, HomeModuleEvent.ClosePetLivePanel)
  self.module:UnRegisterEvent(self, HomeModuleEvent.OnEnterHomeEditMode)
  self.module:UnRegisterEvent(self, HomeModuleEvent.OnExitHomeEditMode)
  self.module:UnRegisterEvent(self, HomeModuleEvent.OnActiveFurnitureChange)
  FunctionBanManager:RemoveFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_HOME_PET_PROMPTION, self, self.OnFunctionBan)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnectFinish)
end

function FurnitureNPC:OnReconnectFinish()
  if self.viewObj then
    self.viewObj:MakeWidgetFlashInPreviewPanel(nil)
  end
  self:QueryCurrentStatus()
end

function FurnitureNPC:OnEnterHomeEditMode()
  if not self.viewObj then
    return
  end
  if self.currentStatus == HomeEnum.FURNITURE_NPC_STATE.Free then
    self.viewObj:RefreshWidgetVisibility(false, true)
  elseif self.currentStatus == HomeEnum.FURNITURE_NPC_STATE.OccupiedWithPet then
    self.viewObj:RefreshWidgetVisibility(true, true)
    self.viewObj:MakeWidgetFlashByPetType(true)
  end
end

function FurnitureNPC:OnExitHomeEditMode()
  if not self.viewObj then
    return
  end
  self:QueryCurrentStatus()
  self.viewObj:RefreshWidgetVisibility(self.viewObj:NeedShowWidget())
end

function FurnitureNPC:OnActiveFurnitureChange(furnitureId)
  local interComp = self.HomeInteractComponent
  if not interComp then
    return
  end
  if furnitureId ~= self.furnitureId and interComp.isInOverlapArea then
    interComp:ChangeInteractEnable(false)
  elseif furnitureId == self.furnitureId and not interComp.isInOverlapArea then
    interComp:ChangeInteractEnable(true)
  end
end

function FurnitureNPC:OnFunctionBan()
  local isBan = _G.FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_HOME_PET_PROMPTION)
  if self.viewObj and self.viewObj.RefreshWidgetVisibility then
    self.viewObj:RefreshWidgetVisibility(isBan)
  end
end

function FurnitureNPC:OnHomePetPreview(petData, furnitureId)
  if not furnitureId or furnitureId ~= self.furnitureId then
    return
  end
  local preViewPetData = {}
  if petData then
    preViewPetData = {
      name = petData.name or "",
      base_conf_id = petData.base_conf_id or 0,
      mutation_type = petData.mutation_type or 0,
      glass_info = petData.glass_info,
      gender = petData.gender or 1,
      actor_id = petData.actor_id or 0
    }
  end
  if preViewPetData and table.len(preViewPetData) > 0 then
    self:UpdatePairPetInfo(true, preViewPetData)
    if self.viewObj then
      self.viewObj:MakeWidgetFlashInPreviewPanel(preViewPetData)
    end
  else
    Log.Error("invalid petData")
  end
end

function FurnitureNPC:OnCloseHomePetPreview()
  if self.viewObj then
    self.viewObj:MakeWidgetFlashInPreviewPanel(nil)
  end
  self:QueryCurrentStatus()
end

function FurnitureNPC:OnHomeLevelStatusChanged(Status, PropsData)
  if Status == HomeEnum.EnmEditPropsStatus.SPAWN_SUCCESS then
    local interactFurnitureList = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.OnCmdGetInteractiveFurniture)
    if interactFurnitureList and table.containsKey(interactFurnitureList, PropsData.Id) then
      return
    end
    if PropsData and PropsData.Id then
      self.furnitureId = PropsData.Id
    end
    _G.NRCModuleManager:DoCmd(HomeModuleCmd.InteractiveFurnitureEnter, self.furnitureId, self)
    if PropsData and PropsData.Location then
      self.position = PropsData.Location
    end
    self:QueryCurrentStatus()
    self:InitComponent()
  elseif Status == HomeEnum.EnmEditPropsStatus.UNLOAD_PACK_UP then
    self:RemoveEventListener()
    _G.NRCModuleManager:DoCmd(HomeModuleCmd.InteractiveFurnitureLeave, self.furnitureId, self)
  end
end

function FurnitureNPC:OnStatusChanged(newStatus)
  self.currentStatus = newStatus
  if not self.HomeInteractComponent or not self.HomeInteractComponent.UpdateOptions then
    return
  end
  self.HomeInteractComponent:UpdateOptions()
end

function FurnitureNPC:OnHomePetChanged(petInfo, bEnter)
  Log.Debug("OnHomePetChanged invoked with homePetInfo.furniture_guid" .. petInfo.home_pet.home_pet_info.furniture_guid .. " self.furnitureId " .. self.furnitureId)
  if petInfo and petInfo.home_pet.home_pet_info.furniture_guid == self.furnitureId then
    local petData = HomeUtils.GetHomePetAdditionalInfo(petInfo.home_pet.home_pet_info.pet_gid)
    if bEnter then
      self.currentStatus = HomeEnum.FURNITURE_NPC_STATE.OccupiedWithPet
      if petData then
        self:UpdatePairPetInfo(true, petData)
      end
      _G.NRCModuleManager:DoCmd(HomeModuleCmd.UpdatePairNestAndPet, self.furnitureId, petInfo)
    else
      self.currentStatus = HomeEnum.FURNITURE_NPC_STATE.Free
      if self.viewObj then
        self:UpdatePairPetInfo(self.viewObj:NeedShowWidget(), nil)
      end
      _G.NRCModuleManager:DoCmd(HomeModuleCmd.UpdatePairNestAndPet, self.furnitureId, nil)
    end
    local InterComp = self.HomeInteractComponent
    if InterComp then
      InterComp:UpdateOptions()
      Log.PrintScreenMsgRed("InterComp:UpdateOptions() invoked")
    end
    self:UpdateEventListerOnPet()
  end
end

function FurnitureNPC:QueryCurrentStatus()
  Log.Debug("current nest status query with self.furnitureId: ", self.furnitureId)
  if not self.furnitureId then
    return
  end
  local pairPetData = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.GetPairNestAndPet, self.furnitureId)
  if not pairPetData then
    self.currentStatus = HomeEnum.FURNITURE_NPC_STATE.Free
  elseif pairPetData.home_pet and pairPetData.home_pet.home_pet_info.furniture_guid == self.furnitureId then
    self.currentStatus = HomeEnum.FURNITURE_NPC_STATE.OccupiedWithPet
  else
    self.currentStatus = HomeEnum.FURNITURE_NPC_STATE.Free
  end
  Log.Debug("QueryCurrentStatus with currentStatus: ", self.currentStatus)
  if self.currentStatus == HomeEnum.FURNITURE_NPC_STATE.OccupiedWithPet then
    if not pairPetData or not pairPetData.home_pet then
      return
    end
    local petData = HomeUtils.GetHomePetAdditionalInfo(pairPetData.home_pet.home_pet_info.pet_gid)
    if petData and table.len(petData) > 0 then
      self:UpdatePairPetInfo(true, petData)
    end
  elseif self.viewObj then
    self:UpdatePairPetInfo(self.viewObj:NeedShowWidget(), nil)
  end
  local InterComp = self.HomeInteractComponent
  if InterComp then
    InterComp:UpdateOptions()
  end
  self:UpdateEventListerOnPet()
end

function FurnitureNPC:UpdatePairPetInfo(visibility, petData)
  if not self.viewObj or not UE.UObject.IsValid(self.viewObj) then
    Log.Error("FurnitureNPC viewObj not prepared")
    return
  end
  self.viewObj:UpdateWidgetComponent(visibility, petData)
end

function FurnitureNPC:UpdateDisForOption()
  self:CalSquaredDis2Local()
end

function FurnitureNPC:CalSquaredDis2Local()
  if not self.viewObj then
    return
  end
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  self.playerPosCache, self.playerForwardCache = NPCModule:GetPlayerPosCache()
  local playerX, playerY, playerZ
  playerX, playerY, playerZ, self.squaredDis2Local, self.squaredDis2LocalIgnoreZ, self.forwardDotValue, self.PlayerForwardDotCache = UE.NPCUtils.CalcDist(self.viewObj, nil, nil)
  self.playerPosCache.X = playerX
  self.playerPosCache.Y = playerY
  self.playerPosCache.Z = playerZ
  if self.viewObj and self.viewObj.K2_GetActorLocation then
    local viewObjLoc = self.viewObj:K2_GetActorLocation()
    if viewObjLoc then
      self.playerHeightDiff = self.viewObj and math.abs(playerZ - viewObjLoc.Z) or 9.0E9
    else
      self.playerHeightDiff = 9.0E9
    end
  end
  return self.squaredDis2Local, self.squaredDis2LocalIgnoreZ
end

function FurnitureNPC:GetCurStatus()
  Log.Debug("current status is " .. self.currentStatus)
  return self.currentStatus
end

function FurnitureNPC:SetNewStatus(newStatus)
  if newStatus == self.currentStatus then
    Log.Warning("duplicate status to set, ", newStatus)
    return
  end
  self.currentStatus = newStatus
end

function FurnitureNPC:SetViewObj(viewObj)
  if viewObj then
    self.viewObj = viewObj
  end
end

function FurnitureNPC:InitComponent()
  self:EnsureComponent(HomeInteractComponent)
  Base.InitComponent(self)
end

function FurnitureNPC:ReceiveEndPlay()
  if self.furnitureId then
    NRCModuleManager:DoCmd(HomeModuleCmd.InteractiveFurnitureLeave, self.furnitureId)
  end
end

function FurnitureNPC:CheckOptionInAngeleForward(relativeLoc, minAngle, maxAngle)
  if not self.viewObj then
    return false
  end
  local locatingMesh = self.viewObj:GetComponent(UE.UStaticMeshComponent)
  if not locatingMesh then
    return false
  end
  local furnitureLoc = locatingMesh:GetScketLocation("PetCreatePos")
  if minAngle > 180 or minAngle < -180 or maxAngle > 180 or maxAngle < -180 then
    return true
  end
  if minAngle == maxAngle then
    return true
  end
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  self.playerPosCache = NPCModule:GetPlayerPosCache()
  local currentLocToHitVec = self.playerPosCache - furnitureLoc
  currentLocToHitVec.Z = 0
  currentLocToHitVec:Normalize()
  local forwardVec = self.viewObj:GetActorForwardVector()
  forwardVec.Z = 0
  forwardVec:Normalize()
  local innerCos = math.clamp(currentLocToHitVec:Dot(forwardVec), -1, 1)
  local degree = math.deg(math.acos(innerCos))
  if maxAngle < minAngle then
    if minAngle <= degree and degree <= 180 or degree >= -180 and maxAngle >= degree then
      return true
    else
      return false
    end
  elseif minAngle <= degree and maxAngle >= degree then
    return true
  else
    return false
  end
end

function FurnitureNPC:Destroy()
  self:RemoveEventListener()
  Base.Destroy(self)
end

function FurnitureNPC:UpdateEventListerOnPet()
  local pairPetData = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.GetPairNestAndPet, self.furnitureId)
  if not pairPetData then
    self:RemoveEventListenerOnOldPet(self.pairPet)
    return
  end
  local pairPet
  if pairPetData then
    pairPet = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, pairPetData.base.actor_id)
  end
  if not pairPet then
    self:RemoveEventListenerOnOldPet(self.pairPet)
    return
  end
  if self.pairPet == pairPet then
    return
  end
  self:RemoveEventListenerOnOldPet(self.pairPet)
  self.pairPet = pairPet
  self:AddEventListenerOnNewPet(pairPet)
end

function FurnitureNPC:AddEventListenerOnNewPet(petNpc)
  if not petNpc then
    return
  end
  petNpc:AddEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnPetStatusChanged)
  self:OnPetStatusChanged()
end

function FurnitureNPC:RemoveEventListenerOnOldPet(petNpc)
  if not petNpc then
    return
  end
  petNpc:RemoveEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnPetStatusChanged)
end

function FurnitureNPC:OnPetStatusChanged()
  if self.viewObj then
    self.viewObj:OnPetStatusChanged()
  end
end

return FurnitureNPC
