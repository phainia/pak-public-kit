local BattleShowDialogueAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.B1FinalBattle.BattleShowDialogueAction")
local Base = BattleShowDialogueAction
local BattleB1P3FinalSkillDialogueAction = Base:Extend("BattleB1P3FinalSkillDialogueAction")

function BattleB1P3FinalSkillDialogueAction:OnEnter()
  if _G.BattleManager.battleRuntimeData.battleStartParam:IsReconnect() then
    local b1P3FinalSkillDialogue = self.fsm:GetProperty("b1P3FinalSkillDialogue")
    if b1P3FinalSkillDialogue then
      self:Finish()
      return
    end
  end
  self.fsm:SetProperty("b1P3FinalSkillDialogue", true)
  Base.OnEnter(self)
end

function BattleB1P3FinalSkillDialogueAction:GetDialogueId()
  return DataConfigManager:GetBattleGlobalConfig("B1_P3_ROUND3_DIALOGUE").num
end

return BattleB1P3FinalSkillDialogueAction
