local UMG_RelationTree_Tips_C = _G.NRCPanelBase:Extend("UMG_RelationTree_Tips_C")
local RLTT_RECOVER = 100001

function UMG_RelationTree_Tips_C:OnActive(RelationItem)
  self.RelationItem = RelationItem
  self:OnAddEventListener()
  self:UpdateUI()
end

function UMG_RelationTree_Tips_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseTips, self.OnCloseClick)
end

function UMG_RelationTree_Tips_C:UpdateUI()
  if self.RelationItem then
    if self.RelationItem.StateStruct and self.RelationItem.StateStruct[1] then
      local iconPath = self.RelationItem.StateStruct[1].icon
      if iconPath and "" ~= iconPath then
        self.BloodPulse:SetPath(iconPath)
      end
      self.Text_Title:SetText(self.RelationItem.StateStruct[1].name)
    end
    local ChangeText = ""
    local Text_State = ""
    if self.RelationItem.RelationTreeType == RLTT_RECOVER then
      ChangeText = _G.DataConfigManager:GetLocalizationConf("relationtree_tietie_explain").msg or ""
      Text_State = _G.DataConfigManager:GetLocalizationConf("relationtree_tietie_subname").msg or ""
    elseif self.RelationItem.RelationTreeType == Enum.RelationTreeType.RLTT_SHAREPET then
      ChangeText = _G.DataConfigManager:GetLocalizationConf("relationtree_sharepet_text_describe").msg or ""
      Text_State = _G.DataConfigManager:GetLocalizationConf("relationtree_sharepet_text_state").msg or ""
    end
    self.Text_State:SetText(Text_State)
    self.ChangeText:SetText(ChangeText)
  end
end

function UMG_RelationTree_Tips_C:OnCloseClick()
  self:PlayAnimation(self.Disappear)
end

function UMG_RelationTree_Tips_C:OnAnimationFinished(anim)
  if anim == self.Disappear then
    _G.NRCModeManager:DoCmd(_G.RelationTreeCmd.CloseRelationTreeTipsPanel)
  end
end

function UMG_RelationTree_Tips_C:OnDeactive()
end

return UMG_RelationTree_Tips_C
