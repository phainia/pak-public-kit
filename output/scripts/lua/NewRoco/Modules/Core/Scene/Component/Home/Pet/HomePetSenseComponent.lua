local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Base = ActorComponent
local HomePetSenseComponent = Base:Extend("HomePetSenseComponent")
local HomeModuleEvent = require("NewRoco/Modules/System/Home/HomeModuleEvent")
local NPCModuleCmd = require("NewRoco.Modules.Core.NPC.NPCModuleCmd")

function HomePetSenseComponent:Attach(owner)
  Base.Attach(self, owner)
  self.option = nil
  self.npcObjId = nil
  self.petGid = nil
  self.npcs = {}
  if not UE.UObject.IsValid(self.player) then
    self.player = self.owner.viewObj
  end
  self.owner:AddEventListener(self, HomeModuleEvent.OnEnterHomeMap, self.OnEnterHomeMap)
  self.owner:AddEventListener(self, HomeModuleEvent.OnExitHomeMap, self.OnExitHomeMap)
  _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.UnRegisterTopKFinder, self)
  local homePetStatusShowDis = _G.DataConfigManager:GetHomeGlobalConfig("home_pet_feed_distance") and _G.DataConfigManager:GetHomeGlobalConfig("home_pet_feed_distance").num or 200
  self.homeFeedShowDis = homePetStatusShowDis * homePetStatusShowDis
  local timerShowDis = _G.DataConfigManager:GetHomeGlobalConfig("home_pet_feed_cd_distance") and _G.DataConfigManager:GetHomeGlobalConfig("home_pet_feed_cd_distance").num or 300
  self.homeTimerShowDistanceSqr = timerShowDis * timerShowDis
  local awardShowDis = _G.DataConfigManager:GetHomeGlobalConfig("home_pet_feed_reward_distance") and _G.DataConfigManager:GetHomeGlobalConfig("home_pet_feed_reward_distance").num or 200
  self.homeAwardShowDistanceSqr = awardShowDis * awardShowDis
  local NPCModuleCmd = require("NewRoco.Modules.Core.NPC.NPCModuleCmd")
  _G.NRCModuleManager:DoCmd(NPCModuleCmd.RegisterTopKFinder, "HomePetSenseComponent", 1, self, self.AlwaysValid)
  self.hasRegisterFinder = true
end

function HomePetSenseComponent:OnEnterHomeMap()
  if self.hasRegisterFinder then
    return
  end
  _G.NRCModuleManager:DoCmd(NPCModuleCmd.RegisterTopKFinder, "HomePetSenseComponent", 1, self, self.AlwaysValid)
  self.hasRegisterFinder = true
  self:SetEnable(true)
end

function HomePetSenseComponent:OnExitHomeMap()
  if not self.hasRegisterFinder then
    return
  end
  _G.NRCModuleManager:DoCmd(NPCModuleCmd.UnRegisterTopKFinder, "HomePetSenseComponent")
  self.hasRegisterFinder = nil
  self:SetEnable(false)
end

function HomePetSenseComponent:AlwaysValid(sceneNpc)
  if not sceneNpc then
    if self.npcs and table.len(self.npcs) > 0 then
      table.clear(self.npcs)
    end
    return nil
  end
  if sceneNpc.serverData and sceneNpc.serverData.home_pet then
    local validHomeOptions = sceneNpc.InteractionComponent:GetValidHomeOptions()
    if sceneNpc.InteractionComponent and not table.isEmpty(validHomeOptions) then
      for _, option in ipairs(validHomeOptions) do
        if option.config and option.config.option_radius * option.config.option_radius >= sceneNpc.squaredDis2Local then
          return sceneNpc
        end
      end
    end
  end
  return nil
end

function HomePetSenseComponent:Update(deltaTime)
  local furnitureNpcList = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.GetTopKFurniture, 1, true)
  if furnitureNpcList and furnitureNpcList[1] and furnitureNpcList[1].furnitureId then
    _G.NRCModuleManager:GetModule("HomeModule"):DispatchEvent(HomeModuleEvent.OnActiveFurnitureChange, furnitureNpcList[1].furnitureId)
  end
end

return HomePetSenseComponent
