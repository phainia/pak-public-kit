local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local Base = NRCModeAction
local NRCPreload3DUIWorldsAction = Base:Extend("NRCPreload3DUIWorldsAction")

function NRCPreload3DUIWorldsAction:OnEnter()
  self.timeout = 30
  Log.Debug("Preload 3D UI Worlds Starts!")
  local WorldViewSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(UE4Helper.GetCurrentWorld(), UE.UWorldViewSubsystem)
  if nil ~= WorldViewSubSystem and not _G.GlobalConfig.DisablePreLoadAsset then
    WorldViewSubSystem:PreloadWorlds()
  end
  self:Finish()
end

return NRCPreload3DUIWorldsAction
