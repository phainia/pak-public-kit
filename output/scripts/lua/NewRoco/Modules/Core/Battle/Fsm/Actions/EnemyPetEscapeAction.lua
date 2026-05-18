local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local AIBlackboardKeyDefine = require("NewRoco.AI.BehaviorTree.Pet.AIBlackboardKeyDefine")
local BattleExitHelper = require("NewRoco.Modules.Core.Battle.Players.BattleExitHelper")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local EnemyPetEscapeAction = Base:Extend("EnemyPetEscapeAction")
FsmUtils.MergeMembers(Base, EnemyPetEscapeAction, {})

function EnemyPetEscapeAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.PawnManger = _G.BattleManager.battlePawnManager
end

function EnemyPetEscapeAction:FindActors()
  self.BattlePet = self.PawnManger:GetFirstPet(BattleEnum.Team.ENUM_ENEMY)
  self.BattlePlayer = self.PawnManger:GetPlayerMyTeam()
  self.WorldPlayer = BattleUtils.GetPlayer()
  self.TraceCache = BattleUtils.GetTraceNpc()
  if self.TraceCache then
    self.WorldPet = self.TraceCache.npc
    if not self.WorldPet.viewObj then
      self.WorldPet = nil
    end
  else
    self.WorldPet = nil
  end
end

function EnemyPetEscapeAction:OnEnter()
  self:FindActors()
  self.PawnManger:TogglePetBuffsVisibility(false)
  if self.BattlePet and self.BattlePet.card and self.BattlePet.card:IsCanSelect() then
    self.SkillComponent = _G.BattleManager.vBattleField.battleFieldActor.Skill
    _G.NRCResourceManager:LoadResAsync(self, self:GetRunAwaySkill(), -1, 10, self.LoadSkillOver, self.Finish)
  else
    self:OnSkillStart()
    self:HideMain()
    self:PetRun()
    self:Finish()
  end
end

function EnemyPetEscapeAction:GetRunAwaySkill()
  return BattleConst.EnemyEscape.SkillPath
end

function EnemyPetEscapeAction:LoadSkillOver(request, skillClass)
  if not self.SkillComponent then
    return
  end
  self.Skill = self.SkillComponent:FindOrAddSkillObj(skillClass)
  self.Skill:RegisterEventCallback("Start", self, self.OnSkillStart)
  self.Skill:RegisterEventCallback("End", self, self.OnSkillEnd)
  self.Skill:RegisterEventCallback("Hide", self, self.HideMain)
  self.Skill:RegisterEventCallback("Run", self, self.PetRun)
  self.Skill:RegisterEventCallback("PreEndAnim", self, self.OnSkillEnd)
  self.Skill:SetCaster(self.WorldPlayer.viewObj)
  if self.WorldPet and self.BattlePet then
    self.Skill:SetTargets({
      self.BattlePet.model,
      self.WorldPet.viewObj
    })
  elseif self.BattlePet then
    self.Skill:SetTargets({
      self.BattlePet.model,
      self.BattlePet.model
    })
  end
  self.SkillComponent:PlaySkill(self.Skill)
end

function EnemyPetEscapeAction:OnSkillEnd(Event, Skill)
  local Blackboard = Skill:GetBlackboard()
  self:SaveBlackboard(Blackboard, "camActor_0001")
  self:SaveBlackboard(Blackboard, "camActor_0001_SA")
  self:Finish()
end

function EnemyPetEscapeAction:HideMain()
  self:ShowWorldPet()
  self:ShowWorldPlayer()
  self:HideBattlePawns()
  _G.NRCModeManager:DoCmd(BattleUIModuleCmd.HideMainWindow, false, false)
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.HideBattlePopupPanel)
end

function EnemyPetEscapeAction:PetRun()
  if not BattleManager.isInBattle then
    return
  end
  BattleExitHelper.ResetPlayerCamera()
end

function EnemyPetEscapeAction:OnSkillStart()
  if self.WorldPlayer then
    local ueController = self.WorldPlayer:GetUEController()
    ueController:ResetCamera()
  end
end

function EnemyPetEscapeAction:ShowWorldPlayer()
  local PetActor
  if self.WorldPet then
    self.WorldPet:SetVisibleForBattleReason(true)
    PetActor = self.WorldPet.viewObj
  end
  if self.WorldPlayer and PetActor then
    NRCModeManager:DoCmd(PlayerModuleCmd.HIDE_LOCAL_PLAYER, false)
    BattleUtils.SetPlayerSkmTickable(true)
    local PlayerActor = self.WorldPlayer.viewObj
    BattleExitHelper.LookAt(PlayerActor, self.WorldPet and self.WorldPet.viewObj or self.BattlePet.model)
    Log.Debug("Show Player Actor Transform", PlayerActor:GetName(), tostring(PlayerActor:Abs_GetTransform()))
  end
end

function EnemyPetEscapeAction:HideBattlePawns()
  if self.BattlePet then
    self.BattlePet:HidePet()
  end
  if self.BattlePlayer then
    self.BattlePlayer:HidePlayer()
  end
end

function EnemyPetEscapeAction:ShowWorldPet()
  if self.WorldPet then
    self.WorldPet:SetVisibleForBattleReason(true)
  end
end

function EnemyPetEscapeAction:OnFinish()
  self.Skill = nil
  self.SkillComponent = nil
  self.BattlePet = nil
  self.BattlePlayer = nil
  self.WorldPet = nil
  self.WorldPlayer = nil
end

function EnemyPetEscapeAction:SaveBlackboard(blackboard, name)
  FsmUtils.SaveAsProperty(self.fsm, blackboard, name)
end

function EnemyPetEscapeAction:ClearVar(name)
  FsmUtils.ClearProperty(self.fsm, name)
end

function EnemyPetEscapeAction:OnExit()
  self:ClearVar("camActor_0001")
  self:ClearVar("camActor_0001_SA")
end

return EnemyPetEscapeAction
