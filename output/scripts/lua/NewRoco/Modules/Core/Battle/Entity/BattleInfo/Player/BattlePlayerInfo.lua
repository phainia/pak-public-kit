local Base = require("NewRoco.Modules.Core.Battle.Entity.BattleInfo.BattleInfo")
local BattlePlayerInfo = Base:Extend("BattlePlayerInfo")

function BattlePlayerInfo:_OnCtor(role_uin)
  self.role_uin = role_uin
end

function BattlePlayerInfo:GetGuid()
  return self.role_uin
end

return BattlePlayerInfo
