require("UnLuaEx")
local MathExtend = require("Utils.MathExtend")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local ProtoEnum = require("Data.PB.ProtoEnum")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local BP_NPCStaticTree_C = Base:Extend("BP_NPCStaticTree_C")

function BP_NPCStaticTree_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCStaticTree_C:OnFrameLoad(distanceRatio)
  Base.OnFrameLoad(self, distanceRatio)
end

function BP_NPCStaticTree_C:OnFirstLoad()
  Base.OnFirstLoad(self)
  local locations = self:GetMountPos()
  self.after_random_pos = MathExtend.GetRandomSequence_TArray(locations, locations:Length())
  self.isfirstloadfinish = true
  self:MountCachedFruit()
end

function BP_NPCStaticTree_C:MountCachedFruit()
  if self.prepareMount then
    for _, fruit in pairs(self.prepareMount) do
      self:SetCreateNPC(fruit)
    end
    self.prepareMount = {}
  end
end

function BP_NPCStaticTree_C:GetMountPos()
  self.Mounts:Clear()
  local sockets = self.StaticMesh:GetAllSocketNames()
  for idx = 1, sockets:Length() do
    local socketName = sockets:Get(idx)
    local location = self.StaticMesh:Abs_GetSocketLocation(socketName)
    self.Mounts:Add(location)
  end
  return self.Mounts
end

function BP_NPCStaticTree_C:GetRandomPos()
  for idx = 1, #self.after_random_pos do
    local pos = self.after_random_pos[idx]
    if not self.socketUseFlag[idx] then
      return pos, idx
    end
  end
end

function BP_NPCStaticTree_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_NPCStaticTree_C:Init()
  Base.Init(self)
  self.isfirstloadfinish = false
  self.fruitPosMap = {}
  self.socketUseFlag = {}
  self.prepareMount = {}
  self.mountedFruits = {}
end

function BP_NPCStaticTree_C:SetCreateNPC(fruit)
  local serverData = fruit.serverData
  local fruitId = serverData.base.actor_id
  local selfId = self.sceneCharacter.serverData.base.actor_id
  self.sceneCharacter:SetNotDestroyFlag(false)
  if self.isfirstloadfinish then
    local location, idx = self:GetRandomPos()
    if idx then
      self.fruitPosMap[fruitId] = idx
      self.socketUseFlag[idx] = true
      if not fruit.viewObj then
        fruit:CreateView()
      end
      if fruit.viewObj.Mount then
        fruit.viewObj:Mount(location)
      else
        fruit.viewObj:Abs_K2_SetActorLocation_WithoutHit(location)
      end
      fruit:ChangeNeedPosAdjust(false, true)
      fruit.viewObj.needTick = false
      fruit.viewObj:SetActorTickEnabled(false)
      fruit.viewObj:OnFrameLoad(fruit:GetDistanceRatio())
      if self.fixcoordFinish then
        fruit.viewObj:SendPosToServer()
      end
      if not fruit:HasListener(self, NPCModuleEvent.On_NPC_LEAVE, self.OnNPCLeave) then
        fruit:AddEventListener(self, NPCModuleEvent.On_NPC_LEAVE, self.OnNPCLeave)
      end
      self.mountedFruits[fruitId] = fruit
    else
    end
  else
    self.prepareMount[fruitId] = fruit
    if not fruit:HasListener(self, NPCModuleEvent.On_NPC_LEAVE, self.OnNPCLeave) then
      fruit:AddEventListener(self, NPCModuleEvent.On_NPC_LEAVE, self.OnNPCLeave)
    end
  end
end

function BP_NPCStaticTree_C:OnNPCLeave(fruit)
  if not fruit then
    return nil
  end
  fruit:RemoveEventListener(self, NPCModuleEvent.On_NPC_LEAVE, self.OnNPCLeave)
  local serverData = fruit.serverData
  local fruitId = serverData.base.actor_id
  local selfId = 0
  if self.sceneCharacter then
    selfId = self.sceneCharacter.serverData.base.actor_id
  end
  self.prepareMount[fruitId] = nil
  self.mountedFruits[fruitId] = nil
  local idx = self.fruitPosMap[fruitId]
  if idx then
    self.socketUseFlag[idx] = false
    self.fruitPosMap[fruitId] = nil
  end
end

function BP_NPCStaticTree_C:LetFruitDrop()
  Log.Debug("Let Fruit Drop")
  for key, fruit in pairs(self.mountedFruits) do
    local meshcomponent = fruit.viewObj:GetComponentByClass(UE4.UStaticMeshComponent)
    if meshcomponent then
      meshcomponent:SetCollisionProfileName("CreatingNPC")
      fruit.viewObj:SetActorTickEnabled(true)
      meshcomponent:SetSimulatePhysics(true)
    end
  end
  self.mountedFruits = {}
end

function BP_NPCStaticTree_C:SetActorLocation(newPos)
  if SceneUtils.IsRuntime then
    Log.Debug("BP_NPCStaticTree_C:SetActorLocation", self.sceneCharacter.serverData.base.actor_id)
  end
  local curPos = self:Abs_K2_GetActorLocation()
  local offset = newPos - curPos
  for _, fruit in pairs(self.mountedFruits) do
    local cur = fruit:GetActorLocation()
    fruit:SetActorLocation(cur + offset)
    if SceneUtils.IsRuntime and self.fixcoordFinish then
      local fruitModel = fruit.viewObj
      if fruitModel then
        fruitModel:SendPosToServer()
      else
      end
    end
  end
  for idx = 1, #self.after_random_pos do
    local pos = self.after_random_pos[idx]
    self.after_random_pos[idx] = pos + offset
  end
  self:Abs_K2_SetActorLocation_WithoutHit(newPos)
end

return BP_NPCStaticTree_C
