local UMG_MaterialItemsPanel_C = _G.NRCPanelBase:Extend("UMG_MaterialItemsPanel_C")

function UMG_MaterialItemsPanel_C:OnActive(exchange_id, ironPan, item_num)
  self.DpiScaleY = 1
  self.item_widgets = {}
  self.ironPan = ironPan
  self.target_num = 0
  self.current_num = 0
  self.DisappearCountDown = 0.05
  self.ShowCountDown = 0.1
  table.insert(self.item_widgets, self.MaterialsItem1)
  table.insert(self.item_widgets, self.MaterialsItem2)
  table.insert(self.item_widgets, self.MaterialsItem3)
  table.insert(self.item_widgets, self.MaterialsItem4)
  for _, item in ipairs(self.item_widgets) do
    item:OnAddEventListener()
  end
  self:QuickHideALl()
  self:UpdateItems(exchange_id, item_num)
end

function UMG_MaterialItemsPanel_C:UpdateItems(exchange_id, item_num)
  self.exchange_id = exchange_id
  if 0 == self.exchange_id then
    for i = 1, 4 do
      self.item_widgets[i]:SetData(nil, i)
      self.target_num = 0
    end
    return
  end
  local costMaterials = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetCostMaterialItems, exchange_id, item_num)
  for i = 1, 4 do
    if i <= #costMaterials and (costMaterials[i].goods_type ~= _G.Enum.GoodsType.GT_VITEM or costMaterials[i].goods_id ~= _G.Enum.VisualItem.VI_COIN) then
      self.item_widgets[i]:SetData(costMaterials[i], i)
    else
      self.item_widgets[i]:SetData(nil, i)
    end
  end
  self.target_num = #costMaterials
  if self.module.TestOpen then
    self:DisappearAll()
    self.current_num = 0
    self:ShowAll()
  end
end

function UMG_MaterialItemsPanel_C:OnDeactive()
end

function UMG_MaterialItemsPanel_C:OnAddEventListener()
end

function UMG_MaterialItemsPanel_C:OnTick(DeltaTime)
  if not UE4.UObject.IsValid(self.ironPan) or not self.ironPan:GetComponentByClass(UE4.USkeletalMeshComponent) then
    return
  end
  self.MaterialsItem1.Slot:SetPosition(self:GetLocatorLocation("item_04_socket"))
  self.MaterialsItem2.Slot:SetPosition(self:GetLocatorLocation("item_03_socket"))
  self.MaterialsItem3.Slot:SetPosition(self:GetLocatorLocation("item_02_socket"))
  self.MaterialsItem4.Slot:SetPosition(self:GetLocatorLocation("item_01_socket"))
  if self.current_num > self.target_num then
    if self.DisappearCountDown < 0 then
      self.item_widgets[self.current_num]:Disappear()
      self.current_num = self.current_num - 1
      self.DisappearCountDown = 0.05
    else
      self.DisappearCountDown = self.DisappearCountDown - DeltaTime
    end
  elseif self.current_num < self.target_num then
    if self.ShowCountDown < 0 then
      self.current_num = self.current_num + 1
      self.item_widgets[self.current_num]:Show()
      self.ShowCountDown = 0.1
    else
      self.ShowCountDown = self.ShowCountDown - DeltaTime
    end
  end
end

function UMG_MaterialItemsPanel_C:GetLocatorLocation(socketName)
  local ironPanMesh = self.ironPan.NRCSkeletalMesh
  local playerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
  local SocketLocation = ironPanMesh:Abs_GetSocketLocation(socketName)
  local ScreenPos = UE4.FVector2D()
  UE4.UGameplayStatics.Abs_ProjectWorldToScreen(playerController, SocketLocation, ScreenPos)
  local ViewportPos = UE4.FVector2D()
  UE4.USlateBlueprintLibrary.ScreenToViewport(_G.UE4Helper.GetCurrentWorld(), ScreenPos, ViewportPos)
  if _G.GlobalConfig.bUseDpiScale then
    ViewportPos.X = ViewportPos.X
    ViewportPos.Y = ViewportPos.Y
  end
  return ViewportPos
end

function UMG_MaterialItemsPanel_C:DisappearAll()
  for i = 1, 4 do
    self.item_widgets[i]:Disappear()
  end
end

function UMG_MaterialItemsPanel_C:DisableClick()
  for i = 1, 4 do
    self.item_widgets[i]:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  end
end

function UMG_MaterialItemsPanel_C:QuickHideALl()
  for i = 1, 4 do
    self.item_widgets[i]:QuickHide()
  end
end

function UMG_MaterialItemsPanel_C:ShowAll()
  while self.current_num < self.target_num do
    self.current_num = self.current_num + 1
    self.item_widgets[self.current_num]:Show()
  end
end

function UMG_MaterialItemsPanel_C:CleanUp()
  self.target_num = 0
  self.current_num = 0
end

function UMG_MaterialItemsPanel_C:DoAllShow()
  for i = 1, self.current_num do
    self.item_widgets[i]:DoShow(i)
  end
end

return UMG_MaterialItemsPanel_C
