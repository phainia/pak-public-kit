local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MagicalStudy_Item_C = Base:Extend("UMG_MagicalStudy_Item_C")

function UMG_MagicalStudy_Item_C:OnConstruct()
  self.arrowFx:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.PhysicalPower_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_MagicalStudy_Item_C:OnDestruct()
end

function UMG_MagicalStudy_Item_C:OnItemUpdate(_data, datalist, index)
  self.type = _data.type
  self.parent = _data.parent
  self.data = _data.data
  self.index = index
  local maxLevelHint = _G.DataConfigManager:GetLocalizationConf("exchange_magic_level_max")
  self.maxLevelHintText = maxLevelHint and maxLevelHint.msg or "\230\150\135\230\156\172\232\175\187\228\184\141\229\136\176"
  if self.type == _G.Enum.VisualItem.VI_ROLE_HP_MAX then
    self.RedDot:SetupKey(231, _G.Enum.VisualItem.VI_ROLE_HP_MAX)
    self.Switcher:SetActiveWidgetIndex(0)
    self.RestoreList = {}
    if 0 == #self.RestoreList then
      for i = 1, self.data.current_value do
        table.insert(self.RestoreList, {isNormal = true})
      end
    end
    self.DriveList:InitGridView(self.RestoreList)
    local title = _G.DataConfigManager:GetLocalizationConf("alchemy_HPup_title")
    self.Title:SetText(title and title.msg or "\232\175\183\233\133\141\231\189\174alchemy_HPup_title")
  elseif self.type == _G.Enum.VisualItem.VI_STAMINA then
    self.RedDot:SetupKey(231, _G.Enum.VisualItem.VI_STAMINA)
    self.Switcher:SetActiveWidgetIndex(1)
    if self.data.upgradeId > 0 then
      self.PhysicalPower_1:SetUpgradeTimes(self.data.upgradeId - 1)
      self.PhysicalPower_1:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    else
      local RolePowerConfTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.POWER_MAX_CONF):GetAllDatas()
      self.PhysicalPower_1:SetUpgradeTimes(#RolePowerConfTable)
      self.PhysicalPower_1:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    end
    local title = _G.DataConfigManager:GetLocalizationConf("alchemy_bottle_stamina_title")
    self.Title_1:SetText(title and title.msg or "\232\175\183\233\133\141\231\189\174alchemy_bottle_stamina_title")
  elseif self.type == _G.Enum.VisualItem.VI_BOTTLE_TIMES then
    self.RedDot:SetupKey(231, _G.Enum.VisualItem.VI_BOTTLE_TIMES)
    self.Switcher:SetActiveWidgetIndex(2)
    self.RestoreList = {}
    if 0 == #self.RestoreList then
      for i = 1, self.data.origin_value do
        table.insert(self.RestoreList, {filled = true})
      end
    end
    self.AlchemyTable:InitGridView(self.RestoreList)
    if 0 == self.data.origin_value and self.data.origin_value == self.data.target_value then
      self.NotBOTTLE = true
    end
    local title = _G.DataConfigManager:GetLocalizationConf("alchemy_bottle_times_result_title")
    self.Title_2:SetText(title and title.msg or "\232\175\183\233\133\141\231\189\174alchemy_bottle_times_result_title")
  end
  if self.data.origin_value == self.data.target_value then
    self.FullLevel:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.itemClickable = false
  else
    self.FullLevel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.itemClickable = true
  end
end

function UMG_MagicalStudy_Item_C:OnItemSelected(_bSelected)
  if not self.parent or self.parent:GetVisibility() == UE4.ESlateVisibility.HitTestInvisible and self.parent:GetVisibility() == UE4.ESlateVisibility.Collapsed and self.parent:GetVisibility() == UE4.ESlateVisibility.Hidden then
    Log.Error("UMG_MagicalStudy_Item_C:OnItemSelected Refuse, parent\229\183\178\231\187\143\228\184\141\229\173\152\229\156\168\230\136\150\232\128\133\228\184\141\229\143\175\231\130\185\229\135\187\228\186\134", _bSelected)
    return
  end
  if _bSelected then
    if self.itemClickable then
      _G.NRCAudioManager:PlaySound2DAuto(41401010, "UMG_MagicalStudy_Item_C:OnItemSelected")
      _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.OnMagicalStudyItemClicked, self.type)
    elseif self.NotBOTTLE then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.exchange_bottle_unlock)
    else
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, self.maxLevelHintText)
    end
  else
  end
end

function UMG_MagicalStudy_Item_C:OnDeactive()
  self.parent = nil
end

return UMG_MagicalStudy_Item_C
