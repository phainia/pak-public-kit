local AIBlackboardKeyDefine = require("NewRoco.AI.BehaviorTree.Pet.AIBlackboardKeyDefine")
local BattleExitHelper = require("NewRoco.Modules.Core.Battle.Players.BattleExitHelper")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local HideBattlePawnsAction = Base:Extend("HideBattlePawnsAction")
FsmUtils.MergeMembers(Base, HideBattlePawnsAction, {})

function HideBattlePawnsAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.PawnManger = _G.BattleManager.battlePawnManager
end

function HideBattlePawnsAction:OnEnter()
  local allTeams = self.PawnManger:GetAllTeam(BattleEnum.Team.ENUM_TEAM)
  if not allTeams then
    self:Finish()
    return
  end
  for i, v in ipairs(allTeams) do
    if v.player and v.player.model then
      v.player:HidePlayer()
      local sceneComp = v.player.model:GetComponentByClass(UE4.USceneComponent)
      if sceneComp then
        sceneComp:SetVisibility(false)
      end
    end
    if #v.pets > 0 then
      for _, p in pairs(v.pets) do
        if p.model and p.card:IsExistAtField() then
          p:HidePet()
        end
      end
    end
  end
  for i, v in ipairs(self.PawnManger:GetAllTeam(BattleEnum.Team.ENUM_ENEMY)) do
    if v.player and v.player.model then
      v.player:HidePlayer()
      local sceneComp = v.player.model:GetComponentByClass(UE4.USceneComponent)
      if sceneComp then
        sceneComp:SetVisibility(false)
      end
    end
    if #v.pets > 0 then
      for _, p in pairs(v.pets) do
        if p.model and p.card:IsExistAtField() then
          p:HidePet()
        end
      end
    end
  end
  self:Finish()
end

function HideBattlePawnsAction:OnFinish()
end

function HideBattlePawnsAction:OnExit()
end

return HideBattlePawnsAction
