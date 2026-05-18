local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local Base = BattleActionBase
local BattlePrepareResAction = Base:Extend("BattlePrepareResAction")
FsmUtils.MergeMembers(Base, BattlePrepareResAction, {})

function BattlePrepareResAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattlePrepareResAction:OnEnter()
  Log.Debug("show me prepareresaction time begin:", UE4.UNRCStatics.GetMilliSeconds())
  local battleInitInfo = BattleUtils.GetBattleInitInfo()
  for playerPos, v in ipairs(battleInitInfo.player_team) do
    self:PrepareBattlePlayer(v)
    local pets = v.pets
    for i = 1, #pets do
      local bInBattleField = BattleUtils.GetInBattle(pets[i].battle_inside_pet_info)
      if bInBattleField then
        local base_conf_id = pets[i].battle_inside_pet_info.base_conf_id
        self:PrepareBattlePet(base_conf_id)
      end
    end
  end
  for playerPos, v in ipairs(battleInitInfo.enemy_team) do
    self:PrepareBattlePlayer(v)
    local pets = v.pets
    for i = 1, #pets do
      local bInBattleField = BattleUtils.GetInBattle(pets[i].battle_inside_pet_info)
      if bInBattleField then
        local base_conf_id = pets[i].battle_inside_pet_info.base_conf_id
        self:PrepareBattlePet(base_conf_id)
      end
    end
  end
  Log.Debug("show me prepareresaction time end:", UE4.UNRCStatics.GetMilliSeconds())
  if self:CheckIsAsync() then
    self:Finish()
  end
end

function BattlePrepareResAction:PrepareBattlePlayer(spawnData)
  local roleID = BattleUtils.GetPlayerModelId(spawnData)
  local modelConfId = roleID
  local modelConf = _G.DataConfigManager:GetModelConf(modelConfId, true)
  if modelConf then
    local modelPath = modelConf.path
    _G.BattleResourceManager:PreloadAssetAsync(self, modelPath, self.PawnPlayerOver, self.PawnPlayerFailed, nil, PriorityEnum.Passive_Battle_Preload)
  else
    Log.Warning("BattlePrepareResAction:PrepareBattlePlayer \232\142\183\229\143\150 model \233\133\141\231\189\174\229\164\177\232\180\165, modelConfId = ", modelConfId)
  end
end

function BattlePrepareResAction:PrepareBattlePet(baseID)
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(baseID)
  local modelConfId = petBaseConf.model_conf
  local modelConf = _G.DataConfigManager:GetModelConf(modelConfId, true)
  if not modelConf then
    Log.Warning("BattlePrepareResAction:PrepareBattlePet \232\142\183\229\143\150 model \233\133\141\231\189\174\229\164\177\232\180\165, modelConfId = ", modelConfId)
  end
  local modelPath = modelConf and modelConf.path or ""
  _G.BattleResourceManager:PreloadAssetAsync(self, modelPath, self.PawnPetOver, self.PawnPetFailed, nil, PriorityEnum.Passive_Battle_Preload)
end

function BattlePrepareResAction:PawnPlayerOver()
  Log.Debug("BattlePrepareResAction PawnPlayerOver")
end

function BattlePrepareResAction:PawnPlayerFailed()
  Log.Debug("BattlePrepareResAction PawnPlayerOver")
end

return BattlePrepareResAction
