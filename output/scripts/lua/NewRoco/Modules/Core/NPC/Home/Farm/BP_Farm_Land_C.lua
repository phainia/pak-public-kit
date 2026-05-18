require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")
local FarmModuleEvent = require("NewRoco.Modules.System.Farm.FarmModuleEvent")
local FarmModuleEnum = require("NewRoco.Modules.System.Farm.FarmModuleEnum")
local FloatingText2DComponent = require("NewRoco.Modules.Core.Scene.Component.Interaction.FloatingText2DComponent")
local BP_Farm_Land_C = Base:Extend("BP_Farm_Land_C")

function BP_Farm_Land_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_Farm_Land_C:Init()
  Base.Init(self)
end

function BP_Farm_Land_C:OnFrameLoad(distanceRatio)
  if not SceneUtils.debugCloseNPCFacialAndWidget then
    local Character = self.sceneCharacter
    if Character then
      local hud = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetHudFromPool, "UMG_Hud_Pet")
      if not hud then
        local hudClass = _G.NRCBigWorldPreloader:Get("PET_HUD")
        hud = UE4.UWidgetBlueprintLibrary.Create(self, hudClass)
      end
      Log.Debug("BP_Farm_Land_C:OnFrameLoad SetWidget")
      if UE.UObject.IsValid(hud) and self.HeadWidget then
        self.HeadWidget:SetWidget(hud)
        hud:SetParentHUD(self.HeadWidget)
      end
      if Character.PetHUDComponent then
        Character.PetHUDComponent:OnFrameLoaded()
      end
    end
  end
  Base.OnFrameLoad(self, distanceRatio)
end

function BP_Farm_Land_C:OnLoadResource()
  Base.OnLoadResource(self)
end

function BP_Farm_Land_C:OnVisible()
  Base.OnVisible(self)
  if self.sceneCharacter and self.sceneCharacter.luaObj and FarmUtils.IsModuleUnlock() then
    self:SetLandUnlockState(FarmUtils.IsLandUnlock(self.sceneCharacter.luaObj.landId), true)
    self:SetHarvestState(FarmUtils.IsLandHarvest(self.sceneCharacter.luaObj.landId))
    self:SetWateringState(FarmUtils.IsLandWatering(self.sceneCharacter.luaObj.landId), true)
    self:SetFertilizingState(FarmUtils.IsLandFertilizing(self.sceneCharacter.luaObj.landId), true)
    self:OnChangeStandSelectionState(FarmUtils.IsStandingOnLand(self.sceneCharacter.luaObj.landId))
  end
  self.isWatering = FarmUtils.IsLandWatering(self.sceneCharacter.luaObj.landId)
  self.isFertilizing = FarmUtils.IsLandFertilizing(self.sceneCharacter.luaObj.landId)
  FarmUtils.FixPlantNPCCoordinate(self.sceneCharacter.luaObj.landId)
end

function BP_Farm_Land_C:Recycle()
  Base.Recycle(self)
end

function BP_Farm_Land_C:SetSceneCharacter(sceneCharacter)
  if sceneCharacter then
    Base.SetSceneCharacter(self, sceneCharacter)
    self:Register()
  else
    self:Unregister()
    Base.SetSceneCharacter(self, sceneCharacter)
  end
end

function BP_Farm_Land_C:Register()
  if not self.sceneCharacter then
    return
  end
  self.sceneCharacter:AddEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnStatusChanged)
  _G.NRCEventCenter:RegisterEvent("BP_Farm_Land_C", self, FarmModuleEvent.OnFarmLandInfoChanged, self.OnFarmLandInfoChanged)
  if not self.resourceLoaded then
    return
  end
  self:OnStatusChanged()
end

function BP_Farm_Land_C:Unregister()
  self.sceneCharacter:RemoveEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnStatusChanged)
  _G.NRCEventCenter:UnRegisterEvent(self, FarmModuleEvent.OnFarmLandInfoChanged, self.OnFarmLandInfoChanged)
  if not self.sceneCharacter then
    return
  end
end

function BP_Farm_Land_C:OnStatusChanged()
end

function BP_Farm_Land_C:OnDistanceOptimize(distance, viewDotValue, bulkyVisible, distanceRatio)
  if not (self.sceneCharacter and self.sceneCharacter.luaObj and self.sceneCharacter.luaObj.landId) or not FarmUtils.GetPlayer() then
    return
  end
  local currentState = FarmUtils.GetLandOptionStatus(self.sceneCharacter.luaObj.landId)
  if self.optionState ~= currentState then
    self.optionState = currentState
    NRCEventCenter:DispatchEvent(FarmModuleEvent.OnFarmSingleLandInfoChanged, self.sceneCharacter.luaObj.landId)
    self:OnFarmLandInfoChanged()
  end
  self:UpdateChildHarvesting()
  local currentWateringState = FarmUtils.IsLandWatering(self.sceneCharacter.luaObj.landId) and not FarmUtils.IsLandHarvestingAvailable(self.sceneCharacter.luaObj.landId)
  if self.isWatering ~= currentWateringState then
    self.isWatering = currentWateringState
    self:SetWateringState(self.isWatering, false)
  end
  local currentFertilizingState = FarmUtils.IsLandFertilizing(self.sceneCharacter.luaObj.landId) and not FarmUtils.IsLandHarvestingAvailable(self.sceneCharacter.luaObj.landId)
  if self.isFertilizing ~= currentFertilizingState then
    self.isFertilizing = currentFertilizingState
    self:SetFertilizingState(self.isFertilizing, false)
  end
end

function BP_Farm_Land_C:UpdateChildHarvesting(newData)
  if self.NRCChildActor ~= nil and nil ~= self.sceneCharacter then
    local child = self.NRCChildActor:GetChildActor()
    if child and UE.UObject.IsValid(child) then
      child.IsHarvesting = FarmUtils.IsLandHarvestingAvailable(self.sceneCharacter.luaObj.landId, newData)
    end
  end
end

function BP_Farm_Land_C:OnChangeStandSelectionState(isIn)
  if self.isStand == isIn then
    return
  end
  if self.NRCChildActor ~= nil and nil ~= self.sceneCharacter then
    local child = self.NRCChildActor:GetChildActor()
    if child and UE.UObject.IsValid(child) then
      self.isStand = isIn
      if isIn then
        child:ShowStandHighlight()
      else
        child:HideStandHighlight()
      end
    end
  end
end

function BP_Farm_Land_C:SetLandUnlockState(isUnlock, isInstant)
  if self.NRCChildActor ~= nil and nil ~= self.sceneCharacter then
    local child = self.NRCChildActor:GetChildActor()
    if child and UE.UObject.IsValid(child) then
      if isUnlock then
        child:ShowUnlockLand(true == isInstant)
        if not isInstant then
          child:HideUnlockHighlight()
        end
      else
        child:ShowLockLand()
      end
    end
  end
end

function BP_Farm_Land_C:SetUnlockHighlightState(isOn)
  if self.NRCChildActor ~= nil and nil ~= self.sceneCharacter then
    local child = self.NRCChildActor:GetChildActor()
    if child and UE.UObject.IsValid(child) then
      if isOn then
        child:ShowUnlockHighlight()
      else
        child:HideUnlockHighlight()
      end
    end
  end
end

function BP_Farm_Land_C:SetActiveLandState(isOn)
  if self.NRCChildActor ~= nil and nil ~= self.sceneCharacter then
    local child = self.NRCChildActor:GetChildActor()
    if child and UE.UObject.IsValid(child) then
      if isOn then
        child:ActivateLand()
      else
        child:DeactivateLand()
      end
    end
  end
end

function BP_Farm_Land_C:SetHarvestState(isOn)
  if self.NRCChildActor ~= nil and nil ~= self.sceneCharacter then
    local child = self.NRCChildActor:GetChildActor()
    if child and UE.UObject.IsValid(child) then
      if isOn then
        child:ShowHarvestFX()
      else
        child:HideHarvestFX()
      end
    end
  end
end

function BP_Farm_Land_C:TryRefreshByNewInfo(newData)
  if not self.sceneCharacter then
    return
  end
  local oldData = FarmUtils.GetLandInfo(self.sceneCharacter.luaObj.landId)
  if newData then
    local isHarvest = FarmUtils.IsLandHarvest(self.sceneCharacter.luaObj.landId, newData)
    local isPrevHarvest = false
    if oldData then
      isPrevHarvest = FarmUtils.IsLandHarvest(self.sceneCharacter.luaObj.landId)
    end
    if isPrevHarvest ~= isHarvest then
      self:SetHarvestState(isHarvest)
    end
    local isUnlock = FarmUtils.IsLandUnlock(self.sceneCharacter.luaObj.landId, newData)
    local isPrevUnlock = false
    if oldData then
      isPrevUnlock = FarmUtils.IsLandUnlock(self.sceneCharacter.luaObj.landId)
    end
    if isPrevUnlock ~= isUnlock then
      self:SetLandUnlockState(isUnlock)
    end
    self:UpdateChildHarvesting(newData)
    local isWatering = FarmUtils.IsLandWatering(self.sceneCharacter.luaObj.landId, newData)
    if self.isWatering ~= isWatering then
      isWatering = isWatering and not FarmUtils.IsLandHarvestingAvailable(self.sceneCharacter.luaObj.landId, newData)
      self.isWatering = isWatering
      self:SetWateringState(isWatering, true)
    end
    local isFertilizing = FarmUtils.IsLandFertilizing(self.sceneCharacter.luaObj.landId, newData)
    if self.isFertilizing ~= isFertilizing then
      isFertilizing = isFertilizing and not FarmUtils.IsLandHarvestingAvailable(self.sceneCharacter.luaObj.landId, newData)
      self.isFertilizing = isFertilizing
      self:SetFertilizingState(isFertilizing, true)
    end
  end
end

function BP_Farm_Land_C:SetWateringState(isOn, isInstant)
  if self.NRCChildActor ~= nil and nil ~= self.sceneCharacter then
    local child = self.NRCChildActor:GetChildActor()
    if child and UE.UObject.IsValid(child) then
      if isOn then
        child:ShowWateringState(true == isInstant)
      else
        child:HideWateringState(true == isInstant)
      end
    end
  end
end

function BP_Farm_Land_C:SetFertilizingState(isOn, isInstant)
  if self.NRCChildActor ~= nil and nil ~= self.sceneCharacter then
    local child = self.NRCChildActor:GetChildActor()
    if child and UE.UObject.IsValid(child) then
      if isOn then
        child:ShowFertilizingState(true == isInstant)
      else
        child:HideFertilizingState(true == isInstant)
      end
    end
  end
end

function BP_Farm_Land_C:OnFarmLandInfoChanged()
  if self.sceneCharacter and self.sceneCharacter.PetHUDComponent then
    self.sceneCharacter.PetHUDComponent:OnRefreshFarmNpcStatus(FarmModuleEnum.NPCType.Land, self.sceneCharacter.luaObj.landId)
  end
end

function BP_Farm_Land_C:AddFloatingText(reduceTime)
  local Comp = self.sceneCharacter:EnsureComponent(FloatingText2DComponent)
  local FmtTimeStr = FarmUtils.GenerateTimeStr(reduceTime, 2)
  Comp:AddFloatingText("-" .. FmtTimeStr, true)
end

return BP_Farm_Land_C
