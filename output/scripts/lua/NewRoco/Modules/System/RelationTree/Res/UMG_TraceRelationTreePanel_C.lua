local OnlineState = require("Core.Service.NetManager.OnlineState")
local RelationTreeEvent = reload("NewRoco.Modules.System.RelationTree.RelationTreeEvent")
local FVector2DUtils = require("NewRoco.Utils.FVector2DUtils")
local LoadingUIModuleEvent = require("NewRoco.Modules.System.LoadingUIModule.LoadingUIModuleEvent")
local UMG_TraceRelationTreePanel_C = _G.NRCViewBase:Extend("UMG_TraceRelationTreePanel_C")
local Collapsed = UE4.ESlateVisibility.Collapsed
local HitTestInvisible = UE4.ESlateVisibility.HitTestInvisible

local function GetNumberFromMapConf(Key, Default)
  local Conf = _G.DataConfigManager:GetMapGlobalConfig(Key)
  if not Conf then
    return Default
  end
  local Num = Conf.num
  if not Num then
    return Default
  end
  return Num
end

local XAxisFactor = GetNumberFromMapConf("hud_x_axis_scale", 70) / 100
local YAxisFactor = GetNumberFromMapConf("hud_y_axis_scale", 70) / 100

function UMG_TraceRelationTreePanel_C:OnConstruct()
  self:OnAddEventListener()
  self:UpdateCached()
  self.PlayerDistance = _G.DataConfigManager:GetGlobalConfigByKeyType("relationtree_interact_distance", _G.DataConfigManager.ConfigTableId.GLOBAL_CONFIG).num
  self.PlayerDistance = self.PlayerDistance * self.PlayerDistance * 10000
  self:UpdateOterRequestTracePlayer()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local CurMode = NRCModeManager:GetCurMode()
  if CurMode then
    self.InCreatePlayerMode = CurMode.modeName == "CreatePlayerMode"
  else
    self.InCreatePlayerMode = false
  end
end

function UMG_TraceRelationTreePanel_C:UpdateCached()
  self.World = _G.UE4Helper.GetCurrentWorld()
  self.playerController = UE4.UGameplayStatics.GetPlayerController(self.World, 0)
  self:UpdateViewport()
end

function UMG_TraceRelationTreePanel_C:OnLoadMapStart()
  self:ClearCached()
  self:ClearSelfTrace()
end

function UMG_TraceRelationTreePanel_C:ClearCached()
  self.World = false
  self.playerController = false
end

function UMG_TraceRelationTreePanel_C:UpdateViewport()
  local Size = UE4.UWidgetLayoutLibrary.GetViewportSize(self.World)
  local Scale = UE4.UWidgetLayoutLibrary.GetViewportScale(self.World)
  self.DpiScaleY = 1
  self.ViewportCenter = Size / Scale / 2
  self.Axis = UE.FVector2D(self.ViewportCenter.X * XAxisFactor, self.ViewportCenter.Y * YAxisFactor)
end

function UMG_TraceRelationTreePanel_C:UpdateCanTick()
  for _, v in pairs(self.Items) do
    if v then
      self:SetVisibility(HitTestInvisible)
      _G.UpdateManager:Register(self)
      return
    end
  end
  self:SetVisibility(Collapsed)
  _G.UpdateManager:UnRegister(self)
end

function UMG_TraceRelationTreePanel_C:OnAddEventListener()
  Log.Debug("Track RelationRequests UMG_TraceRelationTreePanel_C:OnAddEventListener")
  NRCEventCenter:RegisterEvent("UMG_TraceRelationTreePanel_C", self, RelationTreeEvent.UPDATE_OTHERREQUEST_PLAYER_CHANGE, self.UpdateOterRequestTracePlayer)
  NRCEventCenter:RegisterEvent("UMG_TraceRelationTreePanel_C", self, RelationTreeEvent.DELETE_OTHERREQUEST_PLAYER, self.RemovePlayerAndItems)
  NRCEventCenter:RegisterEvent("UMG_TraceRelationTreePanel_C", self, RelationTreeEvent.UPDATE_RELATION_BUBBLE_DIS, self.UpdateTracePlayerInfo)
  NRCEventCenter:RegisterEvent("UMG_TraceRelationTreePanel_C", self, RelationTreeEvent.DELETE_OTHER_INVITE_REQUEST, self.RemovePlayerAndItems)
  NRCEventCenter:RegisterEvent("UMG_TraceRelationTreePanel_C", self, LoadingUIModuleEvent.LOADING_UI_CLOSED, self.OnLoadingClosed)
  NRCEventCenter:RegisterEvent("UMG_TraceRelationTreePanel_C", self, SceneEvent.PlayerBornFinish, self.UpdateCached)
  NRCEventCenter:RegisterEvent("UMG_TraceRelationTreePanel_C", self, SceneEvent.OnTeleportNotify, self.OnLoadMapStart)
end

function UMG_TraceRelationTreePanel_C:UpdateTracePlayerInfo(IsInDis, playerUin)
  if not IsInDis then
    if self.OtherPlayers and self.Items and self.OtherPlayers[playerUin] and self.Items[playerUin] then
      self:RemovePlayerAndItems(playerUin)
    end
  else
    local OherRelationRequestEnumType = _G.NRCModuleManager:DoCmd(_G.RelationTreeCmd.GetOtherRequestsByUin, playerUin)
    if OherRelationRequestEnumType then
      self:UpdateOtherReuqestOne(playerUin, OherRelationRequestEnumType)
    else
      local LocalPlayer = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
      local ActionID = LocalPlayer and LocalPlayer.InviteComponent:GetInviterActionID(playerUin)
      if ActionID then
        self:UpdateInviteInfo(playerUin, _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByUin, playerUin), ActionID)
      elseif self.OtherPlayers and self.Items and self.OtherPlayers[playerUin] and self.Items[playerUin] then
        self:RemovePlayerAndItems(playerUin)
      end
    end
  end
end

function UMG_TraceRelationTreePanel_C:UpdateOtherReuqestOne(playerUin, OherRelationRequestEnumType)
  if not self.OtherPlayers then
    self.OtherPlayers = {}
  end
  if not self.Items then
    self.Items = {}
  end
  if self.OtherPlayers[playerUin] and self.Items[playerUin] then
    self:UpdateCanTick()
    return
  end
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByUin, playerUin)
  if player then
    self:AddRelationTreePlayer(playerUin, player)
    self:AddRelationTreePerception(playerUin, OherRelationRequestEnumType)
    self:UpdateCanTick()
  end
end

function UMG_TraceRelationTreePanel_C:UpdateOterRequestTracePlayer()
  if not self.OtherPlayers then
    self.OtherPlayers = {}
  end
  if not self.Items then
    self.Items = {}
  end
  local OtherRequestsData = _G.NRCModuleManager:DoCmd(_G.RelationTreeCmd.GetAllOtherRequests)
  if OtherRequestsData then
    for OtherPlayUin, RelationType in pairs(OtherRequestsData) do
      local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByUin, OtherPlayUin)
      if player then
        self:AddRelationTreePlayer(OtherPlayUin, player)
        self:AddRelationTreePerception(OtherPlayUin, RelationType)
      end
    end
  end
  self:UpdateCanTick()
end

function UMG_TraceRelationTreePanel_C:UpdateInviteInfo(OtherPlayUin, Player, ActionID)
  if Player then
    self:AddRelationTreePlayer(OtherPlayUin, Player)
    self:AddRelationTreePerception(OtherPlayUin, nil, ActionID)
    self:UpdateCanTick()
  else
    self:RemovePlayerAndItems(OtherPlayUin)
  end
end

function UMG_TraceRelationTreePanel_C:AddRelationTreePlayer(OtherPlayUin, player)
  if not self.OtherPlayers[OtherPlayUin] and player then
    self.OtherPlayers[OtherPlayUin] = player
  end
end

function UMG_TraceRelationTreePanel_C:AddRelationTreePerception(OtherPlayUin, RelationType, ActionID)
  local RelationTreeItem = self.Items[OtherPlayUin]
  if not RelationTreeItem then
    Log.DebugFormat("Add RelationTree Perception %d", OtherPlayUin)
    RelationTreeItem = UE4.UWidgetBlueprintLibrary.Create(self, self.RelationTreeItem)
    self.TrackPanel:AddChildToCanvas(RelationTreeItem)
  end
  RelationTreeItem:SetRelationTreeType(RelationType, ActionID, true)
  self.Items[OtherPlayUin] = RelationTreeItem
end

function UMG_TraceRelationTreePanel_C:RemovePlayerAndItems(OtherPlayUin)
  if self.OtherPlayers and self.OtherPlayers[OtherPlayUin] then
    self.OtherPlayers[OtherPlayUin] = nil
  end
  if self.Items and self.Items[OtherPlayUin] then
    local Item = self.Items[OtherPlayUin]
    Item:ToggleArrow(false)
    Item:RemoveFromParent()
    self.Items[OtherPlayUin] = nil
  end
  if table.getTableCount(self.OtherPlayers) <= 0 or table.getTableCount(self.Items) <= 0 then
    self:UpdateCanTick()
  end
end

function UMG_TraceRelationTreePanel_C:OnTick()
  if not UE.UObject.IsValid(self) then
    return
  end
  self.hasItemShow = false
  local State = _G.ZoneServer:GetOnlineState()
  local ShouldTick = true
  local SelfPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if SelfPlayer then
    ShouldTick = ShouldTick and SelfPlayer
    ShouldTick = ShouldTick and self.World
    if not self.InCreatePlayerMode then
      ShouldTick = ShouldTick and State == OnlineState.EnteredCell
    end
    if ShouldTick and self.Items then
      self.playerPosition = SelfPlayer:GetActorLocationFrameCache()
      for playeruin, v in pairs(self.Items) do
        self:TickItem(v, playeruin)
      end
    elseif self.Items then
      for _, v in pairs(self.Items) do
        v:SetVisibility(Collapsed)
      end
    end
  else
    Log.Debug("selfPlayer is NULL")
    if self.Items then
      for _, v in pairs(self.Items) do
        v:SetVisibility(Collapsed)
      end
    end
    return
  end
end

local TickItemTempParameterVector3D = UE4.FVector(0, 0, 0)
local TickItemScreenPosCache = UE4.FVector2D()
local TickItemViewportPosCache = UE4.FVector2D()
local TickItemDeltaCache = UE4.FVector2D()
local TickItemOnPosCache = UE4.FVector2D()
local DistanceCache = UE4.FVector(0, 0, 0)

function UMG_TraceRelationTreePanel_C:TickItem(Item, playeruin)
  local Player = self.OtherPlayers[playeruin]
  if not Player or Player.isDestroy or not Item then
    self:RemovePlayerAndItems(playeruin)
    return
  end
  local viewObj = Player.viewObj
  local DistSqrt = 1
  local isHeadHudVisible = self:IsTeammateHeadHudVisible(Player)
  if viewObj and UE.UObject.IsValid(viewObj) then
    if not isHeadHudVisible then
      local TargetPosition = viewObj:Abs_K2_GetActorLocation()
      TargetPosition:SubInto(self.playerPosition, DistanceCache)
      DistSqrt = DistanceCache:SizeSquared()
      local ScreenPos = TickItemScreenPosCache
      local ViewportPos = TickItemViewportPosCache
      local result = UE4.UNRCStatics.Abs_ProjectWorldToScreen(self.playerController, TargetPosition, ScreenPos)
      UE4.USlateBlueprintLibrary.ScreenToViewport(self.World, ScreenPos, ViewportPos)
      ViewportPos:SubInto(self.ViewportCenter, TickItemDeltaCache)
      local delta = UE4.FVector2D(TickItemDeltaCache.x, TickItemDeltaCache.y)
      local theta = math.atan(delta.Y, delta.X)
      if not result then
        theta = theta - math.pi
      end
      FVector2DUtils.GetEllipseInplace(self.Axis, theta, TickItemOnPosCache)
      local onPos = TickItemOnPosCache
      if result then
        local CenterLength = delta:SizeSquared()
        local CircleRadius = onPos:SizeSquared()
        if CenterLength > CircleRadius then
          onPos:AddInto(self.ViewportCenter, ViewportPos)
          Item:UpdateArrow(theta)
        else
          Item:ToggleArrow(false, math.sqrt(DistSqrt))
        end
      else
        onPos:AddInto(self.ViewportCenter, ViewportPos)
        Item:UpdateArrow(theta)
      end
      ViewportPos.X = ViewportPos.X * self.DpiScaleY
      ViewportPos.Y = ViewportPos.Y * self.DpiScaleY - 30
      Item:SetPosition(ViewportPos)
    else
      Item:SetVisibility(Collapsed)
    end
  else
    Item:SetVisibility(Collapsed)
    self:RemovePlayerAndItems(playeruin)
  end
end

function UMG_TraceRelationTreePanel_C:IsTeammateHeadHudVisible(Player)
  if not Player or not Player.viewObj then
    return false
  end
  local HeadWidget = Player.viewObj.HeadWidget
  if not HeadWidget then
    return false
  end
  local HeadHud = HeadWidget:GetUserWidgetObject()
  if not HeadHud then
    return false
  end
  if not HeadHud.visible then
    return false
  end
  local World = _G.UE4Helper.GetCurrentWorld()
  if not World then
    return false
  end
  local ViewportSize = UE4.UWidgetLayoutLibrary.GetViewportSize(World)
  local ViewportScale = UE4.UWidgetLayoutLibrary.GetViewportScale(World)
  local ActualViewportSize = ViewportSize / ViewportScale
  local hudGeometry = HeadHud:GetCachedGeometry()
  local hudSize = UE4.USlateBlueprintLibrary.GetLocalSize(hudGeometry)
  local _, hudLeftViewportPos = UE4.USlateBlueprintLibrary.LocalToViewport(World, hudGeometry, UE4.FVector2D(0, 0))
  local _, hudRightViewportPos = UE4.USlateBlueprintLibrary.LocalToViewport(World, hudGeometry, UE4.FVector2D(hudSize.X, 0))
  local _, hudBottomViewportPos = UE4.USlateBlueprintLibrary.LocalToViewport(World, hudGeometry, UE4.FVector2D(0, hudSize.Y))
  local isInViewport = hudLeftViewportPos.X <= ActualViewportSize.X and hudRightViewportPos.X >= 0 and hudBottomViewportPos.Y >= 0 and hudBottomViewportPos.Y <= ActualViewportSize.Y
  return isInViewport
end

function UMG_TraceRelationTreePanel_C:OnLoadingClosed()
  self:ClearSelfTrace()
  self:UpdateCanTick()
end

function UMG_TraceRelationTreePanel_C:ClearSelfTrace()
  table.clear(self.OtherPlayers)
  if self.Items then
    for _, v in pairs(self.Items) do
      v:ToggleArrow(false)
      v:RemoveFromParent()
    end
    table.clear(self.Items)
  end
end

function UMG_TraceRelationTreePanel_C:OnDestruct()
  Log.Debug("Track Task UMG_TraceRelationTreePanel_C:OnRemoveEventListener")
  self:ClearSelfTrace()
  NRCEventCenter:UnRegisterEvent(self, RelationTreeEvent.UPDATE_OTHERREQUEST_PLAYER_CHANGE, self.UpdateOterRequestTracePlayer)
  NRCEventCenter:UnRegisterEvent(self, RelationTreeEvent.DELETE_OTHERREQUEST_PLAYER, self.RemovePlayerAndItems)
  NRCEventCenter:UnRegisterEvent(self, RelationTreeEvent.UPDATE_RELATION_BUBBLE_DIS, self.UpdateTracePlayerInfo)
  NRCEventCenter:UnRegisterEvent(self, LoadingUIModuleEvent.LOADING_UI_CLOSED, self.OnLoadingClosed)
  NRCEventCenter:UnRegisterEvent(self, RelationTreeEvent.DELETE_OTHER_INVITE_REQUEST, self.RemovePlayerAndItems)
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.PlayerBornFinish, self.UpdateCached)
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnTeleportNotify, self.OnLoadMapStart)
end

return UMG_TraceRelationTreePanel_C
