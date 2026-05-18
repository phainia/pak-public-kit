local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Customdot_New_C = Base:Extend("UMG_Customdot_New_C")

function UMG_Customdot_New_C:OnConstruct()
end

function UMG_Customdot_New_C:OnDestruct()
end

function UMG_Customdot_New_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.Icon:SetPath(_data.unpicked_mark_tips_icon)
  self:InitializeInfo()
end

function UMG_Customdot_New_C:InitializeInfo()
  local RenderOpacity = self.Selected:GetRenderOpacity()
  if RenderOpacity > 0 then
    self:StopAllAnimations()
    self:PlayAnimation(self.Initial)
  end
  self.BG_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NRCText_28:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Mask:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Mask_Figure:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Customdot_New_C:SetNum(Num)
  self.BG_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.NRCText_28:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.NRCText_28:SetText(Num)
end

function UMG_Customdot_New_C:SetIsCanClick(_IsCanClick, num, map_show_type)
  if _IsCanClick then
    self.Mask:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Mask_Figure:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:SetClickable(true)
  else
    if map_show_type == Enum.MapIconShowType.MAP_CUSTOMIZED_PET_POINT and num > 0 then
      self.Mask_Figure:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Mask:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Mask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Mask_Figure:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self:SetClickable(false)
  end
end

function UMG_Customdot_New_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.Icon:SetPath(self.data.picked_mark_tips_icon)
    self:StopAllAnimations()
    self:PlayAnimation(self.Select)
    _G.NRCModuleManager:DoCmd(BigMapModuleCmd.MarkerSelect, self.data)
  else
    self:StopAllAnimations()
    self:PlayAnimation(self.UnSelect)
  end
end

function UMG_Customdot_New_C:OnDeactive()
end

return UMG_Customdot_New_C
