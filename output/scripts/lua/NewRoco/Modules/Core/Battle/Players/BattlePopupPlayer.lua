local BattlePlayerBase = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePlayerBase")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = BattlePlayerBase
local BattlePopupPlayer = Base:Extend("BattlePopupPlayer")

function BattlePopupPlayer:Ctor()
  Base.Ctor(self)
end

function BattlePopupPlayer:Play(performNode)
  self.performNode = performNode
  Log.Debug("BattlePopupPlayer:Play")
  local show_letters = performNode:GetPerformData()
  local battleCard = self:GetBattleCard(show_letters.caster_id)
  if not battleCard then
    self:OnSkillComplete()
    return
  end
  if self.performNode:GetCastMoment() == ProtoEnum.Buffbasetrigger_type.OnBeforeAttack then
    self.performNode.performPlayer:Pause()
    Log.Debug("BattlePopupPlayer Pause performplayer")
  end
  local performPlayer = self.performNode.performPlayer
  local recordPopFunc
  if performPlayer and show_letters.buff_id and show_letters.buff_id > 0 then
    if SkillUtils.IsEffect(show_letters.buff_id) then
      if performPlayer:CheckEffectPopRepeatById(show_letters.caster_id) then
        self:OnSkillComplete()
        return
      end
      
      function recordPopFunc()
        performPlayer:RecordEffectPopPlayedId(show_letters.caster_id)
      end
    else
      local buffRes = self:GetBuffResInSameGroup() or show_letters.buff_id
      if buffRes then
        if performPlayer:CheckPopRepeatByRes(buffRes, show_letters.target_id) then
          self:OnSkillComplete()
          return
        end
        
        function recordPopFunc()
          performPlayer:RecordPopPlayedRes(buffRes, show_letters.target_id)
        end
      end
    end
  end
  local isShow = battleCard:ShowPopup(show_letters)
  if isShow and recordPopFunc then
    recordPopFunc()
  end
  self:OnSkillComplete()
end

function BattlePopupPlayer:GetBuffResInSameGroup()
  if self.performNode then
    local show_letters = self.performNode:GetPerformData()
    local cluster = self.performNode:GetOwnerCluster()
    if cluster then
      local groups = cluster.ClusterGroups or {}
      for _, group in pairs(groups) do
        local nodes = group.GroupNodes or {}
        for _, v in pairs(nodes) do
          if v:GetPerformType() == ProtoEnum.BattlePerformType.BPT_BUFF_TRIGGER then
            local buff_trigger = v:GetPerformData()
            if buff_trigger.buff_id == show_letters.buff_id and buff_trigger.caster_id == show_letters.caster_id and buff_trigger.target_id == show_letters.target_id then
              return BattleUtils.GetBuffResByBuffIdAndType(buff_trigger.buff_id, buff_trigger.perform_type)
            end
          end
        end
      end
    end
  end
end

function BattlePopupPlayer:IsInCombinationSkill()
  if self.performNode then
    return self.performNode:GetOwnerCluster().IsCombinationProcessCluster
  end
  return false
end

function BattlePopupPlayer:OnSkillComplete(Event)
  if self.performNode:GetCastMoment() == ProtoEnum.Buffbasetrigger_type.OnBeforeAttack then
    self.performNode.performPlayer:Resume()
    Log.Debug("BattlePopupPlayer Resume performplayer")
  end
  Log.Debug("BattlePopupPlayer:OnSkillComplete")
  self.performNode:PerformComplete()
end

function BattlePopupPlayer:OnSkillCastMoment(castMoment)
  self.performNode:DispatchPerformCallback(castMoment)
end

function BattlePopupPlayer:GetBattlePet(petID)
  return BattleManager.battlePawnManager:GetPetByGuid(petID)
end

function BattlePopupPlayer:GetBattleCard(petID)
  return BattleManager.battlePawnManager:GetCardByGuid(petID)
end

return BattlePopupPlayer
