local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local MarkerModuleEvent = reload("NewRoco.Modules.Core.Marker.MarkerModuleEvent")
local PointOfInterestItem = require("NewRoco.Modules.Core.Marker.PointOfInterestItem")
local MarkerEnum = require("NewRoco.Modules.Core.Marker.MarkerEnum")
local MarkerBeamItem = require("NewRoco.Modules.Core.Marker.MarkerBeamItem")
local PlayerDataEvent = require("Data.Global.PlayerDataEvent")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local SkipFrame = 3
local MarkerModule = NRCModuleBase:Extend("MarkerModule")

function MarkerModule:OnConstruct()
  self.data = self:SetData("MarkerModuleData", "NewRoco.Modules.Core.Marker.MarkerModuleData")
  self.ReverseMiniGame = {}
  self.NPCDict = {}
  self.Beams = {}
  self.PanelMain = false
  self.CurrentFrame = 0
  self.bIsInBattle = false
  self.bWasInDungeon = nil
  for id, comb in pairs(_G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.MINIGAME_CONF):GetAllDatas()) do
    if comb.reward.reward_type == Enum.SendRewardType.SR_CREATE_NPC then
      self.ReverseMiniGame[comb.reward.reward_param[1]] = comb
    end
  end
  _G.NRCEventCenter:RegisterEvent(self.moduleName, self, NPCModuleEvent.On_NPC_Create, self.NPCCreate)
  _G.NRCEventCenter:RegisterEvent(self.moduleName, self, NPCModuleEvent.On_NPC_Destroy, self.NPCDestroy)
  _G.NRCEventCenter:RegisterEvent(self.moduleName, self, NPCModuleEvent.On_NPC_Unlock, self.NPCCreate)
  _G.NRCEventCenter:RegisterEvent(self.moduleName, self, MarkerModuleEvent.OnPanelReady, self.OnPanelReady)
  _G.NRCEventCenter:RegisterEvent(self.moduleName, self, MarkerModuleEvent.OnPanelClosed, self.OnPanelClosed)
  _G.NRCEventCenter:RegisterEvent(self.moduleName, self, SceneEvent.BigWorldPrepared, self.OnMapLoaded)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, PlayerDataEvent.MAP_MARK_CHANGE, self.UpdatePlayerBeam)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, PlayerDataEvent.UPDATE_DATA, self.OnPlayerDataUpdate)
end

function MarkerModule:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.On_NPC_Create, self.NPCCreate)
  _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.On_NPC_Destroy, self.NPCDestroy)
  _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.On_NPC_Unlock, self.NPCCreate)
  _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.OnPanelReady, self.OnPanelReady)
  _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.OnPanelClosed, self.OnPanelClosed)
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.BigWorldPrepared, self.OnMapLoaded)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, PlayerDataEvent.MAP_MARK_CHANGE, self.UpdatePlayerBeam)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, PlayerDataEvent.UPDATE_DATA, self.OnPlayerDataUpdate)
end

function MarkerModule:OnCombineGuideChange(action)
  if not action then
    return
  end
  local Info = action.guide_info
  if not Info then
    return
  end
  local RefreshPoint = Info.npc_refresh_point
  local GuideType = Info.guide_type
  if action.add_or_delete then
    local Item = self.NPCDict[RefreshPoint]
    if not Item then
      local Point = UE.FVector(Info.npc_pos.x, Info.npc_pos.y, Info.npc_pos.z)
      self:CreateMarker(RefreshPoint, Point, GuideType)
    end
  else
    self:RemovePOI(RefreshPoint)
  end
end

function MarkerModule:UpdatePOI()
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not Player then
    return
  end
  local Data = Player.serverData
  if not Data then
    return
  end
  local GuideInfo = Data.guide_info
  local GuideInfos = GuideInfo and GuideInfo.guide_infos
  if not GuideInfos then
    for RefreshPoint, POI in pairs(self.NPCDict) do
      if not POI.bClient then
        self:RemovePOI(RefreshPoint)
      end
    end
    return
  end
  for RefreshPoint, POI in pairs(self.NPCDict) do
    local Found = false
    for _, Info in ipairs(GuideInfos) do
      if Info.npc_refresh_point == RefreshPoint then
        Found = true
        break
      end
    end
    if not Found and not POI.bClient then
      self:RemovePOI(RefreshPoint)
    end
  end
  for _, Info in ipairs(GuideInfos) do
    if not self.NPCDict[Info.npc_refresh_point] then
      local Point = UE.FVector(Info.npc_pos.x, Info.npc_pos.y, Info.npc_pos.z)
      self:CreateMarker(Info.npc_refresh_point, Point, Info.guide_type)
    end
  end
end

function MarkerModule:GetTrackers()
  return self.NPCDict
end

function MarkerModule:NPCCreate(NPC)
  self:AddPOI(NPC)
end

function MarkerModule:OnPanelReady()
  self.PanelMain = true
end

function MarkerModule:OnPanelClosed()
  self.PanelMain = false
end

function MarkerModule:AddPOI(NPC)
  if not NPC then
    return
  end
  if self.NPCDict[NPC.serverData.npc_base.refresh_point] then
    return
  end
  if not NPC.serverData then
    return
  end
  local ContentID = NPC.serverData.npc_base.npc_content_cfg_id
  local Mini = self.ReverseMiniGame and self.ReverseMiniGame[ContentID]
  if Mini and Mini.npc_guide > 0 then
    self:CreateMarker(NPC.serverData.npc_base.refresh_point, NPC.serverPos, Mini.npc_guide, true)
  end
end

function MarkerModule:CreateMarker(RefreshPoint, Position, Klass, bClient)
  local POI = PointOfInterestItem(Position, MarkerEnum.SourceType.NPCCombination)
  POI.PointKlass = Klass
  POI.bClient = bClient
  self.NPCDict[RefreshPoint] = POI
  _G.NRCEventCenter:DispatchEvent(MarkerModuleEvent.POI_UPDATE, POI)
end

function MarkerModule:RemovePOI(RefreshPoint)
  if not self.NPCDict[RefreshPoint] then
    return
  end
  _G.NRCEventCenter:DispatchEvent(MarkerModuleEvent.POI_REMOVE, self.NPCDict[RefreshPoint])
  self.NPCDict[RefreshPoint] = nil
  Log.Debug("remove marker", RefreshPoint)
end

function MarkerModule:NPCDestroy(NPC)
  if not NPC then
    return
  end
  local ServerData = NPC.serverData
  local NPCData = ServerData and ServerData.npc_base
  if not NPCData then
    return
  end
  self:RemovePOI(NPCData.refresh_point)
end

function MarkerModule:RegisterMarker()
end

function MarkerModule:UnregisterMarker()
end

function MarkerModule:OnActive()
  self:UpdatePlayerBeam()
end

function MarkerModule:OnDeactive()
end

function MarkerModule:OnOpenMainPanel(arg)
end

function MarkerModule:OnMapLoaded()
  self:UpdatePlayerBeam()
  self:UpdatePOI()
end

function MarkerModule:OnPlayerDataUpdate()
  local NowInDungeon = _G.DataModelMgr.PlayerDataModel:IsInDungeon()
  if self.bWasInDungeon == NowInDungeon then
    return
  end
  self:UpdatePlayerBeam()
  self.bWasInDungeon = NowInDungeon
end

function MarkerModule:UpdateNPCBeam(Action)
  if not Action then
    return
  end
  if not Action.distribution then
    return
  end
  local RemovedID = {}
  for ID, Beam in pairs(self.Beams) do
    if Beam.Type == MarkerEnum.SourceType.Boss then
      local Found = false
      for _, Dist in ipairs(Action.distribution) do
        local ServerID = Dist and Dist.npc and Dist.npc.base and Dist.npc.base.actor_id
        if ServerID == ID then
          Found = true
          break
        end
      end
      if not Found then
        table.insert(RemovedID, ID)
      end
    end
  end
  for _, ID in ipairs(RemovedID) do
    local Item = self.Beams[ID]
    if Item then
      Item:RemoveBeam()
    end
    self.Beams[ID] = nil
  end
  table.clear(RemovedID)
  for _, Info in ipairs(Action.distribution) do
    local NPC = Info.npc
    if not NPC then
    else
      local Base = NPC.base
      if not Base then
      else
        local Point = Base.pt
        if not Point then
        else
          local Pos = Point.pos
          if not Pos then
          else
            local ID = Base.actor_id
            if not ID or 0 == ID then
            else
              local CurrentBeam = self.Beams[ID]
              if CurrentBeam then
                CurrentBeam:UpdateInfo(Pos)
              else
                self.Beams[ID] = MarkerBeamItem(MarkerEnum.SourceType.Boss, ID, Pos, NPC.npc_base and NPC.npc_base.npc_cfg_id or 0, ID)
              end
            end
          end
        end
      end
    end
  end
end

function MarkerModule:UpdatePlayerBeam()
  local PlayerMarkerList = _G.DataModelMgr.PlayerDataModel:GetPlayerMarkInfo()
  local IsInDungeon = _G.DataModelMgr.PlayerDataModel:IsInDungeon()
  local IsEmptyList = IsInDungeon or not PlayerMarkerList or 0 == #PlayerMarkerList
  local RemovedID = {}
  for ID, Beam in pairs(self.Beams) do
    if Beam.Type == MarkerEnum.SourceType.PlayerCustom then
      local Found = false
      if not IsEmptyList then
        for _, Dist in ipairs(PlayerMarkerList) do
          local ServerID = Dist.mark_number
          if ServerID == ID then
            Found = true
            break
          end
        end
      end
      if not Found then
        table.insert(RemovedID, ID)
      end
    end
  end
  for _, ID in ipairs(RemovedID) do
    local Item = self.Beams[ID]
    if Item then
      Item:RemoveBeam()
    end
    self.Beams[ID] = nil
  end
  table.clear(RemovedID)
  if IsEmptyList then
    return
  end
  for _, Info in ipairs(PlayerMarkerList) do
    local Pos = Info.pos
    if not Pos then
    else
      local ID = Info.mark_number
      if not ID or 0 == ID then
      else
        local CurrentBeam = self.Beams[ID]
        if CurrentBeam then
          CurrentBeam:UpdateInfo(Info.pos)
        else
          self.Beams[ID] = MarkerBeamItem(MarkerEnum.SourceType.PlayerCustom, ID, Info.pos)
        end
      end
    end
  end
end

function MarkerModule:OnEnterBattle()
  self.bIsInBattle = true
end

function MarkerModule:OnLeaveBattle()
  self.bIsInBattle = false
end

function MarkerModule:OnTick(DeltaTime)
  self.CurrentFrame = self.CurrentFrame + 1
  if 0 ~= self.CurrentFrame % SkipFrame then
    return
  end
  if 0 == table.len(self.Beams) then
    return
  end
  local RemoveIDs
  for ID, Beam in pairs(self.Beams) do
    if Beam.Type == MarkerEnum.SourceType.Boss or Beam.Type == MarkerEnum.SourceType.PlayerCustom then
      Beam:OnTick(self.bIsInBattle)
      if Beam.bShouldRemove then
        RemoveIDs = RemoveIDs or {}
        table.insert(RemoveIDs, ID)
      end
    end
  end
  if RemoveIDs then
    for _, ID in ipairs(RemoveIDs) do
      Log.Error("marker remove by client", ID)
      local Item = self.Beams[ID]
      if Item then
        Item:RemoveBeam()
      end
      self.Beams[ID] = nil
    end
  end
end

return MarkerModule
