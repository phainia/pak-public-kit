require("UnLua")
local Base = require("NewRoco.Modules.System.Home.Res.NRCHomePlacementActor_C")
local FurnitureNPC = require("NewRoco.Modules.System.Home.HomePetFeed.FurnitureNPC")
local HomeEnum = require("NewRoco.Modules.System.Home.HomeEnum")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local NPCLuaUtils = require("NewRoco.Modules.Core.NPC.NPCLuaUtils")
local InitialIconHeight
local DefaultIconHeight = 70
local IconMoreHeightIfWithEgg = 40
local BP_NRCFurnitureNPC_C = Base:Extend("BP_NRCFurnitureNPC_C")

function BP_NRCFurnitureNPC_C:Ctor()
  self.bShouldShowEmptyWidget = false
  self.bShouldShowWidget = false
end

function BP_NRCFurnitureNPC_C:OnPostLoad(data)
  if self.HighlightCollision then
    local highlightRadius = _G.DataConfigManager:GetHomeGlobalConfig("home_owner_visible_distance").num or 200
    self.HighlightCollision:SetCapsuleRadius(highlightRadius)
  end
  if self.IconShowDis then
    local showIconRadius = _G.DataConfigManager:GetHomeGlobalConfig("home_pet_bed_icon_distance").num or 200
    self.IconShowDis:SetCapsuleRadius(showIconRadius)
  end
  if self.EmptyStatusShowDis then
    local emptyStatusRadius = _G.DataConfigManager:GetHomeGlobalConfig("home_pet_bed_none_distance").num or 1000
    self.EmptyStatusShowDis:SetCapsuleRadius(emptyStatusRadius)
  end
  if not self.homeLevelCharacter then
    local FurnitureNPC = FurnitureNPC(self, NRCModuleManager:GetModule("HomeModule"))
    self:SetFurnitureNPC(FurnitureNPC)
  end
  self:LoadWidget()
  self.homeLevelCharacter:OnHomeLevelStatusChanged(HomeEnum.EnmEditPropsStatus.SPAWN_SUCCESS, data)
end

function BP_NRCFurnitureNPC_C:LoadWidget()
  if self.homeLevelCharacter and self.bIsFurnitureInHome and not UE4.UObject.IsValid(self.rocoWidget:GetWidget()) then
    local hud = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetHudFromPool, "UMG_Home_Pet")
    if not hud then
      local hudCls = _G.NRCBigWorldPreloader:Get("PET_HUD_HOME")
      hud = UE4.UWidgetBlueprintLibrary.Create(self, hudCls)
    end
    if UE.UObject.IsValid(hud) then
      self.rocoWidget:SetWidget(hud)
      hud:SetParentHUD(self.rocoWidget)
      hud:SetAttachActor(self)
    end
    if not self:NeedShowWidget() then
      self.rocoWidget:SetVisibility(false, true)
    end
  end
  local rocoWidgetRelativeTransform = self.rocoWidget:GetRelativeTransform()
  if rocoWidgetRelativeTransform and rocoWidgetRelativeTransform.Translation and rocoWidgetRelativeTransform.Translation.Z and not InitialIconHeight then
    InitialIconHeight = rocoWidgetRelativeTransform.Translation.Z
  end
end

function BP_NRCFurnitureNPC_C:RefreshWidgetVisibility(enableVisible, bForce)
  if bForce and self.rocoWidget then
    self.rocoWidget:SetVisibility(enableVisible)
  end
  if enableVisible and (self.bShouldShowWidget or self.bShouldShowEmptyWidget and self:NeedShowWidget()) then
    if self.rocoWidget then
      self.rocoWidget:SetVisibility(true, true)
    end
    return
  end
  if self.rocoWidget then
    self.rocoWidget:SetVisibility(false, true)
  end
end

function BP_NRCFurnitureNPC_C:UpdateWidgetComponent(bShow, petData)
  local bVisible = self:NeedShowWidget()
  self:RefreshWidgetVisibility(bVisible)
  if not petData and self.flashTimer then
    self.flashTimer:Stop()
    self.flashTimer = nil
  end
  if bShow and not petData then
    local rocoWidgetC = self.rocoWidget:GetWidget()
    if rocoWidgetC and rocoWidgetC.UpdateIcon then
      rocoWidgetC:UpdateIcon(nil)
      self.rocoWidget:SetVisibility(true, true)
      self.rocoWidget:RequestRedraw()
    end
    return
  end
  if self.rocoWidget and UE4.UObject.IsValid(self.rocoWidget) then
    self.rocoWidget:SetVisibility(false, true)
    if not bShow then
      return
    end
    local rocoWidgetC = self.rocoWidget:GetWidget()
    if rocoWidgetC and rocoWidgetC.UpdateIcon then
      rocoWidgetC:UpdateIcon(petData)
    end
    self:ModifyIconHeightIfWithEgg()
  end
end

function BP_NRCFurnitureNPC_C:SetFurnitureNPC(FurnitureNPC)
  if not FurnitureNPC or self.homeLevelCharacter then
    return
  end
  self.homeLevelCharacter = FurnitureNPC
end

function BP_NRCFurnitureNPC_C:ReceiveActorBeginOverlap(OtherActor)
  if not self.petReleaseLocation then
    local furnitureLoc = self:Abs_K2_GetActorLocation()
    local furnitureRot = self:K2_GetActorRotation()
    self.petReleaseLocation = UE4.FVector(furnitureLoc.X, furnitureLoc.Y, furnitureLoc.Z + 50)
  end
end

function BP_NRCFurnitureNPC_C:IsPlayerInVisibleLocation()
end

function BP_NRCFurnitureNPC_C:ReceiveActorEndOverlap(OtherActor)
  if self.homeLevelCharacter and self.homeLevelCharacter.HomeInteractComponent and self.homeLevelCharacter.HomeInteractComponent.isInOverlapArea then
    self.homeLevelCharacter.HomeInteractComponent:OnPlayerLeaveActionArea()
  end
end

function BP_NRCFurnitureNPC_C:ReceiveBeginPlay()
  Base.ReceiveBeginPlay(self)
  if self.homeLevelCharacter and self.homeLevelCharacter.QueryCurrentStatus then
    self.homeLevelCharacter:QueryCurrentStatus()
  end
end

function BP_NRCFurnitureNPC_C:ReceiveEndPlay()
  Log.Debug("BP_NRCFurnitureNPC_C ReceiveEndPlay")
  if self.otherActor then
    self:ReceiveActorEndOverlap(self.otherActor)
  end
  if self.homeLevelCharacter then
    self.homeLevelCharacter:OnHomeLevelStatusChanged(HomeEnum.EnmEditPropsStatus.UNLOAD_PACK_UP)
    self.homeLevelCharacter:Destroy()
    self.homeLevelCharacter = nil
  end
  if self.flashTimer then
    self.flashTimer:Stop()
    self.flashTimer = nil
  end
end

function BP_NRCFurnitureNPC_C:GetComponent(ClassTable)
  local memberName = ClassTable.className
  local instance = rawget(self, memberName)
  if instance then
    return instance
  end
  if self.components then
    for _, v in ipairs(self.components:Items()) do
      if v:InstanceOf(ClassTable) then
        return v
      end
    end
  end
  return nil
end

function BP_NRCFurnitureNPC_C:OnHighlightActive(OtherActor, bShow)
end

function BP_NRCFurnitureNPC_C:OnIconPrepared()
  if not self.rocoWidget then
    return
  end
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player and player.viewObj then
    local curPos = self:Abs_K2_GetActorLocation()
    local playerPos = player.viewObj:Abs_K2_GetActorLocation()
    local dis = UE4.FVector.DistSquared2D(curPos, playerPos)
    local capsuleRadius = self.IconShowDis and self.IconShowDis:GetUnscaledCapsuleRadius() or 200
    if dis <= capsuleRadius * capsuleRadius then
      self.bShouldShowWidget = true
      self.rocoWidget:SetVisibility(true)
    else
      self.bShouldShowWidget = false
    end
  end
end

function BP_NRCFurnitureNPC_C:OnIconShowActive(OtherActor, bShow)
  if bShow and self.homeLevelCharacter then
    self.bShouldShowWidget = true
    if self:NeedShowWidget() then
      self.homeLevelCharacter:QueryCurrentStatus()
      self:MakeWidgetFlashByPetType(true)
    end
  else
    self.bShouldShowWidget = false
    if not self:NeedShowWidget() then
      self.rocoWidget:SetVisibility(false)
      self:MakeWidgetFlashByPetType(false)
    end
  end
end

function BP_NRCFurnitureNPC_C:OnEmptyStatusShowActive(OtherActor, bShow)
  if bShow then
    self.bShouldShowEmptyWidget = true
    if self:NeedShowWidget() and self.homeLevelCharacter then
      self.homeLevelCharacter:QueryCurrentStatus()
    end
  else
    self.bShouldShowEmptyWidget = false
    if not self:NeedShowWidget() and self.homeLevelCharacter then
      self.rocoWidget:SetVisibility(false)
    end
  end
end

function BP_NRCFurnitureNPC_C:MakeWidgetFlashByPetType(bFlash)
  if not bFlash then
    if self.flashTimer then
      _G.TimerManager:RemoveTimer(self.flashTimer)
      self.flashTimer = nil
      self.rocoWidget.bRedrawRequested = false
    end
    return
  end
  if self.flashTimer then
    return
  end
  local pairPetData = _G.NRCModuleManager:DoCmd(HomeModuleCmd.GetPairNestAndPet, self.homeLevelCharacter.furnitureId)
  local pairPet
  if pairPetData then
    pairPet = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, pairPetData.base.actor_id)
    if pairPet and pairPet.serverData and 0 ~= pairPet.serverData.mutation_type then
      self.flashTimer = _G.TimerManager:CreateTimer(self, "BP_NRCFurnitureNPC" .. pairPetData.base.actor_id, math.maxinteger, function()
        if self.rocoWidget and UE4.UObject.IsValid(self.rocoWidget) and self.rocoWidget:IsWidgetVisible() then
          self.rocoWidget:RequestRedraw()
        end
      end, nil, 0.1)
    end
  end
end

function BP_NRCFurnitureNPC_C:MakeWidgetFlashInPreviewPanel(previewData)
  if not previewData then
    if self.previewTimer then
      self.previewTimer:Stop()
      self.previewTimer = nil
    end
    return
  end
  
  local function MakeWidgetFlash()
    if self.rocoWidget and UE4.UObject.IsValid(self.rocoWidget) and self.rocoWidget:IsWidgetVisible() then
      self.rocoWidget:RequestRedraw()
    end
  end
  
  if 0 ~= previewData.mutation_type then
    if not self.previewTimer then
      self.previewTimer = _G.TimerManager:CreateTimer(self, "BP_NRCFurnitureNPC" .. previewData.actor_id, math.maxinteger, MakeWidgetFlash, nil, 0.1)
      return
    end
    MakeWidgetFlash()
  elseif self.previewTimer then
    self.previewTimer:Stop()
    self.previewTimer = nil
  end
end

function BP_NRCFurnitureNPC_C:NeedShowWidget()
  if not self.homeLevelCharacter then
    return false
  end
  local curStatus = self.homeLevelCharacter:GetCurStatus()
  if _G.FunctionBanManager:GetConditionCounter(Enum.PlayerConditionType.PCT_EDITING_HOME) then
    if curStatus == HomeEnum.FURNITURE_NPC_STATE.Free then
      return false
    elseif curStatus == HomeEnum.FURNITURE_NPC_STATE.OccupiedWithPet then
      return true
    end
  end
  local emptyIconShowRadius, _ = self.EmptyStatusShowDis:GetScaledCapsuleSize()
  local iconShowRadius, _ = self.IconShowDis:GetScaledCapsuleSize()
  if emptyIconShowRadius < iconShowRadius then
    if self.bShouldShowEmptyWidget and curStatus == HomeEnum.FURNITURE_NPC_STATE.Free then
      return true
    elseif self.bShouldShowWidget and curStatus == HomeEnum.FURNITURE_NPC_STATE.OccupiedWithPet then
      return true
    else
      return false
    end
  elseif self.bShouldShowWidget and curStatus == HomeEnum.FURNITURE_NPC_STATE.OccupiedWithPet then
    return true
  elseif self.bShouldShowEmptyWidget and curStatus == HomeEnum.FURNITURE_NPC_STATE.Free then
    return true
  else
    return false
  end
end

function BP_NRCFurnitureNPC_C:Destroy()
end

function BP_NRCFurnitureNPC_C:ModifyIconHeightIfWithEgg()
  local pairPetData = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.GetPairNestAndPet, self.homeLevelCharacter.furnitureId)
  local pairPet
  if pairPetData then
    pairPet = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, pairPetData.base.actor_id)
  end
  if not pairPet then
    return
  end
  local iconHeight = InitialIconHeight or DefaultIconHeight
  if pairPet:IsLogicStatus(Enum.SpaceActorLogicStatus.SALS_HOME_PET_HOLD_EGG) then
    iconHeight = iconHeight + IconMoreHeightIfWithEgg
  end
  if self.rocoWidget and UE4.UObject.IsValid(self.rocoWidget) then
    self.rocoWidget:K2_SetRelativeLocation(UE4.FVector(0, 0, iconHeight), false, nil, false)
  end
end

function BP_NRCFurnitureNPC_C:OnPetStatusChanged()
  self:ModifyIconHeightIfWithEgg()
end

return BP_NRCFurnitureNPC_C
