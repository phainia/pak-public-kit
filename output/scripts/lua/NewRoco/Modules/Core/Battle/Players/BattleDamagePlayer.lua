local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local EventDispatcher = require("Common.EventDispatcher")
local BattlePerformEvent = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePerformEvent")
local BattlePlayerBase = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePlayerBase")
local BattleDamagePlayer = BattlePlayerBase:Extend()

function BattleDamagePlayer:Ctor(owner)
  BattlePlayerBase.Ctor(self)
end

function BattleDamagePlayer:Play(performNode)
  _G.BattleEventCenter:Bind(self, BattleEvent.MultiAttack_TookDamage)
  self.WillEnterRewardRound = false
  self.performNode = performNode
  self.performInfo = performNode:GetInfo()
  self:ShowDamageNumber()
end

function BattleDamagePlayer:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.MultiAttack_TookDamage then
    self:ShowDamageNumber()
    return true
  end
end

function BattleDamagePlayer:ShowDamageNumber()
  if self.performInfo then
    local damageInfo = self.performInfo.damage_info
    self.WillEnterRewardRound = damageInfo.execution or false
    if damageInfo.totalDamageNumber <= 1 or damageInfo.totalDamageNumber <= damageInfo.curDamageNumber then
      self:Complete()
    else
      local loop = damageInfo.performDamageNumber - damageInfo.curDamageNumber
      if loop > 0 then
        for i = 1, loop do
          local targetID = _G.BattleDataCenter:WriteDamageInfo(self.performInfo)
          local option = {petId = targetID, imme = false}
          _G.BattleDataCenter:Dispatch(BattlePerformEvent.HitBattlePet, option)
        end
      end
      if damageInfo.totalDamageNumber <= damageInfo.curDamageNumber then
        self:Complete()
      end
    end
  else
    self:Complete()
  end
end

function BattleDamagePlayer:Complete()
  if self.WillEnterRewardRound then
    local targetPet = BattleManager.battlePawnManager:GetPetByGuid(self.performInfo.damage_info.target_id)
    if targetPet and targetPet.model then
      local Klass = BattleSkillManager:GetLoadedClass(BattleConst.WorldLeaderEnterReward)
      if Klass then
        local Skill = targetPet.model.RocoSkill:AddSkillObjFromClassAndReturn(Klass)
        if Skill then
          Skill:SetCaster(targetPet.model)
          Skill:SetTargets({
            targetPet.model
          })
          Skill:SetPassive(true)
          Skill:RegisterEventCallback("End", self, self.LeaderEnterRewardOver)
          Skill:RegisterEventCallback("PreEnd", self, self.LeaderEnterRewardOver)
          Skill:RegisterEventCallback("Interrupt", self, self.LeaderEnterRewardOver)
          local initInfo = _G.BattleManager.battleRuntimeData.battleStartParam.battleInitInfo
          if initInfo and initInfo.world_leader_fight_info then
            initInfo.world_leader_fight_info.execution_trigger_available = false
          end
          _G.BattleDataCenter:Dispatch(BattlePerformEvent.WillEnterRewardRound)
          targetPet.model.RocoSkill:LoadAndPlaySkill(Skill)
          self:Finish()
          return
        end
      end
    end
  end
  self:Finish()
end

function BattleDamagePlayer:LeaderEnterRewardOver()
  _G.BattleDataCenter:Dispatch(BattlePerformEvent.EnterRewardRoundPlayOver)
end

function BattleDamagePlayer:Finish()
  _G.BattleEventCenter:UnBind(self)
  if self.performNode then
    self.performNode:PerformComplete()
  end
  self.performNode = nil
  self.performInfo = nil
end

return BattleDamagePlayer
