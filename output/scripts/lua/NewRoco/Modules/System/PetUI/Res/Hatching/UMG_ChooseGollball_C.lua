local UMG_ChooseGollball_C = _G.NRCPanelBase:Extend("UMG_ChooseGollball_C")

function UMG_ChooseGollball_C:OnConstruct()
  self:SetChildViews(self.PopUp)
end

function UMG_ChooseGollball_C:OnActive(data, eggGid)
  self:SetCommonPopUpInfo()
  self.selectIndex = nil
  self._data = data
  self.curEggGid = eggGid
  self.PetBallScrollView:ClearSelection()
  self.PetBallScrollView:InitList(data)
  self.PetBallScrollView:SetItemSelectedCallback(self.OnPetBallSelected, self)
end

function UMG_ChooseGollball_C:OnAddEventListener()
end

function UMG_ChooseGollball_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnBtnCancelClick
  CommonPopUpData.Btn_RightHandler = self.OnBtnOkClick
  CommonPopUpData.ClosePanelHandler = self.OnBtnCancelClick
  self.PopUp:SetPanelInfo(CommonPopUpData)
  self.PopUp:SetBtnLeftText(LuaText.instancemodule_2)
  self.PopUp:SetBtnRightText(LuaText.instancemodule_1)
  self.PopUp:SetBtnRightGrayStateText(LuaText.instancemodule_1)
  self.PopUp:SetBtnRightEnableState(false)
  self.PopUp:SetDescInfo(LuaText.choose_ball_tips_1)
end

function UMG_ChooseGollball_C:OnBtnCancelClick()
  NRCModuleManager:DoCmd(PetUIModuleCmd.CloseChoosePetBallPanel)
end

function UMG_ChooseGollball_C:OnBtnOkClick()
  self:RequsetEstablishContract()
end

function UMG_ChooseGollball_C:RequsetEstablishContract()
  if self.curEggGid == nil then
    return
  end
  if nil == self.selectBallId then
    return
  end
  if nil == self.ballItemId then
    return
  end
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_HATCH_EGG, true)
  isBan = isBan or _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_HATCH_EGG_GET_BACK, true)
  if isBan then
    return
  end
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ZoneCrackEggReq, self.curEggGid, self.selectBallId, self.ballItemId)
end

function UMG_ChooseGollball_C:OnPetBallSelected(item, rawIndex, userClick)
  if nil == item then
    return
  end
  if nil == self._data then
    return
  end
  if nil == self._data[rawIndex + 1] then
    return
  end
  self.selectBallId = self._data[rawIndex + 1].gid
  self.ballItemId = self._data[rawIndex + 1].itemId
  self.selectIndex = rawIndex
  Log.Debug("UMG_ChooseGollball_C:OnPetBallSelected selectBallId=[", item.id, "]")
  self.PopUp:SetBtnRightEnableState(true)
  local petBallConf = _G.DataConfigManager:GetBallConf(self._data[rawIndex + 1].itemId)
  local ballType = petBallConf.ball_effect_type
  local ballName = string.format("<span color=\"#FF901DFF\">%s</>", petBallConf.editor_name)
  local DescBase = ""
  if ballType == _G.Enum.BallEffectType.BET_NORMAL then
    DescBase = LuaText.choose_ball_tips_2
  elseif ballType == _G.Enum.BallEffectType.BET_CHANGE_PET_ATTRIBUTE then
    DescBase = LuaText.choose_ball_tips_3
  end
  local Desc = string.format(DescBase, ballName)
  self.PopUp:SetDescInfo(Desc)
end

function UMG_ChooseGollball_C:OnDeactive()
end

function UMG_ChooseGollball_C:OnDestruct()
end

function UMG_ChooseGollball_C:OnAnimationFinished(anim)
end

return UMG_ChooseGollball_C
