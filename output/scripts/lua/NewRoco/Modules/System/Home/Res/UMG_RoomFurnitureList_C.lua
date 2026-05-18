local FurnitureView = require("NewRoco/Modules/System/Home/Res/Helpers/FurnitureView")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_RoomFurnitureList_C = Base:Extend("UMG_RoomFurnitureList_C")

function UMG_RoomFurnitureList_C:OnConstruct()
  self.MoneyIcon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.WidgetHoverStatus = nil
  local Size = self.Combination.Ordinary.Brush.ImageSize
  self.DownDir = UE.FVector2D(Size.X, Size.Y)
  self.UpDir = UE.FVector2D(Size.X, -Size.Y)
  self:AddButtonListener(self.Storage.btnLevelUp, self.OnClickUnload, self)
  self:AddButtonListener(self.Combination.btnLevelUp, self.OnClickExpand, self)
  self:AddButtonListener(self.Button, self.OnClickSelect, self)
end

function UMG_RoomFurnitureList_C:OnDestruct()
  self:RemoveButtonListener(self.Storage.btnLevelUp)
  self:RemoveButtonListener(self.Combination.btnLevelUp)
  self:RemoveButtonListener(self.Button)
end

function UMG_RoomFurnitureList_C:OnClickUnload()
  HomeIndoorSandbox:DispatchEvent(HomeIndoorSandbox.Event.OnManagerUnloadNoDependPropsData, self.NoDependencyPropsData)
end

function UMG_RoomFurnitureList_C:OnClickExpand()
  if self.NoDependencyPropsData then
    if self.NoDependencyPropsData.bExpandedInManager then
      _G.NRCAudioManager:PlaySound2DAuto(40008025, "UMG_RoomFurnitureList_C:OnClickExpand")
    else
      _G.NRCAudioManager:PlaySound2DAuto(40008024, "UMG_RoomFurnitureList_C:OnClickExpand")
    end
  end
  HomeIndoorSandbox.HomeEditServ:ToggleExpandPropsData(self.NoDependencyPropsData)
  self.Combination:StopAllAnimations()
  self:RefreshArrow()
  self:RefreshSubPropsList()
end

function UMG_RoomFurnitureList_C:RefreshArrow()
  if self.NoDependencyPropsData.bExpandedInManager then
    self.Combination.Ordinary.Brush.ImageSize.Y = self.UpDir.Y
    self.Combination.Select.Brush.ImageSize.Y = self.UpDir.Y
    self.Combination.ps.Brush.ImageSize.Y = self.UpDir.Y
    self.Combination:OnClickbtnPressed()
  else
    self.Combination.Ordinary.Brush.ImageSize.Y = self.DownDir.Y
    self.Combination.Select.Brush.ImageSize.Y = self.DownDir.Y
    self.Combination.ps.Brush.ImageSize.Y = self.DownDir.Y
    self.Combination:OnClickbtnLevelReleased()
  end
end

function UMG_RoomFurnitureList_C:OnItemUpdate(_data, datalist, index)
  self.NoDependencyPropsData = _data
  self.FurnitureView = FurnitureView()
  self.FurnitureView:BindIconView(self.Icon)
  self.FurnitureView:BindComfortValueView(self.SumNum_1)
  self.FurnitureView:BindNameView(self.Title)
  self.FurnitureView:BindQualityColorView(self.QualityColor)
  self:RefreshArrow()
  self:RefreshSubPropsList()
  if self.NoDependencyPropsData.bInManagerSelected ~= nil then
    self:SetPropsHoverEnabled(self.NoDependencyPropsData.bInManagerSelected)
  end
end

function UMG_RoomFurnitureList_C:RefreshSubPropsList()
  local Array = self.NoDependencyPropsData:ResolveSubPropsActorArray()
  local SubPropsDataList = {}
  if Array then
    for k, v in tpairs(Array) do
      if v.PropsData then
        table.insert(SubPropsDataList, {
          PropsData = v.PropsData,
          OnUnloaded = FPartial(self.RefreshSubPropsList, self),
          ParentWidget = self
        })
      end
    end
  end
  if #SubPropsDataList > 0 then
    self.Combination:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Combination:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  self.SubPropsDataList = SubPropsDataList
  if self.NoDependencyPropsData.bExpandedInManager then
    self.CombinationView:InitGridView(SubPropsDataList)
  end
  self.CombinationView:SetVisibility(self.NoDependencyPropsData.bExpandedInManager and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
  self.FurnitureView:SetInCombination(#SubPropsDataList > 0)
  self.FurnitureView:SetEnableCombinationName(true)
  self.FurnitureView:BindCombinationTag(self.CombinationIcon)
  self.FurnitureView:SetFurnitureItemConf(self.NoDependencyPropsData.Conf)
end

function UMG_RoomFurnitureList_C:OnClickSelect()
  HomeIndoorSandbox:DispatchEvent(HomeIndoorSandbox.Event.OnManagerSelectPropsData, self.NoDependencyPropsData, self)
end

function UMG_RoomFurnitureList_C:SetPropsHoverEnabled(bEnabled)
  if not self.NoDependencyPropsData then
    return
  end
  if self.WidgetHoverStatus == bEnabled then
    return
  end
  self.WidgetHoverStatus = bEnabled
  if bEnabled then
    self:PlayAnimation(self.Select_in)
  else
    self:PlayAnimationReverse(self.Select_in)
  end
  HomeIndoorSandbox:LogInfo("\230\146\173\230\148\190\229\138\168\231\148\187:", bEnabled, self.NoDependencyPropsData:GetName())
end

function UMG_RoomFurnitureList_C:SetChildPropsHoverEnabled(bEnabled)
  if self.SubPropsDataList then
    for i = 1, #self.SubPropsDataList do
      local Item = self.CombinationView:GetItemByIndex(i - 1)
      Item:SetPropsHoverEnabled(bEnabled)
    end
  end
end

function UMG_RoomFurnitureList_C:OnDeactive()
end

return UMG_RoomFurnitureList_C
