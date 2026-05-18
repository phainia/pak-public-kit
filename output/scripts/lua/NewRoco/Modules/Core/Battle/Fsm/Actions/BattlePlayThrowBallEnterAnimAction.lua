local BattlePlayAnimBaseAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattlePlayAnimBaseAction")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = BattlePlayAnimBaseAction
local BattlePlayThrowBallEnterAnimAction = Base:Extend("BattlePlayThrowBallEnterAnimAction")

function BattlePlayThrowBallEnterAnimAction:Ctor()
  Base.Ctor(self)
end

function BattlePlayThrowBallEnterAnimAction:OnEnter()
  self:Finish()
end

function BattlePlayThrowBallEnterAnimAction:OnHidePlayer()
  Log.Debug("BattlePlayThrowBallEnterAnimAction OnHidePlayer")
  NRCModeManager:DoCmd(PlayerModuleCmd.HIDE_ALL, true)
end

function BattlePlayThrowBallEnterAnimAction:End()
  local Blackboard = self.skillObj:GetBlackboard()
  self:SaveObject(Blackboard, BattleConst.BattleThrowBallEnter.CameraID1)
  self:SaveObject(Blackboard, BattleConst.BattleThrowBallEnter.CameraID1_SA)
  self:SaveObject(Blackboard, BattleConst.BattleThrowBallEnter.CameraID2)
  self:SaveObject(Blackboard, BattleConst.BattleThrowBallEnter.CameraID2_SA)
end

function BattlePlayThrowBallEnterAnimAction:SaveObject(bb, name)
  Log.Debug("BattlePlayThrowBallEnterAnimAction SaveObject:", name, bb:GetValueAsObject(name))
  self.fsm:SetProperty(name, bb:GetValueAsObject(name))
  bb:RemoveObjectValue(name)
end

return BattlePlayThrowBallEnterAnimAction
