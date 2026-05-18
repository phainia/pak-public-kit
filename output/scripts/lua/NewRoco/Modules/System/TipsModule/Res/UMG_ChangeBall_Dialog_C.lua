local UMG_ChangeBall_Dialog_C = _G.NRCPanelBase:Extend("UMG_ChangeBall_Dialog_C")

function UMG_ChangeBall_Dialog_C:OnConstruct()
  self:SetChildViews(self.PopUp4)
end

function UMG_ChangeBall_Dialog_C:OnDestruct()
end

function UMG_ChangeBall_Dialog_C:OnActive(equipBallList)
  self:OnAddEventListener()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1004, "UMG_ChangeBall_Dialog_C:OnActive")
  local tipText = _G.DataConfigManager:GetLocalizationConf("Equipped_Ball_Exchange").msg
  self:SetCommonPopUpInfo(self.PopUp4, tipText)
  if equipBallList then
    for k, v in ipairs(equipBallList) do
      v.FromBag = false
    end
    table.sort(equipBallList, function(a, b)
      local aIdx = a and _G.NRCModeManager:DoCmd(_G.BagModuleCmd.GetBagItemEquipIndexByGid, a.gid) or 0
      local bIdx = b and _G.NRCModeManager:DoCmd(_G.BagModuleCmd.GetBagItemEquipIndexByGid, b.gid) or 0
      return aIdx < bIdx
    end)
    self.equipBallList = equipBallList
    local AllText = _G.DataConfigManager:GetLocalizationConf("UMG_ChangeBall_Dialog1").msg
    self.PopUp4:SetDescInfo(AllText)
    self.BallList:InitGridView(equipBallList)
    for j, equipBall in ipairs(self.equipBallList) do
      local item = self.BallList:GetItemByIndex(j - 1)
      item:SetParentPanel(self)
    end
    self:LoadAnimation(0)
  end
end

function UMG_ChangeBall_Dialog_C:OnDeactive()
end

function UMG_ChangeBall_Dialog_C:ItemSelect(index)
  local AllText = string.format(_G.DataConfigManager:GetLocalizationConf("UMG_ChangeBall_Dialog2").msg, tostring(index))
  self.PopUp4:SetDescInfo(AllText)
end

function UMG_ChangeBall_Dialog_C:OnAddEventListener()
end

function UMG_ChangeBall_Dialog_C:OnOKBtnClicked()
  local isChange = _G.NRCModuleManager:DoCmd(BagModuleCmd.ChangeBall)
  if isChange then
    self:OnCancelBtnClicked()
  end
end

function UMG_ChangeBall_Dialog_C:SetCommonPopUpInfo(PopUp, TitleText)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnCancelBtnClicked
  CommonPopUpData.Btn_RightHandler = self.OnOKBtnClicked
  CommonPopUpData.ClosePanelHandler = self.OnCancelBtnClicked
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_ChangeBall_Dialog_C:OnCancelBtnClicked()
  self:UpdateBallList()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1008, "UMG_ChangeBall_Dialog_C:OnCancelBtnClicked")
  _G.NRCModuleManager:DoCmd(BagModuleCmd.SetSelectedItem, nil, 1)
  self:LoadAnimation(2)
end

function UMG_ChangeBall_Dialog_C:UpdateBallList()
  _G.NRCModuleManager:DoCmd(BagModuleCmd.SetBagItemArrayFromBagInfo, self.equipBallList)
  if self.equipBallList then
    for j, equipBall in ipairs(self.equipBallList) do
      local item = self.BallList:GetItemByIndex(j - 1)
      item:UpdateFromBag()
    end
  end
end

function UMG_ChangeBall_Dialog_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_ChangeBall_Dialog_C
