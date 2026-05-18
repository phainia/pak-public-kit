local EnhancedInputModuleEvent = require("NewRoco.Modules.Core.EnhancedInput.EnhancedInputModuleEvent")
local UMG_Pet_VeryIntimate_C = _G.NRCPanelBase:Extend("UMG_Pet_VeryIntimate_C")

function UMG_Pet_VeryIntimate_C:OnConstruct()
  _G.NRCEventCenter:RegisterEvent("UMG_Pet_VeryIntimate_C", self, EnhancedInputModuleEvent.KeyMappingsChanged, self.PCKeySetting)
end

function UMG_Pet_VeryIntimate_C:OnDestruct()
end

function UMG_Pet_VeryIntimate_C:OnActive()
  self:PlayAnimation(self.In)
  self.option = nil
  self:OnAddEventListener()
  self.Button.OnClicked:Add(self, self.OnClicked)
  self:PCKeySetting()
  self:PlayAnimation(self.Loop, 0, 10000)
end

function UMG_Pet_VeryIntimate_C:OnDeactive()
end

function UMG_Pet_VeryIntimate_C:OnAddEventListener()
  self:AddButtonListener(self.Button, self.ExecuteOption)
end

function UMG_Pet_VeryIntimate_C:OnClicked()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_Pet_VeryIntimate_C:OnClicked")
  self:PlayAnimation(self.Click)
end

function UMG_Pet_VeryIntimate_C:PCKeySetting()
  if SystemSettingModuleCmd and self.Text_PCKey then
    self.Text_PCKey:SetKeyVisibility(true)
    local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, "IA_FondlePet")
    if "" ~= image then
      self.Text_PCKey:SetImageMode(image)
    else
      self.Text_PCKey:SetText(text)
    end
  end
end

function UMG_Pet_VeryIntimate_C:SetOption(option)
  self.option = option
end

function UMG_Pet_VeryIntimate_C:ClearOption()
  self.option = nil
end

function UMG_Pet_VeryIntimate_C:ExecuteOption()
  local panelName = "LobbyMain"
  local moduleName = "MainUIModule"
  local isSelectBtn = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetIsSelectBtn, moduleName, panelName)
  if isSelectBtn then
    return
  end
  local PlayerInteractState = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetPlayerInteractStateCache)
  if self.option:IsInteractBanState(PlayerInteractState) then
    return
  end
  if self.option and self.option.owner then
    self.option:OnOptionAction()
    self.option = nil
  end
end

return UMG_Pet_VeryIntimate_C
