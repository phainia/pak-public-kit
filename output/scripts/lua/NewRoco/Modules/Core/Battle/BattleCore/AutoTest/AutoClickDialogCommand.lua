local Base = require("NewRoco.Modules.Core.Battle.BattleCore.AutoTest.BattleAutoCommand")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local AutoClickDialogCommand = Base:Extend("AutoClickDialogCommand")

function AutoClickDialogCommand:Ctor(isClickOk)
  Base.Ctor(self)
  self.IsClickOk = isClickOk
end

function AutoClickDialogCommand:ExecuteCommand()
  Base.ExecuteCommand(self)
  local TipsModule = _G.NRCModuleManager:GetModule("TipsModule")
  if TipsModule then
    local isOpening, _ = TipsModule:HasPanel("UMG_Dialog")
    if isOpening then
      local DialogCtrl = TipsModule:GetPanel("UMG_Dialog")
      local clickBtn
      if self.IsClickOk then
        if DialogCtrl.BtnOk and DialogCtrl.BtnOk:IsVisible() then
          clickBtn = DialogCtrl.BtnOk.NxButton
        end
      elseif DialogCtrl.BtnCancel and DialogCtrl.BtnCancel:IsVisible() then
        clickBtn = DialogCtrl.BtnCancel.NxButton
      end
      if clickBtn then
        Log.Debug("BattleAutoTest \229\147\141\229\186\148\228\186\134\229\175\185\232\175\157\230\161\134  IsClickOk ", self.IsClickOk)
        clickBtn.OnClicked:Broadcast()
        self:CompleteCommand()
      else
        self:WaitToRepeat()
      end
    else
      self:WaitToRepeat()
    end
  else
    self:WaitToRepeat()
  end
end

function AutoClickDialogCommand:LogFinish()
  Log.Debug("BattleAutoTest  \231\130\185\229\135\187\229\175\185\232\175\157\230\161\134\229\174\140\230\136\144")
end

function AutoClickDialogCommand:Break()
  Log.Error("BattleAutoTest.AutoClickDialogCommand \230\137\167\232\161\140\229\164\177\232\180\165 \231\130\185\229\135\187\229\175\185\232\175\157\230\161\134\230\178\161\230\156\137\230\137\167\232\161\140")
  Base.Break(self)
end

return AutoClickDialogCommand
