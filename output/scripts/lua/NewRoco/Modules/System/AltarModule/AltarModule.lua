local PlayerTip = false
local AltarModule = NRCModuleBase:Extend("AltarModule")

function AltarModule:OnConstruct()
  _G.AltarModuleCmd = reload("NewRoco.Modules.System.AltarModule.AltarModuleCmd")
  self.data = self:SetData("AltarModuleData", "NewRoco.Modules.System.AltarModule.AltarModuleData")
end

function AltarModule:OnActive()
  Log.Debug("AltarModule:OnActive")
  self:RegPanel("PetAltarPanel", "UMG_PetAltar", _G.Enum.UILayerType.UI_LAYER_FULLSCREEN)
  self:RegPanel("ItemAltarPanel", "UMG_ItemAltar", _G.Enum.UILayerType.UI_LAYER_FULLSCREEN)
  self:RegPanel("GivePetAway_Tips", "UMG_GivePetAway_Tips", _G.Enum.UILayerType.UI_LAYER_POPUP)
  self:RegPanel("ItemAltarPanelFree", "UMG_ItemAltarFree", _G.Enum.UILayerType.UI_LAYER_FULLSCREEN)
end

function AltarModule:OpenPetAltarPanel(action)
  self:Log("AltarModule:OpenPetAltarPanel")
  if not self:HasPanel("PetAltarPanel") then
    self:OpenPanel("PetAltarPanel", action)
  else
    Log.Warning("\229\183\178\231\187\143\229\173\152\229\156\168PetAltarPanel")
  end
end

function AltarModule:ClosePetAltarPanel()
  self:Log("AltarModule:ClosePetAltarPanel")
  if self:HasPanel("PetAltarPanel") then
    self:ClosePanel("PetAltarPanel")
  end
end

function AltarModule:OpenItemAltarPanel(action)
  self:Log("AltarModule:OpenItemAltarPanel")
  if not self:HasPanel("ItemAltarPanel") then
    self:OpenPanel("ItemAltarPanel", action)
  end
end

function AltarModule:CloseItemAltarPanel()
  self:Log("AltarModule:CloseItemAltarPanel")
  if self:HasPanel("ItemAltarPanel") then
    self:ClosePanel("ItemAltarPanel")
  end
end

function AltarModule:OpenItemAltarPanelFree(action)
  self:Log("AltarModule:OpenItemAltarPanelFree")
  if not self:HasPanel("ItemAltarPanelFree") then
    self:OpenPanel("ItemAltarPanelFree", action)
  end
end

function AltarModule:CloseItemAltarPanelFree()
  self:Log("AltarModule:CloseItemAltarPanelFree")
  if self:HasPanel("ItemAltarPanelFree") then
    self:ClosePanel("ItemAltarPanelFree")
  end
end

function AltarModule:OnCmdOpenGivePetAwayTips(PetData, action)
  self:Log("AltarModule:OnCmdOpenGivePetAwayTips")
  if not self:HasPanel("GivePetAway_Tips") then
    self:OpenPanel("GivePetAway_Tips", PetData, action)
  else
    Log.Warning("\229\183\178\231\187\143\229\173\152\229\156\168GivePetAway_Tips")
  end
end

function AltarModule:OnCmdCloseGivePetAwayTips()
  self:Log("AltarModule:OnCmdCloseGivePetAwayTips")
  if self:HasPanel("GivePetAway_Tips") then
    self:ClosePanel("GivePetAway_Tips")
  end
end

function AltarModule:OnRelogin()
end

function AltarModule:OnDeactive()
end

function AltarModule:OnDestruct()
end

function AltarModule:RegPanel(name, path, layer, openAnimName, closeAnimName)
  local registerData = _G.NRCPanelRegisterData()
  registerData.panelName = name
  registerData.panelPath = string.format("/Game/NewRoco/Modules/System/Altar/Res/%s", path)
  registerData.panelLayer = layer
  registerData.customDisableRendering = true
  if openAnimName then
    registerData.openAnimName = openAnimName
  end
  if closeAnimName then
    registerData.closeAnimName = closeAnimName
  end
  self:RegisterPanel(registerData)
end

return AltarModule
