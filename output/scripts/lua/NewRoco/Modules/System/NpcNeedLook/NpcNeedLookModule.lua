local HeadLookAtComponent = require("NewRoco.Modules.Core.Scene.Component.HeadLookAt.HeadLookAtComponent")
local NpcNeedLookModule = NRCModuleBase:Extend("NpcNeedLookModule")

function NpcNeedLookModule:OnConstruct()
  _G.NpcNeedLookModuleCmd = reload("NewRoco.Modules.System.NpcNeedLook.NpcNeedLookModuleCmd")
  self.data = self:SetData("NpcNeedLookModuleData", "NewRoco.Modules.System.NpcNeedLook.NpcNeedLookModuleData")
  self.needLookNpcDict = {}
  WeakTable(self.needLookNpcDict)
  self.playerHeadLookAtComp = nil
  self.watchingTarget = nil
  self.bIsWatching = false
  self.bUpdate = false
  self.bOnEnableDebug = false
  self.bOnEnableDebugTurnScale = false
  self.debugTurnScale = 1
end

function NpcNeedLookModule:OnActive()
end

function NpcNeedLookModule:OnRelogin()
end

function NpcNeedLookModule:OnDeactive()
  _G.UpdateManager:UnRegister(self)
end

function NpcNeedLookModule:OnDestruct()
end

function NpcNeedLookModule:RegisterNpc(sceneNpc, playerTurnScale)
  if not sceneNpc then
    Log.Error("[NpcNeedLookModule] Error, RegisterNpc\228\184\173\228\188\160\229\133\165\231\154\132SceneNpc\230\151\160\230\149\136!")
    return
  end
  if not self.bUpdate then
    _G.UpdateManager:Register(self)
    self.bUpdate = true
  end
  self.needLookNpcDict[sceneNpc] = playerTurnScale or 1
  self:TryPlayerLookAtNpc(sceneNpc)
end

function NpcNeedLookModule:UnRegisterNpc(sceneNpc)
  if not sceneNpc then
    Log.Error("[NpcNeedLookModule] Error, UnRegisterNpc\228\184\173\228\188\160\229\133\165\231\154\132SceneNpc\230\151\160\230\149\136!")
    return
  end
  self.needLookNpcDict[sceneNpc] = nil
  if sceneNpc == self.watchingTarget then
    self:TryFinishPlayerLookAt()
  end
end

function NpcNeedLookModule:TryPlayerLookAtNpc(sceneNpc)
  if not sceneNpc then
    return false
  end
  local bSuccess = false
  self.watchingTarget = sceneNpc
  if self.bIsWatching then
    Log.Debug("[NpcNeedLookModule] Debug, \229\156\168\229\183\178\231\187\143\229\173\152\229\156\168\230\179\168\232\167\134\231\155\174\230\160\135\231\154\132\230\131\133\229\134\181\228\184\139\230\183\187\229\138\160\228\186\134\230\150\176\231\154\132\231\155\174\230\160\135NPC!")
    self:ProcessConflict()
  end
  if self.watchingTarget == sceneNpc then
    bSuccess = true
  end
  self:LetPlayerLookAtNpc(self.watchingTarget)
  return bSuccess
end

function NpcNeedLookModule:LetPlayerLookAtNpc(TargetNpc)
  self.playerHeadLookAtComp = self:GetPlayerHeadLookAtComponent()
  if not self.playerHeadLookAtComp then
    Log.Error("[NpcNeedLookModule] Error, \231\188\186\229\176\145HeadLookAt\231\187\132\228\187\182!")
    return
  end
  if self.bOnEnableDebugTurnScale then
    self.playerHeadLookAtComp:ModifySpeedScale(self.debugTurnScale)
  else
    self.playerHeadLookAtComp:ModifySpeedScale(self.needLookNpcDict[TargetNpc])
  end
  self.playerHeadLookAtComp:SetAutoLookAtParam(UE4.ELookAtParamType.Target, TargetNpc.viewObj)
  self.playerHeadLookAtComp:SetAutoLookAtParam(UE4.ELookAtParamType.Body, nil, nil, nil, 0, 0)
  self.playerHeadLookAtComp:ActiveAutoLookAt(false)
  self.playerHeadLookAtComp:EnableManualOverride()
  self.bIsWatching = true
  if self.bOnEnableDebug then
    self:DrawDebugLine()
  end
end

function NpcNeedLookModule:TryFinishPlayerLookAt()
  if self:DictionarySize(self.needLookNpcDict) > 0 then
    self:TryPlayerLookAtNpc(self:GetNearestNpc())
    return false
  end
  self:FinishPlayerLookAt()
  return true
end

function NpcNeedLookModule:FinishPlayerLookAt()
  if self.playerHeadLookAtComp and UE4.UObject.IsValid(self.playerHeadLookAtComp) then
    self.playerHeadLookAtComp:DisableManualOverride(false)
  end
  self:ClearData()
  _G.UpdateManager:UnRegister(self)
  self.bUpdate = false
end

function NpcNeedLookModule:ClearData()
  self.bIsWatching = false
  self.watchingTarget = nil
  self.playerHeadLookAtComp = nil
  table.clear(self.needLookNpcDict)
end

function NpcNeedLookModule:ProcessConflict()
  self.watchingTarget = self:GetNearestNpc()
end

function NpcNeedLookModule:GetNearestNpc()
  local nearestNpc
  local minDis = math.huge
  for npc, _ in pairs(self.needLookNpcDict) do
    local npcDist = npc.squaredDis2LocalIgnoreZ
    if minDis > npcDist then
      minDis = npcDist
      nearestNpc = npc
    end
  end
  return nearestNpc
end

function NpcNeedLookModule:GetPlayerHeadLookAtComponent()
  local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  return player:GetHeadLookAtComponent()
end

function NpcNeedLookModule:GetLookTarget()
  return self.watchingTarget
end

function NpcNeedLookModule:UpdateWatchingTarget()
  if self:DictionarySize(self.needLookNpcDict) <= 1 then
    return
  end
  local newNearestNpc = self:GetNearestNpc()
  if newNearestNpc and newNearestNpc ~= self.watchingTarget then
    self.watchingTarget = newNearestNpc
    self:LetPlayerLookAtNpc(newNearestNpc)
  end
end

function NpcNeedLookModule:DictionarySize(t)
  local count = 0
  for _ in pairs(t) do
    count = count + 1
  end
  return count
end

function NpcNeedLookModule:DrawDebugLine()
  if not self.watchingTarget or not self.playerHeadLookAtComp then
    return
  end
  local color = UE.FLinearColor(0.4, 0.89, 0, 1)
  local viewComp = self.playerHeadLookAtComp:GetViewObject()
  local playerPos = viewComp:K2_GetActorLocation()
  local targetPos = self.watchingTarget:GetActorLocation()
  UE.UKismetSystemLibrary.DrawDebugLine(viewComp, playerPos, targetPos, color, 5, 1)
end

function NpcNeedLookModule:OnTick(deltaTime)
  self:UpdateWatchingTarget()
end

function NpcNeedLookModule:Debug(bOnEnable)
  self.bOnEnableDebug = bOnEnable
end

function NpcNeedLookModule:DebugTurnScale(bOnEnable, newScale)
  self.bOnEnableDebugTurnScale = bOnEnable
  self.debugTurnScale = newScale or 1
end

return NpcNeedLookModule
