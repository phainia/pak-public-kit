local UMG_GivePetAway_Tips_C = _G.NRCPanelBase:Extend("UMG_GivePetAway_Tips_C")

function UMG_GivePetAway_Tips_C:OnConstruct()
  self:OnAddEventListener()
  self:SetChildViews(self.PopUp)
end

function UMG_GivePetAway_Tips_C:OnDestruct()
end

function UMG_GivePetAway_Tips_C:OnActive(PetData, action)
  self.PetData = PetData
  self.action = action
  self:SetPanelInfo()
  self:LoadAnimation(0)
end

function UMG_GivePetAway_Tips_C:SetPanelInfo()
  local LocalizationConf = _G.DataConfigManager:GetLocalizationConf("act_submit_pet_1").msg
  self.NRCText_86:SetText(string.format(LocalizationConf, self.PetData.name))
  self:SetCommonPopUpInfo(self.PopUp)
end

function UMG_GivePetAway_Tips_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.OnClickCancel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_GivePetAway_Tips_C:OnClickConfirm()
  Log.Warning("\230\143\144\228\186\164\230\138\128\232\131\189\230\154\130\230\151\182\230\178\161\230\156\137,\229\133\136\229\144\140\230\151\182\229\133\179\233\151\173\231\149\140\233\157\162\229\146\140\232\176\131\231\148\168\229\174\140\230\136\144action")
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_GivePetAway_Tips_C:OnClickConfirm")
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer.inputComponent:SetInputEnable(self, true)
  local petData = self.PetData
  if petData then
    local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
    if #battlePetList <= 1 then
      if battlePetList[1].gid == petData.gid then
        local tipTxt = LuaText.umg_petaltar_4
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tipTxt)
      elseif petData.canCommit then
        if self.action then
          self.action:GiveFinish(petData)
          self.action = nil
        end
        _G.NRCModuleManager:DoCmd(AltarModuleCmd.ClosePetAltarPanel)
        _G.NRCModuleManager:DoCmd(AltarModuleCmd.CloseGivePetAwayTips)
      else
        local tipTxt = LuaText.umg_petaltar_5
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tipTxt)
      end
    elseif petData.canCommit then
      if self.action then
        self.action:GiveFinish(petData)
        self.action = nil
      end
      _G.NRCModuleManager:DoCmd(AltarModuleCmd.ClosePetAltarPanel)
      _G.NRCModuleManager:DoCmd(AltarModuleCmd.CloseGivePetAwayTips)
    else
      local tipTxt = LuaText.umg_petaltar_5
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tipTxt)
    end
  else
    local tipTxt = _G.DataConfigManager:GetLocalizationConf("Client_Error_0001")
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tipTxt.msg)
  end
end

function UMG_GivePetAway_Tips_C:OnClickCancel()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_GivePetAway_Tips_C:OnClickCancel")
  self:LoadAnimation(2)
end

function UMG_GivePetAway_Tips_C:OnDeactive()
  self.action = nil
end

function UMG_GivePetAway_Tips_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_Cancel.btnLevelUp, self.OnClickCancel)
  self:AddButtonListener(self.Btn_Confirm.btnLevelUp, self.OnClickConfirm)
end

function UMG_GivePetAway_Tips_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  elseif anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_GivePetAway_Tips_C
