local EventDispatcher = require("Common.EventDispatcher")
local BattleAsyncLoader = NRCClass()

function BattleAsyncLoader:Ctor()
  EventDispatcher():Attach(self)
  self.AssetManagerInstance = _G.NRCResourceManager
  self.LoadingPaths = {}
  self.LoadedObjects = {}
  self.isLoading = false
end

function BattleAsyncLoader:SetCallback(owner, callback)
  self.Owner = owner
  self.Callback = callback
end

function BattleAsyncLoader:AddRes(path)
  if table.contains(self.LoadedObjects, path) then
    return
  end
  Log.DebugFormat("adding path %s", path)
  table.insert(self.LoadingPaths, path)
end

function BattleAsyncLoader:StartAsyncLoading()
  if 0 == #self.LoadingPaths then
    return
  end
  Log.DebugFormat("Start Async Load %d!!!!!!!!", #self.LoadingPaths)
  self.isLoading = true
  for i, v in ipairs(self.LoadingPaths) do
    BattleResourceManager:LoadResAsync(self, v, self.OnLoaded, self.OnLoaded)
  end
  Log.Dump(self.LoadingPaths)
end

function BattleAsyncLoader:OnLoaded(res)
  table.insert(self.LoadedObjects, res)
  if #self.LoadingPaths ~= #self.LoadedObjects then
    return
  end
  self.isLoading = false
  local Owner = self.Owner
  self.Owner = nil
  local Callback = self.Callback
  self.Callback = nil
  if Callback then
    Callback(Owner)
  end
  Log.DebugFormat("Finish Async Load %d!!!!!!!!", #self.LoadedObjects)
end

function BattleAsyncLoader:IsLoading()
  return self.isLoading
end

function BattleAsyncLoader:AddFromPet(pet)
  if not pet then
    return
  end
  if not pet.battle_inside_pet_info then
    return
  end
  if not pet.battle_inside_pet_info.skill_round_data then
    return
  end
  local SkillDatas = pet.battle_inside_pet_info.skill_round_data
  if not SkillDatas then
    return
  end
  for _, v in ipairs(SkillDatas) do
    local Conf = _G.DataConfigManager:GetSkillConf(v.skill_id)
    if Conf and not string.IsNilOrEmpty(Conf.res_id) then
      self:AddRes(Conf.res_id)
    end
  end
end

function BattleAsyncLoader.CreateFromBattleInitInfo(info)
  local loader = BattleAsyncLoader()
  local PlayerTeam = info and info.player_team[1]
  local EnemyTeam = info and info.enemy_team[1]
  local PlayerPets = PlayerTeam and PlayerTeam.pets
  local EnemyPets = EnemyTeam and EnemyTeam.pets
  local PlayerPet = PlayerPets and PlayerPets[1]
  local EnemyPet = EnemyPets and EnemyPets[1]
  loader:AddFromPet(PlayerPet)
  loader:AddFromPet(EnemyPet)
  return loader
end

return BattleAsyncLoader
