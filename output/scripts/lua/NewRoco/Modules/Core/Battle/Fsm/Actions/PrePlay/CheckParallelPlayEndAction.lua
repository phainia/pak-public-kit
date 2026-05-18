local Base = BattleActionBase
local CheckParallelPlayEndAction = Base:Extend("CheckParallelPlayEndAction")

function CheckParallelPlayEndAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
  self.PawnManager = self.BattleManager.battlePawnManager
end

function CheckParallelPlayEndAction:OnEnter()
  local showEndTime = self.BattleManager.battleRuntimeData:GetParallelShowTime()
  if not showEndTime or 0 == showEndTime then
    self:Finish()
    return
  end
end

function CheckParallelPlayEndAction:OnTick()
  if self.finished then
    return
  end
  local showEndTime = self.BattleManager.battleRuntimeData:GetParallelShowTime()
  local waitTime = showEndTime - os.time()
  if waitTime > 0 then
    return
  end
  self:Finish()
end

function CheckParallelPlayEndAction:OnFinish()
  BattleManager.stateFsm:SetProperty("IsPreplay", false)
  self.BattleManager.battleRuntimeData:ClearCacheRidOf()
end

return CheckParallelPlayEndAction
