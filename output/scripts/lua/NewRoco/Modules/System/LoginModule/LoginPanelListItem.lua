local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local LoginPanelListItem = NRCClass()

function LoginPanelListItem:Ctor()
  Log.Debug("LoginPanelListItem Ctor")
  self.data = NRCModuleManager:GetModule("LoginModule"):GetData("LoginData")
end

function LoginPanelListItem:SetData(data)
  self.Display:SetText(data.key)
  self.data = data
  self.parent = self.data.parent
  self.Selected:SetVisibility(self.data.selectedServer == self.data and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Hidden)
end

function LoginPanelListItem:OnClick()
  NRCModuleManager:GetModule("LoginModule"):DispatchEvent(LoginModuleEvent.ItemClick, self.data)
end

function LoginPanelListItem:OnItemSelected(selected)
  self.Selected:SetVisibility(selected and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Hidden)
end

return LoginPanelListItem
