local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local PVESpecialDelayAction = BattleActionBase:Extend("PVESpecialDelayAction")

function PVESpecialDelayAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
end

function PVESpecialDelayAction:OnEnter()
  local BattleConf = BattleUtils.GetBattleConfig()
  if BattleConf.special_battle_start_time > 0 then
    self.DelayId = _G.DelayManager:DelaySeconds(BattleConf.special_battle_start_time / 1000, self.TryFinish, self)
  else
    self:Finish()
  end
end

function PVESpecialDelayAction:TryFinish()
  self.DelayId = nil
  self:Finish()
end

function PVESpecialDelayAction:OnFinish()
  self:CancelDelay()
end

function PVESpecialDelayAction:CancelDelay()
  if self.DelayId then
    _G.DelayManager:CancelDelayById(self.DelayId)
  end
  self.DelayId = nil
end

function PVESpecialDelayAction:OnExit()
end

return PVESpecialDelayAction
