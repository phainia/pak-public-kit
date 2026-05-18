local EventDispatcher = require("Common.EventDispatcher")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local BattlePlayerBase = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePlayerBase")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattlePlayerPredictionInfo = require("NewRoco.Modules.Core.Battle.Entity.BattlePlayerPredictionInfo")
local BattleUseItemPlayer = BattlePlayerBase:Extend()

function BattleUseItemPlayer:Ctor(owner)
  BattlePlayerBase.Ctor(self)
  EventDispatcher():Attach(self)
  self.PawnManager = _G.BattleManager.battlePawnManager
end

function BattleUseItemPlayer:Reset()
  self.use_item = nil
  self.target = nil
  self.Player = nil
  self.type = nil
  self.performNode = nil
end

function BattleUseItemPlayer:Play(performNode)
  self:Reset()
  self:InitFromNode(performNode)
  if self.performNode.performPlayer.turnPlayer.IsMySelfPerform then
    _G.BattleManager.vBattleField.battleCameraManager:ChangeToPlayerItem(0)
  end
  local player = _G.BattleManager.battlePawnManager:GetPlayerByGuid(self.use_item.player_id)
  local target = _G.BattleManager.battlePawnManager:GetPetByGuid(self.use_item.target_id)
  self.type = self.use_item.effect_type
  self.target = target
  self.id = player:TryGetItemConfID(self.use_item.item_id)
  self.IsPartnerPerform = player.teamEnm == BattleEnum.Team.ENUM_TEAM and player ~= BattleManager.battlePawnManager:GetPlayerMyTeam()
  if self.type == ProtoEnum.BattleUseEffect.BE_HINTLEVEL then
    local info = BattlePlayerPredictionInfo(self.use_item.player_id)
    table.insert(self.target.predictionHistoryInfos, info)
  end
  if not self.id then
    Log.ErrorFormat("No item %d found on player", self.use_item.item_id)
    self:OnSkillComplete()
  else
    player:UseItem(self.id, self, self.HandleUseItemCallback)
  end
end

function BattleUseItemPlayer:InitFromNode(performNode)
  self.performNode = performNode
  local performInfo = performNode:GetInfo()
  self.PerformInfo = performInfo
  self.use_item = performInfo.use_item
end

function BattleUseItemPlayer:HandleUseItemCallback()
  if not self.target or not self.target.model then
    Log.Error("No target found")
    return
  end
  self.target:ApplyItem(self.id, self, self.HandleApplyItemCallback)
end

function BattleUseItemPlayer:HandleApplyItemCallback()
  local runtimeData = _G.BattleManager.battleRuntimeData
  if not self.IsPartnerPerform then
    runtimeData.backOperateType = BattleEnum.Operation.ENUM_ITEM
  end
  Log.Debug("Apply Item OnSkillComplete:", self.performNode:GetNodeIdx())
  self:OnSkillComplete()
end

function BattleUseItemPlayer:OnSkillComplete()
  Log.Debug("BattleUseItemPlayer Play OnSkillComplete:", self.performNode:GetNodeIdx())
  self.performNode:PerformComplete()
end

return BattleUseItemPlayer
