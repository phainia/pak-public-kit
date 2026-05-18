local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local Base = BattleActionBase
local BattlePreloadSupplyPetPlayerAction = Base:Extend("BattlePreloadSupplyPetPlayer")
FsmUtils.MergeMembers(Base, BattlePreloadSupplyPetPlayerAction, {
  {name = "Infos", type = "table"}
})

function BattlePreloadSupplyPetPlayerAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self:SetActionType(BattleActionBase.ActionType.ClientLoadResAction)
end

function BattlePreloadSupplyPetPlayerAction:OnEnter()
  BattleEventCenter:Bind(self, BattleEvent.OnAllSkillResLoaded)
  local Infos = self:GetProperty("Infos")
  if Infos then
    self.resList = {}
    self.resSet = {}
    for i = 1, #Infos do
      self:PreloadRes(Infos[i])
    end
    if #self.resList > 0 then
      BattleSkillManager:PreLoadRes(self.resList, true)
    else
      self:Finish()
    end
  else
    self:Finish()
  end
end

function BattlePreloadSupplyPetPlayerAction:PreloadRes(info)
  local player = BattleManager.battlePawnManager:GetPlayerByGuid(info.player_id)
  if not player then
    return
  end
  if BattleUtils.IsFinalBattleP1() then
    self:TryAddToPreloadResList(BattleConst.FinalBattleHuanChong)
  elseif BattleUtils.IsFinalBattleP2() then
    self:TryAddToPreloadResList(BattleConst.FinalBattleP2Debut)
  elseif player.teamEnm == BattleEnum.Team.ENUM_TEAM then
    if BattleUtils.IsNpcAssist() and player:IsAssistNpc() then
      self:TryAddToPreloadResList(BattleConst.EnemyHuanChong)
    elseif info.pet_infos then
      for _, pet_info in ipairs(info.pet_infos) do
        local res = BattleUtils.GetChangePetPathBySuit(player, pet_info.pet_info.battle_inside_pet_info.base_conf_id)
        local NoSuitRes = BattleUtils.GetChangePetPathBySuit(player, -1)
        if res ~= NoSuitRes then
          self:TryAddToPreloadResList(NoSuitRes)
        end
        self:TryAddToPreloadResList(res)
      end
    else
      Log.Error("zgx \230\137\190\228\184\141\229\136\176\232\161\165\229\174\160\231\154\132\229\175\185\232\177\161")
    end
  elseif BattleUtils.IsWildEnemy() then
    local BattleConf = BattleUtils.GetCurrentBattleConf()
    self:TryAddToPreloadResList(BattleUtils.GetWildSupplySkillRes(BattleConf))
  elseif BattleUtils.IsB1FinalBattleP1() then
    return BattleConst.B1P1EnemyCallOutG6
  elseif info.pet_infos then
    for _, pet_info in ipairs(info.pet_infos) do
      local res = BattleUtils.GetChangePetPathBySuit(player, pet_info.pet_info.battle_inside_pet_info.base_conf_id)
      local NoSuitRes = BattleUtils.GetChangePetPathBySuit(player, -1)
      if res ~= NoSuitRes then
        self:TryAddToPreloadResList(NoSuitRes)
      end
      self:TryAddToPreloadResList(res)
    end
  else
    Log.Error("zgx \230\137\190\228\184\141\229\136\176\232\161\165\229\174\160\231\154\132\229\175\185\232\177\161")
  end
end

function BattlePreloadSupplyPetPlayerAction:TryAddToPreloadResList(resPath)
  if not self.resSet[resPath] then
    self.resSet[resPath] = 1
    table.insert(self.resList, resPath)
  end
end

function BattlePreloadSupplyPetPlayerAction:OnFinish()
  BattleEventCenter:UnBind(self)
end

function BattlePreloadSupplyPetPlayerAction:OnBattleEvent(eventName)
  if eventName == BattleEvent.OnAllSkillResLoaded then
    Log.Debug("BattleEvent.OnAllSkillResLoaded:", eventName)
    self:Finish()
    return true
  end
end

return BattlePreloadSupplyPetPlayerAction
