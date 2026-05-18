require("UnLuaEx")
local BattleLog = require("NewRoco.Modules.Battle.Common.BattleLog")
local UMG_BattleLoading_base_C = NRCUmgClass:Extend("")

function UMG_BattleLoading_base_C:LoadingFinish()
  local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
  BattleLog.DebugF("---------- UMG_BattleLoading_base:OnLoadingFinish")
  _G.BattleEventCenter:Dispatch(BattleEvent.UI_CHANGE_TO_BATTLE_SHOW_TWEENOUT_FINISH)
end

return UMG_BattleLoading_base_C
