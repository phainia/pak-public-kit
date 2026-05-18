local HandbookModuleHead = NRCModuleHeadBase:Extend("HandbookModuleHead")

function HandbookModuleHead:OnConstruct()
  _G.HandbookModuleCmd = reload("NewRoco.Modules.System.Handbook.HandbookModuleCmd")
  self:BindCmd(_G.HandbookModuleCmd.OpenMainPanel, "OnOpenMainPanel")
end

return HandbookModuleHead
