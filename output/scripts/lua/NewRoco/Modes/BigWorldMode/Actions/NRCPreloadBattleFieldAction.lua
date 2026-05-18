local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleFieldConst = require("NewRoco.Modules.Core.Battle.Common.BattleFieldConst")
local NRCPreloadBattleFieldAction = NRCModeAction:Extend("NRCPreloadBattleFieldAction")

function NRCPreloadBattleFieldAction:Ctor(name, properties)
  NRCModeAction.Ctor(self, name, properties)
end

function NRCPreloadBattleFieldAction:OnEnter()
  Log.Debug("[NRCPreloadBattleFieldAction] OnEnter")
  local mapWidth = BattleFieldConst.mapWidth
  local mapHeight = BattleFieldConst.mapHeight
  local minx = BattleFieldConst.minx
  local miny = BattleFieldConst.miny
  if not BattleConst.bUseBattleFieldMulity then
    UE4.UNRCBattleFieldStatics.InitMapInfo(mapWidth, mapHeight, minx, miny)
  else
    UE4.UNRCBattleFieldDataManager.Clear()
    local num = 0
    local dataManager = UE4.UNRCBattleFieldDataManager.LoadManagerObject()
    if dataManager then
      local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
      if player.viewObj then
        local PlayerLocation = player.viewObj:Abs_K2_GetActorLocation()
        if not _G.GlobalConfig.DisableBattleField then
          num = dataManager:Init(PlayerLocation, false)
          dataManager:StartTick()
          if num > 0 then
          else
            Log.Warning("\229\164\167\228\184\150\231\149\140\230\136\152\230\150\151\233\128\137\231\130\185\230\151\160\230\149\176\230\141\174\239\188\140\233\156\128\230\163\128\230\159\165\230\149\176\230\141\174\231\148\159\230\136\144\229\175\188\229\133\165\232\191\135\231\168\139 PlayerLocation:", PlayerLocation.X, PlayerLocation.Y, PlayerLocation.Z)
          end
        end
      else
        Log.Error("\230\136\152\230\150\151\233\128\137\231\130\185\233\162\132\229\138\160\232\189\189\239\188\140player.viewObj\228\184\186\231\169\186")
      end
    else
      Log.Error("\230\136\152\230\150\151\233\128\137\231\130\185 dataManager\229\138\160\232\189\189\229\164\177\232\180\165")
    end
  end
  _G.NRCModuleManager:DoCmd(BattleModuleCmd.LoadBattleFieldLevel, function(ok, errorMessage)
    if not ok then
      Log.Error("NRCPreloadBattleFieldAction:OnEnter failed to load battle field level:", errorMessage)
    end
    NRCModuleManager:DoCmd(LoadingUIModuleCmd.OpenLoadingUI, LuaText.Loading, 0.7)
    self:Finish()
  end)
end

function NRCPreloadBattleFieldAction:OnExit()
end

return NRCPreloadBattleFieldAction
