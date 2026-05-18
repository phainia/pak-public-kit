local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BeastPreloadBattleActor = Base:Extend("BeastPreloadBattleActor")
FsmUtils.MergeMembers(Base, BeastPreloadBattleActor, {})

function BeastPreloadBattleActor:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BeastPreloadBattleActor:OnEnter()
  self:LoadHud()
  BattleManager:PrepareBattle()
  if self:CheckIsAsync() then
    self:Finish()
  end
end

function BeastPreloadBattleActor:LoadHud()
  if BattleUtils.IsEnterCatchInTeamBattle() then
    return
  end
  _G.BattleEventCenter:Bind(self, BattleEvent.PrepareBattleOver, BattleEvent.OnSkillBeforeAsync)
  self.fsm:SetProperty("BeastHud", nil)
  local hudRes = "/Game/NewRoco/Modules/Core/Battle/FourEnterHud.FourEnterHud_C"
  _G.BattleResourceManager:LoadWidgetAsync(self, hudRes, UE4.UGameplayStatics:GetPlayerController(0), function(caller, widget)
    caller.fsm:SetProperty("BeastHud", widget)
    caller.fsm:SetProperty("BeastHudRef", UnLua.Ref(widget))
  end, function(caller)
    caller.fsm:SetProperty("BeastHud", false)
  end)
end

function BeastPreloadBattleActor:LoadSkill()
  if BattleUtils.IsEnterCatchInTeamBattle() then
    return false
  end
  local resList = BattleConst.TeamBeastEnterSkill
  self.LoadNum = #resList
  BattleSkillManager:PreLoadRes(resList, true)
end

function BeastPreloadBattleActor:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.PrepareBattleOver then
    self:LoadSkill()
  elseif eventName == BattleEvent.OnSkillBeforeAsync then
    local value, skillObject = ...
    for i = 1, #BattleConst.TeamBeastEnterSkill do
      if value == BattleConst.TeamBeastEnterSkill[i] then
        self.LoadNum = self.LoadNum - 1
        if 0 == self.LoadNum then
          BattleEventCenter:UnBind(self)
        end
        local skill = skillObject
        if _G.BattleManager.battlePawnManager.TeamatePlayer then
          skill:SetCaster(_G.BattleManager.battlePawnManager.TeamatePlayer.model)
        end
        skill:SetCharacters(BattleManager.battlePawnManager:GetAllPawnActorForSkill())
        self:SetBallPath(skillObject)
      end
    end
  end
end

function BeastPreloadBattleActor:SetBallPath(skill)
  local blackboard = skill:GetBlackboard()
  local pets = BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_TEAM)
  if #pets > 0 then
    local ballAddPath = {
      "None",
      "None",
      "None",
      "None"
    }
    local ballAddLinkActor = {}
    for i = 1, #pets do
      local petData = pets[i].card.petInfo.battle_common_pet_info
      ballAddPath[i] = BattleUtils.GetPetBallPath(petData)
      ballAddLinkActor[i] = pets[i].model
      if blackboard then
        local effectBlackboard = "Normal"
        if petData.ball_id and 0 ~= petData.ball_id then
          local BallConfig = _G.DataConfigManager:GetBallConf(petData.ball_id)
          if BallConfig then
            effectBlackboard = BallConfig.catch_effect_blackboard or "Normal"
          end
        end
        blackboard:SetValueAsString("IsCommon", "IsCommon")
        BattleUtils.SetParticleKeyForSkillObj(pets[i].model, skill, effectBlackboard)
        BattleUtils.SetParticleKeyForSkillObj(pets[i].model, skill, pets[i].card.medalBlackBoard)
        BattleUtils.SetParticleKeyForSkillObj(pets[i].player.model, skill, effectBlackboard)
      end
    end
    skill:SetDynamicData({
      BallPath = "None",
      BallAdditionalPaths = ballAddPath,
      BallAddLinkActors = ballAddLinkActor
    })
  end
end

return BeastPreloadBattleActor
