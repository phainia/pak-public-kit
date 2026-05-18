local AIComponent, PetHUDComponent
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local BP_MiaoMiaoSpawner_C = Class()

function BP_MiaoMiaoSpawner_C:Ctor()
  self.NpcInstances = {}
  self.InstanceCount = 0
end

function BP_MiaoMiaoSpawner_C:SpawnInstance(location, npcId)
  if not GlobalConfig.VisualSpawningNpc then
    return
  end
  if self.InstanceCount > 5 then
    return
  end
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  if not npcModule then
    return
  end
  location = SceneUtils.ConvertRelativeToAbsolute(location)
  local finalPos = SceneUtils.ClientPos2ServerPos(location)
  local npc = npcModule:CreateLocalNPC(npcId, finalPos)
  if not npc then
    Log.Warning("MiaomiaoSpawner : Cant create npc", npcId)
    return nil
  end
  if not SceneUtils.debugCloseCreateAIComp then
    if not AIComponent then
      AIComponent = require("NewRoco.Modules.Core.Scene.Component.AI.AIComponent")
    end
    local aiComp = npc:EnsureComponent(AIComponent)
    aiComp.PersistentEnable = true
    aiComp:OnDistanceOptimize(0, 1, 0, 0)
  end
  if not SceneUtils.debugCloseCreateHUDComp then
    if not PetHUDComponent then
      PetHUDComponent = require("NewRoco.Modules.Core.Scene.Component.HUD.PetHUDComponent")
    end
    local hudComp = npc:EnsureComponent(PetHUDComponent)
    hudComp:ForceUpdate()
  end
  self.NpcInstances[npc:GetServerId()] = true
  self.InstanceCount = self.InstanceCount + 1
  npc:AddEventListener(self, NPCModuleEvent.On_NPC_LEAVE, self.OnNpcLeave)
  return npc.viewObj
end

function BP_MiaoMiaoSpawner_C:OnNpcLeave(npc)
  self.NpcInstances[npc:GetServerId()] = nil
  self.InstanceCount = self.InstanceCount - 1
end

function BP_MiaoMiaoSpawner_C:RemoveInstances()
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  for id, valid in pairs(self.NpcInstances) do
    local npc = npcModule:GetNpcByServerID(id)
    if npc then
      npc:RemoveEventListener(self, NPCModuleEvent.On_NPC_LEAVE, self.OnNpcLeave)
      npcModule:OnNPCLeave(id)
    end
  end
  self.NpcInstances = {}
  self.InstanceCount = 0
end

return BP_MiaoMiaoSpawner_C
