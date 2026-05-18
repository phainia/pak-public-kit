local BattleRogueModuleEvent = require("NewRoco.Modules.System.BattleRogue.BattleRogueModuleEvent")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleRogueState = {
  None = 0,
  StartChallenge = 1,
  ChooseEvent = 2,
  InEvent = 3,
  FinishedEvent = 4,
  ChooseBuff = 5,
  EndChallenge = 6,
  ClientChoseEvent = 16,
  FinishedChooseEvent = 32,
  ClientChoseBuff = 64,
  FinishedChooseBuff = 128
}
local BattleRogueModule = NRCModuleBase:Extend("BattleRogueModule")

function BattleRogueModule:OnConstruct()
  _G.BattleRogueModuleCmd = reload("NewRoco.Modules.System.BattleRogue.BattleRogueModuleCmd")
  self.Data = self:SetData("BattleRogueModuleData", "NewRoco.Modules.System.BattleRogue.BattleRogueModuleData")
  self.bInEvent = false
  self.CurState = BattleRogueState.None
  self.PreState = BattleRogueState.None
  self.MaxCombineNum = -1
  self:RegPanel("BattleRogue_Main", "UMG_BattleRogue_Main", _G.Enum.UILayerType.UI_LAYER_FULLSCREEN, nil, nil, true)
  self:RegPanel("CardTips", "UMG_CardTips", _G.Enum.UILayerType.UI_LAYER_POPUP)
  self:RegPanel("Settlement_Tips", "UMG_Settlement_Tips", _G.Enum.UILayerType.UI_LAYER_POPUP)
  self:RegPanel("BuffTips", "UMG_BuffTips", _G.Enum.UILayerType.UI_LAYER_TOP)
  self:ProcessCombineConf()
  _G.ZoneServer:AddProtocolListener(self, _G.ProtoCMD.ZoneSvrCmd.ZONE_BADGE_CHALLENGE_SETTLE_NOTIFY, self.OnFinishEventNotify)
end

function BattleRogueModule:ChangeState(NextState)
  if self.CurState == NextState then
    return
  end
  self.PreState = self.CurState
  self.CurState = NextState
  self:DispatchEvent(BattleRogueModuleEvent.OnRogueStateChange, self.PreState, self.CurState)
  Log.Warning("\232\130\137\233\184\189\230\140\145\230\136\152\231\138\182\230\128\129\229\143\152\230\155\180", self.PreState, self.CurState)
end

function BattleRogueModule:EnsureStateFinished()
  if self.CurState < BattleRogueState.ChooseEvent then
    return
  end
  self.PreState = self.CurState
  self.CurState = self.CurState << 1
  Log.Warning("\232\130\137\233\184\189\230\140\145\230\136\152\231\138\182\230\128\129\229\143\152\230\155\180", self.PreState, self.CurState)
end

function BattleRogueModule:SendChallengeLevelReq(LevelID)
  local Req = _G.ProtoMessage:newZoneStartBadgeChallengeReq()
  Req.id = LevelID
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_START_BADGE_CHALLENGE_REQ, Req, self, self.OnChallengeLevelRsp, false, false)
  self.Data.CurLevelID = LevelID
  self:ChangeState(BattleRogueState.StartChallenge)
end

function BattleRogueModule:OnChallengeLevelRsp(Rsp)
  if self:CheckRspInvalid(Rsp.ret_info) then
    return
  end
  self:InitLevelInfo(Rsp.level_infos)
  self:InitPetDatas()
  self:UpdateEventDatas(Rsp.event_infos)
  self:UpdateCoinNum(Rsp.remain_coin, Rsp.refresh_need_coin)
  self.Data.RefreshBaseCost = Rsp.refresh_need_coin
  self:ChangeState(BattleRogueState.ChooseEvent)
  self.Data.CurBuffDatas = {}
  self.Data.bFinishedChallenge = false
  self.Data.CurNodeIndex = 1
  self:DispatchEvent(BattleRogueModuleEvent.OnUpdateEvents, self.Data.UIEventDatas, self.Data.CombineEventIndexes)
  self:DispatchEvent(BattleRogueModuleEvent.StartRogueChallenge, self.Data.LevelInfo)
  self.Data:SetIsOpenSettlementTips(false)
  self:OpenBattleRoguePanel()
end

function BattleRogueModule:SendChooseRogueEventReq(Index)
  if self.CurState ~= BattleRogueState.ChooseEvent then
    return
  end
  local Req = _G.ProtoMessage:newZoneSelectBadgeChallengeCardReq()
  Req.index = Index - 1
  self.Data.CurEventIndex = Index
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SELECT_BADGE_CHALLENGE_CARD_REQ, Req, self, self.OnChooseRogueEventRsp, false, false)
  self:ChangeState(BattleRogueState.ClientChoseEvent)
end

function BattleRogueModule:OnChooseRogueEventRsp(Rsp)
  if self:CheckRspInvalid(Rsp.ret_info) then
    return
  end
  self:SetNodeData(self.Data.CurNodeIndex, self.Data.CurEventInfos[self.Data.CurEventIndex])
  self:UpdateEventDatas(Rsp.event_infos)
  self:EnsureStateFinished()
  self:DispatchEvent(BattleRogueModuleEvent.OnUpdateEvents, self.Data.UIEventDatas, self.Data.CombineEventIndexes)
  self:DispatchEvent(BattleRogueModuleEvent.OnChoseEvent, self.Data.UIEventDatas)
end

function BattleRogueModule:SendFixedEventReq(Index)
  local Req = _G.ProtoMessage:newZoneFixedBadgeChallengeCardReq()
  Req.index = Index - 1
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_FIXED_BADGE_CHALLENGE_CARD_REQ, Req, self, self.OnFixedEventRsp, false, false)
  self.Data.CurEventIndex = Index
end

function BattleRogueModule:OnFixedEventRsp(Rsp)
  if self:CheckRspInvalid(Rsp.ret_info) then
    return
  end
  self:FixedEvent(self.Data.CurEventIndex)
  self:DispatchEvent(BattleRogueModuleEvent.OnFixedEvent, self.Data.CurEventIndex, self.Data.UIEventDatas)
end

function BattleRogueModule:SendCombineEventReq(Indexes)
  local Req = _G.ProtoMessage:newZoneCombineBadgeChallengeCardReq()
  local SendIndexes = self:ClientIndexes2Server(Indexes)
  Req.indexes = SendIndexes
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_COMBINE_BADGE_CHALLENGE_CARD_REQ, Req, self, self.OnCombineEventRsp, false, false)
end

function BattleRogueModule:OnCombineEventRsp(Rsp)
  if self:CheckRspInvalid(Rsp.ret_info) then
    return
  end
  self:UpdateEventDatas(Rsp.event_infos)
  self:DispatchEvent(BattleRogueModuleEvent.OnUpdateEvents, self.Data.UIEventDatas, self.Data.CombineEventIndexes)
  self.Data:SetSelectCombineCardList(nil)
end

function BattleRogueModule:SendRefreshEventReq()
  local Req = _G.ProtoMessage:newZoneRefreshBadgeChallengeCardReq()
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_REFRESH_BADGE_CHALLENGE_CARD_REQ, Req, self, self.OnRefreshEventRsp, false, false)
end

function BattleRogueModule:OnRefreshEventRsp(Rsp)
  if self:CheckRspInvalid(Rsp.ret_info) then
    return
  end
  self:UpdateEventDatas(Rsp.event_infos)
  self:UpdateCoinNum(Rsp.remain_coin, Rsp.refresh_need_coin)
  self:DispatchEvent(BattleRogueModuleEvent.OnUpdateEvents, self.Data.UIEventDatas, self.Data.CombineEventIndexes)
  self.Data:SetSelectCombineCardList(nil)
end

function BattleRogueModule:SendStartEventReq()
  local Req = _G.ProtoMessage:newZoneBadgeChallengeEnterReq()
  Req.node_id = self.Data.LevelInfo.Nodes[self.Data.CurNodeIndex].NodeID - 1
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_BADGE_CHALLENGE_ENTER_REQ, Req, self, self.OnStartEventRsp, false, false)
end

function BattleRogueModule:OnStartEventRsp(Rsp)
  if self:CheckRspInvalid(Rsp.ret_info) then
    return
  end
  self.bInEvent = true
  self:ChangeState(BattleRogueState.InEvent)
  self:DispatchEvent(BattleRogueModuleEvent.OnStartEvent)
  _G.NRCEventCenter:RegisterEvent(self.name, self, BattleEvent.EnterBattle, self.OnEnterBattle)
  _G.NRCEventCenter:RegisterEvent(self.name, self, BattleEvent.LeaveBattle, self.OnLeaveBattle)
end

function BattleRogueModule:OnEnterBattle()
  local CurBuffDatas = self.Data:GetCurBuffDatas()
  if CurBuffDatas and #CurBuffDatas > 0 then
    self:OpenBuffTips(CurBuffDatas)
  end
  _G.NRCEventCenter:UnRegisterEvent(self, BattleEvent.EnterBattle, self.OnEnterBattle)
end

function BattleRogueModule:OnLeaveBattle()
  if not self.bInEvent then
    return
  end
  self:CloseBuffTips()
  self:OpenBattleRoguePanel()
  self.Data:SetIsOpenSettlementTips(true)
  self.bInEvent = false
  _G.NRCEventCenter:UnRegisterEvent(self, BattleEvent.LeaveBattle, self.OnLeaveBattle)
end

function BattleRogueModule:OnFinishEventNotify(notify)
  Log.Dump(notify, 3, "ZoneBadgeChallengeSettleNotify")
  Log.Debug("\228\186\139\228\187\182\230\140\145\230\136\152\231\187\147\230\158\156win\230\178\161win\239\188\154", notify.is_win)
  self.Data.EventResult = notify.is_win
  if notify.is_finish_challenge then
    self.Data.bFinishedChallenge = notify.is_finish_challenge
    self:DispatchEvent(BattleRogueModuleEvent.FinishChallenge, self.Data.CurLevelID, notify.is_win)
    self:ChangeState(BattleRogueState.EndChallenge)
  end
  if notify.is_win then
    self.Data.LevelInfo.Nodes[self.Data.CurNodeIndex].bFinished = true
    self.Data.CurNodeIndex = math.min(self.Data.CurNodeIndex + 1, #self.Data.LevelInfo.Nodes)
    self:CheckShowHideNode(self.Data.CurNodeIndex)
  end
  if notify.upgrade_rewards then
    self:UpdateBuffDatas(notify.upgrade_rewards, self.Data.UIBuffDatas)
  else
    table.clear(self.Data.UIBuffDatas)
    Log.Warning("\228\186\139\228\187\182\231\187\147\230\157\159\230\178\161\230\156\137buff\231\154\132\229\165\150\229\138\177\228\191\161\230\129\175\239\188\140\230\136\150\232\174\184\230\140\145\230\136\152\229\175\185\232\177\161\230\152\175NPC\229\144\167\239\188\140\232\175\183\230\163\128\230\159\165\228\184\128\228\184\139....")
  end
  self:UpdateCoinNum(notify.coins, nil)
  self.Data.CanChooseBuffNum = notify.upgrade_num
  self.Data.PetInfo = notify.pet_info
  self:ChangeState(BattleRogueState.ChooseBuff)
  self:DispatchEvent(BattleRogueModuleEvent.OnFinishEvent, notify.pet_info, self.Data.UIBuffDatas)
end

function BattleRogueModule:SendChooseBuffReq(Indexes)
  local Req = _G.ProtoMessage:newZoneBadgeChallengeSelectUpgradeReq()
  local SendIndexes = self:ClientIndexes2Server(Indexes)
  Req.index = SendIndexes
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_BADGE_CHALLENGE_SELECT_UPGRADE_REQ, Req, self, self.OnChoseBuffsRsp, false, false)
  self:ChangeState(BattleRogueState.ClientChoseBuff)
end

function BattleRogueModule:OnChoseBuffsRsp(Rsp)
  if not Rsp.upgrade_ids or self:CheckRspInvalid(Rsp.ret_info) then
    return
  end
  self:UpdateBuffDatas(Rsp.upgrade_ids, self.Data.CurBuffDatas)
  self:EnsureStateFinished()
  self:ChangeState(BattleRogueState.ChooseEvent)
  self:DispatchEvent(BattleRogueModuleEvent.OnChoseBuff, self.Data.UIEventDatas, self.Data.CurBuffDatas)
  self:OpenSettlementTipsPanelChange(false)
end

function BattleRogueModule:SendLetPetFree()
end

function BattleRogueModule:OnReConnect()
end

function BattleRogueModule:CheckShowHideNode(NodeIndex)
  local UINodeInfo = self.Data.LevelInfo.Nodes[NodeIndex]
  if UINodeInfo.bHide then
    UINodeInfo.bHide = false
  end
end

function BattleRogueModule:GetCurChallengeLevelConf()
  if -1 == self.Data.CurLevelID then
    Log.Warning("\232\175\183\229\133\136\233\128\137\230\139\169\228\184\128\228\184\170\232\130\137\233\184\189\229\133\179\229\141\161\232\191\155\232\161\140\230\140\145\230\136\152")
    return nil
  end
  return _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.ROGUE_LEVEL_CONF):GetData(self.Data.CurLevelID)
end

function BattleRogueModule:GetEventConf(EventID)
  return _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.EVENT_BASE_CONF):GetData(EventID)
end

function BattleRogueModule:GetBuffConf(ID)
  return _G.DataConfigManager:GetBuffConf(ID)
end

function BattleRogueModule:GetUpGradeConf(ID)
  return _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.UPGRADE_CONF):GetData(ID)
end

function BattleRogueModule:GetPetHeadIconPath(PetBaseID)
  local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(PetBaseID)
  local ModelConf = _G.DataConfigManager:GetModelConf(PetBaseConf.model_conf)
  return ModelConf.icon
end

function BattleRogueModule:GetPetName(PetBaseID)
  return _G.DataConfigManager:GetPetbaseConf(PetBaseID).name
end

function BattleRogueModule:GetNpcHeadIconPath(NpcID)
  local NpcConf = _G.DataConfigManager:GetNpcConf(NpcID)
  local ModelConf = _G.DataConfigManager:GetModelConf(NpcConf.model_conf)
  return ModelConf.icon
end

function BattleRogueModule:GetNpcName(NpcID)
  return _G.DataConfigManager:GetNpcConf(NpcID).name
end

function BattleRogueModule:GetEventName(EventConf)
  if EventConf.name then
    return EventConf.name
  end
  local ConcatName = {}
  for _, EventCombine in ipairs(EventConf.event_combine) do
    local Name = EventCombine.type == _G.Enum.IncidentType.IT_CHARACTER and self:GetNpcName(EventCombine.type_param1) or self:GetPetName(EventCombine.type_param1)
    table.insert(ConcatName, Name)
  end
  return #ConcatName > 1 and table.concat(ConcatName, "/") or ConcatName[1]
end

function BattleRogueModule:GetEventIcon(EventConf)
  if EventConf.icon then
    return EventConf.icon
  end
  local IconPaths = {}
  for _, EventCombine in ipairs(EventConf.event_combine) do
    local IconPath = EventCombine.type == _G.Enum.IncidentType.IT_CHARACTER and self:GetNpcHeadIconPath(EventCombine.type_param1) or self:GetPetHeadIconPath(EventCombine.type_param1)
    table.insert(IconPaths, IconPath)
  end
  return #IconPaths > 1 and IconPaths or IconPaths[1]
end

function BattleRogueModule:GetEventType(EventCombines)
  if #EventCombines > 0 then
    return EventCombines[1].type
  end
  Log.Warning("\232\142\183\229\143\150\228\186\139\228\187\182\231\177\187\229\158\139\229\164\177\232\180\165\239\188\140\230\163\128\230\159\165\230\149\176\230\141\174")
  return nil
end

function BattleRogueModule:AddEventPetsTypes(EventCombines, PetsTypesDict, PetsTypeList)
  if not PetsTypeList then
    return
  end
  for _, EventCombine in ipairs(EventCombines) do
    local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(EventCombine.type_param1)
    for _, PetType in ipairs(PetBaseConf.unit_type) do
      if not PetsTypesDict[PetType] then
        PetsTypesDict[PetType] = true
        table.insert(PetsTypeList, PetType)
      end
    end
  end
end

function BattleRogueModule:SetUIEventDataPetsTypes(UIEventData, TypesDict)
  if next(TypesDict) then
    UIEventData.PetsTypes = {}
    for Type, _ in pairs(TypesDict) do
      table.insert(UIEventData.PetsTypes, Type)
    end
  end
end

function BattleRogueModule:InitUIEventType(UIEventData, EventCombine)
  if not UIEventData.EventType then
    UIEventData.EventType = self:GetEventType(EventCombine)
    if UIEventData.EventType ~= _G.Enum.IncidentType.IT_CHARACTER then
      UIEventData.PetsTypes = {}
    end
  end
end

function BattleRogueModule:GetUIDataFormEventCardInfo(EventCardInfo)
  local UIEventData = {
    EventType = nil,
    bFixed = EventCardInfo.is_fixed,
    Name = "",
    HeadIcons = {},
    PetsTypes = nil
  }
  local EventIDs = EventCardInfo.event_ids
  local ConcatNames = {}
  local PetsTypesDict = {}
  if #EventIDs > 1 then
    for _, EventID in ipairs(EventIDs) do
      local EventConf = self:GetEventConf(EventID)
      self:InitUIEventType(UIEventData, EventConf.event_combine)
      self:AddEventPetsTypes(EventConf.event_combine, PetsTypesDict, UIEventData.PetsTypes)
      table.insert(ConcatNames, self:GetEventName(EventConf))
      local EventIcon = self:GetEventIcon(EventConf)
      if type(EventIcon) == "string" then
        table.insert(UIEventData.HeadIcons, EventIcon)
      else
        for _, Icon in ipairs(EventIcon) do
          table.insert(UIEventData.HeadIcons, Icon)
        end
      end
    end
    UIEventData.Name = table.concat(ConcatNames, "/")
  else
    local EventConf = self:GetEventConf(EventIDs[1])
    self:InitUIEventType(UIEventData, EventConf.event_combine)
    self:AddEventPetsTypes(EventConf.event_combine, PetsTypesDict, UIEventData.PetsTypes)
    UIEventData.Name = self:GetEventName(EventConf)
    local EventIcon = self:GetEventIcon(EventConf)
    if type(EventIcon) == "string" then
      table.insert(UIEventData.HeadIcons, EventIcon)
    else
      UIEventData.HeadIcons = EventIcon
    end
  end
  return UIEventData
end

function BattleRogueModule:SetUIEventData(EventCardInfos)
  for i, EventCardInfo in ipairs(EventCardInfos) do
    if self.Data.CurEventInfos and self:CompareIfEventDatasDiff(EventCardInfo, self.Data.CurEventInfos[i]) then
    else
      self.Data.UIEventDatas[i] = self:GetUIDataFormEventCardInfo(EventCardInfo)
    end
  end
end

function BattleRogueModule:UpdateEventDatas(EventInfos)
  self:SetUIEventData(EventInfos)
  self.Data.CurEventInfos = EventInfos
  self:ProcessCombineEvents()
end

function BattleRogueModule:CheckRspInvalid(RetInfo)
  return not RetInfo or 0 ~= RetInfo.ret_code
end

function BattleRogueModule:UpdateCoinNum(CoinNum, RefreshNeedCoinNum)
  self.Data.RogueCoinNum = CoinNum or self.Data.RogueCoinNum
  self.Data.RefreshNeedCoinNum = RefreshNeedCoinNum or self.Data.RefreshBaseCost
  self:DispatchEvent(BattleRogueModuleEvent.OnUpdateCoinNum, self.Data.RogueCoinNum, self.Data.RefreshNeedCoinNum)
end

function BattleRogueModule:InitLevelInfo(LevelNodeEventInfos)
  local LevelConf = self:GetCurChallengeLevelConf()
  self.Data.LevelInfo.topic = LevelConf.topic
  self.Data.LevelInfo.Nodes = {}
  for i, NodeInfo in ipairs(LevelConf.node) do
    if not NodeInfo.node_id then
    else
      local UINodeInfo = {
        NodeID = NodeInfo.node_id,
        bFinished = false,
        bHide = false,
        NodeUIEventData = nil
      }
      if #NodeInfo.event_id > 0 then
        if i <= #LevelNodeEventInfos then
          UINodeInfo.NodeUIEventData = self:GetUIDataFormEventCardInfo(LevelNodeEventInfos[i])
        end
        UINodeInfo.bHide = NodeInfo.hide
      end
      table.insert(self.Data.LevelInfo.Nodes, UINodeInfo)
    end
  end
end

function BattleRogueModule:InitPetDatas()
  table.clear(self.Data.PetInfo)
  local PetListInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  if not PetListInfo or not (#PetListInfo > 0) then
    Log.Error("[\229\133\171\229\164\167\229\139\139\231\171\160]\239\188\154\229\138\160\232\189\189\229\164\167\228\184\150\231\149\140\229\174\160\231\137\169\231\188\150\233\152\159\228\191\161\230\129\175\229\164\177\232\180\165\239\188\140\232\175\183\230\163\128\230\159\165\231\178\190\231\129\181\230\149\176\230\141\174")
    return
  end
  for _, Info in ipairs(PetListInfo) do
    local RoguePetInfo = ProtoMessage:newBadgeChallengePetInfo()
    RoguePetInfo.pet_gid = Info.gid
    RoguePetInfo.remain_energy = Info.energy
    RoguePetInfo.remain_hp = Info.attribute_new_info.addi_attr_data[1].addi_attr
    RoguePetInfo.level = Info.level
    RoguePetInfo.max_hp = Info.attribute_new_info.addi_attr_data[2].addi_attr
    RoguePetInfo.conf_id = Info.base_conf_id
    RoguePetInfo.mutation_type = Info.mutation_type
    RoguePetInfo.glass_info = Info.glass_info
    table.insert(self.Data.PetInfo, RoguePetInfo)
  end
end

function BattleRogueModule:SetNodeData(CurNodeIndex, EventCardInfo)
  self.Data.LevelInfo.Nodes[CurNodeIndex].NodeUIEventData = self:GetUIDataFormEventCardInfo(EventCardInfo)
  self:DispatchEvent(BattleRogueModuleEvent.OnSetNodeData, CurNodeIndex, self.Data.LevelInfo.Nodes)
end

function BattleRogueModule:UpdateBuffDatas(UpGradeIDs, BuffDatas)
  if #UpGradeIDs ~= #BuffDatas then
    table.clear(BuffDatas)
  end
  for i, UpGradeID in ipairs(UpGradeIDs) do
    if #BuffDatas > 0 and i < #BuffDatas and UpGradeID == BuffDatas[i].ID then
    else
      local UpgradeConf = self:GetUpGradeConf(UpGradeID)
      local UIBuffData = {
        ID = UpGradeID,
        topic = UpgradeConf.topic,
        Description = UpgradeConf.text,
        Icon = -1
      }
      for _, BuffID in ipairs(UpgradeConf.buff) do
        local BuffConf = self:GetBuffConf(BuffID)
        UIBuffData.Icon = BuffConf.icon
      end
      BuffDatas[i] = UIBuffData
    end
  end
end

function BattleRogueModule:ProcessCombineConf()
  local CombineConfTable = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.EVENT_COMBINE_CONF):GetAllDatas()
  self:ProcessMaxCombineNum(CombineConfTable)
  for _, CombineConf in pairs(CombineConfTable) do
    local BitSetValue = 0
    local TypeNumDic = {}
    for _, Type in ipairs(CombineConf.type) do
      if not TypeNumDic[Type] then
        TypeNumDic[Type] = 0
      end
      TypeNumDic[Type] = TypeNumDic[Type] + 1
      BitSetValue = BitSetValue + 2 ^ (self.MaxCombineNum * Type + TypeNumDic[Type] - 1)
    end
    self.Data.CombineConfBitSet[BitSetValue] = true
  end
end

function BattleRogueModule:ProcessMaxCombineNum(CombineConfTable)
  local CombineNum, Type
  for _, CombineConf in pairs(CombineConfTable) do
    CombineNum = #CombineConf.type
    Type = CombineConf.type[1]
    if not self.Data.CombineTypeMaxNum[Type] then
      self.Data.CombineTypeMaxNum[Type] = CombineNum
    end
    if CombineNum > self.Data.CombineTypeMaxNum[Type] then
      self.Data.CombineTypeMaxNum[Type] = CombineNum
    end
    if CombineNum > self.MaxCombineNum then
      self.MaxCombineNum = CombineNum
    end
  end
end

function BattleRogueModule:ProcessCombineEvents()
  table.clear(self.Data.CombineEventIndexes)
  table.clear(self.Data.CombineEventBitSet)
  local PetTypeEventDic = {}
  local OtherEventDic = {}
  for i, EventData in ipairs(self.Data.UIEventDatas) do
    if EventData.EventType == Enum.IncidentType.IT_MONSTER_1 then
      for _, PetType in ipairs(EventData.PetsTypes) do
        if not PetTypeEventDic[PetType] then
          PetTypeEventDic[PetType] = {}
        end
        table.insert(PetTypeEventDic[PetType], i)
      end
    else
      if not OtherEventDic[EventData.EventType] then
        OtherEventDic[EventData.EventType] = {}
      end
      table.insert(OtherEventDic[EventData.EventType], i)
    end
  end
  for _, EventDict in ipairs({PetTypeEventDic, OtherEventDic}) do
    for _, IndexList in pairs(EventDict) do
      if #IndexList > 1 then
        table.insert(self.Data.CombineEventIndexes, IndexList)
        table.insert(self.Data.CombineEventBitSet, self:CastList2BitNumber(IndexList))
      end
    end
  end
end

function BattleRogueModule:CompareIfEventDatasDiff(NewData, CurData)
  local NewEventIDs = NewData.event_ids
  local CurEventIDs = CurData.event_ids
  if #NewEventIDs ~= #CurEventIDs then
    return false
  end
  if NewData.is_fixed ~= CurData.is_fixed then
    return false
  end
  for i, EventID in ipairs(NewEventIDs) do
    if EventID ~= CurEventIDs[i] then
      return false
    end
  end
  return true
end

function BattleRogueModule:SubSetBitJudge(SubSet, UniversalSet)
  local SubSetValue = self:CastList2BitNumber(SubSet)
  if SubSetValue & self:CastList2BitNumber(UniversalSet) == SubSetValue then
    return true
  end
  return false
end

function BattleRogueModule:CastList2BitNumber(Set)
  local FinalValue = 0
  for _, Value in ipairs(Set) do
    FinalValue = FinalValue + 2 ^ Value
  end
  return FinalValue
end

function BattleRogueModule:CheckCombineIndexes(IndexList)
  local Message = ""
  if #IndexList < 2 then
    Message = "\229\144\136\230\136\144\233\149\191\229\186\166\228\184\141\231\172\166\229\144\136\232\166\129\230\177\130"
    return false, Message
  end
  local CombineNum = 0
  for _, Index in ipairs(IndexList) do
    if self.Data.CurEventInfos and #self.Data.CurEventInfos[Index].event_ids >= self.Data.CombineTypeMaxNum[self.Data.CurEventInfos[Index].incident_type[1]] then
      Message = "\229\141\149\229\188\160\229\141\161\229\183\178\232\190\190\229\136\176\230\156\128\229\164\167\229\143\175\229\144\136\230\136\144\228\184\138\233\153\144"
      return false, Message
    end
    CombineNum = CombineNum + #self.Data.CurEventInfos[Index].event_ids
  end
  if CombineNum > self.Data.CombineTypeMaxNum[self.Data.CurEventInfos[IndexList[1]].incident_type[1]] then
    Message = "\232\182\133\232\191\135\229\144\136\230\136\144\231\177\187\229\158\139\231\154\132\230\156\128\229\164\167\229\144\136\230\136\144\228\184\138\233\153\144"
    return false, Message
  end
  if not self:CheckEventCombineConf(IndexList) then
    Message = "\228\184\141\229\173\152\229\156\168\232\175\165\231\177\187\229\158\139\228\186\139\228\187\182\231\187\132\229\144\136\231\154\132\229\144\136\230\136\144\233\133\141\231\189\174"
    return false, Message
  end
  local CheckValue = self:CastList2BitNumber(IndexList)
  for _, BitSet in ipairs(self.Data.CombineEventBitSet) do
    if CheckValue & BitSet == CheckValue then
      return true, Message
    end
  end
  Message = "\228\184\141\229\173\152\232\191\153\230\160\183\231\154\132\229\143\175\229\144\136\230\136\144\229\136\151\232\161\168"
  return false, Message
end

function BattleRogueModule:CheckEventCombineConf(IndexList)
  local TypeNumDic = {}
  local BitSetValue = 0
  for _, Index in ipairs(IndexList) do
    local Type = self.Data.UIEventDatas[Index].EventType
    if not TypeNumDic[Type] then
      TypeNumDic[Type] = 0
    end
    TypeNumDic[Type] = TypeNumDic[Type] + 1
    BitSetValue = BitSetValue + 2 ^ (self.MaxCombineNum * Type + TypeNumDic[Type] - 1)
  end
  if self.Data.CombineConfBitSet[BitSetValue] then
    return true
  end
  return false
end

function BattleRogueModule:FixedEvent(Index)
  self.Data.UIEventDatas[Index].bFixed = not self.Data.UIEventDatas[Index].bFixed
  self.Data.CurEventInfos[Index].is_fixed = not self.Data.CurEventInfos[Index].is_fixed
end

function BattleRogueModule:CheckBuffIndexes(Indexes)
  if not self.Data.CanChooseBuffNum or 0 == self.Data.CanChooseBuffNum then
    return true
  end
  if not Indexes or not next(Indexes) then
    return false
  end
  return #Indexes == self.Data.CanChooseBuffNum
end

function BattleRogueModule:ClientIndexes2Server(ClientIndexes)
  local ServerIndexes = {}
  for i, Index in ipairs(ClientIndexes) do
    ServerIndexes[i] = Index - 1
  end
  return ServerIndexes
end

function BattleRogueModule:OnCmdSelectCombineCard(Add, Index)
  self.Data:AddOrRemoveCombineCard(Add, Index)
end

function BattleRogueModule:OpenBattleRoguePanel()
  self:OpenPanel("BattleRogue_Main")
end

function BattleRogueModule:OnCmdHideMainInfo(IsHide)
  if self:HasPanel("BattleRogue_Main") then
    local Panel = self:GetPanel("BattleRogue_Main")
    Panel:ShowOrHideMainInfo(IsHide)
  end
end

function BattleRogueModule:OnCmdPetMainClose()
  if self:HasPanel("BattleRogue_Main") then
    self:InitPetDatas()
    local Panel = self:GetPanel("BattleRogue_Main")
    Panel:SetPetList()
    local CurBuffDatas = self.Data:GetCurBuffDatas()
    if CurBuffDatas and #CurBuffDatas > 0 then
      self:OpenBuffTips(CurBuffDatas)
    end
  end
end

function BattleRogueModule:OpenBattleRogueCardTips()
  self:OpenPanel("CardTips")
end

function BattleRogueModule:OpenSettlement_Tips()
  self:OpenPanel("Settlement_Tips")
end

function BattleRogueModule:OpenSettlementTipsPanelChange(Open)
  if self:HasPanel("BattleRogue_Main") then
    local Panel = self:GetPanel("BattleRogue_Main")
    Panel:OpenSettlementTipsPanelChange(Open)
  end
end

function BattleRogueModule:OpenBuffTips(CurBuffDatas)
  if self:HasPanel("BuffTips") then
    local Panel = self:GetPanel("BuffTips")
    if Panel then
      Panel:UpdateBuff(CurBuffDatas)
    end
  else
    self:OpenPanel("BuffTips", CurBuffDatas)
  end
end

function BattleRogueModule:CloseBuffTips()
  self:ClosePanel("BuffTips")
end

function BattleRogueModule:OnCmdSelectBuffInfo(Add, _Index)
  self.Data:AddOrRemoveBuffList(Add, _Index)
end

function BattleRogueModule:RegPanel(name, path, layer, openAnimName, closeAnimName, bCustomDisableRendering, enablePcEsc)
  local registerData = _G.NRCPanelRegisterData()
  registerData.panelName = name
  registerData.panelPath = string.format("/Game/NewRoco/Modules/System/BattleRogue/Res/%s", path)
  registerData.panelLayer = layer
  if openAnimName then
    registerData.openAnimName = openAnimName
  end
  if closeAnimName then
    registerData.closeAnimName = closeAnimName
  end
  registerData.enablePcEsc = enablePcEsc
  registerData.customDisableRendering = bCustomDisableRendering or false
  self:RegisterPanel(registerData)
end

return BattleRogueModule
