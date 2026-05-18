local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local FallingBeamComponent = require("NewRoco.Modules.Core.NPC.ViewNPCComponent.FallingBeamComponent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DebugTabNPCEffect = Base:Extend("DebugTabNPCEffect")

function DebugTabNPCEffect:Ctor()
  Base.Ctor(self)
  self._petBattleFlag = true
end

function DebugTabNPCEffect:SetupTabs()
  self:Add("\229\188\128\229\133\179LookAtLine", self.LookAtModuleDebug, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "LookAtModuleDebug")
  self:Add("\229\188\128\229\133\179\231\142\169\229\174\182\232\189\172\229\164\180\233\128\159\229\186\166Scale", self.SetLookAtModuleScale, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "SetLookAtModuleScale")
  self:Add("\229\133\179\233\151\173\232\135\170\229\138\168\230\139\190\229\143\150", self.TurnOffAutoCollect, self)
  self:Add("\229\188\128\229\144\175\232\135\170\229\138\168\230\139\190\229\143\150", self.TurnOnAutoCollect, self)
end

function DebugTabNPCEffect:AdjustFlowerSeedNiagaraDefault()
  local Npc = self:GetNearestNpc()
  if Npc and Npc.viewObj.default then
    Npc.viewObj:default()
  end
end

function DebugTabNPCEffect:AdjustFlowerSeedNiagaraSelected()
  local Npc = self:GetNearestNpc()
  if Npc and Npc.viewObj.self_selected_flower_seed then
    Npc.viewObj:self_selected_flower_seed()
  end
end

function DebugTabNPCEffect:AdjustFlowerSeedNiagaraShiny()
  local Npc = self:GetNearestNpc()
  if Npc and Npc.viewObj.shiny_flower_seed then
    Npc.viewObj:shiny_flower_seed()
  end
end

function DebugTabNPCEffect:DebugNpcDrop()
  SceneUtils.debugNPCDrop = not SceneUtils.debugNPCDrop
end

function DebugTabNPCEffect:DebugNavInterPathPoint()
  SceneUtils.debugInterNavPathPoint = not SceneUtils.debugInterNavPathPoint
end

function DebugTabNPCEffect:DebugNavInterTarget()
  SceneUtils.debugInterNavTargetPoint = not SceneUtils.debugInterNavTargetPoint
end

function DebugTabNPCEffect:ToggleNpcOptionInvalid()
  SceneUtils.debugForceNpcOptionInvalid = not SceneUtils.debugForceNpcOptionInvalid
end

function DebugTabNPCEffect:DebugNavInterForcePoint()
  SceneUtils.debugInterNavPathForcePoint = not SceneUtils.debugInterNavPathForcePoint
end

function DebugTabNPCEffect:PlayDestroyEffect(name, panel, id)
  if panel then
    local idRec = tonumber(panel.InputBox:GetText())
    if not idRec then
      Log.Warning("DebugTabNPCEffect:UnlockNPC, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    if npcs[idRec] then
      if npcs[idRec].viewObj.PlayDestroyEffect then
        npcs[idRec].viewObj:PlayDestroyEffect()
      end
    else
      Log.Warning("DebugTabNPCEffect:UnlockNPC\239\188\140\232\190\147\229\133\165\231\154\132id\229\156\168\229\189\147\229\137\141npc\228\184\173\228\184\141\229\173\152\229\156\168", idRec)
    end
  elseif id then
    local idRec = id
    if not idRec then
      Log.Warning("DebugTabNPCEffect:UnlockNPC, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    if npcs[idRec] then
      if npcs[idRec].viewObj.PlayDestroyEffect then
        npcs[idRec].viewObj:PlayDestroyEffect()
      end
    else
      Log.Warning("DebugTabNPCEffect:UnlockNPC\239\188\140\232\190\147\229\133\165\231\154\132id\229\156\168\229\189\147\229\137\141npc\228\184\173\228\184\141\229\173\152\229\156\168", idRec)
    end
  end
end

function DebugTabNPCEffect:TriggerAllInteractInArea()
  SceneUtils.debugTriggerInteract = not SceneUtils.debugTriggerInteract
end

function DebugTabNPCEffect:DebugCoordFix()
  SceneUtils.debugCoordFix = true
end

function DebugTabNPCEffect:HideAllForBattle()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npcDict = NPCModule._npcDic
  for id, npc in pairs(npcDict) do
    npc:SetVisibleForBattleReason(false)
  end
end

function DebugTabNPCEffect:ShowAllForBattle()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npcDict = NPCModule._npcDic
  for id, npc in pairs(npcDict) do
    npc:SetVisibleForBattleReason(true)
  end
end

function DebugTabNPCEffect:DebugBeamShow()
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local fx = _G.NRCResourceManager:LoadUObjectForDebugOnly(_G.UEPath.QUALITYMAP[UE4.UKismetMathLibrary.RandomIntegerInRange(1, 5)])
  if fx then
    Log.Error("Load Beam Success")
    local rootcomponent = localPlayer.viewObj:K2_GetRootComponent()
    local location = localPlayer.viewObj:Abs_K2_GetActorLocation()
    local rotation = UE4.FRotator()
    local scale = UE4.FVector(1.0, 1.0, 1.0)
    if UE4.UGameplayStatics.Abs_SpawnEmitterAtLocation(_G.UE4Helper.GetCurrentWorld(), fx, location, rotation, scale, true, UE4.EPSCPoolMethod.None, true) then
      Log.Error("Spawn Beam Success")
    else
      Log.Error("Spawn Beam Faild")
    end
  else
    Log.Error("Load Beam Faild")
  end
end

function DebugTabNPCEffect:PetFollowTest()
  local mainFightId = 0
  do
    local bagPosArray = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo().bag_pos_gid
    if bagPosArray then
      mainFightId = bagPosArray[1] or 0
    end
  end
  local petInfo
  local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  if battlePetList then
    for i, petData in ipairs(battlePetList) do
      if mainFightId == petData.gid then
        petInfo = petData
        break
      end
    end
  end
  local petBaseConf
  if petInfo then
    petBaseConf = _G.DataConfigManager:GetPetbaseConf(petInfo.base_conf_id)
  end
  if not petBaseConf then
    return
  end
  local modelId = petBaseConf.model_conf
  local npcid = 10012
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  local npcInfo = ProtoMessage:newActorInfo_Npc()
  if not npcInfo then
    return
  end
  npcInfo.base.actor_id = -114514
  npcInfo.base.lv = petInfo.level
  npcInfo.base.pt.pos = ProtoMessage:newPosition()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local player = localPlayer.viewObj:Abs_K2_GetActorLocation()
  npcInfo.base.pt.pos.x = player.X + math.random(-300, 300)
  npcInfo.base.pt.pos.y = player.Y + math.random(-300, 300)
  npcInfo.base.pt.pos.z = player.Z + 50
  npcInfo.base.pt.dir = UE.FVector(0, 0, 1)
  npcInfo.npc_base.npc_cfg_id = npcid
  local sceneNPC = npcModule:CreateFollowingNpc(npcInfo, modelId)
end

function DebugTabNPCEffect:OnServerUnlockNPC(_rsp)
  _G.NRCModuleManager:DoCmd(BigMapModuleCmd.BonfireFinishNotify)
end

function DebugTabNPCEffect:ServerUnlockNPC(Name, Panel, npcRefreshCfgId)
  local MapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  if MapModule:HasPanel("MainBigMap") then
    local panel = MapModule:GetPanel("MainBigMap")
    if panel then
      Log.Error("\232\175\183\229\133\179\233\151\173\229\156\176\229\155\190\229\144\142\228\189\191\231\148\168\232\175\165GM")
      return
    end
  end
  local req = ProtoMessage:newZoneGmUnlockWorldMapStaticNpcReq()
  if Panel then
    req.npc_refresh_cfg_id = Panel:GetInputNumber()
  else
    req.npc_refresh_cfg_id = tonumber(npcRefreshCfgId)
  end
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_UNLOCK_WORLD_MAP_STATIC_NPC_REQ, req, self, self.OnServerUnlockNPC)
end

function DebugTabNPCEffect:ServerUnlockDungeonEntry(Name, Panel, npcRefreshCfgId)
  local MapModule = _G.NRCModuleManager:GetModule("BigMapModule")
  if MapModule:HasPanel("MainBigMap") then
    local panel = MapModule:GetPanel("MainBigMap")
    if panel then
      Log.Error("\232\175\183\229\133\179\233\151\173\229\156\176\229\155\190\229\144\142\228\189\191\231\148\168\232\175\165GM")
      return
    end
  end
  local req = ProtoMessage:newZoneGmUnlockWorldMapStaticNpcReq()
  if Panel then
    req.npc_refresh_cfg_id = Panel:GetInputNumber()
  else
    req.npc_refresh_cfg_id = tonumber(npcRefreshCfgId)
  end
  req.exclude_dungeon = true
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_UNLOCK_WORLD_MAP_STATIC_NPC_REQ, req, self, self.OnServerUnlockNPC)
end

function DebugTabNPCEffect:UnlockNPC(name, panel, id)
  if panel then
    local idRec = tonumber(panel.InputBox:GetText())
    if not idRec then
      Log.Warning("DebugTabNPCEffect:UnlockNPC, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    if npcs[idRec] then
      npcs[idRec].luaObj:OnLogicStatusChange(0)
    else
      Log.Warning("DebugTabNPCEffect:UnlockNPC\239\188\140\232\190\147\229\133\165\231\154\132id\229\156\168\229\189\147\229\137\141npc\228\184\173\228\184\141\229\173\152\229\156\168", idRec)
    end
  elseif id then
    local idRec = id
    if not idRec then
      Log.Warning("DebugTabNPCEffect:UnlockNPC, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    if npcs[idRec] then
      npcs[idRec].luaObj:OnLogicStatusChange(0)
    else
      Log.Warning("DebugTabNPCEffect:UnlockNPC\239\188\140\232\190\147\229\133\165\231\154\132id\229\156\168\229\189\147\229\137\141npc\228\184\173\228\184\141\229\173\152\229\156\168", idRec)
    end
  end
end

function DebugTabNPCEffect:CombineUnlockNPC(name, panel, id)
  if panel then
    local idRec = tonumber(panel.InputBox:GetText())
    if not idRec then
      Log.Warning("DebugTabNPCEffect:CombineUnlockNPC, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    if npcs[idRec] then
      npcs[idRec].luaObj:OnCombineLockStateChange(nil, 1)
    else
      Log.Warning("DebugTabNPCEffect:CombineUnlockNPC\239\188\140\232\190\147\229\133\165\231\154\132id\229\156\168\229\189\147\229\137\141npc\228\184\173\228\184\141\229\173\152\229\156\168", idRec)
    end
  elseif id then
    local idRec = id
    if not idRec then
      Log.Warning("DebugTabNPCEffect:CombineUnlockNPC, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    if npcs[idRec] then
      npcs[idRec].luaObj:OnCombineLockStateChange(nil, 1)
    else
      Log.Warning("DebugTabNPCEffect:CombineUnlockNPC\239\188\140\232\190\147\229\133\165\231\154\132id\229\156\168\229\189\147\229\137\141npc\228\184\173\228\184\141\229\173\152\229\156\168", idRec)
    end
  end
end

function DebugTabNPCEffect:RefreshNPC(name, panel, id)
  if panel then
    local idRec = tonumber(panel.InputBox:GetText())
    if not idRec then
      Log.Warning("DebugTabNPCEffect:RefreshNPC, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    if npcs[idRec] then
      local act = {}
      act.executable_times = 2
      npcs[idRec].luaObj:UpdateActStatus(act)
    else
      Log.Warning("DebugTabNPCEffect:RefreshNPC\239\188\140\232\190\147\229\133\165\231\154\132id\229\156\168\229\189\147\229\137\141npc\228\184\173\228\184\141\229\173\152\229\156\168", idRec)
    end
  elseif id then
    local idRec = id
    if not idRec then
      Log.Warning("DebugTabNPCEffect:RefreshNPC, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    if npcs[idRec] then
      local act = {}
      act.executable_times = 2
      npcs[idRec].luaObj:UpdateActStatus(act)
    else
      Log.Warning("DebugTabNPCEffect:RefreshNPC\239\188\140\232\190\147\229\133\165\231\154\132id\229\156\168\229\189\147\229\137\141npc\228\184\173\228\184\141\229\173\152\229\156\168", idRec)
    end
  end
end

function DebugTabNPCEffect:ExhaustedNPC(name, panel, id)
  if panel then
    local idRec = tonumber(panel.InputBox:GetText())
    if not idRec then
      Log.Warning("DebugTabNPCEffect:ExhaustedNPC, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    if npcs[idRec] then
      local act = {}
      act.executable_times = 0
      npcs[idRec].luaObj:UpdateActStatus(act)
    else
      Log.Warning("DebugTabNPCEffect:ExhaustedNPC\239\188\140\232\190\147\229\133\165\231\154\132id\229\156\168\229\189\147\229\137\141npc\228\184\173\228\184\141\229\173\152\229\156\168", idRec)
    end
  elseif id then
    local idRec = id
    if not idRec then
      Log.Warning("DebugTabNPCEffect:ExhaustedNPC, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    if npcs[idRec] then
      local act = {}
      act.executable_times = 0
      npcs[idRec].luaObj:UpdateActStatus(act)
    else
      Log.Warning("DebugTabNPCEffect:ExhaustedNPC\239\188\140\232\190\147\229\133\165\231\154\132id\229\156\168\229\189\147\229\137\141npc\228\184\173\228\184\141\229\173\152\229\156\168", idRec)
    end
  end
end

function DebugTabNPCEffect:ForceFixCoordNearestNPC()
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if not npc then
    Log.Warning("\230\178\161\230\156\137\230\137\190\229\136\176npc")
    return
  end
  if npc.viewObj then
    npc.viewObj:FixCoord(true)
  else
    Log.Warning("viewobj\228\184\141\229\173\152\229\156\168")
  end
end

function DebugTabNPCEffect:DebugNearestNPCDetail()
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if not npc then
    Log.Warning("\230\178\161\230\156\137\230\137\190\229\136\176npc")
    return
  end
  npc:DebugDetail()
end

function DebugTabNPCEffect:CheckIfNearestNPCLockGroundInConfig(name, panel)
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if not npc then
    Log.Warning("\230\178\161\230\156\137\230\137\190\229\136\176npc")
    return
  end
  local bLockOnGround
  local sceneCharacter = npc
  local refreshId = sceneCharacter.serverData.npc_base.npc_content_cfg_id
  local refreshConf
  if refreshId and 0 ~= refreshId then
    refreshConf = _G.DataConfigManager:GetNpcRefreshContentConf(refreshId)
  end
  if not refreshConf or 0 == refreshConf.lock_on_ground then
    bLockOnGround = 1 == sceneCharacter.config.lock_on_ground
  else
    bLockOnGround = 1 == refreshConf.lock_on_ground
  end
  local txt
  if bLockOnGround then
    txt = "\233\133\141\231\189\174\228\184\173\232\180\180\229\156\176"
  else
    txt = "\233\133\141\231\189\174\228\184\173\230\156\170\232\180\180\229\156\176"
  end
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerLocation = player.viewObj:Abs_K2_GetActorLocation()
  local Ctx = DialogContext()
  Ctx:SetContent(txt .. "\n" .. string.format("%s,%d,%u,%d,%d,%s", npc.config.name, npc.config.id, npc.serverData.base.actor_id, npc.serverData.base.actor_id, npc.serverData.npc_base.npc_content_cfg_id, string.format("\229\189\147\229\137\141\228\186\186\231\137\169\228\189\141\231\189\174 %f,%f,%f", playerLocation.X, playerLocation.Y, playerLocation.Z)))
  Ctx:SetMode(DialogContext.Mode.OK)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function DebugTabNPCEffect:ResetToServerPos(name, panel, id)
  if panel then
    local idRec = tonumber(panel.InputBox:GetText())
    if not idRec then
      Log.Warning("DebugTabNPCEffect:ResetToServerPos, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    if npcs[idRec] then
      local born_pt = npcs[idRec].serverData.base.born_pt
      local pos = UE4.FVector(born_pt.pos.x, born_pt.pos.y, born_pt.pos.z)
      npcs[idRec]:SetActorLocation(pos)
    else
      Log.Warning("DebugTabNPCEffect:ResetToServerPos\239\188\140\232\190\147\229\133\165\231\154\132id\229\156\168\229\189\147\229\137\141npc\228\184\173\228\184\141\229\173\152\229\156\168", idRec)
    end
  elseif id then
    local idRec = id
    if not idRec then
      Log.Warning("DebugTabNPCEffect:ResetToServerPos, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    if npcs[idRec] then
      local born_pt = npcs[idRec].serverData.base.born_pt
      local pos = UE4.FVector(born_pt.pos.x, born_pt.pos.y, born_pt.pos.z)
      npcs[idRec]:SetActorLocation(pos)
    else
      Log.Warning("DebugTabNPCEffect:ResetToServerPos\239\188\140\232\190\147\229\133\165\231\154\132id\229\156\168\229\189\147\229\137\141npc\228\184\173\228\184\141\229\173\152\229\156\168", idRec)
    end
  end
end

function DebugTabNPCEffect:ResetNearestNPCToServerPos(panel)
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if npc then
    local born_pt = npc.serverData.base.born_pt
    local pos = UE4.FVector(born_pt.pos.x, born_pt.pos.y, born_pt.pos.z)
    Log.Debug("\230\156\141\229\138\161\229\153\168\229\136\157\229\167\139\229\157\144\230\160\135", pos.X, pos.Y, pos.Z)
    npc:SetActorLocation(pos)
  end
end

function DebugTabNPCEffect:ForceTryFixCoord(name, panel, id)
  if panel then
    local idRec = tonumber(panel.InputBox:GetText())
    if not idRec then
      Log.Warning("DebugTabNPCEffect:ForceTryFixCoord, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    if npcs[idRec] then
      if npcs[idRec].viewObj then
        npcs[idRec].viewObj:FixCoord(true)
      end
    else
      Log.Warning("DebugTabNPCEffect:ForceTryFixCoord\239\188\140\232\190\147\229\133\165\231\154\132id\229\156\168\229\189\147\229\137\141npc\228\184\173\228\184\141\229\173\152\229\156\168", idRec)
    end
  elseif id then
    local idRec = id
    if not idRec then
      Log.Warning("DebugTabNPCEffect:ForceTryFixCoord, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    if npcs[idRec] then
      if npcs[idRec].viewObj then
        npcs[idRec].viewObj:FixCoord(true)
      end
    else
      Log.Warning("DebugTabNPCEffect:ForceTryFixCoord\239\188\140\232\190\147\229\133\165\231\154\132id\229\156\168\229\189\147\229\137\141npc\228\184\173\228\184\141\229\173\152\229\156\168", idRec)
    end
  end
end

function DebugTabNPCEffect:CreateFakeNPC()
  Log.Debug("DebugTabNPCEffect:CreateFakeNPC")
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local Pos = Player:GetActorLocationFrameCache()
  local npc = NPCModule:CreateFakeNpc(50021)
  npc.viewObj:SetThrowFlag()
  npc:SetActorLocation(UE4.FVector(Pos.X + 150, Pos.Y, Pos.Z))
  local rootComponent = npc.viewObj:K2_GetRootComponent()
  rootComponent:SetSimulatePhysics(true)
end

function DebugTabNPCEffect:LockPlayer()
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  _G.GlobalConfig.DisableBattle = true
  localPlayer.inputComponent:SetInputEnable(self, false)
end

function DebugTabNPCEffect:UnLockPlayer()
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  _G.GlobalConfig.DisableBattle = true
  localPlayer.inputComponent:SetInputEnable(self, true)
end

function DebugTabNPCEffect:FakePendantChange()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npc = NPCModule:GetNearestNPC()
  local pendantComp = npc:GetComponent(require("NewRoco.Modules.Core.Scene.Component.Pendant.PendantComponent"))
  if pendantComp and #pendantComp.pendantGroups > 0 then
    local group = pendantComp.pendantGroups[1]
    local changelist = {}
    for _, item in pairs(group.pendantStates) do
      table.insert(changelist, {
        id = _,
        enable = math.random(1, 10) > 5
      })
    end
    pendantComp:ApplyGroupChange(group, not group.enabled, changelist, 1)
  end
end

function DebugTabNPCEffect:DebugInteractRangeInfo()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local Npc = NPCModule:GetNearestNPC()
  if not Npc then
    Log.Error("\233\153\132\232\191\145\230\178\161\230\156\137Npc")
    return
  end
  local MainAction = Npc.InteractionComponent:GetMainAction()
  if not MainAction then
    Log.Error("Npc\230\178\161\230\156\137Option")
    return
  end
  UE4.UKismetSystemLibrary.Abs_DrawDebugCircle(_G.UE4Helper.GetCurrentWorld(), Npc:GetActorLocation() + UE.FVector(0, 0, 50), MainAction.config.option_radius, 100, UE4.FLinearColor(1, 0, 0, 1), 100, 1, UE.FVector(1, 0, 0), UE.FVector(0, 1, 0))
  local CancelRadius = MainAction.config.cancel_option_radius
  if 0 ~= CancelRadius then
    UE4.UKismetSystemLibrary.Abs_DrawDebugCircle(_G.UE4Helper.GetCurrentWorld(), Npc:GetActorLocation() + UE.FVector(0, 0, 50), CancelRadius, 100, UE4.FLinearColor(0, 1, 0, 1), 100, 1, UE.FVector(1, 0, 0), UE.FVector(0, 1, 0))
  end
  local PlayerViewRange = MainAction.config.vision_range / 2
  if 0 ~= PlayerViewRange then
    local LocalPlayer = _G.NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    local PlayerLocation = Npc.PlayerPosCache
    local PlayerForward = LocalPlayer.viewObj:GetActorForwardVector()
    UE4.UKismetSystemLibrary.DrawDebugConeInDegrees(_G.UE4Helper.GetCurrentWorld(), PlayerLocation, PlayerForward, 300, PlayerViewRange, 1, 12, UE4.FLinearColor(0, 1, 0, 1), 100)
  end
end

function DebugTabNPCEffect:LookAtModuleDebug()
  _G.GlobalConfig.DrawDebugLookAt = not _G.GlobalConfig.DrawDebugLookAt
  if NRCModuleManager:IsModuleActive("NpcNeedLookModule") then
    _G.NRCModuleManager:DoCmd(_G.NpcNeedLookModuleCmd.Debug, _G.GlobalConfig.DrawDebugLookAt)
  end
end

function DebugTabNPCEffect:SetLookAtModuleScale(name, panel, id)
  if not NRCModuleManager:IsModuleActive("NpcNeedLookModule") then
    return
  end
  local idRec = tonumber(panel.InputBox:GetText())
  if nil == idRec then
    _G.NRCModuleManager:DoCmd(_G.NpcNeedLookModuleCmd.DebugTurnScale, false, nil)
  else
    _G.NRCModuleManager:DoCmd(_G.NpcNeedLookModuleCmd.DebugTurnScale, true, idRec)
  end
end

function DebugTabNPCEffect:TurnOnAutoCollect()
  SceneUtils.debugDisableAutoCollect = false
end

function DebugTabNPCEffect:TurnOffAutoCollect()
  SceneUtils.debugDisableAutoCollect = true
  Log.Error("\232\135\170\229\138\168\230\139\190\229\143\150\229\183\178\229\133\179\233\151\173")
end

return DebugTabNPCEffect
