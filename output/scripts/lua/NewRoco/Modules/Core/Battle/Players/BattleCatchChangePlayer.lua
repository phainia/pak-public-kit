local EventDispatcher = require("Common.EventDispatcher")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local BattlePlayerBase = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePlayerBase")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleCatchChangePlayer = BattlePlayerBase:Extend()

function BattleCatchChangePlayer:Ctor(owner)
  BattlePlayerBase.Ctor(self)
  EventDispatcher():Attach(self)
  self.PawnManager = _G.BattleManager.battlePawnManager
end

function BattleCatchChangePlayer:Reset()
  self.monster_catch_change = nil
  self.performNode = nil
end

function BattleCatchChangePlayer:Play(performNode)
  self:Reset()
  self:InitFromNode(performNode)
  Log.Dump(performNode, 2, "Processing Catch Info Change")
  local pet = self.PawnManager:GetPetByGuid(self.monster_catch_change.monster_id)
  if pet and pet:IsWild() then
    _G.BattleEventCenter:Dispatch(BattleEvent.PET_CATCH_CHANGED, pet.guid, performNode:GetSyncData().pet_sync_info[1].catch_threshold_result, false)
    local CatchCondID = self.monster_catch_change.catch_cond_id
    if 0 == CatchCondID then
      self:OnSkillComplete()
      Log.Debug("not a valid cond id")
      return
    end
    local Cond = _G.DataConfigManager:GetCatchConditionConf(CatchCondID)
    if not Cond then
      self:OnSkillComplete()
      Log.Debug("can't find  valid conf id")
      return
    end
    if not Cond.flavor_text then
      self:OnSkillComplete()
      Log.Debug("No flavor text found")
      return
    end
    local WaitTime = 1
    _G.BattleEventCenter:Dispatch(BattleEvent.UI_SHOW_INFO_POPUP, {
      BattleEnum.InfoPopupType.PetStatus,
      pet.team.player,
      pet.card.config.name,
      Cond.flavor_text
    })
    if not string.IsNilOrEmpty(Cond.res_id) then
      pet:PlayAnimByName(Cond.res_id, 1, -1, 0, 0, 1, -1)
    else
      WaitTime = 0.5
    end
    _G.DelayManager:DelaySeconds(WaitTime, self.CloseCatchPopup, self, pet.team.player)
  else
    Log.Debug("It's not a wild pet")
    self:OnSkillComplete()
  end
end

function BattleCatchChangePlayer:InitFromNode(performNode)
  self.performNode = performNode
  local performInfo = performNode:GetInfo()
  self.PerformInfo = performInfo
  self.monster_catch_change = performInfo.monster_catch_change
end

function BattleCatchChangePlayer:CloseCatchPopup(player)
  Log.Debug("Will Close Info Pop Up")
  _G.BattleEventCenter:Dispatch(BattleEvent.UI_HIDE_INFO_POPUP, player)
  self:OnSkillComplete()
end

function BattleCatchChangePlayer:OnSkillComplete()
  Log.Debug("BattleCatchChangePlayer Play OnSkillComplete:", self.performNode:GetNodeIdx())
  self.performNode:PerformComplete()
end

function BattleCatchChangePlayer:OnSkillCastMoment(castMoment)
  self.performNode:DispatchPerformCallback(castMoment)
end

return BattleCatchChangePlayer
