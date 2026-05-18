local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Map_PlotTab_C = Base:Extend("UMG_Map_PlotTab_C")

function UMG_Map_PlotTab_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_Map_PlotTab_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_Map_PlotTab_C:OnAddEventListener()
end

function UMG_Map_PlotTab_C:OnRemoveEventListener()
end

function UMG_Map_PlotTab_C:OnItemUpdate(_data, datalist, index)
  self.bSelected = false
  self.uiData = _data
  self.Name:SetText(_data.display_name)
  self.Suit_Ordinary:SetPath(_data.map_layer_icon_unselected)
  self.Suit_Selected:SetPath(_data.map_layer_icon_select)
  if #datalist == index then
    self.Image_Line:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Image_Line:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Map_PlotTab_C:OnItemSelected(_bSelected)
  self:StopAllAnimations()
  if _bSelected then
    _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_Map_PlotTab_C:OnItemSelected")
    self:PlayAnimation(self.Select_in)
    _G.NRCModuleManager:DoCmd(BigMapModuleCmd.SetCurShowLayerMap, self.uiData.id)
  else
    self:PlayAnimation(self.Select_out)
  end
  self.bSelected = _bSelected
end

function UMG_Map_PlotTab_C:OnSelectBtnClicked()
end

function UMG_Map_PlotTab_C:OnMouseEnter(MyGeometry, MouseEvent)
end

function UMG_Map_PlotTab_C:OnMouseLeave()
end

function UMG_Map_PlotTab_C:OnDeactive()
end

function UMG_Map_PlotTab_C:SetMapNameVisible(bVisible)
  self:StopAllAnimations()
  if bVisible then
    if not self.bSelected then
      self:PlayAnimation(self.Select_in)
    end
  elseif not self.bSelected then
    self:PlayAnimation(self.Select_out)
  end
end

return UMG_Map_PlotTab_C
