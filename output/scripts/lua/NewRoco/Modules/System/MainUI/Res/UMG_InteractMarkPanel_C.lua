local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local InteractionComponent = require("NewRoco.Modules.Core.Scene.Component.Interaction.InteractionComponent")
local npcStateUpdateNumOneTick = 3
local UMG_InteractMarkPanel_C = _G.NRCPanelBase:Extend("UMG_InteractMarkPanel_C")

function UMG_InteractMarkPanel_C:OnConstruct()
  local detectNpcDistance = 1000
  local config = _G.DataConfigManager:GetNpcGlobalConfig("npc_option_hint_scan_distance", true)
  if config and config.num and config.num > 0 then
    detectNpcDistance = config.num
  end
  self:ResetParameters()
  self:OnActive()
  InteractionComponent.SetShouldCacheShownNpc(false, true)
end

function UMG_InteractMarkPanel_C:OnDestruct()
  InteractionComponent.SetShouldCacheShownNpc(true)
  self:ResetParameters()
  self:OnDeactive()
end

function UMG_InteractMarkPanel_C:ResetParameters()
  self.tickedInterval = 0.1
  self.tickedTime = 0
  self.markers = {}
  self.currentCheckNpc = nil
  self.trackedNpcs = {}
end

function UMG_InteractMarkPanel_C:OnActive()
  _G.NRCEventCenter:RegisterEvent(self.name, self, NPCModuleEvent.OnNpcMarkDestroy, self.OnMarkDestroy)
  _G.NRCEventCenter:RegisterEvent(self.name, self, NPCModuleEvent.OnNpcMarkHide, self.OnMarkHide)
  _G.NRCEventCenter:RegisterEvent(self.name, self, NPCModuleEvent.OnNpcMarkShow, self.OnMarkShow)
  local npcs = InteractionComponent.GetCachedShownNpc()
  if npcs then
    for npc in pairs(npcs) do
      self:OnMarkShow(npc)
    end
  end
end

function UMG_InteractMarkPanel_C:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.OnNpcMarkDestroy, self.OnMarkDestroy)
  _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.OnNpcMarkHide, self.OnMarkHide)
  _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.OnNpcMarkShow, self.OnMarkShow)
end

function UMG_InteractMarkPanel_C:OnMarkDestroy(npc)
  if not npc then
    return
  end
  local mark = self.markers[npc]
  if not mark or not UE4.UObject.IsValid(mark) then
    return
  end
  Log.Debug("UMG_InteractMarkPanel_C:RemoveMark", npc:DebugNPCNameAndID())
  self.MainPanel:RemoveChild(mark)
  self.markers[npc] = nil
end

function UMG_InteractMarkPanel_C:OnMarkHide(npc)
  if not npc then
    return
  end
  local mark = self.markers[npc]
  if not mark or not UE4.UObject.IsValid(mark) then
    return
  end
  mark.inRange = false
end

function UMG_InteractMarkPanel_C:OnMarkShow(npc)
  if not npc then
    return
  end
  local item = self.markers[npc]
  if not item then
    if not self.MarkItem then
      Log.Debug("UMG_InteractMarkPanel_C:AddMark failed, MarkItem is nil. ", npc:DebugNPCNameAndID())
      return
    end
    Log.Debug("UMG_InteractMarkPanel_C:AddMark", npc:DebugNPCNameAndID())
    item = UE4.UWidgetBlueprintLibrary.Create(self, self.MarkItem)
    item:SetNpc(npc)
    self.MainPanel:AddChildToCanvas(item)
    self.markers[npc] = item
    item:OnShow()
  end
  if item then
    item.inRange = true
  end
end

function UMG_InteractMarkPanel_C:GetShouldTick()
  if not _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.GetLobbyMainEnableState) then
    return false
  end
  if not _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.GetLobbyMainPanelOpen) then
    return false
  end
  return true
end

function UMG_InteractMarkPanel_C:OnTick(deltaTime)
  if not self:GetShouldTick() then
    if self:IsVisible() then
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    return
  end
  if not self:IsVisible() then
    self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  end
  self.tickedTime = self.tickedTime + deltaTime
  if self.tickedTime >= self.tickedInterval then
    self.tickedTime = self.tickedTime - self.tickedInterval
    self:UpdateMarksRank()
    self:UpdateTrackedNpcs()
  end
  self:UpdateMarksState()
  self:UpdateMarksPositions(deltaTime)
end

local keysCache = {}

function UMG_InteractMarkPanel_C:OnLoadingClosed()
  if not self.markers then
    return
  end
  for npc, _ in pairs(self.markers) do
    local interactionComponent = npc.InteractionComponent
    if interactionComponent and npc:CanInteract() then
      npc:CalSquaredDis2Local()
      interactionComponent:UpdateMarkStateByDistance()
    end
  end
end

function UMG_InteractMarkPanel_C:UpdateMarksRank()
  if not self.markers then
    return
  end
  local keys = keysCache
  table.clear(keys)
  for npc, mark in pairs(self.markers) do
    if mark and mark:GetIsShown() then
      table.insert(keys, npc)
    end
  end
  table.sort(keys, function(a, b)
    return a.squaredDis2Local > b.squaredDis2Local
  end)
  for idx, npc in ipairs(keys) do
    local item = self.markers[npc]
    if item then
      item.Slot:SetZOrder(idx)
    end
  end
end

local trackedNPCsCache = {}

function UMG_InteractMarkPanel_C:UpdateTrackedNpcs()
  self.trackedNpcs = trackedNPCsCache
  table.clear(self.trackedNpcs)
  local taskMapTrack = _G.NRCModuleManager:DoCmd(_G.TaskModuleCmd.GetTrackTask)
  if taskMapTrack and taskMapTrack.Trackers then
    for _, tracker in pairs(taskMapTrack.Trackers) do
      table.insert(self.trackedNpcs, tracker)
    end
  end
end

function UMG_InteractMarkPanel_C:UpdateMarksState()
  if not self.markers or not next(self.markers) then
    return
  end
  local iterateMax = math.min(npcStateUpdateNumOneTick, table.len(self.markers))
  local currentMark
  if self.currentCheckNpc and not self.markers[self.currentCheckNpc] then
    self.currentCheckNpc = nil
  end
  for _ = 1, iterateMax do
    self.currentCheckNpc, currentMark = next(self.markers, self.currentCheckNpc)
    if not self.currentCheckNpc then
      self.currentCheckNpc, currentMark = next(self.markers)
    end
    if not self.currentCheckNpc then
      break
    end
    if currentMark then
      currentMark:UpdateState(self.trackedNpcs)
    end
  end
end

function UMG_InteractMarkPanel_C:UpdateMarksPositions(deltaTime)
  local playerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
  if not playerController then
    return
  end
  for _, mark in pairs(self.markers) do
    if mark then
      mark:UpdatePosition(playerController, deltaTime)
    end
  end
end

return UMG_InteractMarkPanel_C
