local Base = require("NewRoco.Modules.Core.Battle.BattleCore.AutoTest.BattleAutoCommand")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local AutoCatchPetInBagCommand = Base:Extend("AutoCatchPetInBagCommand")

function AutoCatchPetInBagCommand:Ctor(ballId)
  Base.Ctor(self)
  self.BallId = ballId
end

function AutoCatchPetInBagCommand:ExecuteCommand()
  Base.ExecuteCommand(self)
  local BattleMain = BattleUtils.GetMainWindow()
  if BattleMain then
    if not BattleMain.isShowing then
      self:WaitToRepeat()
    elseif BattleMain._inPanelChanging then
      self:WaitToRepeat()
    elseif BattleMain._curOperateType == BattleEnum.Operation.ENUM_CATCH then
      local ballPanel = BattleMain.BallOperation
      if ballPanel:IsVisible() then
        local balls = ballPanel.Balls
        local isClick = false
        for i = 1, #balls do
          if balls[i] and balls[i].ballData and balls[i].ballData.id == self.BallId then
            isClick = true
            balls[i]:_OnItemPressed()
            balls[i]:_OnItemRelease()
            Log.Debug("BattleAutoTest \231\130\185\229\135\187\228\186\134\229\146\149\229\153\156\231\144\131\232\131\140\229\140\133 ", self.BallId)
            break
          end
        end
        if not isClick then
          self:WaitToRepeat()
        else
          Log.Debug("BattleAutoTest  \231\130\185\229\135\187\228\186\134\229\146\149\229\153\156\231\144\131\232\131\140\229\140\133\231\187\147\230\157\159 ", self.BallId)
          self:CompleteCommand()
        end
      else
        self:WaitToRepeat()
      end
    else
      _G.BattleEventCenter:Dispatch(BattleEvent.CHANGE_OPERATE_TYPE, 2, true)
      self:WaitToRepeat()
    end
  else
    self:WaitToRepeat()
  end
end

function AutoCatchPetInBagCommand:Break()
  Log.Error("BattleAutoTest.AutoCatchPetInBagCommand \230\137\167\232\161\140\229\164\177\232\180\165 ,\231\130\185\229\135\187\228\186\134\229\146\149\229\153\156\231\144\131\232\131\140\229\140\133 \229\146\149\229\153\156\231\144\131id  ", self.BallId)
  Base.Break(self)
end

return AutoCatchPetInBagCommand
