local TaskModuleEvent = require("NewRoco.Modules.Core.Task.TaskModuleEvent")
local EventDispatcher = require("Common.EventDispatcher")
local TaskUtils = require("NewRoco.Modules.Core.Task.TaskUtils")
local Class = _G.MakeSimpleClass
local AcceptableTaskTrackItem = Class("AcceptableTaskTrackItem")
local SkipFrame = 3
local PlayerPosCache
local FinderRegisterDistance = 10000
local FinderUnregisterDistance = 11000
local FinderRegisterDistanceSquared = FinderRegisterDistance * FinderRegisterDistance
local FinderUnregisterDistanceSquared = FinderUnregisterDistance * FinderUnregisterDistance

function AcceptableTaskTrackItem:PreCtor()
  self.CumulativeDeltaTime = 0
  self.FrameCount = 0
end

function AcceptableTaskTrackItem:Ctor(Config, Guide)
  self.TaskConfig = Config
  self.Guide = Guide
  self.AcceptNPCs = {}
  self.NpcList = {}
  self.Position = nil
  self.ServerPosition = nil
  self.SceneID = -1
  EventDispatcher():Attach(self)
  _G.UpdateManager:Register(self)
  self:UpdateNpcList()
  self:UpdatePositionAndScene()
end

function AcceptableTaskTrackItem:Destroy()
  Log.Debug("AcceptableTaskTrackItem:Destroy", self.TaskConfig.ID)
  EventDispatcher.Detach(self)
  _G.UpdateManager:UnRegister(self)
  self:FindNPC(false)
  self:UnRegisterFinder()
  self.TaskConfig = nil
  self.Guide = nil
  self.SceneID = -1
  self.AcceptNPCs = {}
  self.NpcList = {}
  self.ServerPosition = nil
end

function AcceptableTaskTrackItem:OnTick(DeltaTime)
  self.CumulativeDeltaTime = self.CumulativeDeltaTime + DeltaTime
  if 0 == self.FrameCount % SkipFrame then
    self.CumulativeDeltaTime = 0
    self:FindNPC(true)
  end
  self.FrameCount = self.FrameCount + 1
  if self.FrameCount >= SkipFrame then
    self.FrameCount = 0
  end
end

function AcceptableTaskTrackItem:FindNPC(bVisible)
  if not bVisible then
    if self.Npc then
      if self.Npc.PetHUDComponent and self.Npc.PetHUDComponent:HasNpcHud() then
        self.Npc:UpdateAcceptTaskHUD(self.TaskConfig.ID, false)
      end
    else
      local Npcs = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetTopKNPC, self.FinderRef)
      if Npcs and #Npcs > 0 then
        local Npc = Npcs[1]
        if Npc and Npc.PetHUDComponent and Npc.PetHUDComponent:HasNpcHud() then
          Npc:UpdateAcceptTaskHUD(self.TaskConfig.ID, false)
        end
      end
    end
    return
  end
  if self:NeedRefresh() then
    if not self:IsRegisteredFinder() then
      self:RegisterFinder()
    end
    local Npcs = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetTopKNPC, self.FinderRef)
    if Npcs and #Npcs > 0 then
      local Npc = Npcs[1]
      if Npc then
        if self.Npc and self.Npc ~= Npc and self.Npc.PetHUDComponent and self.Npc.PetHUDComponent:HasNpcHud() then
          self.Npc:UpdateAcceptTaskHUD(self.TaskConfig.ID, false)
        end
        if Npc.PetHUDComponent and Npc.PetHUDComponent:HasNpcHud() then
          Npc:UpdateAcceptTaskHUD(self.TaskConfig.ID, bVisible)
          if self.Npc ~= Npc then
            self.Npc = Npc
          end
        end
      end
    end
  elseif self:IsRegisteredFinder() then
    self:UnRegisterFinder()
  end
end

function AcceptableTaskTrackItem:SearchNPC(Npc)
  if not self.NpcList or 0 == #self.NpcList then
    return false
  end
  if not Npc.config then
    return false
  end
  return table.contains(self.NpcList, Npc.config.id)
end

function AcceptableTaskTrackItem:SearchContentFunc(Npc)
  if not self.NpcList or 0 == #self.NpcList then
    return false
  end
  local Data = Npc.serverData
  local NPCBase = Data and Data.npc_base
  local Content = NPCBase and NPCBase.npc_content_cfg_id or 0
  if 0 == Content then
    return false
  end
  return table.contains(self.NpcList, Content)
end

function AcceptableTaskTrackItem:UpdateNpcList()
  self.NpcList = {}
  if self.Guide.guide_info and #self.Guide.guide_info > 0 then
    for _, GuideItem in ipairs(self.Guide.guide_info) do
      if GuideItem.dest_npc_id then
        table.insert(self.NpcList, GuideItem.dest_npc_id)
      end
    end
  end
end

function AcceptableTaskTrackItem:AdjustValidFunc(Npc)
  local Options = Npc.InteractionComponent and Npc.InteractionComponent._options
  if not Options then
    return false
  end
  for _, o in pairs(Options) do
    if o:IsOptionEnable() then
      return true
    end
  end
  return false
end

function AcceptableTaskTrackItem:CompareSceneNpcFunc(NpcA, NpcB)
  if nil == NpcA or nil == NpcB then
    return false
  end
  if NpcA:GetVisible() == false then
    return false
  end
  if NpcB:GetVisible() == false then
    return true
  end
  local DistA = NpcA.squaredDis2LocalIgnoreZ or 1000000
  local DistB = NpcB.squaredDis2LocalIgnoreZ or 1000000
  return DistA < DistB
end

function AcceptableTaskTrackItem:UpdatePositionAndScene()
  self.Position = {
    X = 0,
    Y = 0,
    Z = 0
  }
  self.ServerPosition = {
    x = 0,
    y = 0,
    z = 0
  }
  local Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not Player then
    return
  end
  if self.Guide.guide_info and #self.Guide.guide_info > 0 then
    local NearestDist, NearestItem
    for _, GuideItem in ipairs(self.Guide.guide_info) do
      local Pos = self:GetGuidePos(GuideItem)
      local CurrentDist = self:DistSquared2D(Player:GetActorLocationFrameCache(), Pos)
      if not NearestDist or NearestDist > CurrentDist then
        NearestItem = GuideItem
        NearestDist = CurrentDist
      end
    end
    if NearestItem then
      local Pos = self:GetGuidePos(NearestItem)
      self.Position = {}
      self.Position.X = Pos.x
      self.Position.Y = Pos.y
      self.Position.Z = Pos.z
      self.ServerPosition = Pos
      self.SceneID = NearestItem.dest_res_cfg_id
    end
  end
end

function AcceptableTaskTrackItem:GetPosition()
  return self.Position
end

function AcceptableTaskTrackItem:GetServerPosition()
  return self.ServerPosition
end

function AcceptableTaskTrackItem:GetSceneID()
  return self.SceneID
end

function AcceptableTaskTrackItem:UpdateScenePosList(InPosition, InSceneID)
  local SceneModule = TaskUtils:getSceneModule()
  if not SceneModule then
    return
  end
  local SceneID = InSceneID
  if nil == InSceneID or 0 == InSceneID then
    return
  end
  if InPosition then
    self.ScenePosList[SceneID] = InPosition
  end
end

function AcceptableTaskTrackItem:GetGuidePos(GuideInfo)
  if nil == GuideInfo then
    local Pos = {
      x = 0,
      y = 0,
      z = 0
    }
    return Pos
  end
  local Pos = GuideInfo.dest_pos or {
    x = 0,
    y = 0,
    z = 0
  }
  return Pos
end

function AcceptableTaskTrackItem:DistSquared2D(a, b)
  if not a or not b then
    return math.maxinteger
  end
  local X = (a.X or a.x) - (b.X or b.x)
  local Y = (a.Y or a.y) - (b.Y or b.y)
  return X * X + Y * Y
end

function AcceptableTaskTrackItem:UpdatePlayerPosCache()
  local Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not Player then
    PlayerPosCache = nil
    return nil
  end
  PlayerPosCache = Player:GetActorLocationFrameCache()
  return Player
end

function AcceptableTaskTrackItem:RegisterFinder()
  self.FinderRef = string.format("AcceptTracker_%d_%d", self.TaskConfig.id, 1)
  _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.RegisterTopKFinder, self.FinderRef, 1, self, self.SearchNPC, self, self.AdjustValidFunc, self, self.CompareSceneNpcFunc)
  self.bIsRegisteredFinder = true
end

function AcceptableTaskTrackItem:UnRegisterFinder()
  if self.FinderRef then
    _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.UnRegisterTopKFinder, self.FinderRef)
    self.FinderRef = nil
  end
  self.bIsRegisteredFinder = false
end

function AcceptableTaskTrackItem:IsRegisteredFinder()
  return self.bIsRegisteredFinder
end

function AcceptableTaskTrackItem:NeedRefresh()
  local SceneModule = TaskUtils:getSceneModule()
  if not SceneModule then
    return false
  end
  local CurrentMapID = SceneModule.mapResId
  if self.SceneID == CurrentMapID then
    self:UpdatePlayerPosCache()
    local DistSquared = self:DistSquared2D(PlayerPosCache, self.Position)
    if self:IsRegisteredFinder() then
      return DistSquared < FinderUnregisterDistanceSquared
    else
      return DistSquared < FinderRegisterDistanceSquared
    end
  end
  return false
end

return AcceptableTaskTrackItem
