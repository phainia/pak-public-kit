local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local BattleRoundAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Round.BattleRoundAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = BattleRoundAction
local RoundGiveUpAction = Base:Extend("RoundGiveUpAction")
FsmUtils.MergeMembers(Base, RoundGiveUpAction, {})

function RoundGiveUpAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self:SetActionType(BattleActionBase.ActionType.ClientPlayerSelectAction)
end

function RoundGiveUpAction:OnEnter()
  Base.OnEnter(self)
  self.SelectMarkerManager:ClearSelection()
  if self.CurrentEnemyPets and self.CurrentPlayer then
    for _, v in ipairs(self.CurrentEnemyPets) do
      v:SetLookAt(self.CurrentPlayer.model)
    end
  end
  if self.CurrentPlayer then
    self.CurrentPlayer:RunAway(true)
  end
  self:OpenGiveUpDialog()
end

function RoundGiveUpAction:OpenGiveUpDialog()
  local tickName = _G.NRCModuleManager:DoCmd(_G.LegendaryBattleModuleCmd.GetTicketName)
  local des = string.format(LuaText.legendary_battle_tips_4, tickName or "")
  local GiveUpDialog = DialogContext()
  GiveUpDialog:SetCallback(self, self.OnDialogCallback)
  GiveUpDialog:SetContent(des)
  GiveUpDialog:SetMode(DialogContext.Mode.OK_CANCEL)
  GiveUpDialog:SetTitle(LuaText.TIPS)
  GiveUpDialog:SetButtonText(_G.LuaText.YES, _G.LuaText.NO)
  self:OpenDialog(GiveUpDialog)
end

function RoundGiveUpAction:OpenDialog(GiveUpDialog)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, GiveUpDialog)
  _G.NRCAudioManager:PlaySound2DAuto(1291, "UMG_BattleMainWindow_C:OpenGiveUpDialog")
end

function RoundGiveUpAction:OnDialogCallback(result)
  if result then
    _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_BattleMainWindow_C:ClickYes")
  else
    _G.NRCAudioManager:PlaySound2DAuto(1006, "UMG_BattleMainWindow_C:ClickNo")
  end
  _G.BattleEventCenter:Dispatch(BattleEvent.ON_CLICK_GIVEUP, result)
end

function RoundGiveUpAction:OnExit()
  if self.CurrentPlayer then
    self.CurrentPlayer:RunAway(false)
  end
  Base.OnExit(self)
end

return RoundGiveUpAction
