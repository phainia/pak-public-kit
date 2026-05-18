local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DebugTabBattleSpectator = Base:Extend("DebugTabBattleSpectator")

function DebugTabBattleSpectator:Ctor()
  Base.Ctor(self)
end

function DebugTabBattleSpectator:SwitchDebug()
  local bDrawDebug = _G.NRCModuleManager:DoCmd(_G.BattleSpectatorModuleCmd.GetCanDrawDebug)
  bDrawDebug = not bDrawDebug
  _G.NRCModuleManager:DoCmd(_G.BattleSpectatorModuleCmd.SetCanDrawDebug, bDrawDebug)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format("\229\177\128\229\164\150\232\161\168\230\188\148\231\154\132debug\231\138\182\230\128\129\239\188\154%s", tostring(bDrawDebug)), 1, nil, 5)
end

return DebugTabBattleSpectator
