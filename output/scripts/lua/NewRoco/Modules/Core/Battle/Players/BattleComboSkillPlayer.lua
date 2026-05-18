local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local ServerData = require("Common.LocalServer.LocalBattleRSPTable")
local BattleAttackPlayer = require("NewRoco.Modules.Core.Battle.Players.BattleAttackPlayer")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = BattleAttackPlayer
local BattleComboSkillPlayer = Base:Extend("BattleComboSkillPlayer")

function BattleComboSkillPlayer:PreprocessSkillObj()
  local prevSkillIndex = self.skill_cast.combo_index - 1
  local nextSkillIndex = self.skill_cast.combo_index + 1
  local curSkill = self.skill_cast
  local prevSkill = self:GetCombinationSkillByIndex(prevSkillIndex)
  local nextSkill = self:GetCombinationSkillByIndex(nextSkillIndex)
  if prevSkill then
    if not prevSkill.IsRemote then
      curSkill.IsSkipMeleeForeswing = true
    else
      curSkill.IsSkipRangedForeswing = true
    end
  end
  if nextSkill then
    if not nextSkill.IsRemote then
      curSkill.IsSkipMeleeBackswing = true
    else
      curSkill.IsSkipRangedBackswing = true
    end
  end
end

function BattleComboSkillPlayer:GetCombinationSkillByIndex(combinationIndex)
  if combinationIndex < 0 or combinationIndex >= self.skill_cast.combo_count then
    return
  end
  local performGroupLst = self.performNode:GetPerformPlayer().PerformGroupLst
  local target
  for _, group in ipairs(performGroupLst) do
    local performNode = group.HeadNode
    if performNode:GetPerformType() == ProtoEnum.BattlePerformType.BPT_COMBO_SKILL then
      local comboSkillCast = performNode:GetPerformData()
      if comboSkillCast.combo_index == combinationIndex and self.skill_cast.caster_id == comboSkillCast.caster_id then
        target = target or _G.BattleManager.battlePawnManager:GetPetByGuid(comboSkillCast.caster_id)
        Log.Debug("BattleComboSkillPlayer PreprocessSkillObj:", combinationIndex)
        if target then
          local skillClass = BattleUtils.GetSkillClassBySkillId(comboSkillCast.skill_id)
          local skillObj = target.model.RocoSkill:FindOrAddSkillObj(skillClass)
          comboSkillCast.IsRemote = SkillUtils.IsRemoteSkill(skillObj)
        else
          comboSkillCast.IsRemote = true
        end
        return comboSkillCast
      end
    end
  end
  return nil
end

function BattleComboSkillPlayer:OnPlay()
  Log.Debug("performNode:GetInfo().skill_cast.caster_id:", self.skill_cast.caster_id, self.skill_cast.skill_id)
  self:PreprocessSkillObj()
  self:TryLookAtTarget()
  self.Team = self.Caster.team
  self.Player = self.Team.player
  self.BreakFlow = false
  self:ApplyDefaultCamera()
  self:CheerPetPerform()
  if self.CastParam then
    if ServerData.values.battleMode then
      self.Caster:ClearSkill()
    end
    if self.skill_cast.IsSkipMeleeBackswing then
      self.CastParam:SetSkipMeleeBackswingCallback(self.OnSkillComplete)
    end
    if self.skill_cast.IsSkipRangedBackswing then
      self.CastParam:SetSkipRangedBackswingCallback(self.OnSkillComplete)
    end
    local rocoSkillComponent
    rocoSkillComponent, self.SkillObject = BattleSkillManager:PrepareSkill(self.Caster, self.Caster.model.RocoSkill, self.CastParam)
    if not self.performNode.performPlayer.turnPlayer.IsMySelfPerform then
      self.SkillObject.IsIgnoreCameraAction = true
    end
    self.SkillObject.IsSkipMeleeForeswing = self.skill_cast.IsSkipMeleeForeswing
    self.SkillObject.IsSkipRangedBackswing = self.skill_cast.IsSkipRangedBackswing
    self.SkillObject.IsSkipMeleeBackswing = self.skill_cast.IsSkipMeleeBackswing
    self.SkillObject.IsSkipRangedForeswing = self.skill_cast.IsSkipRangedForeswing
    SkillUtils.SetRangedMultiAtkTimes(self.SkillObject, self.totalHits - 1)
    self:ScanMultiDamage()
    self:ScanEnergyPerform()
    self:SetComboData()
    rocoSkillComponent:PlaySkill(self.SkillObject)
    Log.Debug("BattleComboSkillPlayer SkillObject:", self.SkillObject:GetName())
    if ServerData.values.battleMode then
      local frameCount = self.SkillObject:GetLength() * self.SkillObject:GetFPS()
      local cmd = string.format("FxPerf.Start %s_%s %f", self.skill_cast.skill_id, self.SkillObject:GetDisplayName(), frameCount)
      UE4.UNRCStatics.ExecConsoleCommand(cmd)
    end
  else
    self:OnSkillComplete()
    return
  end
  self:DelayHidePopup()
end

function BattleComboSkillPlayer:OnSkillComplete(Event)
  if self.skill_cast.combo_index == self.skill_cast.combo_count - 1 and self.Caster and self.Caster.model and self.PawnManager and self.PawnManager.VBattleField then
    local RightPosTransForm = self.PawnManager.VBattleField:GetPositionInBattleMap(self.Caster.teamEnm, self.Caster.card.posInField)
    if RightPosTransForm then
      local RightPos = RightPosTransForm.Translation
      local NowPos = self.Caster:GetActorLocation()
      RightPos.Z = NowPos.Z
      if NowPos:Dist(RightPos) >= 150 then
        RightPos = UE4.UNRCStatics.PinActorOnGround(nil, self.Caster.model, SceneUtils.ConvertAbsoluteToRelative(RightPos), self.Caster.model)
        self.Caster:JumpToLocation(RightPos, self, Base.OnSkillComplete)
        return
      end
    end
  end
  Base.OnSkillComplete(self, Event)
end

function BattleComboSkillPlayer:SetComboData()
  if self.SkillObject then
    local casterPos
    if 0 == self.skill_cast.combo_index then
      self.BattleManager.ComboSkillInfo[self.Caster.guid] = nil
      if self.Caster.model then
        casterPos = self.Caster.model:K2_GetActorLocation()
        self.BattleManager.ComboSkillInfo[self.Caster.guid] = casterPos
      end
    else
      casterPos = self.BattleManager.ComboSkillInfo[self.Caster.guid]
    end
    if casterPos then
      local blackboard = self.SkillObject:GetBlackboard()
      if blackboard then
        blackboard:SetValueAsVector("ComboSkillCaterPos", casterPos)
      end
    end
    if self.skill_cast.combo_count > 1 and (not self.SkillConf or 0 == self.SkillConf.is_showlens) then
      self.SkillObject.IsIgnoreCameraAction = true
    end
  end
end

return BattleComboSkillPlayer
