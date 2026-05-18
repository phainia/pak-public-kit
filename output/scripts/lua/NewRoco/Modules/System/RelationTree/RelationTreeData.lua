local RelationTreeEvent = reload("NewRoco.Modules.System.RelationTree.RelationTreeEvent")
local RelationTreeData = _G.NRCData:Extend("RelationTreeData")
local MaxCacheNum = 5

function RelationTreeData:Ctor()
  NRCData.Ctor(self)
  self.PlayingCloseBondId = nil
  self.PlayingClosePetGid = nil
  local RelationTreeConf = DataConfigManager:GetTable(DataConfigManager.ConfigTableId.RELATIONTREE_CONF)
  if RelationTreeConf then
    self.RelationTreeAllData = RelationTreeConf:GetAllDatas()
  else
    Log.Error("\233\133\141\231\189\174\232\161\168\228\184\141\229\173\152\229\156\168,\230\159\165\231\156\139\229\142\159\229\155\160 RELATIONTREE_CONF")
    return
  end
  local RelationTreeBasicConf = DataConfigManager:GetTable(DataConfigManager.ConfigTableId.RELATIONTREE_BASIC_CONF)
  if RelationTreeBasicConf then
    self.RelationTreeBasicData = RelationTreeBasicConf:GetAllDatas()
  else
    Log.Error("\233\133\141\231\189\174\232\161\168\228\184\141\229\173\152\229\156\168,\230\159\165\231\156\139\229\142\159\229\155\160 RELATIONTREE_BASIC_CONF")
    return
  end
  self.RelationTreeTable = {}
  self:CreatRelationMainData()
  self:CreateRelationBasicData()
  if not self.RelationTreePool then
    self.RelationTreePool = {}
  end
  if not self.OtherRequests then
    self.OtherRequests = {}
  end
  self.todaySendEggTimes = nil
  local PetRelationTreeConf = DataConfigManager:GetTable(DataConfigManager.ConfigTableId.INTERACTIONTREE_CONF)
  if PetRelationTreeConf then
    self.PetRelationTreeAllData = PetRelationTreeConf:GetAllDatas()
  else
    Log.Error("\233\133\141\231\189\174\232\161\168\228\184\141\229\173\152\229\156\168,\230\159\165\231\156\139\229\142\159\229\155\160 INTERACTIONTREE_CONF")
    return
  end
  self.PetRelationTreeTabel = {}
  self:CreatPetRelationMainData()
end

function RelationTreeData:CreatRelationMainData()
  if self.RelationTreeAllData then
    if not self.RelationTreeTable then
      self.RelationTreeTable = {}
    end
    for k, v in ipairs(self.RelationTreeAllData) do
      local RelationTreeInfo = DataConfigManager:GetRelationtreeConf(k)
      local NodeFloor = RelationTreeInfo.node_floor
      local NodeUnlock = RelationTreeInfo.RelationTreeTypeDefault > 0
      local OptionName = RelationTreeInfo.option_name or ""
      local NodeInfo = {
        ID = RelationTreeInfo.id,
        NodeType = RelationTreeInfo.node_type,
        UnlockCost = RelationTreeInfo.unlock_cost,
        RelationTreeTypeDefault = RelationTreeInfo.RelationTreeTypeDefault,
        RelationTreeType = RelationTreeInfo.RelationTreeType,
        Unlock = NodeUnlock,
        StateStruct = {},
        LockAnimKey = RelationTreeInfo.anim_key1,
        OptionName = OptionName,
        NodeFloor = RelationTreeInfo.node_floor
      }
      if RelationTreeInfo.anim_key2 and 0 ~= RelationTreeInfo.anim_key2 then
        local RelationNodeConfig_State_One = DataConfigManager:GetRelationtreeAnimConf(RelationTreeInfo.anim_key2)
        if RelationNodeConfig_State_One then
          local Struct = {
            actionID = RelationTreeInfo.anim_key2,
            name = RelationNodeConfig_State_One.name_icon_struct[2].name,
            icon = RelationNodeConfig_State_One.name_icon_struct[2].icon
          }
          table.insert(NodeInfo.StateStruct, 1, Struct)
        end
      end
      if RelationTreeInfo.anim_key3 and 0 ~= RelationTreeInfo.anim_key3 then
        local RelationNodeConfig_State_Two = DataConfigManager:GetRelationtreeAnimConf(RelationTreeInfo.anim_key3)
        if RelationNodeConfig_State_Two then
          local Struct = {
            actionID = RelationTreeInfo.anim_key2,
            name = RelationNodeConfig_State_Two.name_icon_struct[2].name,
            icon = RelationNodeConfig_State_Two.name_icon_struct[2].icon
          }
          table.insert(NodeInfo.StateStruct, 2, Struct)
        end
      end
      if not self.RelationTreeTable[NodeFloor] then
        self.RelationTreeTable[NodeFloor] = {}
      end
      table.insert(self.RelationTreeTable[NodeFloor], NodeInfo.NodeType, NodeInfo)
    end
  end
end

function RelationTreeData:CreateRelationBasicData()
  if self.RelationTreeBasicData then
    if not self.RelationTreeBasicTable then
      self.RelationTreeBasicTable = {}
    end
    for k, v in ipairs(self.RelationTreeBasicData) do
      local RelationTreeBasicInfo = DataConfigManager:GetRelationtreeBasicConf(k)
      if v.friend_need == "" then
      end
      local BasicInfo = {
        ID = v.id,
        Name = v.name,
        RelationTreeBasic = v.RelationTreeBasic,
        FriendNeed = v.friend_need
      }
      self.RelationTreeBasicTable[k] = BasicInfo
    end
  end
end

function RelationTreeData:GetRelationTreeNodeByEnum(RelationType)
  for floor, floorValue in pairs(self.RelationTreeTable) do
    for nodetype, nodevalue in pairs(floorValue) do
      if nodevalue.RelationTreeType == RelationType then
        return nodevalue
      end
    end
  end
end

function RelationTreeData:GetRelationTreeNode(OtherPlayerID, IsNotClone)
  if self.RelationTreePool and self.RelationTreePool[OtherPlayerID] then
    if IsNotClone then
      return self.RelationTreePool[OtherPlayerID]
    else
      return table.clone(self.RelationTreePool[OtherPlayerID])
    end
  else
    if not self.RelationTreePool[OtherPlayerID] then
      self.RelationTreePool[OtherPlayerID] = {}
    end
    self:CheckCacheRelationTreePool(OtherPlayerID)
    self.RelationTreePool[OtherPlayerID].OterLevelData = {peer_role_lv = 1, peer_role_world_lv = 1}
    if IsNotClone then
      return self.RelationTreePool[OtherPlayerID]
    else
      return table.clone(self.RelationTreePool[OtherPlayerID])
    end
  end
  return nil
end

function RelationTreeData:GetRelationTreeBasicTable(isClone)
  if isClone then
    return table.clone(self.RelationTreeBasicTable)
  else
    return self.RelationTreeBasicTable
  end
end

function RelationTreeData:CheckCacheRelationTreePool(OtherPlayerID, RelationTreeTable, LevelData, UnlockRelationType)
  if not self.RelationTreePool then
    self.RelationTreePool = {}
  end
  if self.RelationTreePool and self.RelationTreePool[OtherPlayerID] then
    self:UpdateRelationTreeAndCache(false, OtherPlayerID, RelationTreeTable, LevelData, UnlockRelationType)
  elseif table.getTableCount(self.RelationTreePool) >= MaxCacheNum then
    local MinTime = _G.ZoneServer:GetServerTime()
    local RemovePlayerId = 0
    for PlayerID, Value in pairs(self.RelationTreePool) do
      if MinTime > Value.UpdateTime then
        MinTime = Value.UpdateTime
        RemovePlayerId = PlayerID
      end
    end
    self.RelationTreePool[RemovePlayerId] = nil
    self:UpdateRelationTreeAndCache(true, OtherPlayerID, RelationTreeTable, LevelData, UnlockRelationType)
  else
    self:UpdateRelationTreeAndCache(true, OtherPlayerID, RelationTreeTable, LevelData, UnlockRelationType)
  end
end

function RelationTreeData:UpdateRelationTreeAndCache(isClone, OtherPlayerID, ServerRelationTreeTable, LevelData, UnlockRelationType)
  local CurTime = _G.ZoneServer:GetServerTime()
  local MainRelationTreeTable = {}
  if not self.RelationTreePool[OtherPlayerID] then
    self.RelationTreePool[OtherPlayerID] = {}
  end
  if isClone then
    MainRelationTreeTable = table.clone(self.RelationTreeTable)
  elseif self.RelationTreePool[OtherPlayerID].RelationTree then
    MainRelationTreeTable = self.RelationTreePool[OtherPlayerID].RelationTree
  else
    MainRelationTreeTable = table.clone(self.RelationTreeTable)
  end
  self.RelationTreePool[OtherPlayerID].UpdateTime = CurTime
  local MaxUnLockFloor = 0
  for floor, floorvalue in ipairs(MainRelationTreeTable) do
    for nodetype, nodevalue in ipairs(floorvalue) do
      nodevalue.IsWaitAccpet = self.MyRequests ~= nil and nodevalue.RelationTreeType == self.MyRequests or false
      if 1 == nodetype then
        local ForwardFloor = floor > 1 and floor - 1 or floor
        local ForwardNodeTreeTable = MainRelationTreeTable[ForwardFloor]
        nodevalue.ForwardNodeID = 1 == floor and 0 or ForwardNodeTreeTable[nodetype].ID
        nodevalue.ForwardUnlockState = false
        nodevalue.Unlock = false
        if 1 == ForwardFloor then
          nodevalue.ForwardUnlockState = true
          if nodevalue.RelationTreeTypeDefault > 0 then
            nodevalue.Unlock = true
            MaxUnLockFloor = floor
          elseif nodevalue.RelationTreeType > 0 then
            if ServerRelationTreeTable and ServerRelationTreeTable[nodevalue.RelationTreeType] and 1 == ServerRelationTreeTable[nodevalue.RelationTreeType] then
              nodevalue.Unlock = true
              MaxUnLockFloor = floor
            else
              nodevalue.Unlock = false
            end
          end
        elseif nodevalue.RelationTreeTypeDefault > 0 then
          nodevalue.Unlock = true
          MaxUnLockFloor = floor
        elseif nodevalue.RelationTreeType > 0 then
          if ServerRelationTreeTable and ServerRelationTreeTable[nodevalue.RelationTreeType] and 1 == ServerRelationTreeTable[nodevalue.RelationTreeType] then
            if ForwardNodeTreeTable[nodetype].Unlock then
              nodevalue.ForwardUnlockState = true
              nodevalue.Unlock = true
              MaxUnLockFloor = floor
            else
              nodevalue.Unlock = false
            end
          elseif ForwardNodeTreeTable[nodetype].Unlock then
            nodevalue.ForwardUnlockState = true
            nodevalue.Unlock = false
          else
            nodevalue.Unlock = false
          end
        end
      elseif 4 ~= nodetype then
        if floorvalue[nodetype - 1] then
          nodevalue.ForwardNodeID = floorvalue[nodetype - 1].ID
          nodevalue.ForwardUnlockState = false
          nodevalue.Unlock = false
          if floorvalue[nodetype - 1].Unlock then
            nodevalue.ForwardUnlockState = true
            if nodevalue.RelationTreeTypeDefault > 0 then
              nodevalue.Unlock = true
            elseif ServerRelationTreeTable and ServerRelationTreeTable[nodevalue.RelationTreeType] and 1 == ServerRelationTreeTable[nodevalue.RelationTreeType] then
              nodevalue.Unlock = true
            else
              nodevalue.Unlock = false
            end
          end
        else
          Log.Error("RelationTree UpdateRelationTreeAndCache, Configuration node type pre-error")
        end
      else
        Log.Error("RelationTree UpdateRelationTreeAndCache, Configuration node type not have >= 4")
      end
    end
  end
  self.RelationTreePool[OtherPlayerID].RelationTree = MainRelationTreeTable
  self.RelationTreePool[OtherPlayerID].MaxUnLockFloor = MaxUnLockFloor
  LevelData = LevelData or {peer_role_lv = 1, peer_role_world_lv = 1}
  self.RelationTreePool[OtherPlayerID].OterLevelData = LevelData
end

function RelationTreeData:GetRelationTreePoolByUin(OtherPlayerID)
  if self.RelationTreePool and self.RelationTreePool[OtherPlayerID] then
    return self.RelationTreePool[OtherPlayerID]
  end
  return nil
end

function RelationTreeData:GetMyRequests()
  return self.MyRequests
end

function RelationTreeData:UpdateMyRequests(RelationTreeType)
  self.MyRequests = RelationTreeType
  _G.NRCEventCenter:DispatchEvent(RelationTreeEvent.RELATION_UPDATE_MYREQUES, false)
end

function RelationTreeData:ClearMyRequests()
  _G.NRCEventCenter:DispatchEvent(RelationTreeEvent.RELATION_ITEM_UNLOCK_CANCEL, self.MyRequests, true)
  self.MyRequests = nil
  _G.NRCEventCenter:DispatchEvent(RelationTreeEvent.RELATION_UPDATE_MYREQUES, true)
end

function RelationTreeData:GetOtherRequestsData()
  return self.OtherRequests
end

function RelationTreeData:UpdateOtherRequestsData(PlayerUid, RelationTreeType, IsDelete)
  if not self.OtherRequests then
    self.OtherRequests = {}
  end
  if IsDelete then
    if self.OtherRequests[PlayerUid] then
      self.OtherRequests[PlayerUid] = nil
      NRCEventCenter:DispatchEvent(RelationTreeEvent.DELETE_OTHERREQUEST_PLAYER, PlayerUid)
    end
    return
  end
  self.OtherRequests[PlayerUid] = RelationTreeType
  _G.NRCEventCenter:DispatchEvent(RelationTreeEvent.UPDATE_OTHERREQUEST_PLAYER_CHANGE)
end

function RelationTreeData:ClearOtherRequests()
  self.OtherRequests = {}
end

function RelationTreeData:CreatPetRelationMainData()
  if not self.PetReltionTreeTable then
    self.PetRelationTreeTable = {}
  end
  local NodeFloor = 1
  if self.PetRelationTreeAllData then
    for NodeId, NodeValue in ipairs(self.PetRelationTreeAllData) do
      if NodeId <= 3 then
        NodeFloor = 1
      else
        NodeFloor = NodeFloor + 1
      end
      local Unlock = NodeValue.InteractionTreeTypeDefault > 0 and NodeValue.InteractionTreeTypeDefault ~= Enum.InteractiontreeTypeDefault.ITTD_EMPTY and true or false
      local NodeInfo = {
        ID = NodeValue.id,
        Unlock = Unlock,
        InteractionTreeTypeDefault = NodeValue.InteractionTreeTypeDefault,
        Cost = NodeValue.cost,
        StateStruct = {}
      }
      if NodeValue.anim_key2 and 0 ~= NodeValue.anim_key2 then
        local PetRelationNodeConfig_State_One = DataConfigManager:GetRelationtreeAnimConf(NodeValue.anim_key2)
        if PetRelationNodeConfig_State_One then
          local Struct = {}
          if NodeValue.InteractionTreeTypeDefault == Enum.InteractiontreeTypeDefault.ITTD_RIDE then
            local IconList = {}
            for i = 1, 3 do
              local Icon = PetRelationNodeConfig_State_One.name_icon_struct[i].icon
              table.insert(IconList, Icon)
            end
            Struct = {
              actionID = NodeValue.anim_key2,
              name = PetRelationNodeConfig_State_One.name_icon_struct[2].name,
              icon = IconList
            }
          else
            Struct = {
              actionID = NodeValue.anim_key2,
              name = PetRelationNodeConfig_State_One.name_icon_struct[2].name,
              icon = PetRelationNodeConfig_State_One.name_icon_struct[2].icon
            }
          end
          table.insert(NodeInfo.StateStruct, 1, Struct)
        end
      end
      if NodeValue.anim_key3 and 0 ~= NodeValue.anim_key3 then
        local PetRelationNodeConfig_State_Two = DataConfigManager:GetRelationtreeAnimConf(NodeValue.anim_key3)
        if PetRelationNodeConfig_State_Two then
          local Struct = {
            actionID = NodeValue.anim_key3,
            name = PetRelationNodeConfig_State_Two.name_icon_struct[2].name,
            icon = PetRelationNodeConfig_State_Two.name_icon_struct[2].icon
          }
          table.insert(NodeInfo.StateStruct, 2, Struct)
        end
      end
      if not self.PetRelationTreeTable[NodeFloor] then
        self.PetRelationTreeTable[NodeFloor] = {}
      end
      table.insert(self.PetRelationTreeTable[NodeFloor], NodeInfo)
    end
    table.reverse(self.PetRelationTreeTable)
  end
end

function RelationTreeData:GetPetRelationMainTable()
  return self.PetRelationTreeTable
end

return RelationTreeData
