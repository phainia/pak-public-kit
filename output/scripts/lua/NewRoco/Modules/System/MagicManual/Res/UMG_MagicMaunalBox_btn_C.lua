local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MagicMaunalBox_btn_C = Base:Extend("UMG_MagicMaunalBox_btn_C")

function UMG_MagicMaunalBox_btn_C:OnConstruct()
end

function UMG_MagicMaunalBox_btn_C:OnDestruct()
end

function UMG_MagicMaunalBox_btn_C:OnItemUpdate(_data, datalist, index)
  self.MainPlotTItle:SetText(_data.name)
  self.curSelect = _data.CurRegionSelect
  if _data.IsSeason then
    self.MainPlotList:InitGridView(_data.list)
  else
    self.MainPlotList:InitGridView(_data.list.data)
  end
end

function UMG_MagicMaunalBox_btn_C:OnItemSelected(_bSelected)
  if _bSelected then
    if self.curSelect then
      self.MainPlotList:SelectItemByIndex(self.curSelect - 1)
    else
      self.MainPlotList:SelectItemByIndex(0)
    end
  end
end

function UMG_MagicMaunalBox_btn_C:OnTouchEnded(_MyGeometry, _InTouchEvent)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_MagicMaunalBox_btn_C:OnDeactive()
end

return UMG_MagicMaunalBox_btn_C
