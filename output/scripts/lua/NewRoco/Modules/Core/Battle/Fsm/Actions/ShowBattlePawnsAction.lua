local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local AIBlackboardKeyDefine = require("NewRoco.AI.BehaviorTree.Pet.AIBlackboardKeyDefine")
local BattleExitHelper = require("NewRoco.Modules.Core.Battle.Players.BattleExitHelper")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local ShowBattlePawnsAction = Base:Extend("ShowBattlePawnsAction")
FsmUtils.MergeMembers(Base, ShowBattlePawnsAction, {})

function ShowBattlePawnsAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.PawnManger = _G.BattleManager.battlePawnManager
end

function ShowBattlePawnsAction:OnEnter()
  if not self.PawnManger:IsValid() then
    self:Finish()
    return
  end
  for i, v in ipairs(self.PawnManger:GetAllTeam(BattleEnum.Team.ENUM_TEAM)) do
    self:ShowPlay(v)
  end
  for i, v in ipairs(self.PawnManger:GetAllTeam(BattleEnum.Team.ENUM_ENEMY)) do
    self:ShowPlay(v)
  end
  self:Finish()
end

function ShowBattlePawnsAction:ShowPlay(battleTeam)
  if battleTeam.player and battleTeam.player.model and UE4.UObject.IsValid(battleTeam.player.model) then
    battleTeam.player:ShowPlayer()
    local sceneComp = battleTeam.player.model:GetComponentByClass(UE4.USceneComponent)
    if sceneComp then
      sceneComp:SetVisibility(true)
    end
    battleTeam.player.model:TryHelmetOn()
    local battlePlayerComponents = battleTeam.player.battlePlayerComponents
    if battlePlayerComponents and battlePlayerComponents.HideMark then
      battleTeam.player.battlePlayerComponents:HideMark()
    end
  end
  if battleTeam.pets then
    for _, p in pairs(battleTeam.pets) do
      if p.model and p.card:IsExistAtField() then
        p:ShowPet()
      end
    end
  end
end

function ShowBattlePawnsAction:OnFinish()
end

function ShowBattlePawnsAction:OnExit()
end

return ShowBattlePawnsAction
