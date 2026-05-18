local DelaySafeCaller = require("NewRoco.Modules.Core.Battle.Common.DelaySafeCaller")
local BattlePlayerBase = NRCClass:Extend()

function BattlePlayerBase:Ctor()
  self.isFree = false
  self.playerPool = BattlePlayerPool
  self.playerType = 0
  self.isWorking = false
  self.delaySafeCaller = DelaySafeCaller()
  self.runtime_data = {}
end

function BattlePlayerBase:SetRuntimeData(key, value)
  self.runtime_data[key] = value
end

function BattlePlayerBase:GetRuntimeData(key)
  return self.runtime_data[key]
end

function BattlePlayerBase:Start()
  self.isWorking = true
  self.isFree = false
end

function BattlePlayerBase:Stop()
  self.delaySafeCaller:SafeCancelAllDelay()
  self.isWorking = false
  self.isFree = true
end

function BattlePlayerBase:Release()
  self.playerPool:ReleasePlayer(self)
end

function BattlePlayerBase:Clear()
end

function BattlePlayerBase:SafeDelaySeconds(idName, ...)
  self.delaySafeCaller:SafeDelaySeconds(idName, ...)
end

function BattlePlayerBase:SafeDelayFrames(idName, ...)
  self.delaySafeCaller:SafeDelayFrames(idName, ...)
end

function BattlePlayerBase:SafeCancelDelayById(idName)
  self.delaySafeCaller:SafeCancelDelayById(idName)
end

function BattlePlayerBase:SafeFindDelayById(idName)
  return self.delaySafeCaller:SafeFindDelayById(idName)
end

return BattlePlayerBase
