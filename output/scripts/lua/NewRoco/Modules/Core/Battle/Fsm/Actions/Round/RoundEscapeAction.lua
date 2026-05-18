local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local BattleRoundAction = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Round.BattleRoundAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = BattleRoundAction
local RoundEscapeAction = Base:Extend("RoundEscapeAction")
FsmUtils.MergeMembers(Base, RoundEscapeAction, {})

function RoundEscapeAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self:SetActionType(BattleActionBase.ActionType.ClientPlayerSelectAction)
end

function RoundEscapeAction:OnEnter()
  Base.OnEnter(self)
  _G.BattleEventCenter:Bind(self, BattleEvent.ReconnetBattle_RoundStrart)
  self.SelectMarkerManager:ClearSelection()
  if self.CurrentEnemyPets and self.CurrentPlayer then
    for _, v in ipairs(self.CurrentEnemyPets) do
      v:SetLookAt(self.CurrentPlayer.model)
    end
  end
  if self.CurrentPlayer then
    self.CurrentPlayer:RunAway(true)
  end
  self:OpenEscapeDialog()
end

function RoundEscapeAction:OpenEscapeDialog()
  self.IsClickEscape = false
  local EscapeDialog = _G.BattleManager.EscapeContext:SetCallback(self, self.OnDialogCallback)
  if BattleUtils.IsBloodTeam() then
    if BattleUtils.CanCatchAtTeamFight() then
      if BattleUtils.IsTeammatePlayerHasBall() and _G.NRCModeManager:DoCmd(BattleUIModuleCmd.IsAnyRecoveryItemEnough) then
        local PetGlobalConfig = _G.DataConfigManager:GetPetGlobalConfig("team_battle_catch_quit")
        EscapeDialog:SetContent(PetGlobalConfig.str)
        EscapeDialog:SetTitle(LuaText.roundescapeaction_1)
        EscapeDialog:SetClickAnywhereClose(true)
        self:OpenDialog(EscapeDialog)
      else
        _G.BattleManager.EscapeContext:SetCallback(nil, nil)
        self:OnDialogCallback(true)
        _G.NRCAudioManager:PlaySound2DAuto(1291, "UMG_BattleMainWindow_C:OpenEscapeDialog")
        return
      end
    else
      self:NotTeamBattle(EscapeDialog, BattleManager.battleRuntimeData.battleType)
    end
  else
    self:NotTeamBattle(EscapeDialog, BattleManager.battleRuntimeData.battleType)
  end
end

function RoundEscapeAction:NotTeamBattle(EscapeDialog, battleType)
  if battleType == Enum.BattleType.BT_CRUCIAL or battleType == Enum.BattleType.BT_PLOT then
    EscapeDialog:SetContent(LuaText.roundescapeaction_2)
    EscapeDialog:SetClickAnywhereClose(true)
  else
    EscapeDialog:SetContent(LuaText.ASK_ESCAPE_BATTLE)
    EscapeDialog:SetTitle(LuaText.battle_escape_text)
    EscapeDialog:SetClickAnywhereClose(true)
  end
  self:OpenDialog(EscapeDialog)
end

function RoundEscapeAction:OpenDialog(EscapeDialog)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, EscapeDialog)
  _G.NRCAudioManager:PlaySound2DAuto(1291, "UMG_BattleMainWindow_C:OpenEscapeDialog")
end

function RoundEscapeAction:OnDialogCallback(result)
  self.IsClickEscape = true
  if result then
    _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_BattleMainWindow_C:ClickYes")
  else
    _G.NRCAudioManager:PlaySound2DAuto(1006, "UMG_BattleMainWindow_C:ClickNo")
  end
  _G.BattleEventCenter:Dispatch(BattleEvent.ON_CLICK_ESCAPE, result)
end

function RoundEscapeAction:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.ReconnetBattle_RoundStrart then
    if self.IsClickEscape then
      _G.BattleEventCenter:Dispatch(BattleEvent.ON_CLICK_ESCAPE, false)
    end
    return true
  end
end

function RoundEscapeAction:OnExit()
  _G.BattleEventCenter:UnBind(self)
  if self.CurrentPlayer then
    self.CurrentPlayer:RunAway(false)
  end
  Base.OnExit(self)
end

return RoundEscapeAction
