local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PlayerDataEvent = require("Data.Global.PlayerDataEvent")
local MainUIModuleEvent = reload("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local TipsModuleEvent = require("NewRoco.Modules.System.TipsModule.TipsModuleEvent")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local BagModuleCmd = require("NewRoco.Modules.System.Bag.BagModuleCmd")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local PetUtils = require("NewRoco.Utils.PetUtils")
local HomeModuleEvent = require("NewRoco.Modules.System.Home.HomeModuleEvent")
local UMG_PlayerInfoHUD_C = _G.NRCViewBase:Extend("UMG_PlayerInfoHUD_C")

function UMG_PlayerInfoHUD_C:Initialize(Initializer)
  Log.Debug("UMG_PlayerInfoHUD_C:Initialize")
end

function UMG_PlayerInfoHUD_C:OnConstruct()
  local conf = _G.DataConfigManager:GetGlobalConfig("outside_catch_trigger")
  self.bOutsideCatchOpen = conf and 1 == conf.num or false
  self:SetPCPosition()
  self:MagicShowSet()
  self:EquipItemShowSet()
  self:SeedShowSet()
  self:ChcekFoodEquipMode()
  self.uiItem = {}
  self.Tracks = {}
  local petTiredHeadIcons = {
    self.petTriedHead1,
    self.petTriedHead2,
    self.petTriedHead3,
    self.petTriedHead4,
    self.petTriedHead5
  }
  self.uiItem.petTiredHeadIcons = petTiredHeadIcons
  self:OnAddEventListener()
  self.ListType = nil
  self:SetPlayerInfo()
  self.CanPress = true
  if not self:IsPCMode() then
    self:BindInputAction()
  end
  self:SetChildViews(self.UMG_Ability_Slot_Seed, self.AbilitySlot_PetCare)
end

function UMG_PlayerInfoHUD_C:OnDestruct()
  table.clear(self.uiItem)
  self.uiItem = nil
  if self.Tracks then
    for Index, Widget in ipairs(self.Tracks) do
      Widget:RemoveFromParent()
    end
    table.clear(self.Tracks)
  end
  self:OnRemoveEventListener()
  self:UnBindInputAction()
end

function UMG_PlayerInfoHUD_C:OnActive()
end

function UMG_PlayerInfoHUD_C:OnDeactive()
end

function UMG_PlayerInfoHUD_C:OnEnable()
end

function UMG_PlayerInfoHUD_C:OnDisable()
end

function UMG_PlayerInfoHUD_C:MagicSelectStart()
  local isBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionBan, Enum.FunctionEntrance.FE_MAGIC, true)
  if isBan or self.HUDMagic:GetVisibility() == UE4.ESlateVisibility.Collapsed or self.HUDMagic:GetVisibility() == UE4.ESlateVisibility.Hidden then
    return
  else
    self:OnPCUseMagic(0)
  end
end

function UMG_PlayerInfoHUD_C:MagicSelectEnd()
  local isBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionBan, Enum.FunctionEntrance.FE_MAGIC, true)
  if isBan or self.HUDMagic:GetVisibility() == UE4.ESlateVisibility.Collapsed or self.HUDMagic:GetVisibility() == UE4.ESlateVisibility.Hidden then
    return
  else
    self:OnPCUseMagic(1)
  end
end

function UMG_PlayerInfoHUD_C:BallSelectStart()
  local isBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionBan, Enum.FunctionEntrance.FE_THROW, true)
  if isBan or self.EquipItem:GetVisibility() == UE4.ESlateVisibility.Collapsed or self.EquipItem:GetVisibility() == UE4.ESlateVisibility.Hidden then
    return
  else
    self:OnPCUseBall(0)
  end
end

function UMG_PlayerInfoHUD_C:BallSelectEnd()
  local isBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionBan, Enum.FunctionEntrance.FE_THROW, true)
  if isBan or self.EquipItem:GetVisibility() == UE4.ESlateVisibility.Collapsed or self.EquipItem:GetVisibility() == UE4.ESlateVisibility.Hidden then
    return
  else
    self:OnPCUseBall(1)
  end
end

function UMG_PlayerInfoHUD_C:BindInputAction()
  local mappingContext = self:GetInputMappingContext("IMC_MainUIDefault")
  if mappingContext then
    local actions = {
      {
        name = "IA_MagicSelectStart",
        method = "MagicSelectStart"
      },
      {
        name = "IA_MagicSelectEnd",
        method = "MagicSelectEnd"
      },
      {
        name = "IA_BallSelectStart",
        method = "BallSelectStart"
      },
      {
        name = "IA_BallSelectEnd",
        method = "BallSelectEnd"
      },
      {
        name = "IA_OpenSeedBag",
        method = "OpenSeedBag"
      },
      {
        name = "IA_AbilitySlotHomePetFood",
        method = "OpenEquipFood"
      }
    }
    for _, action in ipairs(actions) do
      mappingContext:BindAction(action.name, self, action.method, UE.ETriggerEvent.Triggered)
    end
  end
end

function UMG_PlayerInfoHUD_C:UnBindInputAction()
  local mappingContext = self:GetInputMappingContext("IMC_MainUIDefault")
  if mappingContext then
    local actions = {
      {
        name = "IA_MagicSelectStart"
      },
      {
        name = "IA_MagicSelectEnd"
      },
      {
        name = "IA_BallSelectStart"
      },
      {
        name = "IA_BallSelectEnd"
      },
      {
        name = "IA_OpenSeedBag"
      },
      {
        name = "IA_AbilitySlotHomePetFood"
      }
    }
    for _, action in ipairs(actions) do
      mappingContext:UnBindAction(action.name)
    end
  end
end

function UMG_PlayerInfoHUD_C:OnAddEventListener()
  _G.NRCEventCenter:RegisterEvent("UMG_PlayerInfoHUD_C", self, PetUIModuleEvent.CHANGE_PET_POS_SUCCESS, self.OnChangePetBagPosComplete)
  _G.NRCEventCenter:RegisterEvent("UMG_PlayerInfoHUD_C", self, BagModuleEvent.UpdateBag, self.OnBagInfoChange)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, ENUM_PLAYER_DATA_EVENT.STORY_FLAG_CHANGE, self.OnFlagUpdate)
  _G.FunctionBanManager:AddFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_MAGIC_UI, self, self.OnChangeMagicUi)
  self:AddButtonListener(self.btnClickScreen, self.OnBtnClickScreenClick)
  _G.FunctionBanManager:AddFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_CATCH_IN_WORLD, self, self.OnChangePetCatch)
  local homeModule = _G.NRCModuleManager:GetModule("HomeModule")
  if homeModule then
    homeModule:RegisterEvent(self, HomeModuleEvent.OnEnterHomeMap, self.OnEnterHomeMap)
    homeModule:RegisterEvent(self, HomeModuleEvent.OnExitHomeMap, self.OnExitHomeMap)
  end
end

function UMG_PlayerInfoHUD_C:OnRemoveEventListener()
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.CHANGE_PET_POS_SUCCESS, self.OnChangePetBagPosComplete)
  _G.NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.UpdateBag, self.OnBagInfoChange)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, ENUM_PLAYER_DATA_EVENT.STORY_FLAG_CHANGE, self.OnFlagUpdate)
  _G.FunctionBanManager:RemoveFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_MAGIC_UI, self, self.OnChangeMagicUi)
  _G.FunctionBanManager:RemoveFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_CATCH_IN_WORLD, self, self.OnChangePetCatch)
  local homeModule = _G.NRCModuleManager:GetModule("HomeModule")
  if homeModule then
    homeModule:UnRegisterEvent(self, HomeModuleEvent.OnEnterHomeMap)
    homeModule:UnRegisterEvent(self, HomeModuleEvent.OnExitHomeMap)
  end
end

function UMG_PlayerInfoHUD_C:OnChangeMagicUi(State, FunctionBanType, ConditionType)
  self:ChangeHUDMagicByFunctionBan(not State)
end

function UMG_PlayerInfoHUD_C:OnChangePetCatch(State, FunctionBanType, ConditionType)
  self:ChangeEquipItemByFunctionBan(not State)
end

function UMG_PlayerInfoHUD_C:OnFlagUpdate(flagId, bIsHomeOwner)
  local UseSelf = _G.DataModelMgr.PlayerDataModel:IsUseSelfStoryFlag(flagId)
  if bIsHomeOwner == UseSelf then
    return
  end
  self:OnBagInfoChange()
end

function UMG_PlayerInfoHUD_C:OnBtnClickScreenClick(visible)
  if visible then
    if self:IsPCMode() then
      self.btnClickScreen:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.btnClickScreen:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    _G.NRCModeManager:DoCmd(MainUIModuleCmd.ShowSimpleUseList, self.ListType)
  else
    self.btnClickScreen:SetVisibility(UE4.ESlateVisibility.Collapsed)
    _G.NRCModeManager:DoCmd(MainUIModuleCmd.CloseSimpleUseList)
  end
end

function UMG_PlayerInfoHUD_C:ChangeMale()
end

function UMG_PlayerInfoHUD_C:ChangeFemale()
end

function UMG_PlayerInfoHUD_C:OnPlayerInfoChange()
  self:UpdatePetData()
  self:UpdatePlayerData()
end

function UMG_PlayerInfoHUD_C:OnBagInfoChange(item)
  if item and item.bag_item then
    if item.bag_item.type == ProtoEnum.BagItemType.BI_MAGIC or item.bag_item.type == ProtoEnum.BagItemType.BI_PET_BALL then
      self:UpdateEquipItemInfo(false)
      self:UpdateEquipMagicItemInfo(false)
    end
  else
    self:UpdateEquipItemInfo(false)
    self:UpdateEquipMagicItemInfo(false)
  end
end

function UMG_PlayerInfoHUD_C:UpdatePetData()
end

function UMG_PlayerInfoHUD_C:UpdatePlayerData()
end

function UMG_PlayerInfoHUD_C:SetPlayerInfo()
  self:UpdateEquipItemInfo(false)
end

function UMG_PlayerInfoHUD_C:UpdateEquipItemInfo(bSetThrow)
  local curEquipitem = NRCModuleManager:DoCmd(BagModuleCmd.GetCurEquipItemInfo)
  if not self.bOutsideCatchOpen then
    curEquipitem = nil
  end
  if nil == curEquipitem then
    self:SetEquipItemSelected(false)
  end
  if self:IsPCMode() then
    self.EquipItem:CheckEquipItemShow(false, true)
  else
    self.EquipItem:SetEquipItem(curEquipitem, bSetThrow)
  end
end

function UMG_PlayerInfoHUD_C:UpdateEquipMagicItemInfo(bSetThrow)
  self.CanPress = true
  local curEquipMagicInfo = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetEquipMagicInfo)
  local curEquipItemInfo = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetCurEquipItemInfo)
  local curSelectedPetGid = _G.NRCModuleManager:DoCmd(MainUIModuleCmd.GetSelectedPetGid)
  self:MagicShowSet()
  self.HUDMagic:SetMagicInfo(curEquipMagicInfo, bSetThrow)
  if curSelectedPetGid <= 0 and nil == curEquipMagicInfo and nil == curEquipItemInfo then
    local CatchPetInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
    for i = 1, #CatchPetInfo do
      if PetUtils.GetPetAdditionalByType(CatchPetInfo[i], _G.ProtoEnum.AttributeType.AT_HPCUR) > 0 then
        _G.NRCModuleManager:DoCmd(MainUIModuleCmd.UI_SetThrowItem, _G.MainUIModuleEnum.MainUIChooseType.PET, CatchPetInfo[i])
        return
      end
    end
  end
end

function UMG_PlayerInfoHUD_C:UpdateItemInfoFirstTime(itemInfo)
  if self:IsPCMode() then
    self.EquipItem:CheckEquipItemShow(false, true)
  else
    self.EquipItem:SetEquipItem(itemInfo)
  end
end

function UMG_PlayerInfoHUD_C:SetEquipItemSelected(visible)
  if self:IsPCMode() then
    self.EquipItem:CheckEquipItemShow(false, true)
  else
    self.EquipItem:ShowSelected(visible)
  end
end

function UMG_PlayerInfoHUD_C:SetMagicSelected(visible)
  if not self:IsPCMode() then
    self.HUDMagic:ShowSelected(visible)
  end
end

function UMG_PlayerInfoHUD_C:UpdateEquipItem(itemData)
end

function UMG_PlayerInfoHUD_C:SetSimpleListInfo(type)
  self.ListType = type
end

function UMG_PlayerInfoHUD_C:SetSimpleUseListVisible(visible)
  self:OnBtnClickScreenClick(visible)
end

function UMG_PlayerInfoHUD_C:OnMainUIGameLoginEvent(isRelogin)
  if isRelogin then
    self:UpdatePetData()
  end
end

function UMG_PlayerInfoHUD_C:OnChangePetBagPosComplete()
  Log.Debug("UMG_PlayerInfoHUD_C:OnChangePetBagPosComplete")
  local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(MainUIModuleEvent.UI_Refresh_MainPet, 1, battlePetList)
end

function UMG_PlayerInfoHUD_C:UpdateBar()
end

function UMG_PlayerInfoHUD_C:OnPCUseMagic(action_type)
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_AIMTHROWING) and not player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_MAGIC) then
    local hasMagic = _G.NRCModeManager:DoCmd(_G.BagModuleCmd.CheckHasBagItemByType, Enum.BagItemType.BI_MAGIC)
    if not hasMagic then
      return
    elseif 0 == action_type then
      if self.CanPress then
        self.CanPress = false
        _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.PCKeyPressCloseFriendPanelTeam)
        if not self:IsPCMode() then
          _G.NRCModeManager:DoCmd(MainUIModuleCmd.ResetMainPetProgress)
          self.HUDMagic:OnBtnPressed()
        end
      end
    else
      self.CanPress = true
      if not self:IsPCMode() then
        self.HUDMagic:OnBtnReleased()
      end
    end
  end
end

function UMG_PlayerInfoHUD_C:OnPCUseBall(action_type)
  if not self.bOutsideCatchOpen then
    return
  end
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_AIMTHROWING) and not player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_MAGIC) then
    local hasBall = _G.NRCModeManager:DoCmd(BagModuleCmd.CheckHadUseBall)
    if not hasBall then
      if self:IsPCMode() then
        self.EquipItem:CheckEquipItemShow(false, true)
      else
        self.EquipItem:ShowEquipItem(UE4.ESlateVisibility.Collapsed)
      end
    elseif 0 == action_type then
      if self.CanPress then
        self.CanPress = false
        self.EquipItem:OnBtnPressed()
      end
    else
      self.CanPress = true
      self.EquipItem:OnBtnReleased()
    end
  end
end

function UMG_PlayerInfoHUD_C:SetPCPosition()
  if self:IsPCMode() then
    local pos = self.EquipItem.EquipItemNum.Slot:GetPosition()
    pos.y = -71
    self.EquipItem.EquipItemNum.Slot:SetPosition(pos)
    if not self:IsPCMode() then
      self.HUDMagic.Text_PCKey:SetText("Q")
      self.HUDMagic.Text_PCKey:SetKeyVisibility(true)
      self.EquipItem.Text_PCKey:SetText("E")
      self.EquipItem.Text_PCKey:SetKeyVisibility(true)
    end
  else
    self.btnClickScreen:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PlayerInfoHUD_C:MagicShowSet()
  local Ban, Msg = FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_MAGIC_UI, false, false)
  if Ban then
    Log.Debug("UMG_CompassIcon_C.show \228\186\146\230\150\165\231\179\187\231\187\159\230\139\166\230\136\170,CD", Msg)
    return
  end
  local hasMagic = _G.NRCModeManager:DoCmd(_G.BagModuleCmd.CheckHasBagItemByType, Enum.BagItemType.BI_MAGIC)
  if not hasMagic then
    self.HUDMagic:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif self:IsPCMode() then
    self.HUDMagic:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.HUDMagic:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_PlayerInfoHUD_C:EquipItemShowSet()
  if self:IsPCMode() then
    self.EquipItem:ShowEquipItem(UE4.ESlateVisibility.Collapsed)
  else
    self.EquipItem:ShowEquipItem(UE4.ESlateVisibility.Visible)
  end
end

function UMG_PlayerInfoHUD_C:ChangeHUDMagicState(show)
  local Ban, Msg = FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_MAGIC_UI, false, false)
  if Ban then
    Log.Debug("UMG_CompassIcon_C.show \228\186\146\230\150\165\231\179\187\231\187\159\230\139\166\230\136\170,CD", Msg)
    return
  end
  self.HUDMagic:SetVisibility(show)
end

function UMG_PlayerInfoHUD_C:ChangeEquipItemState(show)
  local Ban, Msg = FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_CATCH_IN_WORLD, false, false)
  if Ban then
    Log.Debug("UMG_CompassIcon_C.show \228\186\146\230\150\165\231\179\187\231\187\159\230\139\166\230\136\170,CD", Msg)
    return
  end
  local hasBall = _G.NRCModeManager:DoCmd(BagModuleCmd.CheckHadUseBall)
  if hasBall then
    if self:IsPCMode() then
      self.EquipItem:CheckEquipItemShow(false, true)
    else
      self.EquipItem:ShowEquipItem(show)
    end
  end
end

function UMG_PlayerInfoHUD_C:ChangeHUDMagicByFunctionBan(bShow)
  if bShow then
    self:MagicShowSet()
  else
    self.HUDMagic:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PlayerInfoHUD_C:ChangeEquipItemByFunctionBan(bShow)
  if self:IsPCMode() then
    self.EquipItem:ShowEquipItem(UE4.ESlateVisibility.Collapsed)
  elseif bShow then
    self.EquipItem:ShowEquipItem(UE4.ESlateVisibility.Visible)
  else
    self.EquipItem:ShowEquipItem(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PlayerInfoHUD_C:IsPCMode()
  return UE.UGameplayStatics.GetGameInstance(self):IsPCMode()
end

function UMG_PlayerInfoHUD_C:OpenSeedBag()
  local Ban = _G.FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_HOME_PLANT, false, false)
  if Ban or self.UMG_Ability_Slot_Seed:GetVisibility() == UE4.ESlateVisibility.Collapsed or self.UMG_Ability_Slot_Seed:GetVisibility() == UE4.ESlateVisibility.Hidden then
    return
  else
    self.UMG_Ability_Slot_Seed:OnSlotClicked()
  end
end

function UMG_PlayerInfoHUD_C:SeedShowSet()
  local bPCMode = self:IsPCMode()
  if self.UMG_Ability_Slot_Seed and self.UMG_Ability_Slot_Seed.SetInputType then
    self.UMG_Ability_Slot_Seed:SetInputType(false, bPCMode)
  end
end

function UMG_PlayerInfoHUD_C:OpenEquipFood()
  local Ban = _G.FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_HOME_PET_FOOD, false, false)
  if Ban or self.AbilitySlot_PetCare:GetVisibility() == UE4.ESlateVisibility.Collapsed or self.AbilitySlot_PetCare:GetVisibility() == UE4.ESlateVisibility.Hidden then
    return
  else
    self.AbilitySlot_PetCare:OnSlotClicked()
  end
end

function UMG_PlayerInfoHUD_C:ChcekFoodEquipMode()
  local bPCMode = self:IsPCMode()
  if self.AbilitySlot_PetCare and self.AbilitySlot_PetCare.SetInputType then
    self.AbilitySlot_PetCare:SetInputType(false, bPCMode)
  end
end

function UMG_PlayerInfoHUD_C:OnEnterHomeMap()
  if _G.HomeIndoorSandbox and _G.HomeIndoorSandbox:InLocalMasterIndoor() then
    self:PlayAnimation(self.Change_1)
  end
end

function UMG_PlayerInfoHUD_C:OnExitHomeMap()
  self:PlayAnimation(self.Change_2)
end

return UMG_PlayerInfoHUD_C
