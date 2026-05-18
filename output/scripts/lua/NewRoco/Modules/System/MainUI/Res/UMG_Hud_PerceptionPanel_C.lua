local UMG_Hud_PerceptionPanel_C = _G.NRCPanelBase:Extend("UMG_Hud_PerceptionPanel_C")
local FVector2DUtils = require("NewRoco.Utils.FVector2DUtils")
local SceneEnum = require("NewRoco.Modules.Core.Scene.Common.SceneEnum")

function UMG_Hud_PerceptionPanel_C:OnConstruct()
  self.Items = {}
  self.npcCount = 0
  self.DpiScaleY = 1
  self:OnAddEventListener()
  self:UpdateCanTick()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Hud_PerceptionPanel_C:OnEnable()
  self:ClearDisableItem()
end

function UMG_Hud_PerceptionPanel_C:ClearDisableItem()
  local disableItem = {}
  if self.Items then
    for _, item in pairs(self.Items) do
      if item.CurType == SceneEnum.PerceptionHudType.Lose then
        table.insert(disableItem, item)
      end
    end
    for _, item in pairs(disableItem) do
      self:RemoveNpc(item)
    end
  end
end

function UMG_Hud_PerceptionPanel_C:OnSceneLoad()
  self.World = _G.UE4Helper.GetCurrentWorld()
  self.playerController = UE4.UGameplayStatics.GetPlayerController(self.World, 0)
  self.playerCameraManager = self:GetOwningPlayerCameraManager()
  self.localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not self.localPlayer then
    Log.Error("Can't find a valid local player!")
  end
  self:UpdateViewport()
end

function UMG_Hud_PerceptionPanel_C:InitForBattle()
  self.isInBattle = true
  self.World = _G.UE4Helper.GetCurrentWorld()
  self.playerController = UE4.UGameplayStatics.GetPlayerController(self.World, 0)
  self.BattleCenter = _G.BattleManager.vBattleField:GetBattleFieldCenter()
end

function UMG_Hud_PerceptionPanel_C:OnAddEventListener()
  if _G.NRCModuleManager:GetModule("PlayerModule").IsSceneLoaded then
    self:OnSceneLoad()
  else
    NRCEventCenter:RegisterEvent("UMG_Hud_PerceptionPanel_C", self, SceneEvent.PlayerBornFinish, self.OnSceneLoad)
  end
end

function UMG_Hud_PerceptionPanel_C:UpdateViewport()
  local Size = UE4.UWidgetLayoutLibrary.GetViewportSize(self.World)
  local Scale = UE4.UWidgetLayoutLibrary.GetViewportScale(self.World)
  self.ViewportCenter = Size / Scale / 2
  self.Axis = UE4.FVector2D(self.ViewportCenter.X * 0.8, self.ViewportCenter.Y * 0.8)
end

function UMG_Hud_PerceptionPanel_C:UpdateViewportInBattle()
  if not self.ViewportCenter then
    self:OnSceneLoad()
  end
  self.Axis = UE4.FVector2D(self.ViewportCenter.X * 0.95, self.ViewportCenter.Y * 0.95)
end

function UMG_Hud_PerceptionPanel_C:RemoveNpc(npc)
  if self.Items[npc] then
    self.Items[npc]:HideOnMain(true)
    if self.Perception then
      self.Perception:RemoveChild(self.Items[npc])
    end
    self.Items[npc] = nil
    self.npcCount = self.npcCount - 1
    self:UpdateCanTick()
  end
end

function UMG_Hud_PerceptionPanel_C:PerceivePlayer(npc)
  if self.Items[npc] then
    self.Items[npc]:SetType(SceneEnum.PerceptionHudType.Perceive)
  end
end

function UMG_Hud_PerceptionPanel_C:TackActionToPlayer(npc)
  if not self.Items[npc] then
    if not self.Perception then
      return
    end
    self.Items[npc] = UE4.UWidgetBlueprintLibrary.Create(self, self.itemClass)
    self.Perception:AddChildToCanvas(self.Items[npc])
    self.Items[npc]:InitData(npc, SceneEnum.PerceptionHudType.TackAction, self)
    self.npcCount = self.npcCount + 1
    self:UpdateCanTick()
  else
    self.Items[npc]:SetType(SceneEnum.PerceptionHudType.TackAction)
  end
end

function UMG_Hud_PerceptionPanel_C:HardActionToPlayer(npc)
  if not self.Items[npc] then
    if not self.Perception then
      return
    end
    self.Items[npc] = UE4.UWidgetBlueprintLibrary.Create(self, self.itemClass)
    self.Perception:AddChildToCanvas(self.Items[npc])
    self.Items[npc]:InitData(npc, SceneEnum.PerceptionHudType.HardAction, self)
    self.npcCount = self.npcCount + 1
    self:UpdateCanTick()
  else
    self.Items[npc]:SetType(SceneEnum.PerceptionHudType.HardAction)
  end
end

function UMG_Hud_PerceptionPanel_C:LosePlayer(npc)
  if self.Items and self.Items[npc] then
    self.Items[npc]:SetType(SceneEnum.PerceptionHudType.Lose)
  end
end

function UMG_Hud_PerceptionPanel_C:UpdateCanTick()
  for _, v in pairs(self.Items) do
    if v then
      _G.UpdateManager:Register(self)
      return
    end
  end
  _G.UpdateManager:UnRegister(self)
end

function UMG_Hud_PerceptionPanel_C:OnTick()
  if not self.localPlayer and not self.BattleCenter then
    return
  end
  self.hasItemShow = false
  self.playerPosition = self.BattleCenter or self.localPlayer:GetActorLocationFrameCache()
  for _, item in pairs(self.Items) do
    if item and item.Owner then
      self:TickItem(item)
    end
  end
  if self.lastItemShow == nil or self.lastItemShow ~= self.hasItemShow then
    if self.hasItemShow then
      self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.lastItemShow = self.hasItemShow
  end
end

local ScreenPos = UE4.FVector2D()
local ViewportPos = UE4.FVector2D()

function UMG_Hud_PerceptionPanel_C:TickItem(item)
  if item.CurType == SceneEnum.PerceptionHudType.Perceive then
    item:HideOnMain(true)
    return
  end
  local TargetPosition = item:GetPosition()
  local result = UE4.UNRCStatics.Abs_ProjectWorldToScreen(self.playerController, TargetPosition, ScreenPos)
  UE4.USlateBlueprintLibrary.ScreenToViewport(self.World, ScreenPos, ViewportPos)
  local delta = ViewportPos - self.ViewportCenter
  local theta = math.atan(delta.Y, delta.X)
  if not result then
    theta = theta - math.pi
  end
  local onPos = FVector2DUtils.GetEllipse(self.Axis, theta)
  if result then
    if math.abs(delta.X) >= self.ViewportCenter.X or math.abs(delta.Y) >= self.ViewportCenter.Y then
      item:HideOnMain(false)
      self.hasItemShow = true
      local CenterLength = delta:SizeSquared()
      local CircleRadius = onPos:SizeSquared()
      if CenterLength > CircleRadius then
        ViewportPos = onPos + self.ViewportCenter
        item:UpdateArrow(math.deg(theta) - 90)
      else
        item:UpdateArrow(0)
      end
    else
      item:HideOnMain(true)
    end
  else
    ViewportPos = onPos + self.ViewportCenter
    item:HideOnMain(false)
    self.hasItemShow = true
    item:UpdateArrow(math.deg(theta) - 90)
  end
  ViewportPos.X = ViewportPos.X * self.DpiScaleY
  ViewportPos.Y = ViewportPos.Y * self.DpiScaleY
  item:SetPosition(ViewportPos)
end

function UMG_Hud_PerceptionPanel_C:OnRemoveEventListener()
  if NRCEventCenter:HasListener("UMG_Hud_PerceptionPanel_C", self, SceneEvent.PlayerBornFinish, self.OnSceneLoad) then
    NRCEventCenter:UnRegisterEvent(self, SceneEvent.PlayerBornFinish, self.OnSceneLoad)
  end
end

function UMG_Hud_PerceptionPanel_C:OnDestruct()
  self.Items = nil
  self.World = nil
  self.playerController = nil
  self.playerCameraManager = nil
  self.localPlayer = nil
  self.ViewportCenter = nil
  self:OnRemoveEventListener()
end

return UMG_Hud_PerceptionPanel_C
