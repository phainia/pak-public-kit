local function IsPlayerId(actor_id)
  return 7 == actor_id >> 60
end

local function GetActor(actor_id)
  if not actor_id then
    return nil
  end
  if IsPlayerId(actor_id) then
    return _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByServerID, actor_id)
  else
    return _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, actor_id)
  end
end

local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local IncrementRefId = 0
local WeakSceneCharacterManager = {
  weak_players = {},
  _register_spawn_player = false,
  weak_npcs = {},
  _register_spawn_npc = false
}

function WeakSceneCharacterManager:RegisterSpawn(WeakObj)
  if not WeakObj then
    return
  end
  if IsPlayerId(WeakObj.actor_id) then
    local weak_refs = self.weak_players[WeakObj.actor_id]
    if not weak_refs then
      weak_refs = {}
      self.weak_players[WeakObj.actor_id] = weak_refs
    end
    weak_refs[WeakObj.id] = WeakObj
    self:RegisterSpawnPlayerEvent()
  else
    local weak_refs = self.weak_npcs[WeakObj.actor_id]
    if not weak_refs then
      weak_refs = {}
      self.weak_npcs[WeakObj.actor_id] = weak_refs
    end
    weak_refs[WeakObj.id] = WeakObj
    self:RegisterSpawnNpcEvent()
  end
end

function WeakSceneCharacterManager:UnregisterSpawn(WeakObj)
  if not WeakObj then
    return
  end
  if IsPlayerId(WeakObj.actor_id) then
    local weak_refs = self.weak_players[WeakObj.actor_id]
    if weak_refs then
      weak_refs[WeakObj.id] = nil
      if nil == next(weak_refs) then
        self.weak_players[WeakObj.actor_id] = nil
        if nil == next(self.weak_players) then
          self:UnregisterSpawnPlayerEvent()
        end
      end
    end
  else
    local weak_refs = self.weak_npcs[WeakObj.actor_id]
    if weak_refs then
      weak_refs[WeakObj.id] = nil
      if nil == next(weak_refs) then
        self.weak_npcs[WeakObj.actor_id] = nil
        if nil == next(self.weak_npcs) then
          self:UnregisterSpawnNpcEvent()
        end
      end
    end
  end
end

function WeakSceneCharacterManager:RegisterSpawnPlayerEvent()
  if self._register_spawn_player then
    return
  end
  self._register_spawn_player = true
  NRCEventCenter:RegisterEvent("WeakSceneCharacterManager", self, SceneEvent.OnNetPlayerSpawn, self.OnNetPlayerSpawn)
end

function WeakSceneCharacterManager:UnregisterSpawnPlayerEvent()
  if not self._register_spawn_player then
    return
  end
  self._register_spawn_player = false
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnNetPlayerSpawn, self.OnNetPlayerSpawn)
end

function WeakSceneCharacterManager:RegisterSpawnNpcEvent()
  if self._register_spawn_npc then
    return
  end
  self._register_spawn_npc = true
  NRCEventCenter:RegisterEvent("WeakSceneCharacterManager", self, NPCModuleEvent.On_NPC_Create, self.OnNetNpcSpawn)
end

function WeakSceneCharacterManager:UnregisterSpawnNpcEvent()
  if not self._register_spawn_npc then
    return
  end
  self._register_spawn_npc = false
  NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.On_NPC_Create, self.OnNetNpcSpawn)
end

function WeakSceneCharacterManager:OnNetPlayerSpawn(player)
  if not player then
    return
  end
  local player_id = player:GetServerId()
  local weak_refs = self.weak_players[player_id]
  if weak_refs then
    self.weak_players[player_id] = nil
    if nil == next(self.weak_players) then
      self:UnregisterSpawnPlayerEvent()
    end
    for _, v in pairs(weak_refs) do
      if v then
        v:InBound(player)
      end
    end
  end
end

function WeakSceneCharacterManager:OnNetNpcSpawn(npc)
  if not npc then
    return
  end
  local npc_id = npc:GetServerId()
  local weak_refs = self.weak_npcs[npc_id]
  if weak_refs then
    self.weak_npcs[npc_id] = nil
    if nil == next(self.weak_npcs) then
      self:UnregisterSpawnNpcEvent()
    end
    for _, v in pairs(weak_refs) do
      if v then
        v:InBound(npc)
      end
    end
  end
end

local Delegate = require("Utils.Delegate")
local WeakSceneCharacter = MakeSimpleClass("WeakSceneCharacter")

function WeakSceneCharacter:Ctor(actor_id, hint_actor)
  IncrementRefId = IncrementRefId + 1
  self.id = IncrementRefId
  self._register_destroy = false
  self._released = false
  self.InBoundDelegate = nil
  self.OutBoundDelegate = nil
  self.actor_id = actor_id
  self.sceneCharacter = hint_actor or GetActor(actor_id)
  if not self.sceneCharacter then
    WeakSceneCharacterManager:RegisterSpawn(self)
  end
end

function WeakSceneCharacter.From(sceneCharacter)
  return WeakSceneCharacter(sceneCharacter:GetServerId(), sceneCharacter)
end

function WeakSceneCharacter:__Dctor()
  self:Release()
end

function WeakSceneCharacter:Release()
  if self._released then
    return
  end
  self._released = true
  self:UnRegisterDestroyEvent()
  WeakSceneCharacterManager:UnregisterSpawn(self)
  if self.InBoundDelegate then
    self.InBoundDelegate:Clear()
    self.InBoundDelegate = nil
  end
  if self.OutBoundDelegate then
    self.OutBoundDelegate:Clear()
    self.OutBoundDelegate = nil
  end
  self.sceneCharacter = nil
  self.actor_id = nil
end

function WeakSceneCharacter:Get()
  return self.sceneCharacter
end

function WeakSceneCharacter:RegisterInBound(caller, callback)
  if not self.InBoundDelegate then
    self.InBoundDelegate = Delegate()
  end
  self.InBoundDelegate:Add(caller, callback)
  return self
end

function WeakSceneCharacter:UnregisterInBound(caller, callback)
  if self.InBoundDelegate then
    self.InBoundDelegate:Remove(caller, callback)
  end
  return self
end

function WeakSceneCharacter:RegisterOutBound(caller, callback)
  if not self.OutBoundDelegate then
    self.OutBoundDelegate = Delegate()
  end
  self.OutBoundDelegate:Add(caller, callback)
  return self
end

function WeakSceneCharacter:UnregisterOutBound(caller, callback)
  if self.OutBoundDelegate then
    self.OutBoundDelegate:Remove(caller, callback)
  end
  return self
end

function WeakSceneCharacter:FlushInBound()
  if not self.sceneCharacter then
    return
  end
  if self.InBoundDelegate then
    self.InBoundDelegate:Invoke(self, self.sceneCharacter)
  end
end

function WeakSceneCharacter:InBound(character)
  if not character then
    return
  end
  self.sceneCharacter = character
  self:RegisterDestroyEvent()
  if self.InBoundDelegate then
    self.InBoundDelegate:Invoke(self, character)
  end
end

function WeakSceneCharacter:OutBound()
  self:UnRegisterDestroyEvent()
  WeakSceneCharacterManager:RegisterSpawn(self)
  self.sceneCharacter = nil
  if self.InBoundDelegate then
    self.InBoundDelegate:Invoke(self)
  end
end

function WeakSceneCharacter:RegisterDestroyEvent()
  if self._register_destroy then
    return
  end
  if not self.sceneCharacter then
    return
  end
  self._register_destroy = true
  if IsPlayerId(self.actor_id) then
    self.sceneCharacter:AddEventListener(self, PlayerModuleEvent.ON_PLAYER_DESTROY, self.OutBound)
  else
    self.sceneCharacter:AddEventListener(self, NPCModuleEvent.On_NPC_Destroy, self.OutBound)
  end
end

function WeakSceneCharacter:UnRegisterDestroyEvent()
  if not self._register_destroy then
    return
  end
  self._register_destroy = false
  if not self.sceneCharacter then
    return
  end
  if IsPlayerId(self.actor_id) then
    self.sceneCharacter:RemoveEventListener(self, PlayerModuleEvent.ON_PLAYER_DESTROY, self.OutBound)
  else
    self.sceneCharacter:RemoveEventListener(self, NPCModuleEvent.On_NPC_Destroy, self.OutBound)
  end
end

return WeakSceneCharacter
