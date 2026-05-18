local DebugModuleEvent = reload("NewRoco.Modules.System.Debug.DebugModuleEvent")
local UMG_DebugButton_C = _G.NRCViewBase:Extend("UMG_DebugButton_C")

function UMG_DebugButton_C:Construct()
  NRCViewBase.Construct(self)
  self:AddButtonListener(self.Button, self.OnClick)
end

function UMG_DebugButton_C:Destruct()
  self:RemoveButtonListener(self.Button)
  self.ButtonName = ""
  self.CallbackOwner = nil
  self.Callback = nil
  self.Overridden.Destruct(self)
end

function UMG_DebugButton_C:OnClick()
  if self.Callback then
    self.Callback(self.CallbackOwner, self.ButtonName, self.Panel)
  end
  if self.ButtonName == "\229\142\134\229\143\178" then
    NRCModuleManager:DoCmd(_G.DebugModuleCmd.RefreshHistory)
  end
end

function UMG_DebugButton_C:Refresh(name, callback, owner)
  self.ButtonName = name
  self.Caption:SetText(name or "None")
  self.Callback = callback
  self.CallbackOwner = owner
end

return UMG_DebugButton_C
