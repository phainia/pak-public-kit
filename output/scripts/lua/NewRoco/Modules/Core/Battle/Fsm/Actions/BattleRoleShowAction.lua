local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleRoleShowAction = Base:Extend("BattleRoleShowAction")
FsmUtils.MergeMembers(Base, BattleRoleShowAction, {})

function BattleRoleShowAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleRoleShowAction:OnEnter()
  self:DestroyProperty(BattleConst.BattleStand.CameraID1)
  self:DestroyProperty(BattleConst.BattleStand.CameraID1_SA)
  self:DestroyProperty(BattleConst.BattleStand.CameraID2)
  self:DestroyProperty(BattleConst.BattleStand.CameraID2_SA)
  self:DestroyProperty(BattleConst.InPlace.Cam1)
  self:DestroyProperty(BattleConst.InPlace.Cam1_SA)
  self:DestroyProperty(BattleConst.InPlace.Cam3)
  self:DestroyProperty(BattleConst.InPlace.Cam3_SA)
  self:DestroyProperty(BattleConst.InPlace.BGFX)
  self:DestroyProperty(BattleConst.BattleStand.CameraRoot)
  self:Finish()
end

function BattleRoleShowAction:OnExit()
end

function BattleRoleShowAction:DestroyProperty(name)
  FsmUtils.ClearProperty(self.fsm, name)
end

return BattleRoleShowAction
