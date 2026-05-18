local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local ThrowSessionBase = require("NewRoco.Modules.Core.NPC.ThrowSessionBase")
local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DebugTabNPC = Base:Extend("DebugTabNPC")

function DebugTabNPC:Ctor()
  Base.Ctor(self)
  self._petBattleFlag = true
end

function DebugTabNPC:SetupTabs()
  self:Add("\229\142\159\229\189\162\230\175\149\231\142\176\239\188\129", self.SpecialisRevelio, self)
  self:Add("\228\189\160\229\156\168\229\144\151\239\188\159", self.AreYouThere, self)
  self:Add("\231\148\159\230\136\144\229\156\186\230\153\175\229\186\167\230\164\133", self.CreateSceneSeat, self)
  self:Add("\229\155\158\230\148\182\229\156\186\230\153\175\229\186\167\230\164\133", self.RecycleSceneSeat, self)
  self:Add("\230\181\139\232\175\149\229\156\186\230\153\175\229\186\167\230\164\133EQS", self.DebugSceneSeatEQS, self)
  self:Add("\231\142\176\229\156\168\230\156\137\229\164\154\229\176\145\228\184\170\232\184\169\232\184\143", self.ShowTrailDebugInfo, self)
  self:Add("\229\188\128\229\133\179\232\184\169\232\184\143Debug\230\152\190\231\164\186", self.ToggleTrailDebug, self)
end

function DebugTabNPC:ShowNPCIterDict(Name, Panel)
  self:Inspect(self:GetModule("NPCModule")._npcIterDic)
end

function DebugTabNPC:ShowNPCDict(Name, Panel)
  self:Inspect(self:GetModule("NPCModule")._npcDic)
end

function DebugTabNPC:ShowNPCByID(Name, Panel)
  local NPCs = self:GetModule("NPCModule")._npcDic
  local ID = self:GetInputNumber(0)
  local Result = {}
  for Index, NPC in pairs(NPCs) do
    if NPC.serverData.base.actor_id == ID then
      Result[string.format("%s-%ul", NPC.config.name, NPC.serverData.base.actor_id)] = NPC
    elseif NPC.serverData.npc_base.npc_cfg_id == ID then
      Result[string.format("%s-%ul", NPC.config.name, NPC.serverData.base.actor_id)] = NPC
    elseif NPC.serverData.npc_base.npc_content_cfg_id == ID then
      Result[string.format("%s-%ul", NPC.config.name, NPC.serverData.base.actor_id)] = NPC
    end
  end
  self:Inspect(Result, "NPC")
end

function DebugTabNPC:PrintNPCModuleInfo(name, panel)
  Log.Debug("DebugTabNPC:PrintNPCModuleInfo")
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  Log.Dump(NPCModule._prepareMountDic)
end

function DebugTabNPC:LoadAndDisplayAllNPC()
  Log.Error("\229\138\159\232\131\189\229\183\178\231\187\143\229\164\177\230\149\136...")
end

function DebugTabNPC:TestWindFieldProto()
  local throw_id = ThrowSessionBase:GetNewSessionId()
  local req = ProtoMessage:newZoneSceneBeginThrowReq()
  table.insert(req.gid, 4)
  req.throw_id = throw_id
  req.throw_type = ProtoEnum.ThrowType.THROW_MAGIC
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_BEGIN_THROW_REQ, req, self, self.OnBeginThrowRsp, true, true)
  local end_req = ProtoMessage:newZoneSceneEndThrowReq()
  end_req.throw_type = ProtoEnum.ThrowType.THROW_MAGIC
  end_req.throw_id = throw_id
  end_req.item_conf_id = 0
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local PlayerLocation = localPlayer.viewObj:Abs_K2_GetActorLocation()
  end_req.end_throw_pos.x = PlayerLocation.X
  end_req.end_throw_pos.y = PlayerLocation.Y
  end_req.end_throw_pos.z = PlayerLocation.Z
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_END_THROW_REQ, req, self, self.OnEndThrowRsp, true, true)
end

function DebugTabNPC:OnBeginThrowRsp(rsp)
  Log.Dump(rsp, 3, "DebugTabNPC:OnBeginThrowRsp")
end

function DebugTabNPC:OnEndThrowRsp(rsp)
  Log.Dump(rsp, 3, "DebugTabNPC:OnEndThrowRsp")
end

function DebugTabNPC:DisableAllOutViewNPC()
  local function filter(npc)
    if npc.distanceRatio >= 1 then
      return true
    end
  end
  
  self:DisableByFilter(filter)
end

function DebugTabNPC:ForceBurnNPCPool()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  NPCModule.npcActorPool:ClearAll()
  SceneUtils.debugCloseNPCPoolExtend = true
end

function DebugTabNPC:DisableByFilter(filter)
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npcDict = NPCModule._npcDic
  local disableNum = 0
  local inDisplay = 0
  for id, npc in pairs(npcDict) do
    if filter(npc) then
      NPCModule._npcIterDic[npc.hashId] = nil
      if npc.distanceRatio < 1 then
        inDisplay = inDisplay + 1
      end
      disableNum = disableNum + 1
    end
  end
  SceneUtils.debugDestroy = true
  Log.Error(string.format("\231\166\129\231\148\168npc\230\149\176\233\135\143%d,\232\167\134\233\135\142\229\134\133\230\149\176\233\135\143%d", disableNum, inDisplay))
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, string.format("\231\166\129\231\148\168npc\230\149\176\233\135\143%d,\232\167\134\233\135\142\229\134\133\230\149\176\233\135\143%d", disableNum, inDisplay))
end

function DebugTabNPC:BlockCreateAndLoad()
  SceneUtils.debugBlockCreateAndLoad = true
  SceneUtils.debugCloseNPCPoolExtend = true
end

function DebugTabNPC:CloseCreateNPC()
  SceneUtils.debugCloseCreateNPC = true
end

function DebugTabNPC:ToggleNPCLabel()
  SceneUtils.debugCloseNPCLabel = not SceneUtils.debugCloseNPCLabel
end

DebugTabNPC.ClosedTickAnimComps = {}

function DebugTabNPC:ToggleNPCAnim()
  SceneUtils.debugCloseNPCAnim = not SceneUtils.debugCloseNPCAnim
  if SceneUtils.debugCloseNPCAnim then
    local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
    local npcDict = NPCModule._npcIterDic
    for id, npc in pairs(npcDict) do
      if npc.viewObj then
        local comps = npc.viewObj:K2_GetComponentsByClass(UE4.USkeletalMeshComponent)
        for idx = 1, comps:Length() do
          local comp = comps:Get(idx)
          if comp:IsComponentTickEnabled() then
            comp:SetComponentTickEnabled(false)
            table.insert(DebugTabNPC.ClosedTickAnimComps, comp)
          end
        end
      end
    end
  else
    for _, comp in pairs(DebugTabNPC.ClosedTickAnimComps) do
      comp:SetComponentTickEnabled(true)
    end
    DebugTabNPC.ClosedTickAnimComps = {}
  end
end

function DebugTabNPC:ToggleCreateNPCView()
  SceneUtils.debugCloseCreateNPCView = not SceneUtils.debugCloseCreateNPCView
end

function DebugTabNPC:ToggleNPCOnFrameLoad()
  SceneUtils.debugCloseNPCOnFrameLoad = not SceneUtils.debugCloseNPCOnFrameLoad
end

function DebugTabNPC:ToggleFacialAndHudWidget()
  SceneUtils.debugCloseNPCFacialAndWidget = not SceneUtils.debugCloseNPCFacialAndWidget
end

function DebugTabNPC:ToggleBasicResLoad()
  SceneUtils.debugCloseNPCBasicResLoad = not SceneUtils.debugCloseNPCBasicResLoad
end

function DebugTabNPC:ToggleABPLoad()
  SceneUtils.debugCloseNPCABPLoad = not SceneUtils.debugCloseNPCABPLoad
end

function DebugTabNPC:ToggleAnimConfigLoad()
  SceneUtils.debugCloseNPCAnimConfigLoad = not SceneUtils.debugCloseNPCAnimConfigLoad
end

function DebugTabNPC:ToggleCreateNPCComp()
  SceneUtils.debugCloseCreateNPCComp = not SceneUtils.debugCloseCreateNPCComp
end

function DebugTabNPC:ToggleCreateAIComp()
  SceneUtils.debugCloseCreateAIComp = not SceneUtils.debugCloseCreateAIComp
end

function DebugTabNPC:ToggleCreateInterComp()
  SceneUtils.debugCloseCreateInterComp = not SceneUtils.debugCloseCreateInterComp
end

function DebugTabNPC:ToggleCreateLookComp()
  SceneUtils.debugCloseCreateLookComp = not SceneUtils.debugCloseCreateLookComp
end

function DebugTabNPC:ToggleCreateHUDComp()
  SceneUtils.debugCloseCreateHUDComp = not SceneUtils.debugCloseCreateHUDComp
end

function DebugTabNPC:CloseNPCUpdate()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npcDict = NPCModule._npcIterDic
  for id, npc in pairs(npcDict) do
    npc:SetUpdateEnable(false)
  end
end

function DebugTabNPC:ToggleNPCPoolAsync()
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  npcModule.npcActorPool.asyncLoad = not npcModule.npcActorPool.asyncLoad
end

function DebugTabNPC:ToggleNPCModuleTick()
  SceneUtils.debugCloseNPCModuleTick = not SceneUtils.debugCloseNPCModuleTick
end

function DebugTabNPC:CloseNPCPool()
  SceneUtils.debugCloseNPCPoolExtend = true
  SceneUtils.debugCloseNPCPool = true
end

function DebugTabNPC:SetNPCPoolExtendTime(name, panel, id)
  if panel then
    local num = tonumber(panel.InputBox:GetText())
    SceneUtils.debugPoolExtendTime = num
  elseif id then
    SceneUtils.debugPoolExtendTime = id
  end
end

function DebugTabNPC:ExtendNPCPoolImme(name, panel)
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  npcModule.npcActorPool:ExtendImmediately()
end

function DebugTabNPC:SetNPCPoolBurnTime(name, panel, id)
  if panel then
    local num = tonumber(panel.InputBox:GetText())
    SceneUtils.debugPoolBurnTime = num
  elseif id then
    SceneUtils.debugPoolBurnTime = id
  end
end

function DebugTabNPC:SetNPCPoolAlwaysBurn(name, panel)
  SceneUtils.debugAlwaysBurn = true
end

function DebugTabNPC:PrintNPCPool()
  local npcModule = NRCModuleManager:GetModule("NPCModule")
  npcModule.npcActorPool:PrintInfo()
end

function DebugTabNPC:CopyNearestNPCId()
  local Ctx = DialogContext()
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if not npc then
    Ctx:SetContent("\230\178\161\230\156\137\230\137\190\229\136\176\228\187\187\228\189\149NPC")
  else
    UE4.UNRCStatics.ClipboardCopy(string.format("%u", npc.serverData.base.actor_id))
    Ctx:SetContent(string.format("%s\231\154\132npc id \228\184\186%u, \229\183\178\229\164\141\229\136\182\229\136\176\229\137\170\229\136\135\230\157\191\228\184\173\239\188\140\229\143\175\228\187\165\231\155\180\230\142\165\229\142\187GM\229\183\165\229\133\183\228\184\173\228\189\191\231\148\168", npc.serverData.base.name, npc.serverData.base.actor_id))
  end
  Ctx:SetMode(DialogContext.Mode.OK)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function DebugTabNPC:PrintNearestNPCInfo()
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  local Ctx = DialogContext()
  if npc then
    Log.Dump(npc.serverData, 3, "Show NPC ServerData")
    Log.Dump(npc.serverData.npc_interact.option_infos, 3, "Show NPC ServerData")
    for _, v in pairs(npc.InteractionComponent._options) do
      Log.Dump(v.optionInfo, 4, "Show NPC Options")
    end
    local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    local playerLocation = player.viewObj:Abs_K2_GetActorLocation()
    local LocationInfo = string.format("\229\189\147\229\137\141\228\186\186\231\137\169\228\189\141\231\189\174 %f,%f,%f", playerLocation.X, playerLocation.Y, playerLocation.Z)
    local ControllerInfo = string.format("\230\152\175\229\144\166\232\162\171\230\156\172\229\156\176\231\142\169\229\174\182\230\142\167\229\136\182?%s", npc:IsControlledByPlayer() and "\230\152\175" or "\229\144\166")
    local NPCOwnerInfo = string.format("NPC Creator: %u", npc:GetCreatorID() or -1)
    local WorldOwnerInfo = string.format("World Owner: %u", npc:GetWorldOwnerID())
    local CreatorInfo = ""
    local RefreshConf = _G.DataConfigManager:GetNpcRefreshContentConf(npc.serverData.npc_base.npc_content_cfg_id, true)
    if RefreshConf then
      CreatorInfo = string.format("\229\133\182\228\187\150\228\191\161\230\129\175: %s,%s,%s", RefreshConf.editor_name[1], RefreshConf.editor_name[2], RefreshConf.editor_name[3])
    end
    Ctx:SetContent(string.format([[
%s,%d,%d
%u,%d
%s
%s
%s
%s
%s]], npc.config.name, npc.config.id, npc.serverData.npc_base.npc_content_cfg_id or 0, npc.serverData.base.actor_id, npc.serverData.base.actor_id, LocationInfo, ControllerInfo, NPCOwnerInfo, WorldOwnerInfo, CreatorInfo))
    NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowTable, npc.InteractionComponent, "NPC Options")
  else
    Ctx:SetContent("\230\178\161\230\156\137\230\137\190\229\136\176\228\187\187\228\189\149NPC")
  end
  Ctx:SetMode(DialogContext.Mode.OK)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function DebugTabNPC:SwitchNpcHudShowId()
  _G.GlobalConfig.bShouldShowDebugPetName = not _G.GlobalConfig.bShouldShowDebugPetName
  if _G.GlobalConfig.bShouldShowDebugPetName then
    Log.Error("\229\188\128\229\144\175\230\152\190\231\164\186NPC ID\229\138\159\232\131\189")
  else
    Log.Error("\229\133\179\233\151\173\230\152\190\231\164\186NPC ID\229\138\159\232\131\189")
  end
end

function DebugTabNPC:OpenShowNPCInfoPanel()
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowPlayerLoction, nil)
end

function DebugTabNPC:DeleteNearestNPC()
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.RemoveNPC, npc.serverData.base.actor_id)
end

function DebugTabNPC:PrintWhenNear(name, panel)
  Log.Debug("DebugTabNPC:PrintWhenNear")
  local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
  local num = 0
  self._printWhenNear = not self._printWhenNear
  for _, v in pairs(npcs) do
    v.viewObj.debugWhenNear = self._printWhenNear
    num = num + 1
  end
  Log.Debug("Set", self._printWhenNear, num)
end

function DebugTabNPC:TogglePetBattle()
  local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
  local closeNum = 0
  self._petBattleFlag = not self._petBattleFlag
  for _, v in pairs(npcs) do
    if v.viewObj and v.viewObj:IsA(UE4.APet) then
      v.viewObj.overlapFlag = self._petBattleFlag
      closeNum = closeNum + 1
    end
  end
  Log.Debug("Set", self._petBattleFlag, closeNum)
end

function DebugTabNPC:ResetToServerPos(name, panel, id)
  if panel then
    local idRec = tonumber(panel.InputBox:GetText())
    if not idRec then
      Log.Warning("DebugTabNPC:ResetToServerPos, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    if npcs[idRec] then
      local born_pt = npcs[idRec].serverData.base.born_pt
      local pos = UE4.FVector(born_pt.pos.x, born_pt.pos.y, born_pt.pos.z)
      npcs[idRec]:SetActorLocation(pos)
    else
      Log.Warning("DebugTabNPC:ResetToServerPos\239\188\140\232\190\147\229\133\165\231\154\132id\229\156\168\229\189\147\229\137\141npc\228\184\173\228\184\141\229\173\152\229\156\168", idRec)
    end
  elseif id then
    local idRec = id
    if not idRec then
      Log.Warning("DebugTabNPC:ResetToServerPos, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    if npcs[idRec] then
      local born_pt = npcs[idRec].serverData.base.born_pt
      local pos = UE4.FVector(born_pt.pos.x, born_pt.pos.y, born_pt.pos.z)
      npcs[idRec]:SetActorLocation(pos)
    else
      Log.Warning("DebugTabNPC:ResetToServerPos\239\188\140\232\190\147\229\133\165\231\154\132id\229\156\168\229\189\147\229\137\141npc\228\184\173\228\184\141\229\173\152\229\156\168", idRec)
    end
  end
end

function DebugTabNPC:PrintNPCInfo(name, panel, id)
  if panel then
    local idRec = tonumber(panel.InputBox:GetText())
    if not idRec then
      Log.Warning("DebugTabNPC:PrintNPCInfo, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    if npcs[idRec] then
      Log.Debug("DebugTabNPC:PrintNPCInfo \230\137\147\229\141\176NPC serverData\229\146\140config")
      if npcs[idRec].viewObj then
        Log.Debug(string.format("%u %d", idRec, idRec), "View\229\173\152\229\156\168", npcs[idRec].viewObj:GetName())
      else
        Log.Debug(string.format("%u %d", idRec, idRec), "View\228\184\141\229\173\152\229\156\168")
      end
      Log.Dump(npcs[idRec].serverData)
      Log.Dump(npcs[idRec].combine_lock)
      Log.Dump(npcs[idRec].config)
      Log.Debug("InteractionComponent _options num", table.size(npcs[idRec].InteractionComponent._options))
    else
      Log.Debug("DebugTabNPC:PrintNPCInfo\239\188\140\232\190\147\229\133\165\231\154\132id\229\156\168\229\189\147\229\137\141npc\228\184\173\228\184\141\229\173\152\229\156\168", idRec)
    end
  elseif id then
    local idRec = id
    if not idRec then
      Log.Warning("DebugTabNPC:PrintNPCInfo, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    if npcs[idRec] then
      Log.Debug("DebugTabNPC:PrintNPCInfo \230\137\147\229\141\176NPC serverData\229\146\140config")
      if npcs[idRec].viewObj then
        Log.Debug(string.format("%u %d", idRec, idRec), "View\229\173\152\229\156\168", npcs[idRec].viewObj:GetName())
      else
        Log.Debug(string.format("%u %d", idRec, idRec), "View\228\184\141\229\173\152\229\156\168")
      end
      Log.Dump(npcs[idRec].serverData)
      Log.Dump(npcs[idRec].combine_lock)
      Log.Dump(npcs[idRec].config)
      Log.Debug("InteractionComponent _options num", table.size(npcs[idRec].InteractionComponent._options))
    else
      Log.Debug("DebugTabNPC:PrintNPCInfo\239\188\140\232\190\147\229\133\165\231\154\132id\229\156\168\229\189\147\229\137\141npc\228\184\173\228\184\141\229\173\152\229\156\168", idRec)
    end
  end
end

function DebugTabNPC:PrintNPCLuaClassInfo(name, panel, id)
  if panel then
    local idRec = tonumber(panel.InputBox:GetText())
    if not idRec then
      Log.Warning("DebugTabNPC:PrintNPCInfo, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    if npcs[idRec] then
      self:Inspect(npcs[idRec].viewObj, "NPC")
    else
      Log.Debug("DebugTabNPC:PrintNPCInfo\239\188\140\232\190\147\229\133\165\231\154\132id\229\156\168\229\189\147\229\137\141npc\228\184\173\228\184\141\229\173\152\229\156\168", idRec)
    end
  elseif id then
    local idRec = id
    if not idRec then
      Log.Warning("DebugTabNPC:PrintNPCInfo, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    local npcs = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetAllNPC)
    if npcs[idRec] then
      self:Inspect(npcs[idRec].viewObj, "NPC")
    else
      Log.Debug("DebugTabNPC:PrintNPCInfo\239\188\140\232\190\147\229\133\165\231\154\132id\229\156\168\229\189\147\229\137\141npc\228\184\173\228\184\141\229\173\152\229\156\168", idRec)
    end
  end
end

function DebugTabNPC:ResetAllVisibleDis(name, panel, id)
  if panel then
    local num = tonumber(panel.InputBox:GetText())
    SceneUtils.debugDisSqr = num * num
  elseif id then
    local num = id
    SceneUtils.debugDisSqr = num * num
  end
end

function DebugTabNPC:MonitorNPCByConfID(name, panel, InputText)
  local id
  if panel then
    id = tonumber(panel.InputBox:GetText())
  else
    id = tonumber(InputText)
  end
  _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.AddMonitorByConfID, id)
end

function DebugTabNPC:MonitorNPCByServerID(name, panel, InputText)
  local id
  if panel then
    id = tonumber(panel.InputBox:GetText())
  else
    id = tonumber(InputText)
  end
  _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.AddMonitorByServerID, id)
end

function DebugTabNPC:ClearMonitor()
  _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.ClearMonitor)
end

function DebugTabNPC:ListNPCMemory(name, panel, InputText)
  local input
  if panel then
    input = panel.InputBox:GetText()
  else
    input = InputText
  end
  local params = input:split(";")
  if not input or "" == input then
    Log.Debug("DebugTabNPC:ListNPCMemory \229\143\175\232\190\147\229\133\165\229\143\130\230\149\176\230\137\147\229\141\176\232\175\166\231\187\134\228\191\161\230\129\175,\228\185\159\229\143\175\228\187\165\228\189\191\231\148\168\230\142\167\229\136\182\229\143\176ListNPCMemory")
    params = {}
  end
  _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.DebugNPCMemInfo, params[1], params[2], params[3])
end

function DebugTabNPC:GenerateBlueprint(path, count)
  count = count or 10
  local characterClass = _G.NRCResourceManager:LoadForDebugOnly(path)
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local Pos = Player:GetActorLocationFrameCache()
  local Rot = Player:GetActorRotationFrameCache()
  local Point = ProtoMessage:newPoint()
  Pos = Pos + Rot:RotateVector(FVectorOne * 300)
  Point.pos.x = math.round(Pos.X)
  Point.pos.y = math.round(Pos.Y)
  Point.pos.z = math.round(Pos.Z)
  for i = 1, count do
    local params = {}
    params.sceneCharacter = nil
    local quat = UE4.FQuat.FromAxisAndAngle(UE4Helper.UpVector, 0)
    local fTransfom = UE4.FTransform(quat, UE4.FVector(Pos.X, Pos.Y, Pos.Z))
    local actor = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActor(characterClass, fTransfom, UE4.ESpawnActorCollisionHandlingMethod.AdjustIfPossibleButAlwaysSpawn, nil, nil, nil, params)
    table.insert(SceneUtils.ActorLoadTest, actor)
  end
end

function DebugTabNPC:DebugCreateSomeLocalNPC1(Name, Panel)
  self:GenerateBlueprint("Blueprint'/Game/NewRoco/Modules/Core/NPC/Utils/Mem/BP_Test_TextureStream1.BP_Test_TextureStream1_C'")
end

function DebugTabNPC:DebugLoadBlueprintUClass(Name, Panel)
  local path = "Blueprint'/Game/NewRoco/Modules/Core/NPC/Utils/Mem/BP_Test6_Scene_NPC_0041.BP_Test6_Scene_NPC_0041_C'"
  local characterClass = _G.NRCResourceManager:LoadForDebugOnly(path)
end

function DebugTabNPC:DebugCreateSomeLocalNPC2(Name, Panel)
  self:GenerateBlueprint("Blueprint'/Game/NewRoco/Modules/Core/NPC/Utils/Mem/BP_Test_TextureStream2.BP_Test_TextureStream2_C'")
end

function DebugTabNPC:DebugCreateSomeLocalNPC3(Name, Panel)
  self:GenerateBlueprint("Blueprint'/Game/NewRoco/Modules/Core/NPC/Utils/Mem/BP_Test7_Scene_NPC_0041.BP_Test7_Scene_NPC_0041_C'")
end

function DebugTabNPC:DebugLoadSkeletalMesh(Name, Panel)
  local path = "SkeletalMesh'/Game/ArtRes/AnimSequence/Human/NPC/NPC_0041/SKM_NPC_0041_Skin.SKM_NPC_0041_Skin'"
  for i = 1, 10 do
    local request = NRCResourceManager:LoadResAsync(self, path, -1, -1, function(caller, resRequest, asset)
      Log.Debug(path, "load success")
      table.insert(SceneUtils.ResLoadTest, asset)
    end, function(caller, resRequest, errMsg)
      Log.Error(path, "load fail")
    end, function(caller, resRequest, asset)
    end)
  end
end

function DebugTabNPC:InterUnLoadAllTest()
  SceneUtils.ResLoadTest = {}
  NRCResourceManager:UnLoadResByCaller(self)
  for _, actor in pairs(SceneUtils.ActorLoadTest) do
    actor:K2_DestroyActor()
    if actor.ReleaseForce then
      actor:ReleaseForce()
    end
  end
  Log.Error("Destroy actor", #SceneUtils.ActorLoadTest)
  SceneUtils.ActorLoadTest = {}
end

function DebugTabNPC:DebugUnLoadAllTest1(Name, Panel)
  self:InterUnLoadAllTest()
  UE4.UNRCStatics.ForceGarbageCollection(true)
end

function DebugTabNPC:DebugUnLoadAllTest2(Name, Panel)
  self:InterUnLoadAllTest()
end

function DebugTabNPC:ToggleNPCStat(Name, Panel)
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.ToggleNPCStat)
end

function DebugTabNPC:InspectNearNPCs(Name, Panel)
  local Range = self:GetInputNumber(2000)
  local Total = {}
  local Player = self:GetPlayer()
  local View = Player.viewObj
  local World = _G.UE4Helper.GetCurrentWorld()
  local ResultArray = UE4.TArray(UE.AActor)
  local Success = UE.UKismetSystemLibrary.SphereOverlapActors(World, View:K2_GetActorLocation(), Range, {
    UE.EObjectTypeQuery.WorldDynamic,
    UE.EObjectTypeQuery.Pawn
  }, UE.ANPCBaseCharacter, nil, ResultArray)
  if Success then
    for _, Actor in tpairs(ResultArray) do
      local Character = Actor.sceneCharacter
      if Character then
        Total[Character:DebugNPCNameAndID()] = Character
      end
    end
  end
  Success = UE.UKismetSystemLibrary.SphereOverlapActors(World, View:K2_GetActorLocation(), Range, {
    UE.EObjectTypeQuery.WorldDynamic,
    UE.EObjectTypeQuery.Pawn
  }, UE.ANPCBaseActor, nil, ResultArray)
  if Success then
    for _, Actor in tpairs(ResultArray) do
      local Character = Actor.sceneCharacter
      if Character then
        Total[Character:DebugNPCNameAndID()] = Character
      end
    end
  end
  self:Inspect(Total, "Near NPCs")
end

function DebugTabNPC:ListAllNPC()
  UE.UNRCStatics.ListAllNPC(false)
end

function DebugTabNPC:SpecialisRevelio(Name, Panel)
  UE.UNRCStatics.ExecConsoleCommand("a.Significance.Debug.Enabled 1")
  UE.UNRCStatics.ExecConsoleCommand("a.Significance.DebugInvisible.Enabled 1")
  UE.UNRCStatics.ExecConsoleCommand("a.Significance.DebugActorType 0")
  UE.UNRCStatics.ExecConsoleCommand(string.format("a.Significance.DebugLogType %d", 4294967295))
end

function DebugTabNPC:AreYouThere(Name, Panel)
  local ID = self:GetInputNumber(0)
  local Found = {}
  local NPCModule = self:GetModule("NPCModule")
  for _, NPC in pairs(NPCModule._npcIterDic) do
    if NPC.config.id == ID then
      table.insert(Found, NPC)
    else
      local ServerData = NPC.serverData
      if ServerData and ServerData.npc_base.npc_content_cfg_id == ID then
        table.insert(Found, NPC)
      end
    end
  end
  local Info
  if 0 == #Found then
    Info = string.format("\229\156\168\229\144\142\229\143\176\228\184\139\229\143\145\231\154\132\230\137\128\230\156\137\230\149\176\230\141\174\228\184\173\233\131\189\230\137\190\228\184\141\229\136\176id\228\184\186%u\231\154\132NPC\227\128\130\229\143\175\232\131\189\231\154\132\229\142\159\229\155\160\230\156\137\239\188\154\n1. \229\144\142\229\143\176\230\178\161\228\184\139\229\143\145\239\188\140\229\143\175\228\187\165\232\129\148\231\179\187bravepan.\n2. \229\144\142\229\143\176\229\143\145\228\186\134\239\188\140\228\189\134\230\152\175NPC\230\168\161\229\157\151\230\178\161\230\156\137\230\148\182\229\136\176\229\140\133\239\188\140\229\143\175\228\187\165\232\129\148\231\179\187kemibai.", ID)
  else
    Info = string.format("\230\137\190\229\136\176\228\186\134%d\230\157\161\231\155\184\229\133\179\230\149\176\230\141\174", #Found)
    for _, NPC in ipairs(Found) do
      local ServerData = NPC.serverData
      local SingleInfo = string.format("%s %s %u, %d, Refresh:%d, NPC:%d", ServerData.base.name, NPC.config.name, ServerData.base.actor_id, ServerData.base.actor_id, ServerData.npc_base.npc_content_cfg_id, NPC.config.id)
      local View = NPC.viewObj
      if View then
        SingleInfo = string.format("%s\n%s,\231\188\169\230\148\190:%s", SingleInfo, View.bHidden and "\233\154\144\232\151\143\228\186\134" or "\230\178\161\233\154\144\232\151\143", tostring(View:GetActorScale3D()))
      end
      Info = string.format([[
%s
%s]], Info, SingleInfo)
    end
  end
  local Ctx = DialogContext()
  Ctx:SetContent(Info)
  Ctx:SetMode(DialogContext.Mode.OK)
  Ctx:SetButtonText("\229\183\178\233\152\133")
  Ctx:SetClickAnywhereClose(true)
  Ctx:SetCloseOnOK(true)
  Ctx:SetCloseOnCancel(true)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function DebugTabNPC:WhyAreYouFloating(Name, Panel)
  local npc = self:GetNearestNpc()
  if not npc then
    return
  end
  local View = npc.viewObj
  if not View then
    return
  end
  local NPCConf = npc.config
  local RefreshConf
  if npc.serverData then
    RefreshConf = _G.DataConfigManager:GetNpcRefreshContentConf(npc.serverData.npc_base.npc_content_cfg_id)
  end
  local RefreshLock = RefreshConf and RefreshConf.lock_on_ground or 0
  local NPCLock = NPCConf.lock_on_ground
  local ServerPos = npc.serverData.base.born_pt
  local CurrentPos = npc:GetServerPoint()
  local ConfPosZ = ""
  if RefreshConf and RefreshConf.refresh_type == Enum.RefreshType.RFT_AREA then
    local Area = _G.DataConfigManager:GetAreaConf(RefreshConf.refresh_param)
    if Area and Area.area_type == Enum.AreaType.AREAT_POINT then
      ConfPosZ = string.format(",%d(\233\133\141\231\189\174)", Area.pos[1].position_xyz[3])
    end
  end
  local HalfHeight = 0
  if View.GetHalfHeight then
    HalfHeight = View:GetHalfHeight()
  end
  local ModelConf = npc.modelConf
  local ModelPath = ModelConf and ModelConf.path or ""
  local Info = string.format("%s\nID:%d %d\n\232\180\180\229\156\176\231\177\187\229\158\139:%d(NPC),%d(\229\136\183\230\150\176)\nZ\229\128\188:%s,%d(\229\135\186\231\148\159\231\130\185),%d(\229\174\158\233\153\133\228\189\141\231\189\174),%f(\229\141\138\233\171\152)", npc:DebugNPCNameAndID(), NPCConf.id, RefreshConf and RefreshConf.id or "0", NPCLock, RefreshLock, ConfPosZ, ServerPos.pos.z, math.round(CurrentPos.pos.z - HalfHeight), math.round(HalfHeight))
  Info = string.format([[
%s
BP:%s]], Info, ModelPath)
  Info = string.format("%s\n\229\135\186\231\148\159\230\151\182\232\180\180\229\156\176\228\184\186:%s", Info, View.LockResult)
  local MovementComp = View and View:GetComponentByClass(UE.UCharacterMovementComponent)
  if MovementComp then
    Info = string.format("%s\n\231\167\187\229\138\168\231\187\132\228\187\182:%s,%s", Info, UE.EMovementMode:GetNameByValue(MovementComp.MovementMode), MovementComp:IsComponentTickEnabled() and "Tick\229\188\128\229\144\175" or "Tick\229\133\179\233\151\173")
    local BaseComp = MovementComp and MovementComp:GetMovementBase()
    if BaseComp then
      Info = string.format("%s\n\231\171\153\229\156\168:%s(%s)", Info, UE.UObject.GetName(BaseComp:GetOwner()), BaseComp:GetCollisionProfileName())
    else
      Info = string.format("%s\n\230\178\161\230\156\137\231\171\153\229\156\168\228\187\187\228\189\149\231\137\169\228\189\147\228\184\138", Info)
    end
    local Floor = MovementComp and MovementComp.CurrentFloor
    if Floor then
      if Floor.HitResult.bBlockingHit then
        Info = string.format("%s\n\230\163\128\230\181\139\229\136\176\229\156\176\233\157\162:%f", Info, Floor.HitResult.ImpactPoint.Z)
      else
        Info = string.format("%s\n\230\178\161\230\156\137\230\163\128\230\181\139\229\136\176\229\156\176\233\157\162", Info)
      end
    end
  else
    Info = string.format("%s\n\231\167\187\229\138\168\231\187\132\228\187\182:\230\151\160", Info)
  end
  if RefreshConf then
    Info = string.format("%s\n\229\133\182\228\187\150\228\191\161\230\129\175: %s,%s,%s", Info, RefreshConf.editor_name[1], RefreshConf.editor_name[2], RefreshConf.editor_name[3])
  end
  local Ctx = DialogContext()
  Ctx:SetContent(Info)
  Ctx:SetMode(DialogContext.Mode.OK_CANCEL)
  Ctx:SetButtonText("\231\161\174\229\174\154", "\229\176\157\232\175\149\232\180\180\229\156\176")
  Ctx:SetCallback(self, function(_, Reason)
    Log.Error("\229\176\157\232\175\149\232\180\180\229\156\176\229\146\175", Reason)
    if Reason then
      return
    end
    if npc and npc.viewObj then
      UE.UNRCStatics.ExecConsoleCommand("n.DrawNpcFixCoordinateDebugLine 1")
      npc.viewObj:ForceLockOnGround()
      UE.UNRCStatics.ExecConsoleCommand("n.DrawNpcFixCoordinateDebugLine 0")
    end
  end)
  Ctx:SetClickAnywhereClose(true)
  Ctx:SetCloseOnOK(true)
  Ctx:SetCloseOnCancel(true)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Ctx)
  self:ClosePanel()
end

function DebugTabNPC:WhyAreYouHidden(Name, Panel)
  local npc = self:GetNearestNpc()
  if not npc then
    return
  end
  local View = npc.viewObj
  if not View then
    return
  end
  local Info = string.format("\229\171\140\231\150\145\228\186\186\231\154\132\229\144\141\229\173\151\230\152\175: %s", npc.serverData.base.name)
  if View.TellMeYourInfo then
    Info = string.format("%s\n\229\171\140\231\150\145\228\186\186\231\154\132NPCActor\228\190\155\232\191\176\229\166\130\228\184\139\n%s", Info, View:TellMeYourInfo())
  else
    Info = string.format("%s\n\229\171\140\231\150\145\228\186\186\228\184\141\230\152\175\230\173\163\231\187\143NPC\239\188\140\230\178\161\230\156\137\229\143\163\228\190\155\239\188\140\229\174\131\231\154\132\229\133\168\229\144\141\230\152\175:\n%s", Info, View:GetFullName())
  end
  if View.resourceLoaded then
    Info = string.format("%s\n\232\181\132\230\186\144\229\183\178\231\187\143\229\174\140\230\136\144\229\138\160\232\189\189\228\186\134", Info)
  else
    Info = string.format("%s\n\232\181\132\230\186\144\232\191\152\230\178\161\230\156\137\229\174\140\230\136\144\229\138\160\232\189\189", Info)
  end
  Info = string.format("%s\n\230\136\145\231\154\132\231\188\169\230\148\190\230\152\175\232\191\153\228\184\170\230\149\176\230\141\174 %f", Info, npc:GetConfigScale())
  local Ctx = DialogContext()
  Ctx:SetContent(Info)
  Ctx:SetMode(DialogContext.Mode.OK)
  Ctx:SetButtonText("\229\183\178\233\152\133")
  Ctx:SetClickAnywhereClose(true)
  Ctx:SetCloseOnOK(true)
  Ctx:SetCloseOnCancel(true)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Ctx)
  self:ClosePanel()
end

function DebugTabNPC:WhyNoOption(Name, Panel)
  local Payload = {}
  local NPC = self:GetNearestNpc()
  if NPC then
    Payload.ServerData = NPC.serverData or "\230\178\161\230\156\137\230\156\141\229\138\161\229\153\168\228\191\161\230\129\175"
    Payload.Config = NPC.config
    Payload.Content = _G.DataConfigManager:GetNpcRefreshContentConf(NPC.serverData.npc_base.npc_content_cfg_id)
    Payload.CanTriggerInteraction = NPC.canTriggerInteraction and "\229\143\175\228\187\165\232\167\166\229\143\145\228\186\164\228\186\146" or "\228\184\141\229\133\129\232\174\184\232\167\166\229\143\145\228\186\164\228\186\146"
    Payload.DontDestroy = NPC.notDestroyFlag and "\228\184\141\229\133\129\232\174\184\232\162\171\229\136\160\233\153\164" or "\229\143\175\228\187\165\232\162\171\229\136\160\233\153\164"
    Payload.ShouldDestroy = NPC.shouldDestroy and "\229\186\148\232\175\165\232\162\171\229\136\160\233\153\164" or "\228\184\141\229\186\148\232\175\165\232\162\171\229\136\160\233\153\164"
    Payload.IsDestroyed = NPC.isDestroy and "\229\183\178\231\187\143\232\162\171\229\136\160\233\153\164" or "\229\176\154\230\156\170\232\162\171\229\136\160\233\153\164"
    if NPC.InteractionComponent then
      Payload.Options = {}
      for ID, Opt in pairs(NPC.InteractionComponent._options) do
        Payload.Options[ID] = {
          Enable = Opt:IsOptionEnable(),
          InArea = Opt.inActionArea and "\229\156\168\228\186\164\228\186\146\232\140\131\229\155\180\229\134\133" or "\228\184\141\229\156\168\228\186\164\228\186\146\232\140\131\229\155\180\229\134\133",
          Config = Opt.config,
          Interacting = Opt.CurrentAction and Opt.CurrentAction.bInteracting or "\230\178\161\230\156\137Action",
          ID = Opt.config.id
        }
      end
      Payload.DisableFlags = {}
      local Flags = NPC.InteractionComponent.DisableFlag
      for i = 0, 32 do
        if Flags & 1 << i > 0 then
          local FlagName = table.getKeyName(NPCModuleEnum.NpcInteractDisableFlag, i)
          if string.IsNilOrEmpty(FlagName) then
            FlagName = tostring(i)
          end
          Payload.DisableFlags[FlagName] = i
        end
      end
    else
      Payload.Options = "\230\178\161\230\156\137\228\186\164\228\186\146\231\187\132\228\187\182"
    end
    Payload.HiddenFlags = {}
    if NPC.hiddenFlag > 0 then
      for i = 0, 32 do
        if NPC.hiddenFlag & 1 << i > 0 then
          local FlagName = table.getKeyName(NPCModuleEnum.NpcReasonFlags, i)
          if string.IsNilOrEmpty(FlagName) then
            FlagName = tostring(i)
          end
          Payload.HiddenFlags[FlagName] = i
        end
      end
    end
    Payload.Ban = {}
    local RawData = _G.FunctionBanManager.playerConditionDic
    for key, _ in pairs(RawData) do
      Payload.Ban[table.getKeyName(Enum.PlayerConditionType, key)] = key
    end
    if NPC.viewObj then
      Payload.ViewInfo = {
        name = NPC.viewObj.name or "\230\178\161\230\156\137\229\144\141\229\173\151",
        url = NPC.viewObj:GetFullName() or "\230\178\161\230\156\137URL",
        HasOnShouldDestroy = NPC.viewObj.OnShouldDestroy and "\233\135\141\229\134\153\228\186\134\229\136\160\233\153\164\232\161\168\231\142\176" or "\230\178\161\230\156\137\233\135\141\229\134\153\229\136\160\233\153\164\232\161\168\231\142\176",
        Visible = NPC.viewObj.bActorVisible and "\229\143\175\232\167\129" or "\228\184\141\229\143\175\232\167\129",
        Loaded = NPC.viewObj.resourceLoaded and "\229\138\160\232\189\189\229\174\140\230\136\144" or "\229\138\160\232\189\189\230\156\170\229\174\140\230\136\144",
        Loading = NPC.viewObj.bIsLoading and "\229\138\160\232\189\189\228\184\173" or "\228\184\141\229\156\168\229\138\160\232\189\189"
      }
      local Comp = NPC.viewObj:GetComponentByClass(UE.USignificanceComponent)
      if Comp then
        Payload.Significance = {
          Value = Comp.bSelfControl and Comp.SelfControlSignificanceValue or Comp:GetCurrentSignificanceValue()
        }
      end
      local LogicStatusComp = NPC.LogicStatusComponent
      if LogicStatusComp then
        Payload.LogicStatus = {}
        if LogicStatusComp.StatusInfo then
          for _, Info in pairs(LogicStatusComp.StatusInfo) do
            local StatusName = table.getKeyName(Enum.SpaceActorLogicStatus, Info.status)
            Payload.LogicStatus[StatusName] = Info.status
          end
        end
      else
        Payload.LogicStatus = "\230\178\161\230\156\137\233\128\187\232\190\145\231\138\182\230\128\129"
      end
      local ViewName = NPC.viewObj.name
      if "BP_NPCBox_C" == ViewName or "BP_NPCBox_PetType_C" == ViewName or "BP_NPCNaughtyBox_C" == ViewName then
        Payload.Box = {
          IsOpen = NPC.viewObj.open and "\229\183\178\230\137\147\229\188\128" or "\230\156\170\230\137\147\229\188\128",
          IsShown = NPC.viewObj.showed and "\232\161\168\230\188\148\232\191\135" or "\230\178\161\232\161\168\230\188\148\232\191\135",
          IsShowing = NPC.viewObj.showing and "\230\173\163\229\156\168\232\161\168\230\188\148" or "\230\178\161\229\156\168\232\161\168\230\188\148",
          LuaObj = {
            IsOpen = NPC.luaObj.opened and "\229\183\178\230\137\147\229\188\128" or "\230\156\170\230\137\147\229\188\128",
            OldEnable = NPC.luaObj.old_enable,
            EnableChanged = NPC.luaObj.enable_has_changed and "\230\178\161\229\143\152\229\140\150" or "\230\156\137\229\143\152\229\140\150"
          }
        }
      else
        Payload.Box = "\232\191\153\228\184\141\230\152\175\228\184\170\229\174\157\231\174\177"
      end
    else
      Payload.ViewInfo = "\232\186\171\228\184\138\230\178\161\230\156\137\230\168\161\229\158\139"
    end
    local Module = self:GetModule("NPCModule")
    local FoundInDic = false
    for _, instance in pairs(Module._npcDic) do
      if instance == NPC then
        FoundInDic = true
        break
      end
    end
    local FoundInDicIter = false
    for _, instance in pairs(Module._npcIterDic) do
      if instance == NPC then
        FoundInDicIter = true
        break
      end
    end
    Payload.Module = {
      InDic = FoundInDic and "\229\156\168NPC\229\173\151\229\133\184\228\184\173" or "\228\184\141\229\156\168NPC\229\173\151\229\133\184\228\184\173",
      InDicIter = FoundInDicIter and "\229\156\168NPC\229\173\151\229\133\184\228\184\173" or "\228\184\141\229\156\168NPC\229\173\151\229\133\184\228\184\173",
      SceneReady = (_G.SceneModuleCmd and _G.NRCModuleManager:DoCmd(_G.SceneModuleCmd.CheckSceneFullyEntered) or false) and "\229\156\186\230\153\175\229\183\178\231\187\143\229\135\134\229\164\135\229\165\189" or "\229\156\186\230\153\175\232\191\152\230\178\161\230\156\137\229\135\134\229\164\135\229\165\189"
    }
  else
    Payload.Message = "\233\153\132\232\191\145\230\178\161\230\156\137\230\159\165\229\136\176NPC\229\145\128"
  end
  self:Inspect(Payload, "NPC\228\186\164\228\186\146\228\191\161\230\129\175")
  NPC.Watch = true
  self:ShowTips("\229\183\178\231\187\143\230\160\135\232\174\176" .. NPC:DebugNPCNameAndID())
end

function DebugTabNPC:DisableNPCFixCoordinate(Name, Panel)
  _G.GlobalConfig.DisableNPCFixCoordinate = true
end

function DebugTabNPC:EnableNPCFixCoordinate(Name, Panel)
  _G.GlobalConfig.DisableNPCFixCoordinate = false
end

function DebugTabNPC:DebugSignificance(Name, Panel)
  UE.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "a.Significance.Debug.Enabled 1")
  UE.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "a.Significance.DebugActorType 0")
  UE.UKismetSystemLibrary.ExecuteConsoleCommand(nil, "a.Significance.DebugLogType 999")
end

function DebugTabNPC:CreateSceneSeat(Name, Panel, InputNumber)
  local ID
  if Panel then
    ID = tonumber(Panel.InputBox:GetText())
  else
    ID = tonumber(InputNumber)
  end
  ID = 68001
  _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.CreateSceneSeat, ID)
end

function DebugTabNPC:RecycleSceneSeat(Name, Panel, InputNumber)
  local ID
  if Panel then
    ID = tonumber(Panel.InputBox:GetText())
  else
    ID = tonumber(InputNumber)
  end
  ID = 68001
  _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.RecycleSceneSeat, ID)
end

function DebugTabNPC:DebugSceneSeatEQS(Name, Panel, InputNumber)
  _G.GlobalConfig.bDebugSceneSeatEQS = not _G.GlobalConfig.bDebugSceneSeatEQS
  if _G.GlobalConfig.bDebugSceneSeatEQS then
    Log.Error("\230\148\190\231\189\174\229\186\167\230\164\133NPC\232\176\131\232\175\149EQS \229\188\128")
  else
    Log.Error("\230\148\190\231\189\174\229\186\167\230\164\133NPC\232\176\131\232\175\149EQS \229\133\179")
  end
end

function DebugTabNPC:ShowTrailDebugInfo()
  local NRCTrailSystem = UE4.ANRCTrailSystem.Get(_G.UE4Helper.GetCurrentWorld())
  local NRCTrailComponent = NRCTrailSystem and NRCTrailSystem.GetTrailComponent and NRCTrailSystem:GetTrailComponent()
  local PlayerInfos = NRCTrailComponent and NRCTrailComponent:GetPlayerInfos_GameThread()
  local charCount, objectCount = NRCTrailComponent:GetDebugCounts()
  local activeNum = NRCTrailComponent:GetPlayerInfos_GameThread():Num()
  local usedNum = PlayerInfos and PlayerInfos:Num() or -1
  if charCount + objectCount > 8 then
    Log.Error("\232\173\166\229\145\138\239\188\154\232\184\169\232\184\143\230\149\176\233\135\143\232\182\133\232\191\1358\228\184\170\239\188\140\233\131\168\229\136\134\229\175\185\232\177\161\232\184\169\232\184\143\231\188\186\229\164\177\239\188\129")
    if charCount >= 8 then
      Log.Error("\229\142\159\229\155\160\239\188\154\232\167\146\232\137\178\230\149\176\233\135\143\232\191\135\229\164\154\239\188\140\229\141\160\230\187\161\230\137\128\230\156\137\231\154\132\229\144\141\233\162\157")
    else
      Log.Error("\229\142\159\229\155\160\239\188\154\232\167\146\232\137\178\229\174\157\231\174\177\230\128\187\230\149\176\233\135\143\232\191\135\229\164\154\239\188\140\232\183\157\231\166\187\232\190\131\232\191\156\231\154\132\229\174\157\231\174\177\232\162\171\228\184\162\229\188\131")
    end
  else
    Log.Error(string.format("\231\155\174\229\137\141\232\184\169\232\184\143\231\154\132\229\174\158\228\190\139\230\149\176\228\184\186%d/8 \230\156\170\232\182\133\232\191\135\228\184\138\233\153\144", usedNum))
  end
end

function DebugTabNPC:ToggleTrailDebug()
  _G.GlobalConfig.DebugTrailBox = not _G.GlobalConfig.DebugTrailBox
  Log.Error(_G.GlobalConfig.DebugTrailBox and "\232\184\169\232\184\143Debug\229\183\178\229\188\128\229\144\175" or "\232\184\169\232\184\143Debug\229\183\178\229\133\179\233\151\173")
end

return DebugTabNPC
