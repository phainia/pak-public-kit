local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleRoundSelectMarkerManager = require("NewRoco.Modules.Core.Battle.BattleRoundSelectMarkerManager")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local ProtoEnum = require("Data.PB.ProtoEnum")
local BattleNpcAutoEscapeSelectAction = BattleActionBase:Extend("BattleNpcAutoEscapeSelectAction")
FsmUtils.MergeMembers(BattleActionBase, BattleNpcAutoEscapeSelectAction, {
  {name = "RoundState", type = "number"}
})

function BattleNpcAutoEscapeSelectAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
  self.battleManager = _G.BattleManager
  self.PawnManger = self.battleManager.battlePawnManager
  self.evolutionData = nil
end

function BattleNpcAutoEscapeSelectAction:OnEnter()
  self.roundState = self:GetProperty("RoundState")
  self.timeout = 120
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.OpenBattleNpcAutoEscapePanel)
  self:AddListeners()
  self:FindActors()
  self.SkillComponent = _G.BattleManager.vBattleField.battleFieldActor.Skill
  local skillClassPath = BattleConst.EnemyEscape.SkillPathNpc1
  local skillClass = _G.BattleResourceManager:LoadUClass(skillClassPath)
  self:LoadSkillOver(skillClass)
end

function BattleNpcAutoEscapeSelectAction:AddListeners()
  _G.BattleEventCenter:Bind(self, BattleEvent.NPC_AUTO_ESCAPE_Accept, BattleEvent.NPC_AUTO_ESCAPE_Deny)
end

function BattleNpcAutoEscapeSelectAction:RemoveListeners()
  _G.BattleEventCenter:UnBind(self)
end

function BattleNpcAutoEscapeSelectAction:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.NPC_AUTO_ESCAPE_Accept then
    self:OnNpcAutoEscapeAccept()
    return true
  elseif eventName == BattleEvent.NPC_AUTO_ESCAPE_Deny then
    self:OnNpcAutoEscapeDeny()
    return true
  end
end

function BattleNpcAutoEscapeSelectAction:OnNpcAutoEscapeAccept()
  self:SendNpcAutoEscapeConfirmReq(1)
end

function BattleNpcAutoEscapeSelectAction:OnNpcAutoEscapeDeny()
  self:SendNpcAutoEscapeConfirmReq(0)
  local cfg = _G.DataConfigManager:GetGlobalConfigByKeyType("escape_emote", _G.DataConfigManager.ConfigTableId.BATTLE_GLOBAL_CONFIG)
  if cfg then
    local type = cfg.num
    if not type or 0 == type then
      type = cfg.str
    end
    self.player.BubbleComponent:Play(nil, type)
  end
  if self.roundState then
    if self.roundState == ProtoEnum.BATTLE_STATE_NOTIFY_TYPE.BATTLE_STATE_SELECT_CMD then
      self.fsm:SendEvent(BattleEvent.EnterRoundSelect)
    elseif self.roundState == ProtoEnum.BATTLE_STATE_NOTIFY_TYPE.BATTLE_STATE_SELECT_PET then
      self:Finish()
    else
      self.fsm:SendEvent(BattleEvent.EnterRoundSelect)
    end
  else
    Log.Error("BattleNpcAutoEscapeSelectAction:OnNpcAutoEscapeDeny: no round start notify state received")
  end
end

function BattleNpcAutoEscapeSelectAction:SendNpcAutoEscapeConfirmReq(result)
  local req = _G.ProtoMessage:newZoneBattleNpcEscapeConfirmReq()
  req.npc_uin = self.battleManager.battleRuntimeData:GetNpcAutoEscapeInfo()[1]
  req.agree = result
  _G.BattleNetManager:SendBattleNpcEscapeConfirmReq(req, self, self.OnNpcAutoEscapeConfirmRsp)
end

function BattleNpcAutoEscapeSelectAction:OnNpcAutoEscapeConfirmRsp()
end

function BattleNpcAutoEscapeSelectAction:OnFinish()
  self:RemoveListeners()
end

function BattleNpcAutoEscapeSelectAction:FindActors()
  self.player = self.PawnManger:GetTeamPlayer(BattleEnum.Team.ENUM_ENEMY)
  if self.player then
    local petEnemy = self.PawnManger:GetInFieldPet(BattleEnum.Team.ENUM_ENEMY)
    self.caster = self.player.model
    self.target1 = petEnemy and petEnemy.model or nil
  end
end

function BattleNpcAutoEscapeSelectAction:LoadSkillOver(skillClass)
  if not self.caster then
    self:Finish()
  end
  self.Skill = self.SkillComponent:FindOrAddSkillObj(skillClass)
  self.Skill:RegisterEventCallback("End", self, self.OnSkillEnd)
  self.Skill:RegisterEventCallback("PreEnd", self, self.OnSkillEnd)
  self.Skill:SetCaster(self.caster)
  if self.target then
    self.Skill:SetTargets({
      self.target1
    })
  end
  self.SkillComponent:PlaySkill(self.Skill)
end

function BattleNpcAutoEscapeSelectAction:OnSkillEnd(Event, Skill)
  local Blackboard = Skill:GetBlackboard()
  self:SaveBlackboard(Blackboard, "camActor_0001")
  self:SaveBlackboard(Blackboard, "camActor_0001_SA")
end

function BattleNpcAutoEscapeSelectAction:SaveBlackboard(blackboard, name)
  FsmUtils.SaveAsProperty(self.fsm, blackboard, name)
end

function BattleNpcAutoEscapeSelectAction:ClearVar(name)
  FsmUtils.ClearProperty(self.fsm, name)
end

function BattleNpcAutoEscapeSelectAction:OnExit()
  self:RemoveListeners()
end

return BattleNpcAutoEscapeSelectAction
