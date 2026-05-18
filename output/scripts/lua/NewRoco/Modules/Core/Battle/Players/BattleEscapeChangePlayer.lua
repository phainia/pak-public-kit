local EventDispatcher = require("Common.EventDispatcher")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local BattlePlayerBase = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePlayerBase")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleEscapeChangePlayer = BattlePlayerBase:Extend()

function BattleEscapeChangePlayer:Ctor(owner)
  BattlePlayerBase.Ctor(self)
  EventDispatcher():Attach(self)
  self.PawnManager = _G.BattleManager.battlePawnManager
end

function BattleEscapeChangePlayer:Reset()
  self.escape_change = nil
  self.target = nil
  self.Player = nil
  self.type = nil
  self.performNode = nil
end

function BattleEscapeChangePlayer:Play(performNode)
  self:Reset()
  self:InitFromNode(performNode)
  local escape_info = _G.ProtoMessage:newBattleMonsterEscapeInfo()
  escape_info.condition_type = self.escape_change.condition_type
  escape_info.threshold = performNode:GetSyncData().pet_sync_info[1].escape_threshold_result
  escape_info.cur_value = performNode:GetSyncData().pet_sync_info[1].escape_cur_val_result
  _G.BattleEventCenter:Dispatch(BattleEvent.PET_RUNAWAY_CHANGE, escape_info)
  self:OnSkillComplete()
end

function BattleEscapeChangePlayer:InitFromNode(performNode)
  self.performNode = performNode
  local performInfo = performNode:GetInfo()
  self.PerformInfo = performInfo
  self.escape_change = performInfo.monster_escape_change
end

function BattleEscapeChangePlayer:OnSkillComplete()
  Log.Debug("BattleEscapeChangePlayer Play OnSkillComplete:", self.performNode:GetNodeIdx())
  self.performNode:PerformComplete()
end

return BattleEscapeChangePlayer
