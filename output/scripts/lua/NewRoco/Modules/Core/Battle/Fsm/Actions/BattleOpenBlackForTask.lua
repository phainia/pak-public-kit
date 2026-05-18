local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local Base = BattleActionBase
local BattleOpenBlackForTask = Base:Extend("BattleOpenBlackForTask")

function BattleOpenBlackForTask:OnEnter()
  if not BattleUtils.ContainTaskPerformControl(Enum.TaskBattlePerformanceControl.TBPC_ENTER_BLACK) then
    self:Finish()
    return
  end
  if BattleUtils.HasBattleLoading() then
    self:OnBlackShown()
    return
  end
  local asyncData = {
    owner = self,
    callback = self.OnBlackShown
  }
  self.isDown = false
  NRCModuleManager:DoCmdAsync(asyncData, BattleUIModuleCmd.OpenLoading)
  self:SafeDelaySeconds("d_CheckDown", 3, self.CheckDown, self)
end

function BattleOpenBlackForTask:OnBlackShown()
  if not self.isDown then
    BattleBudget:GC(true)
    NRCModeManager:DoCmd(PlayerModuleCmd.HIDE_ALL, true)
    self.isDown = true
    local battleConf = BattleUtils.GetBattleConfig()
    if battleConf then
      local BattleID = battleConf.id
      NRCModuleManager:DoCmd(BlackScreenModuleCmd.TryCloseGlobalTransitionBlackScreenIfAny, {BattleId = BattleID})
    end
    self:Finish()
  end
end

function BattleOpenBlackForTask:CheckDown()
  if self.finished then
    return
  end
  if not self.isDown then
    self:OnBlackShown()
  end
end

function BattleOpenBlackForTask:OnExit()
end

return BattleOpenBlackForTask
