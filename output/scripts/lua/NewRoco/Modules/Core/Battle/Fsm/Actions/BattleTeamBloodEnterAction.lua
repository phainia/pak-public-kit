local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local SkillNameIndex = {ThrowBall = 3, ShowPet = 5}
local BattleTeamBloodEnterAction = Base:Extend("BattleTeamBloodEnterAction")
FsmUtils.MergeMembers(Base, BattleTeamBloodEnterAction, {})

function BattleTeamBloodEnterAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.PawnManger = _G.BattleManager.battlePawnManager
end

function BattleTeamBloodEnterAction:OnEnter()
  BattleManager.battlePawnManager:IsShowPetBuffs(false)
  self:SetActionType(BattleActionBase.ActionType.ClientTurnPlayAction)
  local BossPets = self.PawnManger:GetInFieldAllPet(BattleEnum.Team.ENUM_ENEMY, true)
  if BossPets and BossPets[1] then
    self.timeout = 60
    self.BossPet = BossPets[1]
    self.resList = BattleConst.TeamBloodEnterSkill
    self.loadedResCount = 0
    self.BossPetType = self.fsm:GetProperty("BloodPetType", 0)
    self.TeamOpenFlower = nil
    BattleManager.IsRevertPawnPos = true
    self.BossPet:SetIKEnable(false)
    BattleEventCenter:Bind(self, BattleEvent.OnSkillResLoaded, BattleEvent.OnSkillBeforeAsync)
    BattleSkillManager:PreLoadRes(self.resList, true)
  else
    Log.Error("zgx No Boss!!!!")
    self:Finish()
  end
end

function BattleTeamBloodEnterAction:CheckLoadFlowerOver()
  BattleEventCenter:Bind(self, BattleEvent.OnSkillResLoaded)
  BattleSkillManager:PreLoadRes(self.resList, true)
end

function BattleTeamBloodEnterAction:OnBattleEvent(event, ...)
  if event == BattleEvent.OnSkillResLoaded then
    local value = (...)
    for i = 1, #self.resList do
      if value == self.resList[i] then
        self.loadedResCount = self.loadedResCount + 1
      end
    end
    if self.loadedResCount == #self.resList then
      self:OnSkillLoadOver()
    end
    return true
  elseif event == BattleEvent.OnSkillBeforeAsync then
    local value, skillObject = ...
    for i = 1, #self.resList do
      if value == self.resList[i] then
        local skill = skillObject
        local characters = self.PawnManger:GetAllPawnActorForSkill()
        if self.BossPet then
          characters[BattleConst.CharacterIndex.Enemy1] = self.BossPet.model
          skill:SetTargets({
            self.BossPet.model
          })
          skill:SetCaster(characters[BattleConst.CharacterIndex.Player1])
          skill:SetCharacters(characters)
        end
        self:SetBlackBoardForSkillObj(skill, i)
      end
    end
  end
end

function BattleTeamBloodEnterAction:OnSkillLoadOver()
  BattleEventCenter:UnBind(self)
  self.EnterSkillState = 0
  self:StartEnterSkill()
end

function BattleTeamBloodEnterAction:StartEnterSkill(name, skill)
  if not skill or skill == self.SkillObj then
    self.SkillObj = nil
    self.EnterSkillState = self.EnterSkillState + 1
    if self.EnterSkillState <= #BattleConst.TeamBloodEnterSkill then
      if not self.BossPet or not self.BossPet.model then
        self:StartEnterSkill()
        return
      end
      local skillPath = BattleConst.TeamBloodEnterSkill[self.EnterSkillState]
      local skillClass = _G.BattleSkillManager:GetLoadedClass(skillPath)
      if not skillClass then
        Log.WarningFormat("Can't load skill class %s", skillPath)
        self:StartEnterSkill()
        return
      end
      if not UE4.UObject.IsValid(self.PawnManger.TeamatePlayer.model) then
        Log.Warning("There is no model in my player !!!")
        self:StartEnterSkill()
        return
      end
      local skillComponent = self.PawnManger.TeamatePlayer.model.RocoSkill
      local skill = skillComponent:FindOrAddSkillObj(skillClass)
      if not skill then
        Log.WarningFormat("Can't find or load skill object %s %s", skillClass, skillPath)
        self:StartEnterSkill()
        return
      end
      local characters = self.PawnManger:GetAllPawnActorForSkill()
      if self.BossPet then
        characters[BattleConst.CharacterIndex.Enemy1] = self.BossPet.model
        skill:SetTargets({
          self.BossPet.model
        })
      end
      self:SetBlackBoardForSkillObj(skill, self.EnterSkillState)
      if self.EnterSkillState == SkillNameIndex.ShowPet then
        self:SetPetsBuffVisible(false)
      end
      skill:SetCaster(characters[BattleConst.CharacterIndex.Player1])
      skill:SetCharacters(characters)
      skill:RegisterEventCallback("SetBossType", self, self.SetBossType)
      skill:RegisterEventCallback("SaveCamera", self, self.SaveCamera)
      skill:RegisterEventCallback("End", self, self.StartEnterSkill)
      skill:RegisterEventCallback("PreEnd", self, self.StartEnterSkill)
      skill:RegisterEventCallback("PreEndAnim", self, self.StartEnterSkill)
      self.SkillObj = skill
      local currSkill = skillComponent:GetActiveSkill()
      if currSkill then
        skillComponent:CancelSkill(currSkill, UE4.ESkillActionResult.SkillActionResultInterrupted)
      end
      skillComponent:PlaySkill(skill)
    else
      self:Finish()
    end
  end
end

function BattleTeamBloodEnterAction:SetBlackBoardForSkillObj(SkillObj, stateIndex)
  local blackboard = SkillObj:GetBlackboard()
  if blackboard then
    blackboard:SetValueAsString(tostring(self.BossPetType), tostring(self.BossPetType))
  end
  if stateIndex >= SkillNameIndex.ThrowBall then
    local pets = self.PawnManger:GetInFieldAllPet(BattleEnum.Team.ENUM_TEAM)
    if #pets > 0 then
      local ballAddPath = {
        "None",
        "None",
        "None",
        "None"
      }
      for i = 1, #pets do
        local petData = pets[i].card.petInfo.battle_common_pet_info
        ballAddPath[i] = BattleUtils.GetPetBallPath(petData)
        if blackboard then
          local effectBlackboard = "Normal"
          if petData.ball_id and 0 ~= petData.ball_id then
            local BallConfig = _G.DataConfigManager:GetBallConf(petData.ball_id)
            if BallConfig then
              effectBlackboard = BallConfig.catch_effect_blackboard
            end
          end
          if i > 1 then
            effectBlackboard = effectBlackboard .. tostring(i)
          end
          blackboard:SetValueAsString(effectBlackboard, effectBlackboard)
          BattleUtils.SetParticleKeyForSkillObj(pets[i].model, SkillObj, pets[i].card.medalBlackBoard)
        end
      end
      SkillObj:SetDynamicData({BallPath = "None", BallAdditionalPaths = ballAddPath})
    end
  end
end

function BattleTeamBloodEnterAction:SetPetsBuffVisible(isVisible)
  local Pets = self.PawnManger:GetInFieldAllPet(BattleEnum.Team.ENUM_TEAM)
  for _, v in ipairs(Pets) do
    v:ChangeBuffVisibility(isVisible)
  end
end

function BattleTeamBloodEnterAction:ResumeBossPet()
  if self.BossPet and self.BossPet.model and self.BossPet.model:IsA(UE.ARocoCharacter) then
    UE.UNRCCharacterUtils.SetCharacterMeshScale(self.BossPet.model, self.BossPet.card.resourceScale)
    self.BossPet:PinOnTheGround()
  end
end

function BattleTeamBloodEnterAction:SaveCamera(name, skill)
  if skill then
    local blackboard = skill:GetBlackboard()
    if blackboard then
      self:SaveBlackboard(blackboard, "camActor_0005")
      self:SaveBlackboard(blackboard, "camActor_0005_SA")
    end
  end
end

function BattleTeamBloodEnterAction:SetBossType(name, skill)
  if 1 == self.EnterSkillState then
    NRCModeManager:DoCmd(BattleUIModuleCmd.CloseTransformLoadingUI)
  end
end

function BattleTeamBloodEnterAction:SaveBlackboard(blackboard, name)
  FsmUtils.SaveAsProperty(self.fsm, blackboard, name)
end

function BattleTeamBloodEnterAction:OnFinish()
  BattleManager.battlePawnManager:IsShowPetBuffs(true)
  self:SetPetsBuffVisible(true)
  self.BossPet = nil
  NRCModeManager:DoCmd(BattleUIModuleCmd.CloseTransformLoadingUI)
end

return BattleTeamBloodEnterAction
