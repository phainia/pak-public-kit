local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local UMG_RocoStartup_C = _G.NRCPanelBase:Extend("UMG_RocoStartup_C")

function UMG_RocoStartup_C:OnConstruct()
  _G.NRCEventCenter:RegisterEvent("UMG_RocoStartup_C", self, DialogueModuleEvent.DialogueEnded, self.OnDialogueEnded)
end

function UMG_RocoStartup_C:OnActive(Action)
  self:PlayAnimation(self.In)
  self.Action = Action
  self.NRCButton_0.OnPressed:Add(self, self.OnPressed)
  self.NRCButton_0.OnReleased:Add(self, self.OnReleased)
  self:PlayAnimation(self.Normal, 0, 10000)
end

function UMG_RocoStartup_C:OnDestruct()
  self.NRCButton_0.OnPressed:Remove(self, self.OnPressed)
  self.NRCButton_0.OnReleased:Remove(self, self.OnReleased)
  _G.NRCPanelBase.OnDestruct(self)
end

function UMG_RocoStartup_C:OnPressed(MyGeometry, InTouchEvent)
  self:PlayAnimation(self.Press)
  if self.Action then
    self.Action:PlayStartSkill()
  end
end

function UMG_RocoStartup_C:OnReleased()
  self:StopAnimation(self.Press)
  self:PlayAnimation(self.Up)
  if self.Action then
    self.Action:StopStartSkill()
  end
end

function UMG_RocoStartup_C:OnAnimationFinished(Animation)
  if Animation == self.Out then
    _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.CloseStartupPanel)
  end
end

function UMG_RocoStartup_C:OnDialogueEnded()
  if self.Action then
    self.Action:Finish(false, nil)
  end
  self:DoClose()
end

return UMG_RocoStartup_C
