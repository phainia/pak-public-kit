local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Nourish_GoodAndBadi_TipsItem_C = Base:Extend("UMG_Nourish_GoodAndBadi_TipsItem_C")

function UMG_Nourish_GoodAndBadi_TipsItem_C:OnConstruct()
end

function UMG_Nourish_GoodAndBadi_TipsItem_C:OnDestruct()
end

function UMG_Nourish_GoodAndBadi_TipsItem_C:Init(_data, IsAdvantage)
  self.data = _data
  self.AdvantageList:InitGridView(self.data)
  local TypeText = ""
  for i = 1, #self.data do
    local typeDic = _G.DataConfigManager:GetTypeDictionary(self.data[i])
    if i == #self.data then
      TypeText = TypeText .. typeDic.short_name
    else
      TypeText = TypeText .. typeDic.short_name .. "\227\128\129"
    end
  end
  local TypeText1
  if IsAdvantage then
    self.Text_GoodAndBad:SetText(LuaText.umg_nourish_goodandbadi_tipsitem_1)
    TypeText1 = _G.DataConfigManager:GetLocalizationConf("advantage_type_tips").msg
    self.Switcher_175:SetActiveWidgetByWidgetName("Advantage")
    self.textBuffDesc:SetText(string.format(TypeText1, TypeText))
  else
    self.Text_GoodAndBad:SetText(LuaText.umg_nourish_goodandbadi_tipsitem_2)
    TypeText1 = _G.DataConfigManager:GetLocalizationConf("disadvantage_type_tips").msg
    self.Switcher_175:SetActiveWidgetByWidgetName("InferiorPosition")
    self.textBuffDesc:SetText(string.format(TypeText1, TypeText))
    self.DiBian:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_Nourish_GoodAndBadi_TipsItem_C
