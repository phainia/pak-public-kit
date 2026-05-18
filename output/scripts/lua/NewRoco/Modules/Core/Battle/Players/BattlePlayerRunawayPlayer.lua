local EventDispatcher = require("Common.EventDispatcher")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local BattlePlayerBase = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePlayerBase")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattlePlayerRunawayPlayer = BattlePlayerBase:Extend()

function BattlePlayerRunawayPlayer:Ctor(owner)
  BattlePlayerBase.Ctor(self)
  EventDispatcher():Attach(self)
end

function BattlePlayerRunawayPlayer:Reset()
  self.performNode = nil
  self.runaway_info = nil
  self.PerformInfo = nil
end

function BattlePlayerRunawayPlayer:Play(performNode)
  self:Reset()
  self:InitFromNode(performNode)
  local isFinish = self.performNode.performPlayer.turnPlayer:ShouldBattleFinished()
  if isFinish then
    self:OnSkillComplete()
    return
  end
  local player = BattleManager.battlePawnManager:GetPlayerByGuid(self.runaway_info.player_uin)
  if not player then
    self:OnSkillComplete()
    return
  end
  player:RunAwayBattle()
  self:OnSkillComplete()
end

function BattlePlayerRunawayPlayer:InitFromNode(performNode)
  self.performNode = performNode
  local performInfo = performNode:GetInfo()
  self.PerformInfo = performInfo
  self.runaway_info = performInfo.runaway
end

function BattlePlayerRunawayPlayer:OnSkillComplete()
  Log.Debug("BattlePlayerRunawayPlayer Play OnSkillComplete:", self.performNode:GetNodeIdx())
  self.performNode:PerformComplete()
end

return BattlePlayerRunawayPlayer
