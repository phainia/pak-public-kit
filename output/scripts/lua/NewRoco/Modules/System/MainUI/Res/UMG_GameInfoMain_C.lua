local PetUtils = require("NewRoco.Utils.PetUtils")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local MainUIModuleEvent = reload("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local BattleUIModuleCmd = reload("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local UMG_GameInfoMain_C = _G.NRCPanelBase:Extend("UMG_GameInfoMain_C")

function UMG_GameInfoMain_C:OnConstruct()
  Log.Debug("[TxTest] UMG_GameInfoMain_C:OnConstruct")
  self:SetChildViews(self.HeroInfoMain, self.ItemInfoMain, self.AchievementMain, self.PetInfoMain, self.BookInfoMain, self.petChangeTeam)
  local db = _G.DataConfigManager:GetGlobalConfigByKeyType("ui_audio_reduction_db", _G.DataConfigManager.ConfigTableId.GLOBAL_CONFIG).num
  UE4.UNRCAudioManager.SetWorldListenerVolumeOffset(db)
  self.curPanelIndex = 0
  self.subPanels = {
    [1] = self.HeroInfoMain,
    [2] = self.ItemInfoMain,
    [3] = self.AchievementMain,
    [4] = self.PetInfoMain,
    [5] = self.BookInfoMain
  }
  self.menuButtons = {
    self.btnMenu1,
    self.btnMenu2,
    self.btnMenu3,
    self.btnMenu4,
    self.btnMenu5
  }
  for id, subPanel in pairs(self.subPanels) do
    if subPanel then
      subPanel:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  end
  self.localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.Controller = self.localPlayer:GetUEController()
end

function UMG_GameInfoMain_C:OnActive(_param, ...)
  _G.NRCPanelBase.OnActive(self, _param, ...)
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OpenSuitPopupPanel, nil, true, false)
  self:OnAddEventListener()
  self.LoadFinishCallback = _param.callback
  self.LoadFinishCaller = _param.caller
  self.subPanelIndex = _param and _param.subPanelIndex or 1
  self._param = _param
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
  self:DelaySeconds(0.4, function()
    self:OnUMGLoadFinished()
  end)
end

function UMG_GameInfoMain_C:OnDeactive()
end

function UMG_GameInfoMain_C:OnUMGLoadFinished()
  local playerCameraManager = UE4.UGameplayStatics.GetPlayerControllerFromID(_G.UE4Helper.GetCurrentWorld(), 0).PlayerCameraManager
  if self.LoadFinishCallback and self.LoadFinishCaller then
    self.LoadFinishCallback(self.LoadFinishCaller)
  end
  self.LoadFinishCallback = nil
  self.LoadFinishCaller = nil
  playerCameraManager:SwitchBagCamera(true)
  self:DelaySeconds(0.4, function()
    self:StartCamera()
  end)
end

function UMG_GameInfoMain_C:OnSwithBagCameraFinished()
  local bHasCompass = _G.NRCModuleManager:DoCmd(MainUIModuleCmd.HasCompass)
  if not bHasCompass then
    NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  end
  if self then
    self:ShowSubPanel(self.subPanelIndex, self._param)
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_GameInfoMain_C:OnDestruct()
  self:OnRemoveEventListener()
  Log.Debug("[TxTest] UMG_GameInfoMain_C:OnDestruct")
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(9016, "UMG_GameInfoMain_C:OnbtnCloseClick")
  UE4.UNRCAudioManager.ResetWorldListenerVolumeOffset()
  for _, btnMenu in ipairs(self.menuButtons) do
    btnMenu:SetData(nil)
  end
  self.menuButtons = nil
  self.subPanels = nil
  self:CancelDelay()
  self.HeroInfoMain:Destruct()
  self.ItemInfoMain:Destruct()
  self.PetInfoMain:Destruct()
  self.AchievementMain:Destruct()
  self.BookInfoMain:Destruct()
  self.btnMenu1:Destruct()
  self.btnMenu2:Destruct()
  self.btnMenu3:Destruct()
  self.btnMenu4:Destruct()
  self.btnMenu5:Destruct()
  self.petChangeTeam:Destruct()
end

function UMG_GameInfoMain_C:OnAddEventListener()
  self:AddButtonListener(self.UMG_btnClose.btnClose, self.OnCloseButtonClicked)
  self:RegisterEvent(self, PetUIModuleEvent.PET_UI_LEFT_SUBPANEL_CHANGE, self.OnLeftSubPanelChange)
  self:RegisterEvent(self, PetUIModuleEvent.Hide_CloseBtn, self.OnCloseBtnHide)
  self:RegisterEvent(self, PetUIModuleEvent.PET_UI_UPGRADE_CONSTRAINT, self.OnUpGradeConstraint)
  self:RegisterEvent(self, MainUIModuleEvent.OPEN_PET_FORMATION, self.OnOpenPetFormation)
  local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:AddEventListener(self, PlayerModuleEvent.ON_PLAYER_DEAD, self.DeadClosePanel)
end

function UMG_GameInfoMain_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, MainUIModuleEvent.GAMEINFO_UI_SUBPANEL_OUT)
  self:UnRegisterEvent(self, PetUIModuleEvent.PET_UI_LEFT_SUBPANEL_CHANGE)
  self:UnRegisterEvent(self, PetUIModuleEvent.Hide_CloseBtn)
  self:UnRegisterEvent(self, MainUIModuleEvent.OPEN_PET_FORMATION)
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  playerModule:UnRegisterEvent(self, PlayerModuleEvent.ON_PLAYER_DEAD, self.DeadClosePanel)
end

function UMG_GameInfoMain_C:ShowSubPanel(_index, _data)
  self:PlayAnimation(self.in_2)
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self:OnMenuButtonClick(_index, _data, true)
end

function UMG_GameInfoMain_C:ChangeSubPanelState(_index, _isShow, _data, _isOpenPanel)
  if not _index then
    return
  end
  local subPanel = self.subPanels[_index]
  if not subPanel then
    return
  end
  if _data and subPanel.OnShowInitData then
    subPanel:OnShowInitData(_data)
  end
  if subPanel.OnMainPanelStateChange then
    tcall(subPanel, subPanel.OnMainPanelStateChange, _isShow, _isOpenPanel)
    if _isShow then
      subPanel:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  elseif _isShow then
    subPanel:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    subPanel:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_GameInfoMain_C:HidePanel()
  if self.curPanelIndex == nil then
    return
  end
  if self.curPanelIndex and nil ~= self.subPanels[self.curPanelIndex] then
    UE4Helper.SetEnableWorldRendering(true)
    self:PlayAnimation(self.OutPanel)
    self:ChangeSubPanelState(self.curPanelIndex, false, nil, true)
  else
  end
end

function UMG_GameInfoMain_C:DeadClosePanel()
  self:OnCloseButtonClicked()
end

function UMG_GameInfoMain_C:ChangeCurButtonState(_select)
  if self.curPanelIndex ~= nil then
    local curMenuBtton = self.menuButtons[self.curPanelIndex]
    if curMenuBtton then
      curMenuBtton:SetSelectState(_select)
    end
  end
end

function UMG_GameInfoMain_C:OnMenuButtonClick(_index, _data, _isOpenPanel)
  if nil == _index or _index > 0 and _index == self.curPanelIndex then
    return
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1005, "UMG_GameInfoMain_C:OnMenuButtonClick")
  if 4 ~= _index then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_gameinfomain_1)
    return
  end
  self:ChangeCurButtonState(false)
  self:ChangeSubPanelState(self.curPanelIndex, false, nil, false)
  self.curPanelIndex = _index
  self:ChangeSubPanelState(self.curPanelIndex, true, _data, _isOpenPanel)
  self:ChangeCurButtonState(true)
end

function UMG_GameInfoMain_C:OnCloseButtonClicked()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1008, "UMG_GameInfoMain_C:OnbtnCloseClick")
  self:SetPetNewSkillInfo()
  self:UpDateWarehouseMainInfo()
  self:UpdateMainPet()
  self:HidePanel()
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  _G.NRCEventCenter:DispatchEvent(MainUIModuleEvent.OnMainUISubPanelClosed, false)
  local openPetData, index, isRevertPanel = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.GetOpenPanelPetData)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetOpenPanelPetData, nil, index, isRevertPanel)
end

function UMG_GameInfoMain_C:UpdateMainPet()
  local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(MainUIModuleEvent.UI_Refresh_MainPet, 1, battlePetList)
end

function UMG_GameInfoMain_C:UpDateWarehouseMainInfo()
  local openPetData, index = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.GetOpenPanelPetData)
  if openPetData then
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.UpdatePetWareHouseMainInfo)
    _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.UpdatePVPPetInfo, openPetData)
  end
end

function UMG_GameInfoMain_C:OnAnimationFinished(Anim)
  if Anim == self.OutPanel then
    self:OnSubPanelOut()
  elseif Anim == self.in_2 then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.showPanel)
  end
end

function UMG_GameInfoMain_C:SetPetNewSkillInfo()
  if self.PetInfoMain == nil then
    return
  end
  local SelectPetData = self.PetInfoMain.petLeftPanel:GetSelectPet()
  local SelectMenuButtonsIndex = self.PetInfoMain.petLeftPanel:GetMenuButtonsIndex()
  if 3 == SelectMenuButtonsIndex then
    PetUtils.UpdatePetNewSkill(SelectPetData)
  end
end

function UMG_GameInfoMain_C:OnSubPanelOut()
  local playerCameraManager = UE4.UGameplayStatics.GetPlayerControllerFromID(_G.UE4Helper.GetCurrentWorld(), 0).PlayerCameraManager
  playerCameraManager:SwitchBagCamera(false)
  self:FinishCamera()
end

function UMG_GameInfoMain_C:OnBagCameraFinished(bool)
  if bool then
    self:OnSwithBagCameraFinished()
  else
    local MainUIModule = _G.NRCModuleManager:GetModule("MainUIModule")
    if MainUIModule and MainUIModule:HasPanel("GameInfoMain") then
      NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
      self:DoClose()
    end
  end
end

function UMG_GameInfoMain_C:StartCamera()
  self:OnSwithBagCameraFinished()
  UE4Helper.SetEnableWorldRendering(false)
end

function UMG_GameInfoMain_C:FinishCamera()
  local MainUIModule = _G.NRCModuleManager:GetModule("MainUIModule")
  if MainUIModule and MainUIModule:HasPanel("GameInfoMain") then
    local openPetData, index, isRevertPanel = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.GetOpenPanelPetData)
    local bInBattle = _G.BattleManager.isInBattle
    local bHasCompass = _G.NRCModuleManager:DoCmd(MainUIModuleCmd.HasCompass)
    if true == isRevertPanel and not bInBattle then
      if bHasCompass then
      else
        self.localPlayer.inputComponent:SetInputEnable(self, true)
        NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
      end
    else
      isRevertPanel = true
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetOpenPanelPetData, openPetData, index, isRevertPanel)
    end
    self:DoClose()
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.RefreshPetTeamPanel)
  end
end

function UMG_GameInfoMain_C:OnLeftSubPanelChange(_subPanelIndex)
  if _subPanelIndex and _subPanelIndex > 0 then
    self.button_close:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.button_close:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_GameInfoMain_C:OnCloseBtnHide(show)
  if false == show then
    self.button_close:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.button_close:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_GameInfoMain_C:OnUpGradeConstraint(_ISConstraint)
  Log.Debug("UMG_GameInfoMain_C:OnUpGradeConstraint")
  if _ISConstraint then
    self.BannedClick:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.BannedClick:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_GameInfoMain_C:OnOpenPetFormation()
  self.PetInfoMain:OpenPetFormation()
end

function UMG_GameInfoMain_C:IsPCMode()
  return UE.UGameplayStatics.GetGameInstance(self):IsPCMode()
end

function UMG_GameInfoMain_C:UpdatePetBag()
  self.PetInfoMain.petLeftPanel.PetBag:Reconnects()
end

return UMG_GameInfoMain_C
