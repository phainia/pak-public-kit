local FurnitureManager = Class("FurnitureManager")

function FurnitureManager:Ctor(HomeMain)
  self.HomeMain = HomeMain
  self.Text_RoomName = HomeMain.Text_RoomName
  self.FurnitureView = HomeMain.FurnitureView
end

function FurnitureManager:OnAddEventListener()
  self.HomeMain:RegisterEvent(self.HomeMain, HomeIndoorSandbox.Event.OnManagerSelectPropsData, function(_, ...)
    return self:OnManagerSelectPropsData(...)
  end)
  self.HomeMain:RegisterEvent(self.HomeMain, HomeIndoorSandbox.Event.OnManagerUnloadNoDependPropsData, function(_, ...)
    return self:OnManagerUnloadNoDependPropsData(...)
  end)
end

function FurnitureManager:OnManagerSelectPropsData(PropsData, HoverWidget)
  if PropsData == self.HoverPropsData then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(40008024, "FurnitureManager:OnManagerSelectPropsData")
  if self.HoverWidget then
    self.HoverWidget:SetPropsHoverEnabled(false)
    HomeIndoorSandbox.HomeEditServ:SetExpandPropsDataSelectedInManager(self.HoverPropsData, false)
    local ChildArray = self.HoverPropsData:ResolveSubPropsActorArray()
    Log.Debug("\229\174\182\229\133\183\231\174\161\231\144\134 \229\143\150\230\182\136\233\128\137\228\184\173", self.HoverPropsData:GetName())
    if ChildArray then
      self.HoverWidget:SetChildPropsHoverEnabled(false)
      for i, Child in tpairs(ChildArray) do
        HomeIndoorSandbox.HomeEditServ:SetExpandPropsDataSelectedInManager(Child.PropsData, false)
        self:SetPropsActorHoverEnabled(Child, false)
        Log.Debug("\229\174\182\229\133\183\231\174\161\231\144\134 \229\143\150\230\182\136\233\128\137\228\184\173", Child.PropsData:GetName())
      end
    end
  end
  if self.HoverPropsData then
    local Actor = self.HoverPropsData:ResolvePropsActor()
    if Actor and UE.UObject.IsValid(Actor) then
      self:SetPropsActorHoverEnabled(Actor, false)
    end
  end
  self.HoverPropsData = PropsData
  self.HoverWidget = HoverWidget
  if self.HoverWidget then
    self.HoverWidget:SetPropsHoverEnabled(true)
    HomeIndoorSandbox.HomeEditServ:SetExpandPropsDataSelectedInManager(self.HoverPropsData, true)
    Log.Debug("\229\174\182\229\133\183\231\174\161\231\144\134 \233\128\137\228\184\173", self.HoverPropsData:GetName())
    local ChildArray = self.HoverPropsData:ResolveSubPropsActorArray()
    if ChildArray then
      self.HoverWidget:SetChildPropsHoverEnabled(true)
      for i, Child in tpairs(ChildArray) do
        HomeIndoorSandbox.HomeEditServ:SetExpandPropsDataSelectedInManager(Child.PropsData, true)
        self:SetPropsActorHoverEnabled(Child, true)
        Log.Debug("\229\174\182\229\133\183\231\174\161\231\144\134 \233\128\137\228\184\173", Child.PropsData:GetName())
      end
    end
  end
  if self.HoverPropsData then
    local Actor = self.HoverPropsData:ResolvePropsActor()
    if Actor and UE.UObject.IsValid(Actor) then
      self:SetPropsActorHoverEnabled(Actor, true)
    end
  end
end

function FurnitureManager:OnManagerUnloadNoDependPropsData(PropsData)
  _G.NRCAudioManager:PlaySound2DAuto(41401015, "FurnitureManager:OnManagerUnloadNoDependPropsData")
  local Child = PropsData:ResolveSubPropsActorArray()
  if Child and Child:Num() > 0 then
    HomeIndoorSandbox.HomeTipsServ:ShowUnloadFurnitureGroupMessageBox(function()
      HomeIndoorSandbox.Module:UnloadPackUpSpecifyProps(PropsData)
      self:RefreshFurnitureList()
    end)
    return
  end
  HomeIndoorSandbox.Module:UnloadPackUpSpecifyProps(PropsData)
  self:RefreshFurnitureList()
end

function FurnitureManager:SetPropsActorHoverEnabled(Actor, bEnabled)
  Actor:SetHighLightOutlineEnabled(bEnabled, self.HomeMain:EnsureGetHighLightMat())
  Actor:SetHighLightOutlineColor(HomeIndoorSandbox.Enum.Color_ManagerSelect)
end

function FurnitureManager:OnBtnEditRoomName()
  HomeIndoorSandbox.Module:OpenHomeChangeRoomNamePanel(HomeIndoorSandbox.HomeEditServ.EditRoomId, function()
    return self:OnRoomNameChanged()
  end)
end

function FurnitureManager:OnRoomNameChanged()
  local RoomName = self.HomeMain.HomeStats:ResolveRoomName()
  self.Text_RoomName:SetText(RoomName)
end

function FurnitureManager:OnBtnUnloadAllProps()
  HomeIndoorSandbox.HomeTipsServ:ShowUnloadAllFurnitureMessageBox(function()
    HomeIndoorSandbox.Module:UnLoadAllProps()
    self:RefreshFurnitureList()
  end)
end

function FurnitureManager:Release()
  self.HomeMain = nil
end

function FurnitureManager:InitLayer()
  HomeIndoorSandbox.HomeEditServ:ResetPropsDataInManager()
  local RoomName = self.HomeMain.HomeStats:ResolveRoomName()
  self.Text_RoomName:SetText(RoomName)
  if self.HoverPropsData then
    self:OnManagerSelectPropsData()
  end
  self.HoverPropsData = nil
  self.HoverWidget = nil
  self:RefreshFurnitureList()
end

function FurnitureManager:RefreshFurnitureList()
  local RoomId = HomeIndoorSandbox.HomeEditServ.EditRoomId
  local RoomData = HomeIndoorSandbox.Server.WorldData:GetOrCreateRoomData(RoomId)
  local NoDependencyPropsDataList = RoomData:GetNoDependencyPropsDataList()
  local DisplayList = UE4.NRCLuaUtils.CreateTable(#NoDependencyPropsDataList, 0)
  for k, v in pairs(NoDependencyPropsDataList) do
    table.insert(DisplayList, v)
  end
  table.sort(DisplayList, function(a, b)
    return a.Conf.id < b.Conf.id
  end)
  self.FurnitureView.RefreshFurnitureList = FPartial(self.RefreshFurnitureList, self)
  self.FurnitureView:InitList(DisplayList)
  if #DisplayList > 0 then
    self.HomeMain.OneClickBtn:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.HomeMain.OneClickBtn:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function FurnitureManager:OnClose()
  self:OnManagerSelectPropsData()
  self.HoverPropsData = nil
  self.HoverWidget = nil
end

function FurnitureManager:IfPosInFurnitureListBounds(X, Y)
  local Box = self.HomeMain.CanvasPanel_108
  return Box and self:IfPosInWidget(Box, X, Y)
end

function FurnitureManager:IfPosInWidget(Box, ScreenX, ScreenY)
  local TouchScreenPoint = UE.FVector2D(ScreenX, ScreenY)
  local TouchAreaGeo = Box:GetCachedGeometry()
  return UE4.USlateBlueprintLibrary.IsUnderLocation(TouchAreaGeo, TouchScreenPoint)
end

return FurnitureManager
