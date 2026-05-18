local EventDispatcher = require("Common.EventDispatcher")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local BattlePlayerBase = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePlayerBase")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleSkillStatePlayer = BattlePlayerBase:Extend()

function BattleSkillStatePlayer:Ctor(owner)
  BattlePlayerBase.Ctor(self)
  EventDispatcher():Attach(self)
  self.PawnManager = _G.BattleManager.battlePawnManager
end

function BattleSkillStatePlayer:Reset()
  self.skill_state = nil
  self.target = nil
  self.Player = nil
  self.type = nil
  self.performNode = nil
end

function BattleSkillStatePlayer:Play(performNode)
  self:Reset()
  self:InitFromNode(performNode)
  if self.skill_state and 1 == self.skill_state.state_code then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.Battle_Cant_Use_Skill)
  end
  _G.DelayManager:DelaySeconds(3, self.OnSkillComplete, self)
end

function BattleSkillStatePlayer:InitFromNode(performNode)
  self.performNode = performNode
  local performInfo = performNode:GetInfo()
  self.PerformInfo = performInfo
  self.skill_state = performInfo.skill_state
end

function BattleSkillStatePlayer:OnSkillComplete()
  Log.Debug("BattleSkillStatePlayer Play OnSkillComplete:", self.performNode:GetNodeIdx())
  self.performNode:PerformComplete()
end

return BattleSkillStatePlayer
