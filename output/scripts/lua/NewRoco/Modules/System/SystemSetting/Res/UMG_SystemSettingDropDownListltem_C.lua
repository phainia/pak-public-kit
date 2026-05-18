local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SystemSettingDropDownListltem_C = Base:Extend("UMG_SystemSettingDropDownListltem_C")

function UMG_SystemSettingDropDownListltem_C:OnItemUpdate(_data, datalist, index)
  if _data.option.Recommend then
    self.TText:SetText(_data.option.Name .. LuaText.umg_systemsettingdropdownlistltem_1)
  else
    self.TText:SetText(_data.option.Name)
  end
  self.caller = _data.caller
  self.data = _data.option
  self.index = index
  local bSelectable = true
  if self.caller.CurShieldGroupName then
    if self.caller.CurShieldGroupName == "ImageQuality" then
      if self.data.Name == "\230\158\129\232\135\180" then
        bSelectable = false
      end
    elseif self.caller.CurShieldGroupName == "VsyncQuality" and self:IsPCMode() and UE4.UNRCQualityLibrary.GetFrameQuality() == UE4.ENRCFrameQuality.Epic and self.data.Name == LuaText.setting_image_open then
      bSelectable = false
    end
  end
  self.TText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(bSelectable and "C4C2B6FF" or "3D3D3DFF"))
  self.selectable = bSelectable
end

function UMG_SystemSettingDropDownListltem_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.caller:OnItemSelected(self.data, self.index)
    self.TText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("dc9827FF"))
    _G.NRCAudioManager:PlaySound2DAuto(1086, "UMG_LevelMain_C:OnSelecedTabIndex")
  else
    self:CancelSelect()
  end
end

function UMG_SystemSettingDropDownListltem_C:CancelSelect()
  local bSelectable = true
  if self.caller.CurShieldGroupName then
    if self.caller.CurShieldGroupName == "ImageQuality" then
      if self.data.Name == "\230\158\129\232\135\180" then
        bSelectable = false
      end
    elseif self.caller.CurShieldGroupName == "VsyncQuality" and self:IsPCMode() and UE4.UNRCQualityLibrary.GetFrameQuality() == UE4.ENRCFrameQuality.Epic and self.data.Name == LuaText.setting_image_open then
      bSelectable = false
    end
  end
  self.TText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(bSelectable and "C4C2B6FF" or "3D3D3DFF"))
end

function UMG_SystemSettingDropDownListltem_C:OnItemClicked(_bSelected)
  if _bSelected and not self.selectable then
    if self.caller.CurShieldGroupName == "VsyncQuality" then
      do
        local msg = _G.DataConfigManager:GetLocalizationConf("setting_image_rate_high_noselect").msg
        if msg then
          _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, msg, nil, nil, 2)
        end
      end
    elseif self.IsPCMode() then
      if self.data.Name == "\228\189\142" or self.data.Name == "\228\184\173" then
        local msg = _G.DataConfigManager:GetLocalizationConf("video_settings_tips2").msg
        if msg then
          _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, msg, nil, nil, 2)
        end
      elseif self.data.Name == "\230\158\129\233\171\152" or self.data.Name == "\230\158\129\232\135\180" then
        local msg = _G.DataConfigManager:GetLocalizationConf("video_settings_tips1").msg
        if msg then
          _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, msg, nil, nil, 2)
        end
      end
    elseif self.caller.CurShieldGroupName == "ImageQuality" then
      if self.data.Name == "\228\189\142" then
        local msg = _G.DataConfigManager:GetLocalizationConf("video_settings_tips2").msg
        if msg then
          _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, msg, nil, nil, 2)
        end
      elseif self.data.Name == "\230\158\129\232\135\180" then
        local msg = _G.DataConfigManager:GetLocalizationConf("video_settings_tips1").msg
        if msg then
          _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, msg, nil, nil, 2)
        end
      end
    else
      local msg = _G.DataConfigManager:GetLocalizationConf("video_settings_tips2").msg
      if msg then
        _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, msg, nil, nil, 2)
      end
    end
  end
end

function UMG_SystemSettingDropDownListltem_C:IsPCMode()
  if RocoEnv.IS_EDITOR then
    return false
  else
    return RocoEnv.PLATFORM == "PLATFORM_WINDOWS"
  end
end

return UMG_SystemSettingDropDownListltem_C
