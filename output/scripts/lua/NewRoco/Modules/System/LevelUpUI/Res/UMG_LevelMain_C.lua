local PlayerDataEvent = require("Data.Global.PlayerDataEvent")
local LevelUpUIModuleEvent = reload("NewRoco.Modules.System.LevelUpUI.LevelUpUIModuleEvent")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local MainUIModuleEnum = require("NewRoco.Modules.System.MainUI.MainUIModuleEnum")
local UMG_LevelMain_C = _G.NRCPanelBase:Extend("UMG_LevelMain_C")

function UMG_LevelMain_C:OnConstruct()
  self:SetChildViews(self.UMG_LevelInformation, self.UMG_LevelUpRewards)
end

function UMG_LevelMain_C:OnActive(param)
  self.UMG_LevelUpRewards:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.UMG_LevelUpRewards:InitWithData(param.levelListInfo)
  self.UMG_LevelInformation:InitWithData({})
  self.UMG_LevelUpRewards.owner = self
  self.UMG_LevelInformation.owner = self
  self.OpenSystemShop = false
  self.OpenFriend = false
  self.OpenEmail = false
  self.OpenSet = false
  self.OpenTeachManual = false
  self.Lock = false
  self.FriendEntry.RedDot:SetupKey(72)
  self.EmailEntry.RedDot:SetupKey(61)
  self:OnAddEventListener()
  self.UMG_LevelUpRewards:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.UMG_LevelInformation:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:RefreshIcons()
  self.IsOpenIn = true
  _G.NRCEventCenter:DispatchEvent(MainUIModuleEvent.OnMainUILuopanChanged, _G.MainUIModuleEnum.MainUILuopanState.Idle, _G.MainUIModuleEnum.MainUILuopanIdleState.PanelIdle)
  _G.NRCEventCenter:DispatchEvent(MainUIModuleEvent.OnMainUISubPanelOpen)
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  self:PlayAnimation(self.In)
  _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_TogglePropTips, false)
  self.isPlayingAnimation = true
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local ctrl = player:GetUEController()
  ctrl:SetUICameraState(MainUIModuleEnum.MainUICameraState.PlayerInfo)
  self:BindInputAction()
end

function UMG_LevelMain_C:OnDeactive()
  _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_TogglePropTips, true)
  _G.UpdateManager:UnRegister(self)
  self:OnRemoveEventListener()
  self:UnBindInputAction()
end

function UMG_LevelMain_C:BindInputAction()
  local imc = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_MenuClose")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperAddInputMappingContext, imc, self.depth)
  local ia = UE.UNRCEnhancedInputHelper.GetInputAction("IA_CloseMenu")
  UE.UNRCEnhancedInputHelper.BindAction(ia, UE.ETriggerEvent.Triggered, self, "OnPcClose")
end

function UMG_LevelMain_C:UnBindInputAction()
  local ia = UE.UNRCEnhancedInputHelper.GetInputAction("IA_CloseMenu")
  UE.UNRCEnhancedInputHelper.UnBindAction(ia)
  local imc = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_MenuClose")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperRemoveInputMappingContext, imc)
end

function UMG_LevelMain_C:OnPcClose()
  local visible1 = self.UMG_LevelInformation:GetVisibility()
  local visible2 = self.UMG_LevelUpRewards:GetVisibility()
  if visible1 == UE4.ESlateVisibility.HitTestInvisible or visible1 == UE4.ESlateVisibility.SelfHitTestInvisible or visible1 == UE4.ESlateVisibility.Visible then
    self.UMG_LevelInformation:OnCloseButtonClick()
  elseif visible2 == UE4.ESlateVisibility.HitTestInvisible or visible2 == UE4.ESlateVisibility.SelfHitTestInvisible or visible2 == UE4.ESlateVisibility.Visible then
    self.UMG_LevelUpRewards:OnCloseBtnClick()
  end
end

function UMG_LevelMain_C:SwitchToRewards()
  self.UMG_LevelInformation:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.UMG_LevelInformation:PlayAnimation(self.UMG_LevelInformation.Out)
  self.isPlayingAnimation = true
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local ctrl = player:GetUEController()
  ctrl:SetUICameraState(MainUIModuleEnum.MainUICameraState.PlayerInfo)
end

function UMG_LevelMain_C:SwitchToInfo()
  self.UMG_LevelUpRewards:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.UMG_LevelUpRewards:PlayAnimation(self.UMG_LevelUpRewards.Out)
  self.isPlayingAnimation = true
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local ctrl = player:GetUEController()
  ctrl:SetUICameraState(MainUIModuleEnum.MainUICameraState.PlayerInfo)
end

function UMG_LevelMain_C:InfoPlayIn()
  self.UMG_LevelInformation:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.UMG_LevelInformation:PlayAnimation(self.UMG_LevelInformation.In)
  local num = self.UMG_LevelInformation.LevelTipsList:GetItemCount()
  for i = 1, num do
    local item = self.UMG_LevelInformation.LevelTipsList:GetItemByIndex(i - 1)
    self:DelaySeconds(0.05 * i, function()
      item:SetVisibility(UE.ESlateVisibility.Visible)
      item:PlayAnimation(item.list_in)
    end)
  end
end

function UMG_LevelMain_C:RewardsPlayIn()
  self.UMG_LevelUpRewards:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.UMG_LevelUpRewards:PlayAnimation(self.UMG_LevelUpRewards.In)
  self.UMG_LevelUpRewards.CanAnimTick = true
  self.UMG_LevelUpRewards.DeltaTime = 0
  local num = self.UMG_LevelUpRewards.LevelTipsList:GetItemCount()
  for i = 1, num do
    local item = self.UMG_LevelUpRewards.LevelTipsList:GetItemByIndex(i - 1)
    self:DelaySeconds(0.05 * i, function()
      item:SetVisibility(UE.ESlateVisibility.Visible)
      item:PlayAnimation(item.List_in)
    end)
  end
  local num1 = self.UMG_LevelUpRewards.awardListScroll:GetItemCount()
  for i = 1, num1 do
    local item = self.UMG_LevelUpRewards.awardListScroll:GetItemByIndex(i - 1)
    item:SetVisibility(UE.ESlateVisibility.Visible)
    item:PlayAnimation(item.In)
  end
end

function UMG_LevelMain_C:UpdatePlayerHead()
  self.UMG_LevelInformation:SetPlayerHead()
end

function UMG_LevelMain_C:UpdatePlayerName()
  self.UMG_LevelInformation:SetPlayerName()
end

function UMG_LevelMain_C:refreshRewardsPanel(_param)
  self.UMG_LevelUpRewards:refreshRewardsPanel(_param.levelListInfo)
end

function UMG_LevelMain_C:OnAddEventListener()
  self:AddButtonListener(self.FriendEntry.btnLevelUp, self.OnFriendIconClicked)
  self:AddButtonListener(self.SystemShopEntry.btnLevelUp, self.OnSystemShopIconClicked)
  self:AddButtonListener(self.EmailEntry.btnLevelUp, self.OnEmailIconClicked)
  self:AddButtonListener(self.SystemEntry.btnLevelUp, self.OnSystemIconClicked)
  self:AddButtonListener(self.TeachManual.btnLevelUp, self.OnTeachManualClicked)
  self:RegisterEvent(self, LevelUpUIModuleEvent.LEVELUP_REFRESH_REWARDS_PANEL, self.refreshRewardsPanel)
  self:RegisterEvent(self, LevelUpUIModuleEvent.LEVELUP_OPEN_CARD_SET_LOCK, self.SetIsLock)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, PlayerDataEvent.UPDATE_DATA, self.RefreshIcons)
  _G.NRCEventCenter:RegisterEvent("UMG_LevelMain_C", self, MainUIModuleEvent.BackToWorldFast, self.OnFastClose)
end

function UMG_LevelMain_C:OnFriendIconClicked()
  if self.Lock then
    return
  end
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_FRIEND)
  if isBan then
    return
  end
  self:SetIsLock(true)
  self.OpenFriend = true
  _G.NRCAudioManager:PlaySound2DAuto(1324, "UMG_LevelMain_C:OnFriendIconClicked")
  self:StopAnimation(self.Loop)
  self:PlayAnimation(self.Out)
end

function UMG_LevelMain_C:OnSystemShopIconClicked()
  if self.Lock then
    return
  end
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_CHARGE)
  if isBan then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(1003, "UMG_LevelMain_C:OnSystemShopIconClicked")
  self:SetIsLock(true)
  self.OpenSystemShop = true
  self:StopAnimation(self.Loop)
  self:PlayAnimation(self.Out)
end

function UMG_LevelMain_C:OnEmailIconClicked()
  if self.Lock then
    return
  end
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_MAIL)
  if isBan then
    return
  end
  self:SetIsLock(true)
  self.OpenEmail = true
  self:StopAnimation(self.Loop)
  self:PlayAnimation(self.Out)
end

function UMG_LevelMain_C:OnSystemIconClicked()
  if self.Lock then
    return
  end
  self:SetIsLock(true)
  self.OpenSet = true
  self:StopAnimation(self.Loop)
  self:PlayAnimation(self.Out)
end

function UMG_LevelMain_C:OnTeachManualClicked()
  if self.Lock then
    return
  end
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_GUIDE)
  if isBan then
    return
  end
  self:SetIsLock(true)
  self.OpenTeachManual = true
  self:StopAnimation(self.Loop)
  self:PlayAnimation(self.Out)
end

function UMG_LevelMain_C:SetIsLock(Lock)
  self.Lock = Lock
  self.UMG_LevelInformation:SetLockInfo(Lock)
end

function UMG_LevelMain_C:RefreshIcons()
  local hide = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionHide, _G.Enum.FunctionEntrance.FE_FRIEND)
  self.CanvasPanel_81:SetVisibility(hide and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  hide = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionHide, _G.Enum.FunctionEntrance.FE_CHARGE)
  self.CanvasPanel_129:SetVisibility(hide and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  hide = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionHide, _G.Enum.FunctionEntrance.FE_MAIL)
  self.CanvasPanel_189:SetVisibility(hide and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  hide = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionHide, _G.Enum.FunctionEntrance.FE_GUIDE)
  self.CanvasPanel_259:SetVisibility(hide and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_LevelMain_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, LevelUpUIModuleEvent.LEVELUP_REFRESH_REWARDS_PANEL)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, PlayerDataEvent.UPDATE_DATA, self.RefreshIcons)
  _G.NRCEventCenter:UnRegisterEvent(self, MainUIModuleEvent.BackToWorldFast, self.OnFastClose)
end

function UMG_LevelMain_C:OnFastClose()
  self:DoClose()
end

function UMG_LevelMain_C:ChangeLevelListSelected(index)
  self.UMG_LevelUpRewards:ChangeLevelListSelected(index)
end

function UMG_LevelMain_C:FadeOut()
  self:StopAnimation(self.Loop)
  self:PlayAnimation(self.Out)
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local ctrl = player:GetUEController()
  ctrl:SetUICameraState(MainUIModuleEnum.MainUICameraState.Normal)
  _G.NRCEventCenter:DispatchEvent(MainUIModuleEvent.OnMainUILuopanChanged, MainUIModuleEnum.MainUILuopanState.Idle, MainUIModuleEnum.MainUILuopanIdleState.NormalIdle)
  _G.NRCEventCenter:DispatchEvent(MainUIModuleEvent.OnMainUISubPanelClosed, true)
  self.isPlayingAnimation = true
end

function UMG_LevelMain_C:OnAnimationFinished(Animation)
  if Animation == self.Out then
    self:SetIsLock(false)
    self.UMG_LevelUpRewards.CanAnimTick = false
    self.UMG_LevelUpRewards.DeltaTime = 0
    if self.OpenSystemShop then
      _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OpenMainPanel)
      self.OpenSystemShop = false
      return
    elseif self.OpenFriend then
      _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OpenMainPanel)
      self.OpenFriend = false
      return
    elseif self.OpenEmail then
      NRCProfilerLog:NRCClickBtn(true, "EmailMainPanel")
      _G.NRCModuleManager:DoCmd(_G.EmailModuleCmd.OpenMainPanel)
      self.OpenEmail = false
      return
    elseif self.OpenSet then
      _G.NRCAudioManager:PlaySound2DAuto(1003, "UMG_LevelMain_C:OnSystemIconClicked")
      _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.OpenMainPanel)
      self.OpenSet = false
      return
    elseif self.OpenTeachManual then
      _G.NRCAudioManager:PlaySound2DAuto(1003, "UMG_LevelMain_C:OnSystemIconClicked")
      _G.NRCModeManager:DoCmd(TeachingManualModuleCmd.OpenMainPanel)
      self.OpenTeachManual = false
      return
    end
    self:DoClose()
  elseif Animation == self.In then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
    Log.Debug("\233\161\181\233\157\162\230\137\147\229\188\128\229\187\182\232\191\159\233\151\174\233\162\152Log:\230\183\161\229\133\165\229\138\168\231\148\187\231\187\147\230\157\159\228\186\134!", UE4Helper.GetTime())
    if self.IsOpenIn then
      self.UMG_LevelInformation:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      self.UMG_LevelInformation:PlayAnimation(self.UMG_LevelInformation.In)
      local num = self.UMG_LevelInformation.LevelTipsList:GetItemCount()
      for i = 1, num do
        local item = self.UMG_LevelInformation.LevelTipsList:GetItemByIndex(i - 1)
        self:DelaySeconds(0.05 * i, function()
          item:SetVisibility(UE.ESlateVisibility.Visible)
          item:PlayAnimation(item.list_in)
        end)
      end
      self.IsOpenIn = false
    else
      self.UMG_LevelUpRewards.CanAnimTick = true
    end
    self:PlayAnimation(self.Loop)
  end
end

return UMG_LevelMain_C
