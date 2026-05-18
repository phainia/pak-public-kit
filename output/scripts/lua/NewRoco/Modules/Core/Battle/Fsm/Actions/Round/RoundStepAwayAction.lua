local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local BattleRoundAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Round.BattleRoundAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local CommonBtnEnum = require("NewRoco.Modules.System.CommonBtn.CommonBtnEnum")
local Base = BattleRoundAction
local RoundStepAwayAction = Base:Extend("RoundStepAwayAction")
FsmUtils.MergeMembers(Base, RoundStepAwayAction, {})

function RoundStepAwayAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self:SetActionType(BattleActionBase.ActionType.ClientPlayerSelectAction)
end

function RoundStepAwayAction:OnEnter()
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
  self:OpenStepAwayDialog()
end

function RoundStepAwayAction:OpenStepAwayDialog()
  local tickName = _G.NRCModuleManager:DoCmd(_G.LegendaryBattleModuleCmd.GetTicketName)
  local des = string.format(LuaText.Legendary_Battle_Exit_Tip, tickName or "")
  local StepAwayDialog = DialogContext()
  StepAwayDialog:SetCallback(self, self.OnDialogCallback)
  StepAwayDialog:SetContent(des)
  StepAwayDialog:SetMode(DialogContext.Mode.OK_CANCEL)
  StepAwayDialog:SetTitle(LuaText.TIPS)
  StepAwayDialog:SetCloseBtnNotDoCancel(true)
  StepAwayDialog:SetButtonText("\230\154\130\230\151\182\231\166\187\229\188\128", "\230\148\190\229\188\131\230\141\149\230\141\137")
  StepAwayDialog.clickAnywhereClose = true
  self:OpenDialog(StepAwayDialog)
end

function RoundStepAwayAction:OpenDialog(StepAwayDialog)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, StepAwayDialog)
  _G.NRCAudioManager:PlaySound2DAuto(1291, "UMG_BattleMainWindow_C:OpenStepAwayDialog")
end

function RoundStepAwayAction:OnDialogCallback(result, CancelType)
  if result then
    _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_BattleMainWindow_C:ClickYes")
  else
    if CancelType == CommonBtnEnum.DialogCancelType.BtnClickType then
      _G.BattleEventCenter:Dispatch(BattleEvent.ON_CLICK_GIVEUP, true)
    end
    _G.NRCAudioManager:PlaySound2DAuto(1006, "UMG_BattleMainWindow_C:ClickNo")
  end
  _G.BattleEventCenter:Dispatch(BattleEvent.ON_CLICK_STEPAWAY, result)
end

function RoundStepAwayAction:OnExit()
  if self.CurrentPlayer then
    self.CurrentPlayer:RunAway(false)
  end
  Base.OnExit(self)
end

return RoundStepAwayAction
