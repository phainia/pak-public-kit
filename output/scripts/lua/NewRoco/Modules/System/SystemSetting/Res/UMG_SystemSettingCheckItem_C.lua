local SystemSettingModuleEvent = require("NewRoco.Modules.System.SystemSetting.SystemSettingModuleEvent")
local SystemSettingEnum = require("NewRoco.Modules.System.SystemSetting.SystemSettingEnum")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SystemSettingCheckItem_C = Base:Extend("UMG_SystemSettingCheckItem_C")

function UMG_SystemSettingCheckItem_C:OnConstruct()
end

function UMG_SystemSettingCheckItem_C:OnDestruct()
end

function UMG_SystemSettingCheckItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.FirstClick = false
  self.text:SetText(self.data.Name)
  self.Type = self.data.Type
end

function UMG_SystemSettingCheckItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    if not self.bHasSelected then
      if self.Type == SystemSettingEnum.Type.Fps then
        _G.NRCEventCenter:DispatchEvent(SystemSettingModuleEvent.SetFpsItemSelect, false)
      elseif self.Type == SystemSettingEnum.Type.MobileResolution then
        _G.NRCEventCenter:DispatchEvent(SystemSettingModuleEvent.SetMobileResolutionItemSelect, false)
      end
      if self.data and self.data.OnClickAnimationStartCallback then
        if self.data.OnClickAnimationStartCallbackOwner then
          self.data.OnClickAnimationStartCallback(self.data.OnClickAnimationStartCallbackOwner, self)
        else
          self.data.OnClickAnimationStartCallback(self)
        end
      end
      self:PlayAnimation(self.Click)
      _G.NRCAudioManager:PlaySound2DAuto(40007001, "UMG_SystemSettingCheckItem_C:OnItemSelected")
    end
    if not self.FirstClick and self.data and self.data.ListWidget and self.data.ListWidget.SelectValue ~= self.data.Value then
      local SuggestLevel = 0
      local CurLevel = UE4.UNRCQualityLibrary.GetUnifiedDeviceLevel()
      local Table = {}
      local Name = ""
      local Value = self.data.Value
      local QualityID = self.data.QualityID
      local ParamSet
      if QualityID then
        for i, v in ipairs(_G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.QUALITY_GROUP_SETTING_CONF):GetAllDatas()) do
          if v.id == QualityID then
            Table = v
            break
          end
        end
        if Table then
          if RocoEnv.PLATFORM ~= "PLATFORM_WINDOWS" then
            if QualityID == SystemSettingEnum.QualityID.FPS then
              Name = "FPS"
              SuggestLevel = UE4.UNRCQualityLibrary.GetCurMaxSuggestFrameQuality()
              for i, v in pairs(Table.Qualities) do
                if v.Level and v.Level == Value then
                  if SuggestLevel > v.SuggestUnifiedDeviceLevel then
                    SuggestLevel = v.SuggestUnifiedDeviceLevel
                  end
                  break
                end
              end
            elseif QualityID == SystemSettingEnum.QualityID.MobileResolution then
              Name = "MobileResolution"
              SuggestLevel = UE4.UNRCQualityLibrary.GetCurMaxSuggestMobileResolutionQuality()
              for i, v in pairs(Table.Qualities) do
                if v.Level and v.Level == Value then
                  if SuggestLevel > v.SuggestUnifiedDeviceLevel then
                    SuggestLevel = v.SuggestUnifiedDeviceLevel
                  end
                  break
                end
              end
            end
          elseif QualityID == SystemSettingEnum.QualityID.FPS then
            Name = "FPS"
          elseif QualityID == SystemSettingEnum.QualityID.MobileResolution then
            Name = "MobileResolution"
          end
          ParamSet = {}
          ParamSet.QualityId = QualityID
          ParamSet.QualityName = Table.name
          ParamSet.QualityLevel = Value
        end
      end
      
      local function Func(self, bSure)
        if bSure then
          _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.ApplyConfig, Name, Value)
          if ParamSet then
            _G.GEMPostManager:SendOptionChangeTLog(ParamSet)
          end
        else
          _G.NRCEventCenter:DispatchEvent(SystemSettingModuleEvent.RefreshDropDownList)
        end
      end
      
      if CurLevel < SuggestLevel then
        local Ctx = DialogContext()
        Ctx:SetContent(string.format(LuaText.setting_options_overloading, Table.name, self.data.Name))
        Ctx:SetMode(DialogContext.Mode.OK_CANCEL)
        Ctx:SetTitle(LuaText.player_unstuck_confirm_title)
        Ctx:SetButtonText(LuaText.tips_dialog_butten_accept, LuaText.tips_dialog_butten_cancel)
        Ctx:SetCloseFlagWhenPlayerDie()
        Ctx:SetCallback(self, Func)
        NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
      else
        Func(self, true)
      end
    end
    if self.data and self.data.OnItemSelectedCallback then
      if self.data.OnItemSelectedCallbackOwner then
        self.data.OnItemSelectedCallback(self.data.OnItemSelectedCallbackOwner, self)
      else
        self.data.OnItemSelectedCallback(self)
      end
    end
    self.FirstClick = false
  else
    self:PlayAnimation(self.Click_out)
  end
  self.bHasSelected = _bSelected
end

function UMG_SystemSettingCheckItem_C:OnAnimationFinished(anim)
  if anim == self.Click then
    if self.Type == SystemSettingEnum.Type.Fps then
      _G.NRCEventCenter:DispatchEvent(SystemSettingModuleEvent.SetFpsItemSelect, true)
    elseif self.Type == SystemSettingEnum.Type.MobileResolution then
      _G.NRCEventCenter:DispatchEvent(SystemSettingModuleEvent.SetMobileResolutionItemSelect, true)
    end
    if self.data and self.data.OnClickAnimationFinishCallback then
      if self.data.OnClickAnimationFinishCallbackOwner then
        self.data.OnClickAnimationFinishCallback(self.data.OnClickAnimationFinishCallbackOwner, self)
      else
        self.data.OnClickAnimationFinishCallback(self)
      end
    end
  end
end

function UMG_SystemSettingCheckItem_C:OnDeactive()
  self.data = nil
end

return UMG_SystemSettingCheckItem_C
