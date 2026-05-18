local CosUploadModuleHead = NRCModuleHeadBase:Extend("CosUploadModuleHead")

function CosUploadModuleHead:OnConstruct()
  _G.CosUploadModuleCmd = reload("NewRoco.Modules.Core.CosUpload.CosUploadModuleCmd")
  self:BindCmd(_G.CosUploadModuleCmd.StartupUploadLogs, "StartupUploadLogs")
  self:BindCmd(_G.CosUploadModuleCmd.ReqCosUploadUrlForBattle, "ReqCosUploadUrlForBattle")
end

return CosUploadModuleHead
