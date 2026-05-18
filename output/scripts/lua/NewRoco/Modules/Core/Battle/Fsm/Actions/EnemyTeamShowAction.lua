local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local EnemyTeamShowAction = BattleActionBase:Extend("EnemyTeamShowAction")

function EnemyTeamShowAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
  self.PawnManager = self.BattleManager.battlePawnManager
  self.CameraManager = self.BattleManager.vBattleField.battleCameraManager
end

function EnemyTeamShowAction:GetTarget()
  self.targetPets = self.PawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_ENEMY) or {}
  for i = #self.targetPets, 1 do
    if self.targetPets[i].player ~= self.PawnManager.EnemyPlayer then
      table.remove(self.targetPets, i)
    end
  end
  self.targetModels = {}
  for i, v in ipairs(self.targetPets) do
    self.targetModels[i] = v.model
  end
end

function EnemyTeamShowAction:OnEnter()
  if self.PawnManager.EnemyPlayer and self.PawnManager.EnemyPlayer.model then
    local skillPath = BattleConst.ZhaoHuan
    self:GetTarget()
    if _G.BattleManager.vBattleField.battleCameraManager then
      _G.BattleManager.vBattleField.battleCameraManager:ChangeToPlayerPet(0)
    end
    _G.NRCResourceManager:LoadResAsync(self, skillPath, -1, 10, self.OnSkillLoad, self.Finish)
  else
    self:Finish()
  end
end

function EnemyTeamShowAction:OnSkillLoad(request, skillClass)
  if skillClass then
    local Player = self.PawnManager.EnemyPlayer
    if Player.model then
      local Skill = Player.model.RocoSkill:AddSkillObjFromClassAndReturn(skillClass)
      local characters = _G.BattleManager.battlePawnManager:GetAllPawnActorForSkill()
      local ballPath = BattleUtils.GetPetBallPath(self.targetPets[1].card.petInfo.battle_common_pet_info)
      local ballAddPath = {"None", "None"}
      for i = 2, #self.targetPets do
        ballAddPath[i - 1] = BattleUtils.GetPetBallPath(self.targetPets[i].card.petInfo.battle_common_pet_info)
      end
      if 1 == #self.targetPets then
        Skill.PlayerAmountType = 1
        if characters[12] == self.targetPets[1].model then
          characters[13] = nil
        else
          characters[12] = nil
        end
      else
        Skill.PlayerAmountType = 2
      end
      Skill:SetDynamicData({BallPath = ballPath, BallAdditionalPaths = ballAddPath})
      Skill:SetCaster(Player.model)
      Skill:SetTargets(self.targetModels)
      Skill:SetCharacters(characters)
      Skill:RegisterEventCallback("End", self, self.OnSkillFinish)
      Player:PlaySkillObject(Skill)
    end
  end
end

function EnemyTeamShowAction:OnSkillFinish(Event, Skill)
  local Blackboard = Skill:GetBlackboard()
  self:SaveObject(Blackboard, BattleConst.PlayerShow.Cam)
  self:SaveObject(Blackboard, BattleConst.PlayerShow.Cam_SA)
  self:Finish()
end

function EnemyTeamShowAction:SaveObject(bb, name)
  FsmUtils.SaveAsProperty(self.fsm, bb, name)
end

function EnemyTeamShowAction:OnExit()
  self.BattleManager = nil
  self.PawnManager = nil
  self.CameraManager = nil
end

return EnemyTeamShowAction
