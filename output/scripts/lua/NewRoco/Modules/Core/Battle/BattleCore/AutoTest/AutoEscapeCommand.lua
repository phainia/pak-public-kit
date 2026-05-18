local Base = require("NewRoco.Modules.Core.Battle.BattleCore.AutoTest.BattleAutoCommand")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local AutoEscapeCommand = Base:Extend("AutoEscapeCommand")

function AutoEscapeCommand:Ctor()
  Base.Ctor(self)
end

function AutoEscapeCommand:ExecuteCommand()
  Base.ExecuteCommand(self)
  local BattleMain = BattleUtils.GetMainWindow()
  if BattleMain then
    if not BattleMain.isShowing then
      self:WaitToRepeat()
    elseif BattleMain._inPanelChanging then
      self:WaitToRepeat()
    elseif BattleMain._curOperateType == BattleEnum.Operation.ENUM_ESCAPE then
      self:CompleteCommand()
    else
      Log.Debug("BattleAutoTest \231\130\185\229\135\187\228\186\134\233\128\131\232\183\145")
      _G.BattleEventCenter:Dispatch(BattleEvent.CHANGE_OPERATE_TYPE, 0, true)
      self:WaitToRepeat()
    end
  else
    self:WaitToRepeat()
  end
end

function AutoEscapeCommand:LogFinish()
  Log.Debug("BattleAutoTest  \233\128\131\232\183\145\229\145\189\228\187\164\231\187\147\230\157\159")
end

function AutoEscapeCommand:Break()
  Log.Error("BattleAutoTest.AutoEscapeCommand \230\137\167\232\161\140\229\164\177\232\180\165 \233\128\131\232\183\145\229\145\189\228\187\164\230\178\161\230\156\137\230\137\167\232\161\140")
  Base.Break(self)
end

return AutoEscapeCommand
