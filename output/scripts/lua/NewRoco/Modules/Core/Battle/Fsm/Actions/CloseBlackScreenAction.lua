local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local CloseBlackScreenAction = BattleActionBase:Extend("CloseBlackScreenAction")

function CloseBlackScreenAction:OnEnter()
  if BattleUtils.HasUI("BattleLoading") then
    if BattleManager.ShouldWaitGlobalLoading then
      self.waitGap = 0.1
      self.waitTime = 0
      self.blackModule = NRCModuleManager:GetModule("BlackScreenModule")
      self:CheckGlobalLoading()
    else
      self:CloseBattleLoading()
    end
  else
    _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.ForceCloseLoading)
    self:Finish()
  end
end

function CloseBlackScreenAction:CheckGlobalLoading()
  if self.finished then
    return
  end
  if self.blackModule and self.waitTime <= 2 then
    if self.blackModule:HasPanel("GlobalBlack") then
      self:CloseBattleLoading()
    else
      self.waitTime = self.waitTime + self.waitGap
      self:SafeDelaySeconds("d_CheckGlobalLoading", self.waitGap, self.CheckGlobalLoading, self)
    end
  else
    self:CloseBattleLoading()
  end
end

function CloseBlackScreenAction:CloseBattleLoading()
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.SetForbidCloseLoading, nil)
  local closeReasonList = self:GetProperty(BattleConst.FsmVarNames.ShowBlackScreenReasons)
  local asyncData = {
    owner = self,
    callback = self.OnBlackScreenRemoved,
    closeReasonList = closeReasonList
  }
  NRCModuleManager:DoCmdAsync(asyncData, BattleUIModuleCmd.CloseLoading)
end

function CloseBlackScreenAction:OnBlackScreenRemoved()
  if self.finished then
    return
  end
  self:Finish()
end

function CloseBlackScreenAction:OnFinish()
  self.blackModule = nil
end

return CloseBlackScreenAction
