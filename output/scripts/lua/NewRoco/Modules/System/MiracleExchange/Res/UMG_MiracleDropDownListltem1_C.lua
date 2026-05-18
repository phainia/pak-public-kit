local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MiracleDropDownListltem1_C = Base:Extend("UMG_MiracleDropDownListltem1_C")

function UMG_MiracleDropDownListltem1_C:OnConstruct()
end

function UMG_MiracleDropDownListltem1_C:OnDestruct()
end

function UMG_MiracleDropDownListltem1_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  if self.uiData.IsChooseType == true then
    self.SelectSwitcher:SetActiveWidgetIndex(1)
  else
    self.SelectSwitcher:SetActiveWidgetIndex(0)
  end
  if _data.typeIcon then
    self.ShiNeng:SetPath(_data.typeIcon)
    self.ShiNeng:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.ShiNeng:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.Text:SetText(_data.typeName)
end

function UMG_MiracleDropDownListltem1_C:OnItemSelected(_bSelected)
  if _bSelected then
    if self.uiData.IsChooseType == true then
      self.SelectSwitcher:SetActiveWidgetIndex(0)
      _G.NRCModuleManager:DoCmd(MiracleExchangeModuleCmd.OnTypeChooseChanged, self.uiData, false)
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1288, "UMG_PetDropDownListltem1_C:OnItemSelected")
    else
      local chooseTypeList = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.GetTypeChooseNum)
      if #chooseTypeList < 2 then
        self.SelectSwitcher:SetActiveWidgetIndex(1)
        _G.NRCModuleManager:DoCmd(MiracleExchangeModuleCmd.OnTypeChooseChanged, self.uiData, true)
        UE4.UNRCAudioManager.Get():PlaySound2DAuto(1289, "UMG_PetDropDownListltem1_C:OnItemSelected")
      else
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_miracledropdownlistltem1_1)
      end
    end
  elseif self.uiData.IsChooseType == true then
    self.SelectSwitcher:SetActiveWidgetIndex(0)
    _G.NRCModuleManager:DoCmd(MiracleExchangeModuleCmd.OnTypeChooseChanged, self.uiData, false)
  end
  local caller = self.uiData.caller
  self.uiData.handler(caller)
end

function UMG_MiracleDropDownListltem1_C:OnDeactive()
end

return UMG_MiracleDropDownListltem1_C
