local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleCoreEnv = NRCClass()

function BattleCoreEnv:Ctor()
  self.EnableComboAttack = false
end

function BattleCoreEnv:InitEnv()
  if _G.BattleManager.battleRuntimeData.subBattleType == BattleEnum.SubBattleType.MultiPet or _G.BattleManager.battleRuntimeData.subBattleType == BattleEnum.SubBattleType.MultiPlayer then
    self.EnableComboAttack = true
  else
    self.EnableComboAttack = false
  end
end

return BattleCoreEnv
