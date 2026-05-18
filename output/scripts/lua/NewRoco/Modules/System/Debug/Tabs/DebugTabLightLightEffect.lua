local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local EnvSystemModuleCmd = require("NewRoco.Modules.System.EnvSystem.EnvSystemModuleCmd")
local LinearTimeSetter = require("NewRoco.Modules.System.EnvSystem.LinearTimeSetter")
local Base = DebugTabBase
local DebugTabLightLightEffect = Base:Extend("DebugTabLightLightEffect")

function DebugTabLightLightEffect:SetupTabs()
  self:Add("\230\159\165\231\156\139\229\189\147\229\137\141\231\148\159\230\149\136volume", self.checkVolume, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\152\190\231\164\186\229\140\186\229\159\159todvolume", self.showTODVolume, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\152\190\231\164\186\230\137\128\230\156\137\231\148\159\230\149\136\229\174\158\230\151\182\231\129\175", self.showRealtimeLight, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\152\190\231\164\186\230\137\128\230\156\137\231\148\159\230\149\136\229\174\158\230\151\182\230\138\149\229\189\177\231\129\175", self.showRealtimeShadowLight, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\188\128\230\156\128\231\187\136\230\136\152\231\129\175\229\133\137", self.OpenFBSceneSpotLight, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\133\179\230\156\128\231\187\136\230\136\152\231\129\175\229\133\137", self.CloseFBSceneSpotLight, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\137\147\229\141\176EnvPointLight", self.ShowEnvPointLightActor, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
end

function DebugTabLightLightEffect:testLight()
end

function DebugTabLightLightEffect:checkVolume()
  local playerController = UE4.UGameplayStatics.GetPlayerController(_G.UE4Helper.GetCurrentWorld(), 0)
  UE4.UNRCStatics.ExecConsoleCommand("r.ScreenDebugInfo 1", playerController)
  UE4.UNRCStatics.ExecConsoleCommand("r.ScreenDebugInfo.TODVolume 1", playerController)
end

function DebugTabLightLightEffect:showTODVolume()
  local playerController = UE4.UGameplayStatics.GetPlayerController(_G.UE4Helper.GetCurrentWorld(), 0)
  GlobalConfig.LLSC = not GlobalConfig.LLSC
  if GlobalConfig.LLSC then
    UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.TODVolume.Visible 1", playerController)
  else
    UE4.UNRCStatics.ExecConsoleCommand("WorldTileTool.TODVolume.Visible 0", playerController)
  end
end

function DebugTabLightLightEffect:showRealtimeLight()
  local playerController = UE4.UGameplayStatics.GetPlayerController(_G.UE4Helper.GetCurrentWorld(), 0)
  GlobalConfig.Forward = not GlobalConfig.Forward
  if GlobalConfig.Forward then
    UE4.UNRCStatics.ExecConsoleCommand("r.ScreenDebugInfo 1", playerController)
    UE4.UNRCStatics.ExecConsoleCommand("r.ScreenDebugInfo.Forward 1", playerController)
  else
    UE4.UNRCStatics.ExecConsoleCommand("r.ScreenDebugInfo 0", playerController)
    UE4.UNRCStatics.ExecConsoleCommand("r.ScreenDebugInfo.Forward 0", playerController)
  end
end

function DebugTabLightLightEffect:showRealtimeShadowLight()
  local playerController = UE4.UGameplayStatics.GetPlayerController(_G.UE4Helper.GetCurrentWorld(), 0)
  GlobalConfig.LLSC = not GlobalConfig.LLSC
  if GlobalConfig.LLSC then
    UE4.UNRCStatics.ExecConsoleCommand("r.ScreenDebugInfo 1", playerController)
    UE4.UNRCStatics.ExecConsoleCommand("r.ScreenDebugInfo.LLSC 1", playerController)
  else
    UE4.UNRCStatics.ExecConsoleCommand("r.ScreenDebugInfo 0", playerController)
    UE4.UNRCStatics.ExecConsoleCommand("r.ScreenDebugInfo.LLSC 0", playerController)
  end
end

function DebugTabLightLightEffect:OpenFBSceneSpotLight()
  if _G.BattleManager then
    _G.BattleManager:ModifySceneSpotLight(true)
  end
end

function DebugTabLightLightEffect:CloseFBSceneSpotLight()
  if _G.BattleManager then
    _G.BattleManager:ModifySceneSpotLight(false)
  end
end

function DebugTabLightLightEffect:ShowEnvPointLightActor()
  local World = _G.UE4Helper.GetCurrentWorld()
  local LightsArray = UE4.UGameplayStatics.GetAllActorsOfClass(World, UE4.AEnvPointLightActor)
  local Lights = LightsArray and LightsArray:ToTable()
  Log.Debug("DebugTabLightLightEffect:ShowEnvPointLightActor1 ", #Lights)
  if Lights and #Lights > 0 then
    for i, v in ipairs(Lights) do
      local pointLight = v
      Log.Debug("DebugTabLightLightEffect:ShowEnvPointLightActor ", pointLight:GetName(), pointLight.Config.bActive)
    end
  end
end

return DebugTabLightLightEffect
