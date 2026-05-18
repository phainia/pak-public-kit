require("NewRoco.Modules.Core.Battle.Entity.BattleInfo.Basic.TableTools")
local Base = require("NewRoco.Modules.Core.Battle.Entity.BattleInfo.BaseBattleInfoUtility")
local BattleInfo = Base:Extend("BattleInfo")

function BattleInfo:Ctor(...)
  self:SafeCall("_OnCtor", ...)
  table.makeReadOnly(self)
end

function BattleInfo:Modify(...)
  table.unlockReadOnly(self)
  self:SafeCall("_OnModify", ...)
  table.makeReadOnly(self)
end

function BattleInfo:GetGuid()
  return BattleInfoTypes.InvalidGuid
end

function BattleInfo:GetInfoFlags()
  return BattleInfoTypes.EFlags.Undefined
end

BattleInfo.GetInfoFlags = nil
BattleInfo._OnCtor = nil
BattleInfo._OnModify = nil
return BattleInfo
