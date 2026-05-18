local EventDispatcher = require("Common.EventDispatcher")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local BattlePlayerBase = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePlayerBase")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleIdlePlayer = BattlePlayerBase:Extend()

function BattleIdlePlayer:Ctor(owner)
  BattlePlayerBase.Ctor(self)
  EventDispatcher():Attach(self)
  self.PawnManager = _G.BattleManager.battlePawnManager
end

function BattleIdlePlayer:Reset()
  self.idle_info = nil
  self.target = nil
  self.Player = nil
  self.type = nil
  self.performNode = nil
end

function BattleIdlePlayer:Play(performNode)
  self:Reset()
  self:InitFromNode(performNode)
  Log.Debug("---------- %d \229\174\160\231\137\169\229\188\128\229\167\139\232\191\155\229\133\165\228\188\145\230\129\175\231\138\182\230\128\129", self.idle_info.idle_pet_id)
  local pet = self.PawnManager:GetPetByGuid(self.idle_info.idle_pet_id)
  if not pet then
    self:OnSkillComplete()
    return
  end
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format(LuaText.battleidleplayer_1, pet.card.name))
  _G.DelayManager:DelaySeconds(BattleConst.Show.IdleHudHintTime, self.OnSkillComplete, self)
end

function BattleIdlePlayer:InitFromNode(performNode)
  self.performNode = performNode
  local performInfo = performNode:GetInfo()
  self.PerformInfo = performInfo
  self.idle_info = performInfo.idle_info
end

function BattleIdlePlayer:OnSkillComplete()
  Log.Debug("BattleIdlePlayer Play OnSkillComplete:", self.performNode:GetNodeIdx())
  self.performNode:PerformComplete()
end

return BattleIdlePlayer
