local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleShowDialogueAction = Base:Extend("BattleShowDialogueAction")
FsmUtils.MergeMembers(Base, BattleShowDialogueAction, {})

function BattleShowDialogueAction:OnEnter()
  local dialogId = self:GetDialogueId()
  local DialogueConf = _G.DataConfigManager:GetDialogueConf(dialogId)
  if DialogueConf then
    self.fsm:Pause()
    self.player = _G.BattleManager.battlePawnManager:GetPlayerMyTeam()
    _G.NRCModuleManager:DoCmd(DialogueModuleCmd.StartDialogueInBattle, self.player, dialogId, self, self.OnDialogueEnd)
    _G.NRCModuleManager:DoCmd(DialogueModuleCmd.OverridePropertiesInBattleFsm, {ReturnCamera = false})
  else
    self:Finish()
    return
  end
end

function BattleShowDialogueAction:GetDialogueId()
  return 0
end

function BattleShowDialogueAction:OnDialogueEnd()
  if self.fsm and self.fsm.Resume then
    self.fsm:Resume()
  end
  self:Finish()
end

return BattleShowDialogueAction
