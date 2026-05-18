local Class = _G.MakeSimpleClass
local NPCResObject = require("NewRoco.Modules.Core.NPC.NPCResObject")
local ResQueue = require("NewRoco.Utils.ResQueue")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local Lua_NPCBase = Class("Lua_NPCBase")
Lua_NPCBase:SetMemberCount(16)

function Lua_NPCBase:PreCtor()
  self.viewObj = nil
  self.viewObjRef = nil
  self.sceneCharacter = nil
  self.createNum = -1
  self.POIKLass = 0
  self.POIItem = nil
  self.createNum = -1
  self.createdNPC = {}
  self.createdChildNPC = {}
  self.childrenIDs = {}
  self.operator_obj_id = nil
  self.ChildLoadQueue = nil
end

function Lua_NPCBase:Ctor()
end

function Lua_NPCBase:UpdateData(npcInfo, isReconnect)
  if isReconnect and self.ChildLoadQueue then
    self.ChildLoadQueue:Release()
  end
end

function Lua_NPCBase:SetSceneCharacter(sceneCharacter)
  self.sceneCharacter = sceneCharacter
end

function Lua_NPCBase:SetViewObj(viewObj)
  self.viewObj = viewObj
  self.viewObjRef = UE4.UObject.IsValid(viewObj) and UnLua.Ref(viewObj)
  self:OnSetViewObj()
end

function Lua_NPCBase:OnDestroy()
  if self.ChildLoadQueue then
    self.ChildLoadQueue:Release()
  end
  self.viewObj = nil
  self.viewObjRef = nil
  self.sceneCharacter = nil
  self.createNum = -1
end

function Lua_NPCBase:GetDebugInfo()
  if self.sceneCharacter then
    return self.sceneCharacter:DebugNPCNameAndID()
  else
    return "\230\178\161\230\156\137SceneCharacter"
  end
end

function Lua_NPCBase:LuaBeginPlay()
  self.POIKLass = 0
  self.createNum = -1
  self.createdNPC = {}
  self.createdChildNPC = {}
  self.childrenIDs = {}
  self.operator_obj_id = nil
  local InVisibleByLightMagic = self.sceneCharacter:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_TO_BE_REVEALED_BY_MAGIC)
  self.sceneCharacter:SetVisibleForReason(not InVisibleByLightMagic, NPCModuleEnum.NpcReasonFlags.LIGHT_MAGIC)
  if not self.sceneCharacter:IsLocal() and self.sceneCharacter.config and (self.sceneCharacter.config.genre == Enum.ClientNpcType.CNT_PETBOSS or self.sceneCharacter.config.genre == Enum.ClientNpcType.CNT_BOSS_SKILL_ITEM) and self.sceneCharacter.viewObj then
    local InVisibleByBossCombat = self.sceneCharacter:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_HIDDEN)
    self.sceneCharacter:SetVisibleForReason(not InVisibleByBossCombat, NPCModuleEnum.NpcReasonFlags.WORLD_COMBAT_HIDDEN)
  end
end

function Lua_NPCBase:OnLogicStatusChange(ChangeInfo)
  if ChangeInfo and ChangeInfo.changed_status.status == _G.ProtoEnum.SpaceActorLogicStatus.SALS_TO_BE_REVEALED_BY_MAGIC then
    local InVisibleByLightMagic = self.sceneCharacter:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_TO_BE_REVEALED_BY_MAGIC)
    self.sceneCharacter:SetVisibleForReason(not InVisibleByLightMagic, NPCModuleEnum.NpcReasonFlags.LIGHT_MAGIC)
  end
  if ChangeInfo and ChangeInfo.changed_status.status == _G.ProtoEnum.SpaceActorLogicStatus.SALS_HIDDEN and (self.sceneCharacter.config.genre == Enum.ClientNpcType.CNT_PETBOSS or self.sceneCharacter.config.genre == Enum.ClientNpcType.CNT_BOSS_SKILL_ITEM) and self.sceneCharacter.viewObj then
    local InVisibleByBossCombat = self.sceneCharacter:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_HIDDEN)
    self.sceneCharacter:SetVisibleForReason(not InVisibleByBossCombat, NPCModuleEnum.NpcReasonFlags.WORLD_COMBAT_HIDDEN)
  end
end

function Lua_NPCBase:OnNpcOptionChange(option)
end

function Lua_NPCBase:OnLevelChange(NewLevel)
  if not self.sceneCharacter then
    return
  end
  if not self.sceneCharacter.serverData then
    return
  end
  if not self.sceneCharacter.serverData.base then
    return
  end
  self.sceneCharacter.serverData.base.lv = NewLevel
  self.sceneCharacter:SendEvent(NPCModuleEvent.NPC_LEVEL_UP)
end

function Lua_NPCBase:InitActStatus(optionInfo)
  self.isOptTimesValid = 0 ~= optionInfo.executable_times
end

function Lua_NPCBase:UpdateActStatus(optionInfo, Tag, BaseData)
  local oldTimesValid = self.isOptTimesValid
  self.isOptTimesValid = 0 ~= optionInfo.executable_times
  if not self.viewObj or not UE4.UObject.IsValid(self.viewObj) then
    return
  end
  if not self.viewObj.bActorVisible then
    return
  end
  if oldTimesValid and not self.isOptTimesValid then
    local OperatorID = BaseData and BaseData.operator_obj_id
    local Operator
    if OperatorID and 0 ~= OperatorID then
      Operator = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, OperatorID) or _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByServerID, OperatorID)
    end
    if Operator then
      Log.Debug("PlayOptTimesOverEffect \230\151\182\231\154\132Operator\228\191\161\230\129\175\228\184\186: ", Operator.name, OperatorID)
    else
      Log.Debug("PlayOptTimesOverEffect \230\151\182\231\154\132Operator\231\169\186\230\142\137\228\186\134,\228\184\165\230\159\165\239\188\129")
    end
    self.viewObj:PlayOptTimesOverEffect(Operator)
  elseif not oldTimesValid and self.isOptTimesValid then
    self.viewObj:PlayOptRefreshEffect()
  end
end

function Lua_NPCBase:OnSetViewObj()
  if self.initialCombineLockStateAction then
    self:InitialCombineLockState(self.initialCombineLockStateAction)
    self.initialCombineLockStateAction = nil
  end
end

function Lua_NPCBase:SetCreateNPCTotalNum(num, operator_obj_id)
  Log.Debug("Lua_NPCBase:SetCreateNPCTotalNum", num, self:GetDebugInfo())
  self.operator_obj_id = operator_obj_id
  self.createNum = num
  self.createdNPC = {}
  if self.childrenIDs then
    table.clear(self.childrenIDs)
  end
  if not self.ChildLoadQueue then
    self.ChildLoadQueue = ResQueue(30, ResQueue.RunMode.Concurrent, _G.PriorityEnum.Passive_NPC_Drop)
  end
  local MySelf = NPCResObject()
  MySelf.NPC = self.sceneCharacter
  self.ChildLoadQueue:InsertResObject("self", MySelf)
end

function Lua_NPCBase:ReSetCreateNPCTotalNum(num)
  Log.Error("Lua_NPCBase:ReSetCreateNPCTotalNum", num, self:GetDebugInfo())
  self.createNum = num
  if not self.viewObj then
    return
  end
  if not self.createdNPC then
    self.createdNPC = {}
  end
  if #self.createdNPC == self.createNum then
    Log.Debug("\229\136\155\229\187\186\229\174\140\230\175\149, \230\149\176\233\135\143\239\188\154", self.createNum)
    if self.viewObj.Show then
      self.viewObj:Show()
    else
      self.sceneCharacter:SetNotDestroyFlag(false)
    end
  end
end

function Lua_NPCBase:SetCreateNPC(npc)
  if not npc then
    Log.Error("Lua_NPCBase:SetCreateNPC,NPC\228\184\186nil")
    return
  end
  local ID = npc:GetServerId()
  if not self.childrenIDs then
    self.childrenIDs = {}
  end
  if not table.include(self.childrenIDs, ID) then
    table.insert(self.childrenIDs, ID)
  end
  if -1 == self.createNum and npc.serverData.npc_base.pos_need_adjust then
    npc:CreateView(false)
    return
  end
  npc:SetVisibleForExplodeReason(false)
  npc.serverData.base.pt = self.sceneCharacter.serverData.base.pt
  npc.serverPos = self.sceneCharacter.serverPos
  local Loader = NPCResObject()
  Loader.NPC = npc
  Loader.DisableFixCoord = true
  Loader.ShouldCreateView = true
  self.ChildLoadQueue:InsertResObject(ID, Loader)
  if table.len(self.childrenIDs) == self.createNum then
    self.ChildLoadQueue:StartLoad(self, self.OnChildrenLoaded)
  end
end

function Lua_NPCBase:OnChildrenLoaded(Queue, Success)
  if not Success then
    Log.Error("\229\138\160\232\189\189\232\181\132\230\186\144\229\164\177\232\180\165\239\188\129\229\188\186\229\136\182\233\135\138\230\148\190\229\173\144\229\175\185\232\177\161", self.sceneCharacter:DebugNPCNameAndID())
  end
  if not self.createdNPC then
    self.createdNPC = {}
  end
  for ActorID, Item in pairs(Queue.ResMap) do
    if "self" ~= ActorID then
      local NPC = Item:Get()
      if NPC and NPC.viewObj then
        NPC:SetVisibleForExplodeReason(true)
        table.insert(self.createdNPC, NPC.viewObj)
      else
        Log.Error("\229\138\160\232\189\189NPC\229\164\177\232\180\165\239\188\129\239\188\129\239\188\129\239\188\129", ActorID)
      end
    end
  end
  self:LetViewObjShow()
  self.ChildLoadQueue:Release()
end

function Lua_NPCBase:LetViewObjShow()
  self.sceneCharacter:RemoveEventListener(self, NPCModuleEvent.VIEW_SHELL_LOADED, self.LetViewObjShow)
  if self.viewObj and UE4.UObject.IsValid(self.viewObj) then
    self.viewObj:Show()
  end
  self.createdNPC = {}
  self.createNum = -1
end

function Lua_NPCBase:TrySetChildNPC(npc)
  if not self.createdChildNPC then
    self.createdChildNPC = {}
  end
  table.insert(self.createdChildNPC, npc)
  if self.viewObj then
    self:LetSetChildNPC()
  else
    self.sceneCharacter:AddEventListener(self, NPCModuleEvent.VIEW_SHELL_LOADED, self.LetSetChildNPC)
  end
end

function Lua_NPCBase:LetSetChildNPC()
  self.sceneCharacter:RemoveEventListener(self, NPCModuleEvent.VIEW_SHELL_LOADED, self.LetSetChildNPC)
  self.viewObj:SetChildNPC(self.createdChildNPC)
  table.clear(self.createdChildNPC)
end

function Lua_NPCBase:GetChildrenNPCs()
  if not self.childrenIDs then
    return {}
  end
  local Temp = {}
  for _, ID in ipairs(self.childrenIDs) do
    local NPC = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, ID)
    if NPC then
      table.insert(Temp, NPC)
    end
  end
  return Temp
end

function Lua_NPCBase:GetChildrenNPCViews()
  if not self.childrenIDs then
    return {}
  end
  local Temp = {}
  for _, ID in ipairs(self.childrenIDs) do
    local NPC = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, ID)
    if NPC then
      table.insert(Temp, NPC.viewObj)
    end
  end
  return Temp
end

function Lua_NPCBase:ClearChildren()
  if self.childrenIDs then
    table.clear(self.childrenIDs)
  end
end

function Lua_NPCBase:SendPosToServer(op_type, reset_pos_if_failed)
  if not self.sceneCharacter then
    return
  end
  self.sceneCharacter:ReportPosition(op_type, reset_pos_if_failed)
end

function Lua_NPCBase:GetForwardModify()
  local forward = UE4.FVector(1, 0, 0)
  return UE4.UKismetMathLibrary.RotateAngleAxis(forward, self.sceneCharacter.serverData.base.pt.dir.z, _G.FVectorUp)
end

return Lua_NPCBase
