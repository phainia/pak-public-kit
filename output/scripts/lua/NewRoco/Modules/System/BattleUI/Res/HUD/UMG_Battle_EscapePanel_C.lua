local UMG_Battle_EscapePanel_C = _G.NRCPanelBase:Extend("UMG_Battle_EscapePanel_C")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
UMG_Battle_EscapePanel_C.ContextData = nil

function UMG_Battle_EscapePanel_C:OnConstruct()
end

function UMG_Battle_EscapePanel_C:OnDestruct()
end

function UMG_Battle_EscapePanel_C:OnActive(contextData)
  if contextData.runAwayInfo then
    self.RunAwayInfoText:SetText(contextData.runAwayInfo)
  else
    Log.Warning("EscapePanel not get info text")
  end
  self:AddButtonListener(self.btnClose, self.OnBtnCloseClick)
end

function UMG_Battle_EscapePanel_C:OnBtnCloseClick()
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.CloseEscapePanel)
end

function UMG_Battle_EscapePanel_C:OnDeactive()
end

return UMG_Battle_EscapePanel_C
