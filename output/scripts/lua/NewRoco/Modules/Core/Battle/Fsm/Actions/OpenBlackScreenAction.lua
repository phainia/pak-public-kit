local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local Base = BattleActionBase
local OpenBlackScreenAction = Base:Extend("OpenBlackScreenAction")

function OpenBlackScreenAction:OnEnter()
  if BattleUtils.HasBattleLoading() then
    self:OnBlackShown()
    return
  end
  local openReasonList = self:GetProperty(BattleConst.FsmVarNames.ShowBlackScreenReasons)
  local asyncData = {
    owner = self,
    callback = self.OnBlackShown,
    openReasonList = openReasonList
  }
  self.isDown = false
  NRCModuleManager:DoCmdAsync(asyncData, BattleUIModuleCmd.OpenLoading)
  self:SafeDelaySeconds("d_CheckDown", 3, self.CheckDown, self)
end

function OpenBlackScreenAction:OnBlackShown()
  if not self.isDown then
    BattleBudget:GC(true)
    NRCModeManager:DoCmd(PlayerModuleCmd.HIDE_ALL, true)
    self.isDown = true
    self:Finish()
  end
end

function OpenBlackScreenAction:CheckDown()
  if self.finished then
    return
  end
  if not self.isDown then
    self:OnBlackShown()
  end
end

function OpenBlackScreenAction:OnExit()
end

return OpenBlackScreenAction
