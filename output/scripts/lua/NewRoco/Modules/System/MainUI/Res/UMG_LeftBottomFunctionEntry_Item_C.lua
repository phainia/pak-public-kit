local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local MainUIModuleEnum = require("NewRoco.Modules.System.MainUI.MainUIModuleEnum")
local UMG_LeftBottomFunctionEntry_Item_C = Base:Extend("UMG_LeftBottomFunctionEntry_Item_C")

function UMG_LeftBottomFunctionEntry_Item_C:OnConstruct()
end

function UMG_LeftBottomFunctionEntry_Item_C:OnDestruct()
end

function UMG_LeftBottomFunctionEntry_Item_C:OnItemUpdate(_data, datalist, index)
  self._data = _data
  self:SetIcon(_data.icon)
  self.ChatRedPoint:SetupKey(_data.redDotKey)
  if _data.IsHide then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_LeftBottomFunctionEntry_Item_C:OnItemSelected(_bSelected)
  if _bSelected and self._data.on_clicked then
    self._data.on_clicked()
  end
end

function UMG_LeftBottomFunctionEntry_Item_C:ShowOrHideQuickChat(IsHide)
  if self._data.type == _G.Enum.FunctionEntrance.FE_MULTI_MAIN_MULTI_CHAT then
    if IsHide then
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    self._data.IsHide = IsHide
  end
end

function UMG_LeftBottomFunctionEntry_Item_C:OnDeactive()
end

function UMG_LeftBottomFunctionEntry_Item_C:SetIcon(Path)
  if Path and "" ~= Path then
    self.Icon:SetPath(Path)
  end
end

return UMG_LeftBottomFunctionEntry_Item_C
