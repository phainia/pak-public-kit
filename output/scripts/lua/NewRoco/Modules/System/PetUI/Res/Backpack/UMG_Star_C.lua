local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local BagModuleData = reload("NewRoco.Modules.System.Bag.BagModuleData")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local UMG_Star_C = Base:Extend("UMG_Star_C")

function UMG_Star_C:OnConstruct()
end

function UMG_Star_C:OnDestruct()
end

function UMG_Star_C:OnActive()
end

function UMG_Star_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  self:StopAllAnimations()
  self:SetWidgetSwitcher()
end

function UMG_Star_C:SetWidgetSwitcher()
  if self.uiData.GrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToInspire then
    self:SetInspireStarView()
  elseif self.WidgetSwitcher_20 then
    self.WidgetSwitcher_20:SetRenderOpacity(1)
    if self.Image_1013 then
      self.Image_1013:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if self.WidgetSwitcher_0 then
      self.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    end
    self.WidgetSwitcher_20:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if 1 == self.uiData.IsShow then
      if self.uiData.GrowUpType == PetUIModuleEnum.PetGrowUpType.WaitToBreakThrough then
        self.WidgetSwitcher_20:SetActiveWidgetIndex(3)
      elseif self.uiData.bIsReset then
        self.WidgetSwitcher_20:SetActiveWidgetIndex(4)
      else
        self.WidgetSwitcher_20:SetActiveWidgetIndex(0)
      end
    elseif -1 == self.uiData.IsShow then
      if self.uiData.IsHide then
        self.WidgetSwitcher_20:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        self.WidgetSwitcher_20:SetActiveWidgetIndex(1)
      end
    else
      if self.uiData.ShowAnim then
        self.Image_1013:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.WidgetSwitcher_20:SetRenderOpacity(0)
        self:PlayAnimation(self.break_loop, 0, 9999)
      else
        self.Image_1013:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.WidgetSwitcher_20:SetActiveWidgetIndex(0)
      end
      if self.uiData.IsHide then
        self.WidgetSwitcher_20:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        self.WidgetSwitcher_20:SetActiveWidgetIndex(1)
      end
      self.Image_1013:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self.uiData[2] and self.uiData[2].animIndex == self.index then
    self:PlayAnimation(self.Change)
  end
end

function UMG_Star_C:SetInspireStarView()
  if self.WidgetSwitcher_20 then
    self.WidgetSwitcher_20:SetRenderOpacity(1)
    if self.Image_1013 then
      self.Image_1013:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if 1 == self.uiData.IsShow then
      self.WidgetSwitcher_20:SetActiveWidgetIndex(5)
    elseif -1 == self.uiData.IsShow then
      self.WidgetSwitcher_20:SetActiveWidgetIndex(0)
    elseif 0 == self.uiData.IsShow then
      self.WidgetSwitcher_20:SetActiveWidgetIndex(0)
      if self.uiData.ShowAnim and self.break_loop_2 then
        self:PlayAnimation(self.break_loop_2, 0, 0)
      end
    end
  end
end

function UMG_Star_C:OnAnimationFinished(Animation)
end

function UMG_Star_C:OnDeactive()
end

return UMG_Star_C
