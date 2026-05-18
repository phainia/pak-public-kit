local EventDispatcher = require("Common.EventDispatcher")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattlePlayerBase = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePlayerBase")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleExitHelper = require("NewRoco.Modules.Core.Battle.Players.BattleExitHelper")
local BattlePlayerSkillEscapePlayer = BattlePlayerBase:Extend()

function BattlePlayerSkillEscapePlayer:Ctor(owner)
  BattlePlayerBase.Ctor(self)
  EventDispatcher():Attach(self)
  self.PawnManager = _G.BattleManager.battlePawnManager
end

function BattlePlayerSkillEscapePlayer:Reset()
  self.Caster = nil
  self.performNode = nil
end

function BattlePlayerSkillEscapePlayer:InitFromNode(performNode)
  self.performNode = performNode
  self.PerformInfo = performNode:GetInfo()
  self.battler_escape = self.PerformInfo.battler_escape
end

function BattlePlayerSkillEscapePlayer:Play(performNode)
  self:Reset()
  self:InitFromNode(performNode)
  self.Caster = self.PawnManager:GetPlayerByGuid(self.battler_escape.uin)
  if not self.Caster then
    Log.Error("zgx BattlePlayerSkillEscapePlayer caster is nil")
    self:OnSkillComplete()
    return
  end
  if self.Caster == self.PawnManager.TeamatePlayer then
    BattleExitHelper.SetPlayerSkillEscape()
  elseif self.Caster then
    _G.BattleEventCenter:Dispatch(BattleEvent.PLAYER_LEAVE_GAME, self.Caster)
    self.Caster.team:QuitBattle()
    self.Caster:HidePlayer()
  end
  self:OnSkillComplete()
end

function BattlePlayerSkillEscapePlayer:OnSkillComplete()
  self.performNode:PerformComplete()
  self:Reset()
end

return BattlePlayerSkillEscapePlayer
