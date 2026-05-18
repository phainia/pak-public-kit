local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local NPCPressureComponent = Base:Extend("NPCPressureComponent")

function NPCPressureComponent:Attach(owner)
  Base.Attach(self, owner)
end

function NPCPressureComponent:DeAttach()
  Base.DeAttach(self)
end

function NPCPressureComponent:GetNPCHeightAndWidth(NPCInfo)
  local NPCModelInfo = 0
  return NPCModelInfo
end

function NPCPressureComponent:GenerateNPCInColum(num)
end

function NPCPressureComponent:GenerateNPCInRow(num)
end

function NPCPressureComponent:GenerateSpawnPosition(num)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerPosition = localPlayer.viewObj:Abs_K2_GetActorLocation()
end

function NPCPressureComponent:CreateNpcInfo(npcId, distance)
  return self:CreateNpcInfoAtDistance(npcId, distance)
end

function NPCPressureComponent:CreateFixNpcInfo(npcId, x, y)
  return self:CreateNpcInfoAtFixDistance(npcId, x, y)
end

function NPCPressureComponent:CreateNpcInfoAtDistance(npcId, distance)
  local npcInfo = ProtoMessage:newActorInfo_Npc()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  npcInfo.base.actor_id = npcModule:AcquireFakeID()
  npcInfo.base.lv = 1
  npcInfo.base.pt.pos = ProtoMessage:newPosition()
  local player = localPlayer.viewObj:Abs_K2_GetActorLocation()
  npcInfo.base.pt.pos.x = player.X + math.random(-distance, distance)
  npcInfo.base.pt.pos.y = player.Y + math.random(-distance, distance)
  npcInfo.base.pt.pos.z = player.Z + 1000
  npcInfo.base.pt.dir = UE.FVector(0, 0, 1)
  Log.Warning("yajiji Position x", npcInfo.base.pt.pos.x)
  Log.Warning("yajiji Position y", npcInfo.base.pt.pos.y)
  Log.Warning("yajiji Position z", npcInfo.base.pt.pos.z)
  npcInfo.npc_base.npc_cfg_id = npcId
  npcInfo.npc_base.npc_content_cfg_id = 140382
  return npcInfo
end

function NPCPressureComponent:CreateNpcInfoAtFixDistance(npcId, x, y)
  local npcInfo = ProtoMessage:newActorInfo_Npc()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  npcInfo.base.actor_id = npcModule:AcquireFakeID()
  npcInfo.base.lv = 1
  npcInfo.base.pt.pos = ProtoMessage:newPosition()
  local player = localPlayer.viewObj:Abs_K2_GetActorLocation()
  npcInfo.base.pt.pos.x = player.X + x
  npcInfo.base.pt.pos.y = player.Y + y
  npcInfo.base.pt.pos.z = player.Z + 1000
  npcInfo.base.pt.dir = UE.FVector(0, 0, 1)
  Log.Warning("yajiji Position x", npcInfo.base.pt.pos.x)
  Log.Warning("yajiji Position y", npcInfo.base.pt.pos.y)
  Log.Warning("yajiji Position z", npcInfo.base.pt.pos.z)
  npcInfo.npc_base.npc_cfg_id = npcId
  npcInfo.npc_base.npc_content_cfg_id = 140382
  return npcInfo
end

function NPCPressureComponent:SpawnNPC(num)
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  for i = num, 1, -1 do
    local npcInfo = self:CreateNpcInfo(10015, 1000)
    npcModule:CreateNpc(npcInfo)
  end
end

function NPCPressureComponent:SpawnPet(num)
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  local npcInfo = self:CreateNpcInfo(num, 1000)
  npcModule:CreateNpc(npcInfo)
end

function NPCPressureComponent:SpawnNPCs(num, npcID, distance)
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  for i = num, 1, -1 do
    local npcInfo = self:CreateNpcInfo(npcID, distance)
    npcModule:CreateNpc(npcInfo)
  end
end

function NPCPressureComponent:SpawnFixNPCs(xnum, ynum, npcID, distance)
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  for i = xnum, 1, -1 do
    for j = ynum, 1, -1 do
      local npcInfo = self:CreateFixNpcInfo(npcID, distance * i / xnum, distance * j / ynum)
      npcModule:CreateNpc(npcInfo)
    end
  end
end

function NPCPressureComponent:SpawnNPCAtLocation(npcId, x, y)
  local npcInfo = ProtoMessage:newActorInfo_Npc()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  npcInfo.base.actor_id = npcModule:AcquireFakeID()
  npcInfo.base.lv = 1
  npcInfo.base.pt.pos = ProtoMessage:newPosition()
  local player = localPlayer.viewObj:Abs_K2_GetActorLocation()
  npcInfo.base.pt.pos.x = x
  npcInfo.base.pt.pos.y = y
  npcInfo.base.pt.pos.z = player.Z + 1000
  npcInfo.base.pt.dir = UE.FVector(0, 0, 1)
  npcInfo.npc_base.npc_cfg_id = npcId
  npcInfo.npc_base.npc_content_cfg_id = 500007
  return npcModule:CreateNpc(npcInfo)
end

function NPCPressureComponent:Update(deltaTime)
end

return NPCPressureComponent
