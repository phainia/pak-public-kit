local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local BattlePiecesBase = require("NewRoco.Modules.Core.Battle.BattleCore.Pieces.BattlePiecesBase")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local Base = BattlePiecesBase
local BattlePieceCounterSkillPrePlay = Base:Extend("BattlePieceCounterSkillPrePlay")

function BattlePieceCounterSkillPrePlay:OnPlay(Caster, CallBack, CallBackOwner)
  BattleEventCenter:Bind(self, BattleEvent.SKillEvent_LeaveBulletTime)
  local skillClass = BattleResourceManager:GetCacheAssetDirect(BattleConst.CounterSkillPreFx)
  local CastParam = CastSkillObject.Create()
  CastParam.SkillClass = skillClass
  CastParam:SetIsPassive(true)
  CastParam:SetCaster(Caster.model)
  CastParam:SetCallbackOwner(self)
  CastParam:SetCompleteCallback(self.Complete):SetInterrupt(true)
  local com, skillObj = BattleSkillManager:PrepareSkill(Caster, Caster.model.RocoSkill, CastParam)
  self.skillObj = skillObj
  self.CallBack = CallBack
  self.CallBackOwner = CallBackOwner
  self:SetOnBulletTime(true)
  Caster.model.RocoSkill:LoadAndPlaySkill(skillObj)
end

function BattlePieceCounterSkillPrePlay:OnComplete()
  _G.BattleEventCenter:UnBind(self)
  if self.CallBack then
    self.CallBack(self.CallBackOwner)
  end
  self.skillObj = nil
  self.CallBack = nil
  self.CallBackOwner = nil
end

function BattlePieceCounterSkillPrePlay:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.SKillEvent_LeaveBulletTime then
    self:SetOnBulletTime(false)
    return true
  end
end

function BattlePieceCounterSkillPrePlay:SetOnBulletTime(isOn)
  if self.skillObj then
    local blackboard = self.skillObj:GetBlackboard()
    if blackboard then
      blackboard:SetValueAsBool("OnBulletTime", isOn)
    end
  end
end

return BattlePieceCounterSkillPrePlay
