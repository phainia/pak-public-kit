local EventDispatcher = require("Common.EventDispatcher")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local BattlePlayerBase = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePlayerBase")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleNotifyPerformPlayer = BattlePlayerBase:Extend()

function BattleNotifyPerformPlayer:Ctor(owner)
  BattlePlayerBase.Ctor(self)
  EventDispatcher():Attach(self)
end

function BattleNotifyPerformPlayer:Play(performNode)
  self.performNode = performNode
  local tipInfo = performNode.performInfo.notify_perform
  if not tipInfo then
    self:OnSkillComplete()
    return
  end
  if tipInfo.uin and tipInfo.uin > 0 and tipInfo.uin ~= BattleManager.battlePawnManager.TeamatePlayer.guid then
    self:OnSkillComplete()
    return
  end
  if tipInfo.notify_type == ProtoEnum.BattleNotifyPerformType.BNPT_COMMON and tipInfo.tips_id and tipInfo.tips_id == "mark_respon_magic_message" then
    self.willPlayPets = BattleManager.battlePawnManager:GetInFieldAllPet(BattleEnum.Team.ENUM_TEAM)
    self:PlayGetEnergy()
    return
  end
  self:OnSkillComplete()
end

function BattleNotifyPerformPlayer:PlayGetEnergy()
  if self.willPlayPets and #self.willPlayPets > 0 then
    local pet = self.willPlayPets[1]
    table.remove(self.willPlayPets, 1)
    local CastSkill = CastSkillObject.Create()
    CastSkill:SetCallbackOwner(self)
    CastSkill:SetCompleteCallback(self.OnSkillComplete)
    CastSkill:SetIsPassive(true)
    pet:PlaySkillByPath(BattleConst.GetEnergySkill, self, self.OnSkillComplete, CastSkill)
  else
    self:OnSkillComplete()
  end
end

function BattleNotifyPerformPlayer:OnSkillComplete()
  if not self.performNode then
    return
  end
  Log.Debug("BattleNotifyPerformPlayer Play OnSkillComplete:", self.performNode:GetNodeIdx())
  self.performNode:PerformComplete()
  self.performNode = nil
end

return BattleNotifyPerformPlayer
