local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = BattleActionBase
local BattleCheckBattlePlayerOverAction = Base:Extend("BattleCheckBattlePlayerOverAction")

function BattleCheckBattlePlayerOverAction:Ctor()
  Base.Ctor(self)
  self:SetActionType(BattleActionBase.ActionType.ClientLoadResAction)
end

function BattleCheckBattlePlayerOverAction:OnEnter()
  self:OnTick(0)
end

function BattleCheckBattlePlayerOverAction:OnTick(DeltaTime)
  local players = BattleManager.battlePawnManager:GetAllPlayers()
  local isLoadedOver = true
  for i = 1, #players do
    if not players[i]:IsLoadOver() then
      isLoadedOver = false
      return
    end
  end
  self:Finish()
end

return BattleCheckBattlePlayerOverAction
