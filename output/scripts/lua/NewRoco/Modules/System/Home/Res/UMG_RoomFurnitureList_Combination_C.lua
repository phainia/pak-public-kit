local FurnitureView = require("NewRoco/Modules/System/Home/Res/Helpers/FurnitureView")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_RoomFurnitureList_Combination_C = Base:Extend("UMG_RoomFurnitureList_Combination_C")

function UMG_RoomFurnitureList_Combination_C:OnConstruct()
  self.MoneyIcon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.WidgetHoverStatus = nil
  self:AddButtonListener(self.Storage.btnLevelUp, self.OnClickUnload, self)
  self:AddButtonListener(self.Button, self.OnClickSelect, self)
end

function UMG_RoomFurnitureList_Combination_C:OnDestruct()
  self:RemoveButtonListener(self.Storage.btnLevelUp)
  self:RemoveButtonListener(self.Button)
end

function UMG_RoomFurnitureList_Combination_C:OnClickUnload()
  _G.NRCAudioManager:PlaySound2DAuto(41401015, "FurnitureManager:OnClickUnload")
  HomeIndoorSandbox.Module:UnloadPackUpSpecifyProps(self.DependencyPropsData)
  if self.OnSubPropsUnloaded then
    self.OnSubPropsUnloaded()
  end
end

function UMG_RoomFurnitureList_Combination_C:OnItemUpdate(_data, datalist, index)
  self.ParentFurnitureWidget = _data.ParentWidget
  self.DependencyPropsData = _data.PropsData
  self.OnSubPropsUnloaded = _data.OnUnloaded
  self.FurnitureView = FurnitureView()
  self.FurnitureView:BindIconView(self.Icon)
  self.FurnitureView:BindComfortValueView(self.SumNum_1)
  self.FurnitureView:BindNameView(self.Title)
  self.FurnitureView:BindQualityColorView(self.QualityColor)
  self.FurnitureView:BindCombinationTag(self.CombinationIcon)
  self.FurnitureView:SetInCombination(self.DependencyPropsData.RealtimeParentPropsData ~= nil)
  self.FurnitureView:SetFurnitureItemConf(self.DependencyPropsData.Conf)
  if index == #datalist then
    self.Line:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.Line:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
  if nil ~= self.DependencyPropsData.bInManagerSelected then
    self:SetPropsHoverEnabled(self.DependencyPropsData.bInManagerSelected)
  end
end

function UMG_RoomFurnitureList_Combination_C:OnClickSelect()
  self.bInteracted = true
  HomeIndoorSandbox:DispatchEvent(HomeIndoorSandbox.Event.OnManagerSelectPropsData, self.DependencyPropsData, self)
end

function UMG_RoomFurnitureList_Combination_C:SetPropsHoverEnabled(bEnabled)
  if not self.DependencyPropsData then
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
  HomeIndoorSandbox:LogInfo("\230\146\173\230\148\190\229\138\168\231\148\187:", bEnabled, self.DependencyPropsData:GetName())
end

function UMG_RoomFurnitureList_Combination_C:OnDeactive()
end

return UMG_RoomFurnitureList_Combination_C
