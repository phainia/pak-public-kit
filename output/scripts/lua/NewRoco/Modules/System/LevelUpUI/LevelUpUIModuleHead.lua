local LevelUpUIModuleHead = NRCModuleHeadBase:Extend("LevelUpUIModuleHead")

function LevelUpUIModuleHead:OnConstruct()
  _G.LevelUpUIModuleCmd = reload("NewRoco.Modules.System.LevelUpUI.LevelUpUIModuleCmd")
  self:BindCmd(_G.LevelUpUIModuleCmd.OpenMainPanel, "OnOpenMainPanel")
end

return LevelUpUIModuleHead
