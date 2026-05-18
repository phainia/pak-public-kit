local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleB1P3PreloadBattleResAction = Base:Extend("BattleB1P3PreloadBattleResAction")
FsmUtils.MergeMembers(Base, BattleB1P3PreloadBattleResAction, {})

function BattleB1P3PreloadBattleResAction:OnEnter()
  BattleSkillManager:PreLoadSingleResInternal(BattleConst.B1P3EnterG6, true)
  BattleSkillManager:PreLoadSingleResInternal(_G.BattleConst.B1P3TwoPetCamG6, true)
  NRCPanelManager:PreloadPanel("/Game/NewRoco/Modules/System/B1FinalBattleModule/Res/UMG_TwoScreenDialogue")
  self:Finish()
end

return BattleB1P3PreloadBattleResAction
