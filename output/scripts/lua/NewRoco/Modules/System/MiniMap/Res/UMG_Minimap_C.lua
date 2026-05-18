require("UnLuaEx")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local TaskUtils = require("NewRoco.Modules.Core.Task.TaskUtils")
local UMG_Minimap_C = NRCClass()
local DebugLines = false
local Zero = UE4.FVector2D(0, 0)
local Unit = UE4.FVector2D(1, 1)
local White = UE4.FLinearColor(1, 1, 1, 1)
local Left = UE4.FVector2D(1, 0)
local Up = UE4.FVector2D(0, 1)
local Red = UE4.FLinearColor(1, 0, 0, 1)
local Blue = UE4.FLinearColor(0, 0, 1, 1)

function UMG_Minimap_C:PreConstruct(IsDesignTime)
  self.MiniMapHalfSize = -1
  self.PlayerScreenPos = nil
  local sceneModule = NRCModuleManager:GetModule("SceneModule")
  local sceneConf = sceneModule and sceneModule.config
  if not sceneConf then
    Log.Error("[UMG_Minimap_C:PreConstruct]Scene config is nil")
    return
  end
  local minimapTexture = LoadObject(sceneConf.minimap_texture_path)
  if not minimapTexture then
    Log.Error("[UMG_Minimap_C:PreConstruct]Load minimap failed", sceneConf.minimap_texture_path)
    return
  end
  self.MapTexture = minimapTexture
  self.MapTextureRef = UnLua.Ref(minimapTexture)
  self.WorldWidth = sceneConf.world_width
  self.TopLeft.X = sceneConf.world_top_left_x
  self.TopLeft.Y = sceneConf.world_top_left_y
  self.Zoom = sceneConf.minimap_zoom
  self.flipIndex = 0
  self.startTime = 0
  self.stopTime = 0
  self.showNpcList = {}
  self.npcCnt = 0
  local npcTraceSrc = UEPath.MINIMAP_NPC_TRACE
  local npcTraceSrcTexture = LoadObject(npcTraceSrc)
  if npcTraceSrcTexture then
    self.npcTraceSrcTexture = npcTraceSrcTexture
    self.npcTraceSrcTextureRef = UnLua.Ref(npcTraceSrcTexture)
  else
    Log.Error("[UMG_Minimap_C:PreConstruct]no npcTraceSrcTexture", npcTraceSrc)
  end
  self:GetShowNpcList()
  self:InitFogRT()
end

function UMG_Minimap_C:RenderTexture(canvas, texture, location, bound)
  if not texture then
    return nil
  end
  if not canvas then
    return nil
  end
  local ScreenPos = self:CalcBoundedMapLocation(location, bound)
  if ScreenPos then
    local ScreenSize = UE4.FVector2D(texture:Blueprint_GetSizeX(), texture:Blueprint_GetSizeY())
    canvas:K2_DrawTexture(texture, ScreenPos - ScreenSize / 2, ScreenSize, Zero, Unit, White, 2, self.IconRotation)
  end
end

function UMG_Minimap_C:DrawFlipbookTexture(Canvas, Flipbook, Position, Color, Rotation, DeltaTime)
  if self.flipIndex >= Flipbook:GetTotalDuration() then
    self.stopTime = UE4.UGameplayStatics.GetAccurateRealTime(self.World)
    if self.stopTime - self.startTime >= 1.5 then
      self.flipIndex = 0
    end
  else
    local Sprite = Flipbook:GetSpriteAtTime(self.flipIndex)
    if not Sprite then
      Log.Warning("[UMG_Minimap_C:DrawFlipbookTexture]Sprite is nil")
      return
    end
    if not Sprite.SourceTexture then
      Log.Warning("[UMG_Minimap_C:DrawFlipbookTexture]SourceTexture is nil")
      return
    end
    local Texture = Sprite.SourceTexture:Get()
    if Texture then
      local TextureSize = UE4.FVector2D(Texture:Blueprint_GetSizeX(), Texture:Blueprint_GetSizeY())
      local Size = Sprite.SourceDimension
      local CoordPos = Sprite.SourceUV / TextureSize
      local CoordSize = Sprite.SourceDimension / TextureSize
      Canvas:K2_DrawTexture(Texture, Position - Size / 2, Size, CoordPos, CoordSize, Color, 2, Rotation)
    end
    if self.flipIndex < Flipbook:GetTotalDuration() then
      self.startTime = UE4.UGameplayStatics.GetAccurateRealTime(self.World)
    end
  end
  self.flipIndex = self.flipIndex + DeltaTime
end

function UMG_Minimap_C:GetPlayerLocation()
  local Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  return Player and Player:GetActorLocationFrameCache()
end

function UMG_Minimap_C:GetShowNpcList()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npcDict = NPCModule._npcIterDic
  self.npcCnt = #npcDict
  if not npcDict then
    return
  end
  for _, v in pairs(npcDict) do
    local npc = v
    if npc and npc.config and npc.config.map_show_type and 0 ~= npc.config.map_show_type then
      table.insert(self.showNpcList, npc)
    end
  end
end

function UMG_Minimap_C:DrawCustomMarker(canvas, DeltaTime)
  if SceneUtils.debugCloseMinimap then
    return canvas
  end
  local NPCModule = NRCModuleManager:GetModule("NPCModule")
  if not NPCModule then
    return canvas
  end
  self.IconRotation = self:GetOwningPlayerCameraManager():K2_GetActorRotation().Yaw + 90
  local playerLocation = self:GetPlayerLocation()
  if not playerLocation then
    return canvas
  end
  self.PlayerScreenPos = self:WorldLocationToMapLocation(playerLocation.X, playerLocation.Y)
  if self.MiniMapHalfSize <= 0 then
    local geo = self.miniMapCtrl:GetCachedGeometry()
    self.MiniMapSize = UE4.USlateBlueprintLibrary.GetAbsoluteSize(geo)
    self.MiniMapHalfSize = math.min(self.MiniMapSize.X, self.MiniMapSize.Y) / 2 * 0.98
  end
  local NpcDict = NPCModule._npcIterDic
  if not NpcDict then
    return canvas
  end
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npcDict = NPCModule._npcIterDic
  if #npcDict ~= self.npcCnt then
    self:GetShowNpcList()
  end
  for _, v in pairs(self.showNpcList) do
    local npc = v
    local markTexture = self.MarkTextures:Get(npc.config.map_show_type)
    if markTexture then
      if npc.config.id ~= nil and npc.config.id == self:GetTraceNPCId() then
        local ScreenPos = self:CalcBoundedMapLocation(npc:GetActorLocation(), true)
        self:RenderTexture(canvas, markTexture, npc:GetActorLocation(), true)
        self:DrawFlipbookTexture(canvas, self.npcTraceSrcTexture, ScreenPos, White, self.IconRotation, DeltaTime)
      else
        self:RenderTexture(canvas, markTexture, npc:GetActorLocation(), false)
      end
    else
      Log.Warning("Minimap MarkTexture is Null")
    end
  end
  local TaskMap = NRCModuleManager:DoCmd(TaskModuleCmd.GetTaskMap)
  for _, to in pairs(TaskMap) do
    if to.Trackers then
      for _, tracker in ipairs(to.Trackers) do
        if not tracker.Valid then
        else
          local index = TaskUtils.GetTaskStateIndex(tracker.TaskInfo)
          if 0 == index then
          elseif -1 == tracker.AnimIndex then
            local markTexture = self.MarkTextures:Get(index)
            if not markTexture then
            else
              self:RenderTexture(canvas, markTexture, tracker.Position, tracker.TaskInfo.is_track)
            end
          else
            local highlightTexture = self.HighlightFlipbooks:Get(index)
            if not highlightTexture then
            else
              local ScreenPos = self:CalcBoundedMapLocation(tracker.Position, tracker.TaskInfo.is_track)
              if not ScreenPos then
              else
                tracker:DrawFlipbook(canvas, highlightTexture, ScreenPos, White, self.IconRotation, DeltaTime)
              end
            end
          end
        end
      end
    end
  end
  return canvas
end

function UMG_Minimap_C:WorldLocationToMapLocation(x, y)
  local u = (x - self.topLeftX) / self.worldSizeX
  local v = (y - self.topLeftY) / self.worldSizeY
  local ScreenPos = UE4.FVector2D()
  ScreenPos.X = u * self.mapTextureSize.X
  ScreenPos.Y = v * self.mapTextureSize.Y
  return ScreenPos
end

function UMG_Minimap_C:CalcBoundedMapLocation(location, bound)
  local screenPos = UE4.FVector2D()
  screenPos = self:WorldLocationToMapLocation(location.x, location.y)
  local delta = screenPos - self.PlayerScreenPos
  local size = delta:SizeSquared()
  if size >= self.MiniMapHalfSize * self.MiniMapHalfSize then
    if bound then
      delta:Normalize()
      screenPos = delta * self.MiniMapHalfSize * 0.85 * 0.5 + self.PlayerScreenPos
      return screenPos
    end
  else
    return screenPos
  end
  return nil
end

function UMG_Minimap_C:GetTraceNPCId()
  local bigMapModule = NRCModuleManager:GetModule("BigMapModule")
  local traceNpcId = bigMapModule:GetTraceNpcId()
  if self.curTraceNpcEntityId ~= traceNpcId then
    Log.Debug("UMG_Minimap_C:GetTraceNPCId1", self.curTraceNpcEntityId, "xxx", traceNpcId)
    self.curTraceNpcConfigId = -1
    self.curTraceNpcEntityId = traceNpcId
    local npcData = bigMapModule:GetTraceNpcData()
    if npcData and npcData.npcCfg then
      self.curTraceNpcConfigId = npcData.npcCfg.id or -1
    end
  end
  return self.curTraceNpcConfigId
end

function UMG_Minimap_C:OnDeactive()
  ReleaseForceAllChild(self)
  self.MapTexture = nil
  self.MapTextureRef = nil
  self.npcTraceSrcTexture = nil
  self.npcTraceSrcTextureRef = nil
end

return UMG_Minimap_C
