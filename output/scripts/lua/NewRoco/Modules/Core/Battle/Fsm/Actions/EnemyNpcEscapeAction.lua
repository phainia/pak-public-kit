local ProtoEnum = require("Data.PB.ProtoEnum")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local DialogueModuleCmd = require("NewRoco.Modules.System.Dialogue.DialogueModuleCmd")
local Base = BattleActionBase
local EnemyNpcEscapeAction = Base:Extend("EnemyNpcEscapeAction")
FsmUtils.MergeMembers(Base, EnemyNpcEscapeAction, {
  {name = "RoundState", type = "number"}
})

function EnemyNpcEscapeAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.PawnManger = _G.BattleManager.battlePawnManager
end

function EnemyNpcEscapeAction:FindActors()
  self.player = self.PawnManger:GetTeamPlayer(BattleEnum.Team.ENUM_ENEMY)
  if self.player then
    local petEnemy = self.PawnManger:GetInFieldPet(BattleEnum.Team.ENUM_ENEMY)
    local petTeam = self.PawnManger:GetInFieldPet(BattleEnum.Team.ENUM_TEAM)
    self.caster = self.player.model
    self.target1 = nil ~= petEnemy and petEnemy.model or nil
    self.target2 = nil ~= petTeam and petTeam.model or nil
  end
end

function EnemyNpcEscapeAction:OnEnter()
  self.isPerformEnd = false
  self.roundState = self:GetProperty("RoundState")
  self:FindActors()
  self.PawnManger:TogglePetBuffsVisibility(false)
  if self.roundState == ProtoEnum.BATTLE_STATE_NOTIFY_TYPE.BATTLE_STATE_SELECT_PET then
    self:OnPerformStart()
    local time = _G.DataConfigManager:GetGlobalConfigNumByKeyType("escape_camera_time", _G.DataConfigManager.ConfigTableId.BATTLE_GLOBAL_CONFIG, 1)
    _G.DelayManager:DelaySeconds(time, self.OnPerformEnd, self)
  elseif self.roundState == ProtoEnum.BATTLE_STATE_NOTIFY_TYPE.BATTLE_STATE_SELECT_CMD then
    self:OnPerformStart()
    self.delayId = _G.DelayManager:DelaySeconds(2, self.OnPerformEnd, self)
  else
    self:Finish()
  end
end

function EnemyNpcEscapeAction:LoadSkillOver(skillClass)
  if not self.caster then
    self:Finish()
  end
  self.Skill = self.SkillComponent:FindOrAddSkillObj(skillClass)
  self.Skill:RegisterEventCallback("Start", self, self.OnPerformStart)
  self.Skill:RegisterEventCallback("End", self, self.OnPerformEnd)
  self.Skill:RegisterEventCallback("PreEnd", self, self.OnPerformEnd)
  self.Skill:SetCaster(self.caster)
  self.Skill:SetTargets({
    self.target1,
    self.target2
  })
  self.SkillComponent:PlaySkill(self.Skill)
end

function EnemyNpcEscapeAction:OnPerformEnd(Event, Skill)
  self.isPerformEnd = true
  _G.NRCModuleManager:DoCmd(DialogueModuleCmd.CloseDialogueInBattle)
  self:Finish()
end

function EnemyNpcEscapeAction:OnPerformStart()
  if self.player and self.player:GetNpcID() then
    local npcCfg = _G.DataConfigManager:GetNpcConf(self.player:GetNpcID())
    if npcCfg then
      if not npcCfg.escape_dialogue then
        return
      end
      _G.NRCModuleManager:DoCmd(DialogueModuleCmd.StartDialogueInBattle, self.player, npcCfg.escape_dialogue, self, self.DialogueCallback)
    else
      Log.Error("EnemyNpcEscapeAction:OnPerformStart cfg not found", self.player:GetNpcID())
    end
  end
end

function EnemyNpcEscapeAction:DialogueCallback()
  if self.isPerformEnd == true or self.roundState == ProtoEnum.BATTLE_STATE_NOTIFY_TYPE.BATTLE_STATE_SELECT_CMD then
    return
  end
  self:OnPerformEnd()
end

function EnemyNpcEscapeAction:OnFinish()
  self.Skill = nil
  self.SkillComponent = nil
  if self.delayId then
    _G.DelayManager:CancelDelayById(self.delayId)
    self.delayId = nil
  end
end

return EnemyNpcEscapeAction
