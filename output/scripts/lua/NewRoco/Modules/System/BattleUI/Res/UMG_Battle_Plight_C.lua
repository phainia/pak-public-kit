local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local TeleportComponent = require("NewRoco.Modules.Core.Scene.Component.RoleHP.TeleportComponent")
local UMG_Battle_Plight_C = _G.NRCPanelBase:Extend("UMG_Battle_Plight_C")

function UMG_Battle_Plight_C:OnConstruct()
end

function UMG_Battle_Plight_C:OnDestruct()
end

function UMG_Battle_Plight_C:OnActive(callBack, caller)
  self.TeleportComponent = TeleportComponent()
  self.CallBack = callBack
  self.Caller = caller
  self:PlayAnimation(self.Open)
  self:OnAddEventListener()
end

function UMG_Battle_Plight_C:OnDeactive()
end

function UMG_Battle_Plight_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_Surrender.btnLevelUp, self.OnSurrender)
  self:AddButtonListener(self.Btn_Return.btnLevelUp, self.OnBtn_Return)
end

function UMG_Battle_Plight_C:OnSurrender()
  self:PlayAnimation(self.close)
  if self.CallBack then
    self.CallBack(self.Caller, true)
    self.CallBack = nil
    self.Caller = nil
  else
    _G.BattleEventCenter:Dispatch(BattleEvent.ON_CLICK_ESCAPE, true)
  end
end

function UMG_Battle_Plight_C:OnBtn_Return()
  self:PlayAnimation(self.close)
  if self.CallBack then
    self.CallBack(self.Caller, false)
    self.CallBack = nil
    self.Caller = nil
  else
    _G.BattleEventCenter:Dispatch(BattleEvent.ON_CLICK_ESCAPE, false)
  end
end

function UMG_Battle_Plight_C:OnAnimationFinished(Animation)
  if Animation == self.close then
    self:DoClose()
  end
end

return UMG_Battle_Plight_C
