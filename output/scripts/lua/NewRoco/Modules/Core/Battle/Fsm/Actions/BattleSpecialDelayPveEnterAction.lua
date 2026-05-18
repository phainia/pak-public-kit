local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleSpecialDelayPveEnterAction = Base:Extend("BattleSpecialDelayPveEnterAction")
FsmUtils.MergeMembers(Base, BattleSpecialDelayPveEnterAction, {})

function BattleSpecialDelayPveEnterAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleSpecialDelayPveEnterAction:OnEnter()
  self:ShowPlayer()
  self:ShowPet()
  self:Finish()
end

function BattleSpecialDelayPveEnterAction:ShowPlayer()
  local playerTeams = _G.BattleManager.battlePawnManager:GetAllTeam(BattleEnum.Team.ENUM_TEAM)
  local enemyTeams = _G.BattleManager.battlePawnManager:GetAllTeam(BattleEnum.Team.ENUM_ENEMY)
  for i, v in ipairs(playerTeams) do
    if v and v.player and v.player.model then
      v.player:ShowPlayer()
      local sceneComp = v.player.model:GetComponentByClass(UE4.USceneComponent)
      if sceneComp then
        sceneComp:SetVisibility(true)
      end
      if v.player.battlePlayerComponents then
        v.player.battlePlayerComponents:HideMark()
      end
    end
  end
  for i, v in ipairs(enemyTeams) do
    if v and v.player and v.player.model then
      v.player:ShowPlayer()
      local sceneComp = v.player.model:GetComponentByClass(UE4.USceneComponent)
      if sceneComp then
        sceneComp:SetVisibility(true)
      end
      if v.player.battlePlayerComponents then
        v.player.battlePlayerComponents:HideMark()
      end
    end
  end
end

function BattleSpecialDelayPveEnterAction:ShowPet()
  local playerTeams = _G.BattleManager.battlePawnManager:GetAllTeam(BattleEnum.Team.ENUM_TEAM)
  local enemyTeams = _G.BattleManager.battlePawnManager:GetAllTeam(BattleEnum.Team.ENUM_ENEMY)
  for i, v in ipairs(playerTeams) do
    if #v.pets > 0 then
      for _, p in pairs(v.pets) do
        if p.model and p.card:IsExistAtField() then
          p:ShowPet()
        end
      end
    end
  end
  for i, v in ipairs(enemyTeams) do
    if #v.pets > 0 then
      for _, p in pairs(v.pets) do
        if p.model and p.card:IsExistAtField() then
          p:ShowPet()
        end
      end
    end
  end
end

function BattleSpecialDelayPveEnterAction:OnExit()
end

return BattleSpecialDelayPveEnterAction
