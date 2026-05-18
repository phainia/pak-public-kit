local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local Base = NRCModeAction
local NRCPreloadAssetsAction = Base:Extend("NRCPreloadAssetsAction")

function NRCPreloadAssetsAction:OnEnter()
  NRCModuleManager:DoCmd(LoadingUIModuleCmd.OpenLoadingUI, LuaText.Loading, 0.1)
  self.timeout = 60
  if _G.GlobalConfig.DisablePreLoadAsset then
    self.timeout = 1
  end
  UE.UNRCStatics.ExecConsoleCommand("s.AsyncLoadingTimeLimit 30", nil)
  UE.UNRCStatics.ExecConsoleCommand("s.MaxCallbackTimeCost 10", nil)
  _G.NRCBigWorldPreloader:StartPreload(self, self.OnPreloadFinish)
  UE.UNRCPlatformGameInstance.GetInstance():ReadUnlockZoneMasks()
end

function NRCPreloadAssetsAction:OnPreloadFinish()
  Log.Debug("Preload Finish!")
  NRCModuleManager:DoCmd(LoadingUIModuleCmd.OpenLoadingUI, LuaText.Loading, 0.2)
  self:Finish()
end

return NRCPreloadAssetsAction
