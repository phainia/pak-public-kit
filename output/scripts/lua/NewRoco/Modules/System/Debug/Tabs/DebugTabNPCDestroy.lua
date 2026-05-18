local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local FallingBeamComponent = require("NewRoco.Modules.Core.NPC.ViewNPCComponent.FallingBeamComponent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DebugTabNPCDestroy = Base:Extend("DebugTabNPCDestroy")

function DebugTabNPCDestroy:Ctor()
  Base.Ctor(self)
end

function DebugTabNPCDestroy:SetupTabs()
end

function DebugTabNPCDestroy:DestroyAllOutViewBTreeNPC()
  local function filter(npc)
    if npc.distanceRatio >= 1 and npc.config.behavior_tree then
      return true
    end
  end
  
  self:DestroyByFilter(filter)
end

function DebugTabNPCDestroy:DestroyByClass(className)
  local function filter(npc)
    if className then
      if npc.viewObj and npc.viewObj.name == className then
        return true
      end
    else
      return true
    end
  end
  
  self:DestroyByFilter(filter)
end

function DebugTabNPCDestroy:DestroyExclude(name, panel, id)
  if panel then
    local idRec = tonumber(panel.InputBox:GetText(), 10)
    if not idRec then
      Log.Warning("DebugTabNPC:DestroyExclude, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    
    local function filter(npc)
      if npc:GetServerId() ~= idRec then
        return true
      else
        return false
      end
    end
    
    self:DestroyByFilter(filter)
  elseif id then
    local idRec = id
    if not idRec then
      Log.Warning("DebugTabNPC:DestroyExclude, id\228\184\141\229\173\152\229\156\168\230\136\150\228\184\141\228\184\186\230\149\176\229\173\151\239\188\140\232\175\183\229\156\168\228\184\138\230\150\185\232\190\147\229\133\165\229\143\130\230\149\176")
      return
    end
    
    local function filter(npc)
      if npc:GetServerId() ~= idRec then
        return true
      else
        return false
      end
    end
    
    self:DestroyByFilter(filter)
  end
end

function DebugTabNPCDestroy:DestroyByFilter(filter)
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npcDict = NPCModule._npcDic
  local needToRemove = {}
  local inDisplay = 0
  for id, npc in pairs(npcDict) do
    if filter(npc) then
      table.insert(needToRemove, id)
      if npc.distanceRatio < 1 then
        inDisplay = inDisplay + 1
      end
    end
  end
  SceneUtils.debugDestroy = true
  for _, id in pairs(needToRemove) do
    NPCModule:RemoveNpc(id, true, true)
  end
  Log.Error(string.format("\233\148\128\230\175\129npc\230\149\176\233\135\143%d,\232\167\134\233\135\142\229\134\133\230\149\176\233\135\143%d", #needToRemove, inDisplay))
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, string.format("\233\148\128\230\175\129npc\230\149\176\233\135\143%d,\232\167\134\233\135\142\229\134\133\230\149\176\233\135\143%d", #needToRemove, inDisplay))
end

function DebugTabNPCDestroy:DestroyAllInViewNPC()
  local function filter(npc)
    if npc.distanceRatio < 1 then
      return true
    end
  end
  
  self:DestroyByFilter(filter)
end

function DebugTabNPCDestroy:DestroyAllInViewGleam()
  local function filter(npc)
    if npc.distanceRatio < 1 and npc.viewObj and npc.viewObj.name == "BP_NPCGleam_C" then
      return true
    end
  end
  
  self:DestroyByFilter(filter)
end

function DebugTabNPCDestroy:DestroyAllOutViewNPC()
  local function filter(npc)
    if npc.distanceRatio >= 1 then
      return true
    end
  end
  
  self:DestroyByFilter(filter)
end

function DebugTabNPCDestroy:DestroyAllBehaviorTreeNPC()
  local function filter(npc)
    if npc.config.behavior_tree then
      return true
    end
  end
  
  self:DestroyByFilter(filter)
end

function DebugTabNPCDestroy:DestroyAllGleam()
  self:DestroyByClass("BP_NPCGleam_C")
end

function DebugTabNPCDestroy:DestroyAllGuLi()
  self:DestroyByClass("BP_NPCGulitianguo_C")
end

function DebugTabNPCDestroy:DestroyAllSwayTree()
  self:DestroyByClass("BP_NPCTree_C")
end

function DebugTabNPCDestroy:DestroyAllBox()
  self:DestroyByClass("BP_NPCBox_C")
end

function DebugTabNPCDestroy:DestroyAllOre()
  self:DestroyByClass("BP_NPCOreBase_C")
end

function DebugTabNPCDestroy:DestroyAllCamp()
  self:DestroyByClass("BP_NPCCampBonfireBase_C")
end

function DebugTabNPCDestroy:DestroyAllEnclosure()
  self:DestroyByClass("BP_Enclosure_C")
end

function DebugTabNPCDestroy:DestroyAllFruit()
  self:DestroyByClass("BP_NPCFruit_C")
end

function DebugTabNPCDestroy:DestroyAllVeg()
  self:DestroyByClass("BP_NPCVegBase_C")
end

function DebugTabNPCDestroy:DestroyAllNPCCharacter()
  self:DestroyByClass("BP_NPCCharacter_C")
  self:DestroyByClass("BP_PEO_Scene_C")
end

function DebugTabNPCDestroy:DestroyAllNPC()
  self:DestroyByClass()
end

function DebugTabNPCDestroy:DestroyAllNPCClientAndServer()
  self:DestroyByClass()
  local gmReq = _G.ProtoMessage:newZoneGmForbidCreateNpcReq()
  gmReq.uin = 0
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_FORBID_CREATE_NPC_REQ, gmReq, self, self._OnDestroyAllNPCClientAndServerRsp)
end

function DebugTabNPCDestroy:_OnDestroyAllNPCClientAndServerRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.Error("Forbidden Create Npc failed!")
  else
    Log.Debug("Forbidden Create Npc succeed!")
  end
end

function DebugTabNPCDestroy:DestroyAllNPCPlus()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npcDict = NPCModule._npcDic
  local needToRemove = {}
  local inDisplay = 0
  for id, npc in pairs(npcDict) do
    if npc.viewObj then
      local viewObj = npc.viewObj
      npc.luaObj.viewObj = nil
      npc.viewObj = nil
      viewObj.sceneCharacter = nil
      viewObj:UnLoadResource()
      viewObj.staticMeshResInfos = {}
      viewObj.skeletalMeshResInfos = {}
      viewObj.particleResInfos = {}
      viewObj.niagaraParticleResInfos = {}
      viewObj.animConfigResInfos = {}
      viewObj.abpResInfos = {}
      viewObj.actorResInfos = {}
      viewObj:K2_DestroyActor()
      viewObj:ReleaseForce()
    end
    table.insert(needToRemove, id)
    if npc.distanceRatio < 1 then
      inDisplay = inDisplay + 1
    end
  end
  SceneUtils.debugDestroy = true
  for _, id in pairs(needToRemove) do
    NPCModule:RemoveNpc(id, true, true)
  end
  Log.Error(string.format("\233\148\128\230\175\129npc\230\149\176\233\135\143%d,\232\167\134\233\135\142\229\134\133\230\149\176\233\135\143%d", #needToRemove, inDisplay))
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, string.format("\233\148\128\230\175\129npc\230\149\176\233\135\143%d,\232\167\134\233\135\142\229\134\133\230\149\176\233\135\143%d", #needToRemove, inDisplay))
  NPCModule.npcActorPool:ClearAll()
  SceneUtils.debugCloseNPCPoolExtend = true
  UE4.UNRCStatics.ForceGarbageCollection(true)
end

function DebugTabNPCDestroy:DestroyAllNPCPlus2()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npcDict = NPCModule._npcDic
  local needToRemove = {}
  local inDisplay = 0
  for id, npc in pairs(npcDict) do
    if npc.viewObj then
      local viewObj = npc.viewObj
      npc.luaObj.viewObj = nil
      npc.viewObj = nil
      viewObj.sceneCharacter = nil
      viewObj:UnLoadResource()
      viewObj.staticMeshResInfos = {}
      viewObj.skeletalMeshResInfos = {}
      viewObj.particleResInfos = {}
      viewObj.niagaraParticleResInfos = {}
      viewObj.animConfigResInfos = {}
      viewObj.abpResInfos = {}
      viewObj.actorResInfos = {}
      if viewObj.Mesh then
        viewObj:K2_DestroyComponent(viewObj.Mesh)
      end
      viewObj:K2_DestroyActor()
      viewObj:ReleaseForce()
    end
    table.insert(needToRemove, id)
    if npc.distanceRatio < 1 then
      inDisplay = inDisplay + 1
    end
  end
  SceneUtils.debugDestroy = true
  for _, id in pairs(needToRemove) do
    NPCModule:RemoveNpc(id, true, true)
  end
  Log.Error(string.format("\233\148\128\230\175\129npc\230\149\176\233\135\143%d,\232\167\134\233\135\142\229\134\133\230\149\176\233\135\143%d", #needToRemove, inDisplay))
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, string.format("\233\148\128\230\175\129npc\230\149\176\233\135\143%d,\232\167\134\233\135\142\229\134\133\230\149\176\233\135\143%d", #needToRemove, inDisplay))
  NPCModule.npcActorPool:ClearAll()
  SceneUtils.debugCloseNPCPoolExtend = true
end

return DebugTabNPCDestroy
