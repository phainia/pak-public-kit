local BattleUIModuleCmd = reload("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local UMG_Common_Warning_C = _G.NRCPanelBase:Extend("UMG_Common_Warning_C")

function UMG_Common_Warning_C:OnActive(data)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1291, "UMG_Common_Warning_C:OnActive")
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  self:PlayAnimation(self.open)
  self:OnAddEventListener()
  self.uiData = data
  self:UpdatePanelInfo(data)
end

function UMG_Common_Warning_C:OnDeactive()
end

function UMG_Common_Warning_C:OnAddEventListener()
  self:AddButtonListener(self.LeftBtn.btnLevelUp, self.OnLeftBtnClicked)
  self:AddButtonListener(self.RightBtn.btnLevelUp, self.OnRightBtnClicked)
end

function UMG_Common_Warning_C:UpdatePanelInfo(data)
  self.Title:SetText(data.tipText)
  self.LeftBtn:SetBtnText(data.leftBtnText)
  self.RightBtn:SetBtnText(data.rightBtnText)
end

function UMG_Common_Warning_C:OnLeftBtnClicked()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1006, "UMG_Common_Warning_C:OnRightBtnClicked")
  self:PlayAnimation(self.close)
end

function UMG_Common_Warning_C:OnRightBtnClicked()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_Common_Warning_C:OnRightBtnClicked")
  if 0 == self.uiData.PVPShowType then
    _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.StartMatchByType, false)
  else
    _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.StartMatchByType, true)
  end
  self:PlayAnimation(self.close)
end

function UMG_Common_Warning_C:OnAnimationFinished(anim)
  if anim == self.close then
    self:DoClose()
  elseif anim == self.open then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
  end
end

return UMG_Common_Warning_C
