local Super = require("NewRoco/Modules/System/MainUI/Res/Controller/UMG_Control_Joystick_C")
local UMG_Control_Joystick_Home_C = Super:Extend("UMG_Control_Joystick_Home_C")

function UMG_Control_Joystick_Home_C:OnBeforeOpen()
  local Offset = self.JoystickOffset
  self.Joystick.Slot:SetPosition(self.Joystick.Slot:GetPosition() + Offset)
  self.JoystickSmall.Slot:SetPosition(self.JoystickSmall.Slot:GetPosition() + Offset)
  self.oriThumbPos = self.JoystickThumb.Slot:GetPosition()
  self.oriJoystickPos = self.Joystick.Slot:GetPosition()
  self.isJoystickThumbNoMoveShow = false
  self:SetShow(false)
  if self:IsPCMode() then
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

return UMG_Control_Joystick_Home_C
