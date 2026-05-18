local UMG_UnlockInvitation_PopUp_C = _G.NRCPanelBase:Extend("UMG_UnlockInvitation_PopUp_C")

function UMG_UnlockInvitation_PopUp_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
end

function UMG_UnlockInvitation_PopUp_C:OnActive(PopUpData)
  self.PopUpData = PopUpData
  self:UpdatePopUp()
  self:UpdateCoinUI()
  self:PlayAnimation(self.In)
end

function UMG_UnlockInvitation_PopUp_C:UpdateCoinUI()
  local vItemType = self.PopUpData and self.PopUpData.isEgg and _G.ProtoEnum.VisualItem.VI_BRAVE_STAR or _G.ProtoEnum.VisualItem.VI_DIAMOND
  local coin_num = _G.DataModelMgr.PlayerDataModel:GetVItemCount(vItemType) or 0
  local moneyInfo = {}
  table.insert(moneyInfo, {
    moneyType = vItemType,
    sum = coin_num,
    IsShowBuyIcon = false
  })
  self.MoneyBtn:InitGridView(moneyInfo)
  local Path = _G.DataConfigManager:GetVisualItemConf(vItemType).iconPath
  self.Icon:SetPath(Path)
end

function UMG_UnlockInvitation_PopUp_C:OnAddEventListener()
end

function UMG_UnlockInvitation_PopUp_C:UpdatePopUp()
  if self.PopUpData then
    if self.PopUpData.UnLockText then
      self.text_1:SetText(self.PopUpData.UnLockText)
    end
    if self.PopUpData.CostNum then
      self.QuantityText:SetText(self.PopUpData.CostNum)
    end
    local CommonPopUpData = _G.NRCCommonPopUpData()
    CommonPopUpData.Call = self
    CommonPopUpData.Btn_LeftHandler = self.OnCloseClick
    CommonPopUpData.ClosePanelHandler = self.OnCloseClick
    CommonPopUpData.Btn_RightHandler = self.OnReqUnlockRelationNode
    CommonPopUpData.Btn_RightText = LuaText.YES
    CommonPopUpData.Btn_LeftText = LuaText.NO
    if self.PopUpData.isEgg then
      CommonPopUpData.TitleText = LuaText.interactiontree_cifu_req_check_title_self
      self.NRCText_48:SetText(LuaText.interactiontree_cifu_check_tip_2)
    else
      self.NRCText_48:SetText(LuaText.relationtree_unlock_success_cost)
    end
    if self.PopUpData.IsLocal then
      self.text_1:SetText(LuaText.interactiontree_cifu_req_check_self)
    end
    self.PopUp3:SetPanelInfo(CommonPopUpData)
  end
end

function UMG_UnlockInvitation_PopUp_C:OnReqUnlockRelationNode()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_UnlockInvitation_PopUp_C:OnReqUnlockRelationNode")
  if self.PopUpData then
    if self.PopUpData.isEgg then
      local TempPopUpData = self.PopUpData
      local data = self.PopUpData.Data
      _G.NRCModuleManager:DoCmd(_G.RelationTreeCmd.ApplyBlessingEgg, data.targetUin, data.petId, data.petNpcId, data.eggGid, data.bagitemId)
      _G.NRCModuleManager:DoCmd(_G.RelationTreeCmd.CloseRelationEggBag)
      _G.NRCModuleManager:DoCmd(_G.RelationTreeCmd.CloseUnlockInvitationPopup)
    else
      local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
      if player then
        local InviteComponent = player:EnsureComponent(require("NewRoco.Modules.Core.Scene.Component.RolePlay.InviteComponent"))
        if InviteComponent and not InviteComponent:IsCanOverrideInteract(ProtoEnum.InteractInviteType.IIT_DOUBLE_ACTION, InviteComponent._interactType) then
          local Text = LuaText.relationtree_performing_request_tip
          if Text then
            _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, Text)
          end
          return
        end
      end
      _G.NRCModeManager:DoCmd(_G.RelationTreeCmd.UnlockRelationShipNodeReq, self.PopUpData.PlayerUin, self.PopUpData.RelationTreeType)
      _G.NRCModeManager:DoCmd(_G.RelationTreeCmd.CloseUnlockInvitationPopup)
    end
  end
end

function UMG_UnlockInvitation_PopUp_C:OnCloseClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_UnlockInvitation_PopUp_C:OnCloseClick")
  self:StopAnimation(self.Loop)
  self:PlayAnimation(self.Out)
  if self.PopUpData and self.PopUpData.isEgg then
  else
    _G.NRCModeManager:DoCmd(RelationTreeCmd.SelectItemChange)
  end
end

function UMG_UnlockInvitation_PopUp_C:OnAnimationFinished(anim)
  if anim == self.In then
    self:PlayAnimation(self.Loop, 0, 0)
  elseif anim == self.Out then
    _G.NRCModeManager:DoCmd(_G.RelationTreeCmd.CloseUnlockInvitationPopup)
  end
end

function UMG_UnlockInvitation_PopUp_C:OnDeactive()
end

function UMG_UnlockInvitation_PopUp_C:OnPcClose()
  self:OnCloseClick()
end

return UMG_UnlockInvitation_PopUp_C
