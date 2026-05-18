local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleContactPerformInWorldAction = BattleActionBase:Extend("BattleContactPerformInWorldAction")
FsmUtils.MergeMembers(BattleActionBase, BattleContactPerformInWorldAction, {})

function BattleContactPerformInWorldAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
end

function BattleContactPerformInWorldAction:OnEnter()
  if _G.BattleManager.battleRuntimeData:GetEnterBattleType() == ProtoEnum.BattleEnterType.BET_CONTACT and not BattleUtils.IsBattleAIStatus(self:GetEnemyAIStatus()) then
    local contactType = BattleEnum.ContactEnterType.HitTogether
    local speedThreshold = _G.DataConfigManager:GetBattleGlobalConfig("velocity_difference_threshold").num
    local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    local TargetPet = BattleUtils.GetTraceNpc()
    if localPlayer.TouchBattleVel and TargetPet and TargetPet.npc and TargetPet.npc.TouchBattleVel then
      if localPlayer.IsTurnToTarget and not TargetPet.npc.IsTurnToTarget then
        contactType = BattleEnum.ContactEnterType.PlayerHit
      elseif not localPlayer.IsTurnToTarget and TargetPet.npc.IsTurnToTarget then
        contactType = BattleEnum.ContactEnterType.PetHit
      elseif localPlayer.TouchBattleVel < TargetPet.npc.TouchBattleVel - speedThreshold then
        contactType = BattleEnum.ContactEnterType.PetHit
      elseif localPlayer.TouchBattleVel > TargetPet.npc.TouchBattleVel + speedThreshold then
        contactType = BattleEnum.ContactEnterType.PlayerHit
      else
        contactType = BattleEnum.ContactEnterType.HitTogether
      end
      localPlayer.TouchBattleVel = nil
      TargetPet.npc.TouchBattleVel = nil
      localPlayer.IsTurnToTarget = nil
      TargetPet.npc.IsTurnToTarget = nil
      _G.BattleManager.battleRuntimeData:SetContactEnterType(contactType)
      self:Finish()
      return
    end
  end
  _G.BattleManager.battleRuntimeData:SetContactEnterType(BattleEnum.ContactEnterType.None)
  self:Finish()
end

function BattleContactPerformInWorldAction:GetEnemyAIStatus()
  local initInfo = BattleUtils.GetBattleInitInfo()
  if initInfo then
    for _, v in ipairs(initInfo.enemy_team) do
      for i, pet in ipairs(v.pets or {}) do
        if BattleUtils.GetInBattle(pet.battle_inside_pet_info) then
          return pet.battle_inside_pet_info.ai_info.ai_status
        end
      end
    end
  end
  return nil
end

return BattleContactPerformInWorldAction
