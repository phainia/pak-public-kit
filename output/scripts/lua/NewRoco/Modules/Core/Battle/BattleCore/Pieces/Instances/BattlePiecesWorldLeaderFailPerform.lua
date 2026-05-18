local BattlePiecesPlaySkill = require("NewRoco.Modules.Core.Battle.BattleCore.Pieces.Instances.BattlePiecesPlaySkill")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattlePiecesPlaySkill
local BattlePiecesWorldLeaderFailPerform = Base:Extend("BattlePiecesWorldLeaderFailPerform")

function BattlePiecesWorldLeaderFailPerform:Play(action, finishCallBack)
  self.TriggerAction = action
  self.FinishCallBack = finishCallBack
  self.resList = BattleConst.WorldLeaderFailExit
  BattleEventCenter:Bind(self, BattleEvent.OnSkillResLoaded)
  Base.Play(self)
end

function BattlePiecesWorldLeaderFailPerform:IsActionRunning()
  if self.TriggerAction then
    if self.TriggerAction.finished or not self.TriggerAction.active then
      return false
    else
      return true
    end
  end
end

function BattlePiecesWorldLeaderFailPerform:OnResLoadFinish()
  if self:IsActionRunning() then
    self:PrepareFirst()
  end
end

function BattlePiecesWorldLeaderFailPerform:PrepareFirst()
  BattleEventCenter:UnBind(self)
  local Boss = BattleManager.battlePawnManager:GetInFieldPet(BattleEnum.Team.ENUM_ENEMY)
  if not Boss then
    Log.Warning("There is no Enemy Boss")
    self:Complete()
    return
  end
  local skillComponent = Boss.model.RocoSkill
  if not skillComponent then
    Log.Warning("There is no skillComponent")
    self:Complete()
    return
  end
  _G.BattleManager.battlePawnManager:TogglePetBuffsVisibility(false)
  local MyPet = BattleManager.battlePawnManager:GetInFieldPet(BattleEnum.Team.ENUM_TEAM) or {}
  local MyCastObject = CastSkillObject.FromSkillResID(BattleConst.WorldLeaderFailExit[1])
  if MyCastObject then
    MyCastObject:SetCallbackOwner(self)
    MyCastObject:SetCaster(Boss.model)
    MyCastObject:SetTargetPets({MyPet})
    MyCastObject:SetInterrupt(true)
    MyCastObject:SetCharacters(BattleManager.battlePawnManager:GetAllPawnActorForSkill())
    MyCastObject:SetCompleteCallback(self.OnFirstSkillFinish)
    self:PlaySkill(Boss, skillComponent, MyCastObject)
  else
    Log.Error("zgx res is vaild!!", BattleConst.WorldLeaderFailExit[1])
    self:OnFirstSkillFinish()
  end
end

function BattlePiecesWorldLeaderFailPerform:OnFirstSkillFinish()
  if not self:IsActionRunning() then
    self:Complete()
    return
  end
  local player = BattleManager.battlePawnManager.TeamatePlayer
  if not player or not player.model then
    Log.Warning("There is no model in TeamatePlayer !!!")
    self:Complete()
    return
  end
  local skillComponent = player.model.RocoSkill
  if not skillComponent then
    Log.Warning("There is no skillComponent")
    self:Complete()
    return
  end
  _G.BattleManager.battlePawnManager:HideAll(true)
  local MyPet = BattleManager.battlePawnManager:GetInFieldPet(BattleEnum.Team.ENUM_TEAM) or {}
  local MyCastObject = CastSkillObject.FromSkillResID(BattleConst.WorldLeaderFailExit[2])
  if MyCastObject then
    player:Show()
    local characters = {}
    characters[0] = player.model
    MyCastObject:SetInterrupt(true)
    MyCastObject:SetCallbackOwner(self)
    MyCastObject:SetCaster(player.model)
    MyCastObject:SetTargetPets({MyPet})
    MyCastObject:SetCharacters(characters)
    MyCastObject:SetCompleteCallback(self.SkillFinish)
    if MyPet.model then
      MyCastObject:SetDynamicData({
        BallPath = MyPet:GetBallPath()
      })
    end
    self:PlaySkill(player, skillComponent, MyCastObject)
  else
    Log.Error("zgx res is vaild!!", BattleConst.WorldLeaderFailExit[2])
    self:Complete()
  end
end

function BattlePiecesWorldLeaderFailPerform:SkillFinish(name, skill)
  self:Complete()
end

function BattlePiecesWorldLeaderFailPerform:OnComplete()
  if self:IsActionRunning() then
    self.TriggerAction:Finish()
    self.FinishCallBack(self.TriggerAction)
  end
  self.TriggerAction = nil
  self.FinishCallBack = nil
end

return BattlePiecesWorldLeaderFailPerform
