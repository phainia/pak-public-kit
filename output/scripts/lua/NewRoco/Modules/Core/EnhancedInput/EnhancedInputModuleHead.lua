local EnhancedInputModuleHead = NRCModuleHeadBase:Extend("EnhancedInputModuleHead")

function EnhancedInputModuleHead:OnConstruct()
  _G.EnhancedInputModuleCmd = reload("NewRoco.Modules.Core.EnhancedInput.EnhancedInputModuleCmd")
  self:BindCmd(_G.EnhancedInputModuleCmd.GetMappingKey, "GetMappingKey")
  self:BindCmd(_G.EnhancedInputModuleCmd.AddInputMappingContext, "AddInputMappingContext")
  self:BindCmd(_G.EnhancedInputModuleCmd.GetInputMappingContext, "GetInputMappingContext")
  self:BindCmd(_G.EnhancedInputModuleCmd.RemoveInputMappingContext, "RemoveInputMappingContext")
  self:BindCmd(_G.EnhancedInputModuleCmd.ApplyUserModifiedKeyMappings, "ApplyUserModifiedKeyMappings")
  self:BindCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperAddInputMappingContext, "EnhancedInputHelperAddInputMappingContext")
  self:BindCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperRemoveInputMappingContext, "EnhancedInputHelperRemoveInputMappingContext")
  self:BindCmd(_G.EnhancedInputModuleCmd.AddBlockIMC, "BlockPCInput")
  self:BindCmd(_G.EnhancedInputModuleCmd.RemoveBlockIMC, "UnBlockPCInput")
end

return EnhancedInputModuleHead
