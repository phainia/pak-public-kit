local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Json = require("Common.JsonUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local cachePsoAutomation = require("NewRoco.Modules.System.Debug.PSO.CachePsoAutomation")
local teleportPsoAutomation = require("NewRoco.Modules.System.Debug.PSO.TeleportCachePsoAutomation")
local Base = DebugTabBase
local DebugTakePhotos = Base:Extend("DebugTakePhotos")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")

function DebugTakePhotos:SetupTabs()
  self:Add("PSO\233\129\141\229\142\134Mesh\232\135\170\229\138\168\229\140\150(\233\156\128\232\166\129\229\133\136\232\191\155\229\156\186\230\153\175)", self.MeshCachePSOAutomation, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "MeshCachePSOAutomation")
  self:Add("PSO\233\129\141\229\142\134Niagara\232\135\170\229\138\168\229\140\150(\233\156\128\232\166\129\229\133\136\232\191\155\229\156\186\230\153\175)", self.NiagaraCachePSOAutomation, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "NiagaraCachePSOAutomation")
  self:Add("PSO\228\188\160\233\128\129\232\135\170\229\138\168\229\140\150", self.TeleportCachePSOAutomation, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "TeleportCachePSOAutomation")
end

function DebugTakePhotos:OpenTakePhotosDebugPanel()
  local Module = NRCModuleManager:GetModule("TakePhotosModule")
  if Module then
    self:ClosePanel()
    Module:TryOpenMainPanel()
  else
    self:ShowDialog("\230\139\141\231\133\167\230\168\161\229\157\151\232\191\152\230\156\170\229\138\160\232\189\189\239\188\140\230\151\160\230\179\149\228\189\191\231\148\168\230\139\141\231\133\167\229\138\159\232\131\189")
  end
end

function DebugTakePhotos:MeshCachePSOAutomation()
  self:ClosePanel()
  cachePsoAutomation:Start(false)
end

function DebugTakePhotos:NiagaraCachePSOAutomation()
  self:ClosePanel()
  cachePsoAutomation:Start(true)
end

function DebugTakePhotos:TeleportCachePSOAutomation(content)
  self:ClosePanel()
  teleportPsoAutomation:Start()
end

return DebugTakePhotos
