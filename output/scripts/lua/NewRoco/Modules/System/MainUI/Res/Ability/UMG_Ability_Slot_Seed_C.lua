require("UnLuaEx")
local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")
local FarmModuleEnum = require("NewRoco.Modules.System.Farm.FarmModuleEnum")
local FarmModuleEvent = require("NewRoco.Modules.System.Farm.FarmModuleEvent")
local HomeModuleEvent = require("NewRoco.Modules.System.Home.HomeModuleEvent")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local UMG_Ability_Slot_Seed_C = _G.NRCViewBase:Extend("UMG_Ability_Slot_Seed_C")

function UMG_Ability_Slot_Seed_C:OnConstruct()
  self.bFinishConstruct = false
  _G.NRCViewBase.OnConstruct(self)
  self:AddButtonListener(self.Btn_Slot, self.OnSlotClicked)
  self.EquipSeed = 0
  self.EquipSeedTabLevel = 0
  self.SwitchBtn:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  NRCEventCenter:RegisterEvent("UMG_Ability_Slot_Seed_C", self, FarmModuleEvent.OnEnterFarmMap, self.HandleOnEnterFarmMap)
  NRCEventCenter:RegisterEvent("UMG_Ability_Slot_Seed_C", self, FarmModuleEvent.OnExitFarmMap, self.HandleOnExitFarmMap)
  FunctionBanManager:AddFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_HOME_PLANT, self, self.OnFunctionBan)
  _G.UpdateManager:UnRegister(self)
  self.bFinishConstruct = true
end

function UMG_Ability_Slot_Seed_C:OnDestruct()
  _G.NRCViewBase.OnDestruct(self)
  self:SetAvailable(false)
  _G.NRCEventCenter:UnRegisterEvent(self, FarmModuleEvent.OnEnterFarmMap, self.HandleOnEnterFarmMap)
  _G.NRCEventCenter:UnRegisterEvent(self, FarmModuleEvent.OnExitFarmMap, self.HandleOnExitFarmMap)
  FunctionBanManager:RemoveFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_HOME_PLANT, self, self.OnFunctionBan)
end

function UMG_Ability_Slot_Seed_C:RefreshUI()
  local bCurrentPCMode = UE.UGameplayStatics.GetGameInstance(self):IsPCMode()
  if self.bPCModeUI ~= bCurrentPCMode then
    return
  end
  local Ban = _G.FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_HOME_PLANT)
  self._isVisible = self.bAvailable and not Ban
  self:SetVisible(self._isVisible)
  if self._isVisible then
    self:RefreshUI_Seed()
  end
end

function UMG_Ability_Slot_Seed_C:OnSlotClicked()
  local Ban = _G.FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_HOME_PLANT, false, false)
  if Ban or not self:IsVisible() then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_PlantSeedsPanel_C:OnSlotPressed_seedBag")
  _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.OpenSeedBagPanel)
  self:PlayAnimation(self.Press)
end

function UMG_Ability_Slot_Seed_C:OnBagChange()
  self:RefreshUI()
end

function UMG_Ability_Slot_Seed_C:RefreshUI_Seed()
  local equippingSeed, equippingSeedPlantTabLevel = _G.NRCModuleManager:DoCmd(HomeModuleCmd.GetEquipSeed)
  self.EquipSeed = equippingSeed
  self.EquipSeedTabLevel = equippingSeedPlantTabLevel
  if 0 == equippingSeed then
    self.EmptyItem:SetPath("PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUIStatic/Frames/img_HomePlanting_SeedEmpty_png.img_HomePlanting_SeedEmpty_png'")
    self.SwitchBtn:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.EmptyItem:SetVisibility(UE4.ESlateVisibility.Visible)
    self.SeedItem:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCSwitcher_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Fx_icon_light:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if not self:IsAnimationPlaying(self.Loop) then
      self:PlayAnimation(self.Loop, 0, 99999)
    end
  else
    self:StopAnimation(self.Loop)
    self.Fx_icon_light:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SwitchBtn:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.EmptyItem:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SeedItem:SetVisibility(UE4.ESlateVisibility.Visible)
    local bagItemConf = DataConfigManager:GetBagItemConf(equippingSeed)
    local iconPath
    if bagItemConf then
      iconPath = bagItemConf.icon
    end
    self.SeedItem:SetPath(iconPath)
    local plantGrowConf = DataConfigManager:GetPlantGrowConf(equippingSeed)
    if plantGrowConf and plantGrowConf.plant_grow_grade and plantGrowConf.plant_grow_grade[equippingSeedPlantTabLevel] then
      local plantGrowGrade = plantGrowConf.plant_grow_grade[equippingSeedPlantTabLevel]
      self.NRCSwitcher_0:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.NRCSwitcher_0:SetActiveWidgetIndex(0)
      local vItemConf = _G.DataConfigManager:GetVisualItemConf(plantGrowGrade.plant_vitem_type or _G.Enum.VisualItem.VI_COIN)
      if vItemConf then
        self.Item:SetPath(vItemConf.iconPath)
      end
      self.ItemNum:SetText(plantGrowGrade.plant_vitem_value)
      local ownNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(plantGrowGrade.plant_vitem_type) or 0
      if ownNum >= plantGrowGrade.plant_vitem_value then
        self.ItemNum:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("F4EEE1FF"))
      else
        self.ItemNum:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#CF3D3E"))
      end
    else
      self.NRCSwitcher_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_Ability_Slot_Seed_C:OnFunctionBan()
  self:RefreshUI(true)
end

function UMG_Ability_Slot_Seed_C:HandleOnEnterFarmMap()
  local bCurrentPCMode = UE.UGameplayStatics.GetGameInstance(self):IsPCMode()
  if self.bPCModeUI ~= bCurrentPCMode then
    return
  end
  self:SetAvailable(true)
  self:RefreshUI()
end

function UMG_Ability_Slot_Seed_C:HandleOnExitFarmMap()
  self:DelayFrames(2, self.DelayHandleOnExitFarmMapInternal, self)
end

function UMG_Ability_Slot_Seed_C:DelayHandleOnExitFarmMapInternal()
  local bCurrentPCMode = UE.UGameplayStatics.GetGameInstance(self):IsPCMode()
  if self.bPCModeUI ~= bCurrentPCMode then
    return
  end
  self:SetAvailable(false)
  self:RefreshUI()
end

function UMG_Ability_Slot_Seed_C:SetAvailable(bAvailable)
  self.bAvailable = not not bAvailable
  self:OnAvailable(self.bAvailable)
end

function UMG_Ability_Slot_Seed_C:HandleOnEquipSeedChange(unEquipSeedId, EquipSeedId)
  self:RefreshUI()
end

function UMG_Ability_Slot_Seed_C:OnAvailable(bAvailable)
  if bAvailable then
    _G.DataModelMgr.PlayerDataModel:AddEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnBagChange)
    local homeModule = _G.NRCModuleManager:GetModule("HomeModule")
    if homeModule then
      homeModule:RegisterEvent(self, HomeModuleEvent.OnEquipSeedChange, self.HandleOnEquipSeedChange)
    end
  else
    self:StopAllAnimations()
    _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnBagChange)
    local homeModule = _G.NRCModuleManager:GetModule("HomeModule")
    if homeModule then
      homeModule:UnRegisterEvent(self, HomeModuleEvent.OnEquipSeedChange)
    end
  end
end

function UMG_Ability_Slot_Seed_C:SetVisible(bVisible)
  if bVisible then
    if self.FoundationPCKey then
      self.FoundationPCKey:SetKeyVisibility(true)
    end
    if self.ParentPanel then
      self.ParentPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    if self.FoundationPCKey then
      self.FoundationPCKey:SetKeyVisibility(false)
    end
    if self.ParentPanel then
      self.ParentPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Ability_Slot_Seed_C:SetInputType(bPCModeUI, bCurrentPCMode)
  self.bPCModeUI = bPCModeUI
  if self.bPCModeUI ~= bCurrentPCMode then
    if self.FoundationPCKey then
      self.FoundationPCKey:SetKeyVisibility(false)
    end
    if self.ParentPanel then
      self.ParentPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_Ability_Slot_Seed_C
