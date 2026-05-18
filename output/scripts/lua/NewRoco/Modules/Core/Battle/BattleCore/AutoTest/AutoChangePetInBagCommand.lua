local Base = require("NewRoco.Modules.Core.Battle.BattleCore.AutoTest.BattleAutoCommand")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local AutoChangePetInBagCommand = Base:Extend("AutoChangePetInBagCommand")

function AutoChangePetInBagCommand:Ctor(petId)
  Base.Ctor(self)
  self.PetId = petId
end

function AutoChangePetInBagCommand:ExecuteCommand()
  Base.ExecuteCommand(self)
  local BattleMain = BattleUtils.GetMainWindow()
  if BattleMain then
    if not BattleMain.isShowing then
      self:WaitToRepeat()
    elseif BattleMain._inPanelChanging then
      self:WaitToRepeat()
    elseif BattleMain._curOperateType == BattleEnum.Operation.ENUM_CHANGE then
      local petPanel = BattleMain.ChangePetPanel
      if petPanel:IsVisible() then
        local cards = petPanel.items
        local isClick = false
        for i = 1, #cards do
          if cards[i] and cards[i].card and cards[i].card.config.id == self.PetId and not cards[i].statImage:IsVisible() then
            isClick = true
            cards[i]:_OnItemPressed()
            cards[i]:_OnItemRelease()
            Log.Debug("BattleAutoTest \231\130\185\229\135\187\228\186\134\232\131\140\229\140\133\229\174\160\231\137\169 ", self.PetId)
            break
          end
        end
        if not isClick then
          self:WaitToRepeat()
        else
          Log.Debug("BattleAutoTest  \231\130\185\229\135\187\232\131\140\229\140\133\229\174\160\231\137\169\231\187\147\230\157\159 ", self.PetId)
          self:CompleteCommand()
        end
      else
        self:WaitToRepeat()
      end
    else
      _G.BattleEventCenter:Dispatch(BattleEvent.CHANGE_OPERATE_TYPE, 3, true)
      self:WaitToRepeat()
    end
  else
    self:WaitToRepeat()
  end
end

function AutoChangePetInBagCommand:Break()
  Log.Error("BattleAutoTest.AutoChangePetInBagCommand \230\137\167\232\161\140\229\164\177\232\180\165 ,\231\130\185\229\135\187\228\186\134\232\131\140\229\140\133\229\174\160\231\137\169 \229\174\160\231\137\169id  ", self.PetId)
  Base.Break(self)
end

return AutoChangePetInBagCommand
