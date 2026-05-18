local UMG_ComplimentaryPetEggs_C = _G.NRCPanelBase:Extend("UMG_ComplimentaryPetEggs_C")

function UMG_ComplimentaryPetEggs_C:OnConstruct()
  self:SetChildViews(self.PopUp4)
end

function UMG_ComplimentaryPetEggs_C:OnActive(popupData)
  self:LoadAnimation(0)
  if not popupData then
    Log.Error("on UMG_ComplimentaryPetEggs_C:OnActive(popupData) : popupData is null")
    return
  end
  self.popupData = popupData
  self:SetCommonPopUpInfo(self.PopUp4, LuaText.RLTT_Giftegg_text_limit)
  self.ContentText:SetText(popupData.text)
  if self.popupData.petEggId then
    local item = {}
    item.itemId = self.popupData.petEggId
    item.itemType = _G.Enum.GoodsType.GT_BAGITEM
    item.ConsumeNum = 1
    self.List:InitGridView({item})
  end
end

function UMG_ComplimentaryPetEggs_C:SetCommonPopUpInfo(PopUp, Desc)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if Desc then
    CommonPopUpData.Desc = Desc
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnClose
  CommonPopUpData.Btn_RightHandler = self.OnBtnRightClicked
  CommonPopUpData.ClosePanelHandler = self.OnClose
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_ComplimentaryPetEggs_C:OnClose()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_ComplimentaryPetEggs_C:OnClose")
  self:LoadAnimation(2)
end

function UMG_ComplimentaryPetEggs_C:OnBtnRightClicked()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_ComplimentaryPetEggs_C:OnBtnRightClicked")
  if self.popupData then
    local param = _G.ProtoMessage:newInteractParam()
    param.picked_egg_gid = self.popupData.eggGid
    param.picked_bagitem_conf_id = self.popupData.petEggId
    param.action_id = self.popupData.actionId
    _G.NRCModuleManager:DoCmd(_G.RelationTreeCmd.OnGivePetEggStar, self.popupData.targetUin, ProtoEnum.InteractInviteType.IIT_GIFTING_EGG, param)
    _G.NRCModuleManager:DoCmd(_G.RelationTreeCmd.CloseRelationEggBag)
    self:OnClose()
  end
end

function UMG_ComplimentaryPetEggs_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_ComplimentaryPetEggs_C
