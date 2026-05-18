local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleActionBase = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattleActionBase")
local Base = BattleActionBase
local BattleEnterChangeCamera = Base:Extend("BattleEnterChangeCamera")
FsmUtils.MergeMembers(Base, BattleEnterChangeCamera, {})

function BattleEnterChangeCamera:OnEnter()
  _G.BattleManager.vBattleField.battleCraneCamera:ChangeCameraTagDirect(UE4.EBattleCameraTags.PlayerPet, 0)
  self:Finish()
end

return BattleEnterChangeCamera
