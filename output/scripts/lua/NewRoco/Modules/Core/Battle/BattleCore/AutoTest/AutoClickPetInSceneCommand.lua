local Base = require("NewRoco.Modules.Core.Battle.BattleCore.AutoTest.BattleAutoCommand")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local AutoClickPetInSceneCommand = Base:Extend("AutoClickPetInSceneCommand")

function AutoClickPetInSceneCommand:Ctor(isEnemy)
  Base.Ctor(self)
  self.IsEnemy = isEnemy
end

function AutoClickPetInSceneCommand:AddListener()
  _G.BattleEventCenter:Bind(self, BattleEvent.ROUND_STATE_SELECT)
end

function AutoClickPetInSceneCommand:ExecuteCommand()
  Base.ExecuteCommand(self)
  local myTeam = _G.BattleManager.battlePawnManager:GetTeam(self.IsEnemy and BattleEnum.Team.ENUM_ENEMY or BattleEnum.Team.ENUM_TEAM)
  local pets = myTeam.pets
  local isCLick = false
  if pets then
    for i = 1, #pets do
      if pets[i] and pets[i].battlePetComponents and pets[i].battlePetComponents.ClickTipUI:IsVisible() then
        isCLick = true
        pets[i]:OnPetClick()
        Log.Debug("BattleAutoTest \231\130\185\229\135\187\228\186\134\229\156\186\230\153\175\229\174\160\231\137\169")
        break
      end
    end
  end
  if not isCLick then
    self:WaitToRepeat()
  end
end

function AutoClickPetInSceneCommand:LogFinish()
  Log.Debug("BattleAutoTest  \231\130\185\229\135\187\229\156\186\230\153\175\229\174\160\231\137\169\231\187\147\230\157\159")
end

function AutoClickPetInSceneCommand:RemoveListener()
  _G.BattleEventCenter:UnBind(self)
end

function AutoClickPetInSceneCommand:Break()
  Log.Error("BattleAutoTest.AutoClickPetInSceneCommand \230\137\167\232\161\140\229\164\177\232\180\165 ,\231\130\185\229\135\187\229\156\186\230\153\175\229\174\160\231\137\169")
  Base.Break(self)
end

function AutoClickPetInSceneCommand:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.ROUND_STATE_SELECT then
    self:CompleteCommand()
    return true
  end
end

return AutoClickPetInSceneCommand
