local MagicManualModuleEvent = require("NewRoco.Modules.System.MagicManual.MagicManualModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MagicMaunalBox_item_C = Base:Extend("UMG_MagicMaunalBox_item_C")

function UMG_MagicMaunalBox_item_C:OnConstruct()
end

function UMG_MagicMaunalBox_item_C:OnDestruct()
end

function UMG_MagicMaunalBox_item_C:OnItemUpdate(_data, datalist, index)
  self.IsSeason = _data.IsSeason
  if self.IsSeason then
    self.Data = _data.data
  else
    self.Data = _data
  end
  self.index = self.IsSeason and 1 or 2
  self.Sort = self.IsSeason and 2 or 1
  if self.IsSeason then
    self.RedDot:SetupKey(433)
    self.UiConf = _G.DataConfigManager:GetSeasonAdventureUi(self.Data.ui_id)
    self.Text_PlaceName:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(self.UiConf.magic_manual_switch_text_color1))
  else
    self.UiConf = _G.DataConfigManager:GetRegionConf(self.Data.RegionId)
    self.RedDot:SetupKey(166, {
      self.Data.RegionId
    })
    self.Text_PlaceName:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(self.UiConf.magic_manual_switch_text_color1))
  end
  self.Text_PlaceName:SetText(self.Data.name)
  self:PlayAnimation(self.normal)
end

function UMG_MagicMaunalBox_item_C:SetMagicManualComBoxItemBg(_Normal, _Select, SeasonBg, SeasonSelectBg, TextColor)
  local Normal, Select = _Normal, _Select
  if self.IsSeason then
    Normal = SeasonBg
    Select = SeasonSelectBg
  else
  end
  self.TextColor = TextColor
  if self._bSelect then
    self.Text_PlaceName:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(self.UiConf.magic_manual_switch_text_color1))
  else
    self.Text_PlaceName:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(TextColor))
  end
  self.Image_TextBg:SetPath(Normal)
  self.Image_TextBg_select:SetPath(Select)
end

function UMG_MagicMaunalBox_item_C:OnItemSelected(_bSelected)
  if _bSelected then
    self._bSelect = true
    if self.IsSeason then
      _G.NRCModuleManager:GetModule("MagicManualModule"):DispatchEvent(MagicManualModuleEvent.UpdateManualTab, nil, self.Sort)
    else
      _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.SetSelectMagicManualRegion, self.Data.RegionId)
      _G.NRCModuleManager:GetModule("MagicManualModule"):DispatchEvent(MagicManualModuleEvent.UpdateManualTab, nil, self.Sort)
    end
    NRCEventCenter:DispatchEvent(MagicManualModuleEvent.OnMagicManualComBoxItemSelect, self.index)
    self.Text_PlaceName:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(self.UiConf.magic_manual_switch_text_color1))
    self:PlayAnimation(self.select)
  else
    self._bSelect = false
    self.Text_PlaceName:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(self.TextColor))
    self:PlayAnimation(self.normal)
  end
end

function UMG_MagicMaunalBox_item_C:OnTouchEnded(MyGeometry, InTouchEvent)
  _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_MagicMaunalBox_item_C:OnTouchEnded")
  Base.OnTouchEnded(self, MyGeometry, InTouchEvent)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_MagicMaunalBox_item_C:OnDeactive()
end

return UMG_MagicMaunalBox_item_C
