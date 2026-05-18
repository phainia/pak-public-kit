local HeadIconModuleHead = NRCModuleHeadBase:Extend("HeadIconModuleHead")

function HeadIconModuleHead:OnConstruct()
  _G.HeadIconModuleCmd = reload("NewRoco.Modules.System.HeadIcon.HeadIconModuleCmd")
  self:BindCmd(_G.HeadIconModuleCmd.TryGetExternalSavedHeadIconFilePath, "TryGetExternalSavedHeadIconFilePath")
end

return HeadIconModuleHead
