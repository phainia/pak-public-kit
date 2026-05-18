local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local HomePetAttributeComponent = Base:Extend("HomePetAttributeComponent")

function HomePetAttributeComponent:Ctor()
  Base.Ctor(self)
  self.FriendlinessBase = 0
  self.FriendlinessCurrent = {}
  self.JustTriedAttackTime = {}
  self.NestNpcId = 0
end

function HomePetAttributeComponent:Attach(owner)
  Base.Attach(self, owner)
  self:InitAttributeFromConfig()
end

function HomePetAttributeComponent:InitAttributeFromConfig()
  local petBaseData = self.owner:GetConfPetData()
  if petBaseData then
    local bondId = petBaseData.pet_bond_id or 0
    local petBondData = _G.DataConfigManager:GetPetBond(bondId, true)
    if petBondData then
      self.FriendlinessBase = petBondData.base_friendly_param_value or 0
    end
  end
  local serverData = self.owner.serverData
  local nestFurnitureId = serverData.home_pet and serverData.home_pet.home_pet_info and serverData.home_pet.home_pet_info.furniture_guid
  if nestFurnitureId then
    local HomeModule = _G.NRCModuleManager:GetModule("HomeModule")
    local petNest = HomeModule and HomeModule.data:GetPlacedInteractiveFurniture(nestFurnitureId) or nil
    self.NestNpcId = petNest and petNest:GetServerId() or 0
  else
    self.NestNpcId = 0
  end
end

function HomePetAttributeComponent:ModifyFriendliness(fromPlayer, fixVal)
  self:InitFriendliness(fromPlayer)
  self.FriendlinessCurrent[fromPlayer] = math.clamp(self.FriendlinessCurrent[fromPlayer] + fixVal, 0, 100)
end

function HomePetAttributeComponent:SetFriendliness(fromPlayer, finalVal)
  self:InitFriendliness(fromPlayer)
  self.FriendlinessCurrent[fromPlayer] = math.clamp(finalVal or 0, 0, 100)
end

function HomePetAttributeComponent:GetFriendlinessCurrent(fromPlayer)
  if not fromPlayer then
    local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    if not player then
      return self.FriendlinessBase
    end
    fromPlayer = player:GetServerId()
  end
  self:InitFriendliness(fromPlayer)
  return self.FriendlinessCurrent[fromPlayer]
end

function HomePetAttributeComponent:InitFriendliness(fromPlayer)
  if self.FriendlinessCurrent[fromPlayer] then
    return
  end
  local close_level_effect = 0
  if _G.HomeIndoorSandbox then
    local close_level = self.owner and self.owner.serverData and self.owner.serverData.pet_info and self.owner.serverData.pet_info.closeness_lv or 0
    local closeConf = _G.DataConfigManager:GetPetCloseLevelEffectConf(close_level, true)
    local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByServerID, fromPlayer)
    if closeConf and player then
      if _G.HomeIndoorSandbox.Utils.ShouldAiTreatLikeFriendByPlayer(player) then
        close_level_effect = closeConf.friend_close_level_fix_value or 0
      else
        close_level_effect = closeConf.stranger_close_level_fix_valu or 0
      end
    end
  end
  self.FriendlinessCurrent[fromPlayer] = math.clamp(self.FriendlinessBase + close_level_effect, 0, 100)
end

function HomePetAttributeComponent:SetJustTriedAttack(fromPlayer)
  self.JustTriedAttackTime[fromPlayer] = os.msTime()
end

function HomePetAttributeComponent:ClearJustTriedAttack(fromPlayer)
  self.JustTriedAttackTime[fromPlayer] = nil
end

function HomePetAttributeComponent:IsJustTriedAttack(playerId)
  local time = self.JustTriedAttackTime[playerId]
  if not time then
    return false
  end
  if os.msTime() - time < 10000.0 then
    return true
  end
  self.JustTriedAttackTime[playerId] = nil
  return false
end

return HomePetAttributeComponent
