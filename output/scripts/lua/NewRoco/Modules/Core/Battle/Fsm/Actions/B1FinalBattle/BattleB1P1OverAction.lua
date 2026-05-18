local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local Base = BattleActionBase
local BattleB1P1OverAction = Base:Extend("BattleB1P1OverAction")
FsmUtils.MergeMembers(Base, BattleB1P1OverAction, {})

function BattleB1P1OverAction:OnEnter()
  if not BattleUtils.IsB1FinalBattleP1() then
    self:OnSkillComplete()
    return
  end
  local survivePet = _G.BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_TEAM, true)
  if not survivePet or 0 == #survivePet then
    self:OnSkillComplete()
    return
  end
  _G.BattleManager.battleRuntimeData:RemoveB1P1BallActor()
  self.enemyPlayer = _G.BattleManager.battlePawnManager:GetPlayerEnemyTeam()
  BattleSkillManager:PreLoadSingleRes(BattleConst.B1P1EndG6, true, self, self.OnSkillLoad)
end

function BattleB1P1OverAction:OnSkillLoad(isLoadSucceed, resPath)
  if not isLoadSucceed or not self.enemyPlayer.model then
    Log.Error("BattleB1P1OverAction:OnSkillLoad Skill Object not found %s", resPath)
    self:OnSkillComplete()
    return
  end
  self.RocoSkill = self.enemyPlayer.model.RocoSkill
  local pet = _G.BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_TEAM, true)
  local CastParam = CastSkillObject.Create()
  CastParam.ResID = resPath
  CastParam:SetCaster(self.enemyPlayer.model)
  CastParam:SetTargetPets(pet)
  CastParam:SetIsPassive(true)
  CastParam:SetCallbackOwner(self)
  CastParam:SetCompleteCallback(self.OnSkillComplete)
  CastParam:SetCharacters(_G.BattleManager.battlePawnManager:GetAllPawnActorForSkill())
  CastParam:AddExtraEvent("ShowDamage", self.SimulateTookDamage)
  CastParam:AddExtraEvent("TriggerBeHit", self.SimulateTookDamage)
  local _, skillObj = BattleSkillManager:PrepareSkill(self.enemyPlayer, self.RocoSkill, CastParam)
  if not skillObj then
    Log.Error("BattleB1P1OverAction:OnSkillLoad Skill Object not found %s", resPath)
    self:Finish()
    return
  end
  skillObj:RegisterEventCallback("ActionStart", self, self.OnActionStart)
  local result = self.RocoSkill:PlaySkill(skillObj)
  if 0 ~= result then
    Log.Warning("BattleB1P1OverAction:OnSkillLoad", result)
    self:OnSkillComplete()
  end
end

function BattleB1P1OverAction:OnActionStart()
  BattleResourceManager:LoadResAsync(self, BattleConst.B1P2EnterSequence)
end

function BattleB1P1OverAction:SimulateTookDamage()
  Log.Debug("BattleB1P1EnterPerformAction:SimulateTookDamage")
  local target = _G.BattleManager.battlePawnManager:GetFirstPet(BattleEnum.Team.ENUM_TEAM)
  if not target then
    return
  end
  local damage_info = {
    caster_id = target.guid,
    target_id = target.guid,
    is_critical = {false},
    restraint_type = 0,
    has_shield = false,
    dam_type = 2,
    curDamageNumber = 1,
    totalDamageNumber = 1
  }
  target:TookDamage(999, -999, damage_info)
  local option = {
    petId = target.guid,
    imme = false,
    delaySeconds = 0
  }
  _G.BattleDataCenter:Dispatch(BattlePerformEvent.HitBattlePet, option)
end

function BattleB1P1OverAction:OnSkillComplete()
  _G.BattleEventCenter:Dispatch(BattleEvent.HIDE_HP_RED)
  local mainWindow = BattleUtils.GetMainWindow()
  if mainWindow then
    mainWindow:SetShowForRecordingAndChatBtn(false)
  end
  _G.BattleEventCenter:Dispatch(BattleEvent.BATTLE_PLAYERSKILL_ISHIDE_HP, false)
  NRCModeManager:DoCmd(BattleUIModuleCmd.MainHideAll, false)
  _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.OPEN_BLACK_SCREEN, true, self, self.Finish)
end

function BattleB1P1OverAction:OnFinish()
  self.RocoSkill = nil
  self.enemyPlayer = nil
end

return BattleB1P1OverAction
