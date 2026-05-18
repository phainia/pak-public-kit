local TaskUtils = require("NewRoco.Modules.Core.Task.TaskUtils")
local Base = _G.NRCUmgClass
local UMG_TaskBlockItem_C = Base:Extend("UMG_TaskBlockItem_C")
local NormalColor = TaskUtils.MakeSlateColor(58, 66, 84, 255)
local SelectedColor = TaskUtils.MakeSlateColor(255, 255, 255, 255)

function UMG_TaskBlockItem_C:Construct()
end

function UMG_TaskBlockItem_C:Destruct()
  self.Parent = nil
end

function UMG_TaskBlockItem_C:Ctor()
  Base.Ctor(self)
  self.IsSelected = false
end

function UMG_TaskBlockItem_C:SetData(Data)
  self.CurrentData = Data
  self:Refresh()
end

function UMG_TaskBlockItem_C:Refresh()
  if self.Desc then
  end
  if self.TypeIconSide then
    if self.CurrentData and self.CurrentData.Info and self.CurrentData.Info.is_track then
      self.TypeIconSide:SetPath(self.CurrentData.Style.track_mark)
      self.TypeIconSide:PlayAnimation(self.TypeIconSide.loop, 0, -1)
      self.TypeIconSide:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    else
      self.TypeIconSide:StopAllAnimations()
      self.TypeIconSide:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  end
  if self.Dist then
    local Dist = NRCModuleManager:DoCmd(TaskModuleCmd.GetTaskPosition, self.CurrentData.Config, TaskUtils:GetPlayer())
    if Dist and Dist ~= math.maxinteger then
      self.Dist:SetText(string.format("%dm", math.round(Dist)))
      self.Dist:SetVisibility(UE4.ESlateVisibility.Visible)
      self.Unknown:SetVisibility(UE4.ESlateVisibility.Hidden)
    else
      self.Dist:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.Unknown:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  end
  self:SetItemSelected(self.IsSelected)
end

function UMG_TaskBlockItem_C:OnAnimationFinished(Animation)
  if Animation == self.change1 then
    self:PlayAnimation(self.select)
  elseif Animation == self.select then
    self:PlayAnimation(self.select)
  end
end

function UMG_TaskBlockItem_C:SetItemSelected(selected)
  if selected then
    self:PlayAnimation(self.change1)
  else
    self:PlayAnimation(self.change2)
  end
  self.IsSelected = selected
  self.Selected:SetVisibility(selected and UE4.ESlateVisibility.HitTestInvisible or UE4.ESlateVisibility.Hidden)
  self.Desc:SetColorAndOpacity(SelectedColor)
end

function UMG_TaskBlockItem_C:OnClick()
  _G.NRCAudioManager:PlaySound2DAuto(1003, "UMG_TaskBlockItem_C:OnClick")
  self.Parent:SetSelectTask(self.CurrentData)
end

function UMG_TaskBlockItem_C:OnMouseButtonDown(MyGeometry, MouseEvent)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_TaskBlockItem_C:OnMouseButtonUp(MyGeometry, MouseEvent)
  self:OnClick()
  return UE4.UWidgetBlueprintLibrary.Handled()
end

return UMG_TaskBlockItem_C
