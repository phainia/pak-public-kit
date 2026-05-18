local IS_EDITOR = _G.RocoEnv.IS_EDITOR
local BattleDebugger = {}

function BattleDebugger:IsEditor()
  return IS_EDITOR
end

return BattleDebugger
