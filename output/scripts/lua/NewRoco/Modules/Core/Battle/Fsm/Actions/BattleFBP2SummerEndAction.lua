local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local DialogueModuleCmd = require("NewRoco.Modules.System.Dialogue.DialogueModuleCmd")
local Base = BattleActionBase
local BattleFBP2SummerEndAction = Base:Extend("BattleFBP2SummerEndAction")
FsmUtils.MergeMembers(Base, BattleFBP2SummerEndAction, {})

function BattleFBP2SummerEndAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self:SetActionType(BattleActionBase.ActionType.ClientPlayerSelectAction)
end

function BattleFBP2SummerEndAction:OnEnter()
  if not BattleUtils.IsFinalBattleP2() then
    self:Finish()
    return
  end
  self.supplyPetName = self.fsm:GetProperty("SupplyPetName")
  Log.Debug("BattleFBP2SummerEndAction:OnEnter ", self.supplyPetName)
  if string.IsNilOrEmpty(self.supplyPetName) then
    self:Finish()
    return
  end
  self.supplyPetName = self.supplyPetName .. "!"
  self.dialogId = DataConfigManager:GetBattleGlobalConfig("a1_finalbattle_postsummon_dialogue_ID").num
  local Conf = _G.DataConfigManager:GetDialogueConf(self.dialogId)
  if not Conf then
    self:Finish()
    return
  end
  self.dialogSelectIds = Conf.select_ids or {}
  self.dialogEntryType = "SelectText"
  _G.NRCModuleManager:DoCmd(DialogueModuleCmd.AddOverrideCallback, self.dialogEntryType, self, self.AddOverrideCallback)
  self:ShowDialog()
end

function BattleFBP2SummerEndAction:AddOverrideCallback(SelectID, EntryType)
  Log.Debug("BattleFBP2SummerEndAction:AddOverrideCallback ", SelectID, EntryType, #self.dialogSelectIds)
  if self.dialogEntryType == EntryType then
    if 0 == #self.dialogSelectIds then
      return self.supplyPetName
    end
    for i, v in ipairs(self.dialogSelectIds) do
      if v == SelectID then
        return self.supplyPetName
      end
    end
  end
end

function BattleFBP2SummerEndAction:ShowDialog()
  local player = _G.BattleManager.battlePawnManager:GetTeamPlayer(BattleEnum.Team.ENUM_TEAM)
  if player and player.model then
    self.fsm:Pause()
    _G.NRCModuleManager:DoCmd(DialogueModuleCmd.StartDialogueInBattle, player, self.dialogId, self, self.OnDialogEnd)
  else
    self:Finish()
  end
end

function BattleFBP2SummerEndAction:OnDialogEnd()
  self.fsm:Resume()
  self:Finish()
end

function BattleFBP2SummerEndAction:OnFinish()
  _G.NRCModuleManager:DoCmd(DialogueModuleCmd.RemoveOverrideCallback, self.dialogEntryType, self, self.AddOverrideCallback)
end

return BattleFBP2SummerEndAction
