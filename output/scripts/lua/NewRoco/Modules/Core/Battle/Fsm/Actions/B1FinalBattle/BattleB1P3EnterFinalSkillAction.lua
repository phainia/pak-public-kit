local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattleActionBase
local BattleB1P3EnterFinalSkillAction = Base:Extend("BattleB1P3EnterFinalSkillAction")

function BattleB1P3EnterFinalSkillAction:OnEnter()
  self.fsm:Pause()
  self.BattleManager = _G.BattleManager
  self.PawnManager = self.BattleManager.battlePawnManager
  self.CurrentPlayer = self.PawnManager.TeamatePlayer
  for i, v in ipairs(self.CurrentPlayer.deck.cards) do
    if v:IsExistAtField() then
      self.CurrentPet = self.PawnManager:GetPetByGuid(v.guid)
    end
  end
  self.CurrentEnemyPet = self.PawnManager:GetFirstPet(BattleEnum.Team.ENUM_ENEMY)
  _G.BattleManager.vBattleField.battleCraneCamera:ChangeCameraTagDirect(UE4.EBattleCameraTags.B1FBSP3_MasterSkill, 0)
  self.finalSkillId = _G.DataConfigManager:GetBattleGlobalConfig("B1_FINAL_BATTLE_STATE3_LB").num
  self.finalSkill = self.CurrentPet.skillComponent:GetSkillBySkillID(self.finalSkillId)
  self:TryShowFinalSkillUI()
end

function BattleB1P3EnterFinalSkillAction:TryShowFinalSkillUI()
  NRCModeManager:DoCmd(BattleUIModuleCmd.HideMainWindow, false, false)
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.HideBattlePopupPanel)
  _G.BattleEventCenter:Bind(self, BattleEvent.BATTLE_CLICKED_SKILL)
  self.HasListen = true
  _G.NRCEventCenter:RegisterEvent("BattleB1P3EnterFinalSkillAction", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnectStart)
  self:ShowFinalSkillUI()
end

function BattleB1P3EnterFinalSkillAction:ShowFinalSkillUI()
  NRCModeManager:DoCmd(BattleUIModuleCmd.HideMainWindow, false, false)
  local currenPet
  local teamPets = _G.BattleManager.battlePawnManager:GetTeamAllPets()
  local teamMatePlayer = _G.BattleManager.battlePawnManager.TeamatePlayer
  for _, pet in pairs(teamPets) do
    if pet.player == teamMatePlayer then
      currenPet = pet
      break
    end
  end
  _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.OpenBattleUltimateSkillUI, currenPet)
end

function BattleB1P3EnterFinalSkillAction:OnReConnectStart()
  self.isWaitForRsp = nil
  self:ShowFinalSkillUI()
end

function BattleB1P3EnterFinalSkillAction:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.BATTLE_CLICKED_SKILL then
    self:SendFinalSkill()
  end
end

function BattleB1P3EnterFinalSkillAction:SendFinalSkill()
  if self.isWaitForRsp then
    return
  end
  local req = BattleNetManager:BuildBattleCmdPushbackReq()
  req.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL
  local BattleRoundFlowReq = {}
  BattleRoundFlowReq.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL
  BattleRoundFlowReq.cast_skill = {}
  BattleRoundFlowReq.cast_skill.skill_id = self.finalSkill.id
  BattleRoundFlowReq.cast_skill.caster_pet_id = self.CurrentPet.guid
  BattleRoundFlowReq.cast_skill.target_pet_id = self.CurrentEnemyPet.guid
  local BattleRoundFlowReqList = {}
  table.insert(BattleRoundFlowReqList, BattleRoundFlowReq)
  req.req = BattleRoundFlowReqList
  self.isWaitForRsp = true
  _G.BattleNetManager:SendBattleCmdPushbackReq(req, self, self.OnPushbackSent)
  self.fsm:Resume()
end

function BattleB1P3EnterFinalSkillAction:OnPushbackSent(rsp)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnectStart)
end

function BattleB1P3EnterFinalSkillAction:OnFinish()
  if self.HasListen then
    _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnectStart)
  end
  self.HasListen = nil
end

return BattleB1P3EnterFinalSkillAction
