local HandbookModuleEnum = require("NewRoco.Modules.System.Handbook.HandbookModuleEnum")
local UMG_PetUIAdjust_DebugPanel_C = _G.NRCPanelBase:Extend("UMG_PetUIAdjust_DebugPanel_C")
local rapidjson = require("rapidjson")
local AdjustOpMode = {AdjustPetModel = 1, ConfirmTips = 2}
local AdjustOffsetAxis = {
  None = 0,
  Axis_X = 1,
  Axis_Y = 2
}

local function FormatFloat(_value)
  local formatted = string.format("%.3f", _value or 0)
  formatted = string.gsub(formatted, "0+$", "")
  formatted = string.gsub(formatted, "%.$", "")
  return tonumber(formatted)
end

local function FormatVector(_vector)
  return string.format("%s;%s", FormatFloat(_vector.X), FormatFloat(_vector.Y))
end

function UMG_PetUIAdjust_DebugPanel_C:OnConstruct()
  self.PetUIScaleFactorValue = 0.05
  self.PetUIOffsetFactorValue = 1
  self.CurModifyAxis = AdjustOffsetAxis.None
  self.CurPetAdjust = nil
  self.IsNeedReverted = false
  self.PetAdjustChangelist = {}
  self:OnChooseModifyAxis(AdjustOffsetAxis.Axis_X, true)
  self:OnAddEventListener()
end

function UMG_PetUIAdjust_DebugPanel_C:OnDestruct()
  self.CheckBoxModifyIsRevert.OnCheckStateChanged:Remove(self, self.OnClickReversedImage)
  self.CheckBoxModifyAxis_X.OnCheckStateChanged:Remove(self, self.OnChooseModifyAxis_X)
  self.CheckBoxModifyAxis_Y.OnCheckStateChanged:Remove(self, self.OnChooseModifyAxis_Y)
  self.PetUIScaleFactor.OnTextCommitted:Remove(self, self.OnModifyScaleFactor)
  self.PetUIOffsetFactor.OnTextCommitted:Remove(self, self.OnModifyOffsetFactor)
  self.CheckBoxProjection.OnCheckStateChanged:Remove(self, self.OnClickCheckBoxProjection)
  self.CheckBoxFlipHorizontal.OnCheckStateChanged:Remove(self, self.OnChooseCheckBoxFlipHorizontal)
  self.CheckBoxFlipVertical.OnCheckStateChanged:Remove(self, self.OnChooseCheckBoxFlipVertical)
  self.CheckBoxProjection_X.OnCheckStateChanged:Remove(self, self.OnCheckBoxProjection_X)
  self.CheckBoxProjection_Y.OnCheckStateChanged:Remove(self, self.OnCheckBoxProjection_Y)
  self.CharacterDesignSketch.OnCheckStateChanged:Remove(self, self.OnCharacterDesignSketch)
  self.DropShadow.OnCheckStateChanged:Remove(self, self.OnDropShadow)
  self.CharacterDesignSketch_1.OnCheckStateChanged:Remove(self, self.OnCharacterDesignSketch)
  self.DropShadow_1.OnCheckStateChanged:Remove(self, self.OnDropShadow)
  self.Scale_X.OnCheckStateChanged:Remove(self, self.OnScale_X)
  self.Scale_Y.OnCheckStateChanged:Remove(self, self.OnScale_Y)
  self:RemoveDelegateListener(self.Beveling_X.OnValueChanged, self.OnSliderValueChangedX)
  self:RemoveDelegateListener(self.Beveling_Y.OnValueChanged, self.OnSliderValueChangedY)
  self:RemoveDelegateListener(self.RenderOpacityValue.OnValueChanged, self.OnRenderOpacityValueChanged)
end

function UMG_PetUIAdjust_DebugPanel_C:OnActive()
  self:SetAdjustOpMode(AdjustOpMode.AdjustPetModel)
  self.PetUIScaleFactor:SetText(self.PetUIScaleFactorValue)
  self.PetUIOffsetFactor:SetText(self.PetUIOffsetFactorValue)
  self:RefreshPetVisualParam(_G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.GetPetVisualParam, true))
end

function UMG_PetUIAdjust_DebugPanel_C:OnDeactive()
end

function UMG_PetUIAdjust_DebugPanel_C:OnAddEventListener()
  self.CheckBoxModifyIsRevert.OnCheckStateChanged:Add(self, self.OnClickReversedImage)
  self.CheckBoxModifyAxis_X.OnCheckStateChanged:Add(self, self.OnChooseModifyAxis_X)
  self.CheckBoxModifyAxis_Y.OnCheckStateChanged:Add(self, self.OnChooseModifyAxis_Y)
  self.PetUIScaleFactor.OnTextCommitted:Add(self, self.OnModifyScaleFactor)
  self.PetUIOffsetFactor.OnTextCommitted:Add(self, self.OnModifyOffsetFactor)
  self.CheckBoxProjection.OnCheckStateChanged:Add(self, self.OnClickCheckBoxProjection)
  self.CheckBoxFlipHorizontal.OnCheckStateChanged:Add(self, self.OnChooseCheckBoxFlipHorizontal)
  self.CheckBoxFlipVertical.OnCheckStateChanged:Add(self, self.OnChooseCheckBoxFlipVertical)
  self.CheckBoxProjection_X.OnCheckStateChanged:Add(self, self.OnCheckBoxProjection_X)
  self.CheckBoxProjection_Y.OnCheckStateChanged:Add(self, self.OnCheckBoxProjection_Y)
  self.CharacterDesignSketch.OnCheckStateChanged:Add(self, self.OnCharacterDesignSketch)
  self.DropShadow.OnCheckStateChanged:Add(self, self.OnDropShadow)
  self.CharacterDesignSketch_1.OnCheckStateChanged:Add(self, self.OnCharacterDesignSketch)
  self.DropShadow_1.OnCheckStateChanged:Add(self, self.OnDropShadow)
  self.Scale_X.OnCheckStateChanged:Add(self, self.OnScale_X)
  self.Scale_Y.OnCheckStateChanged:Add(self, self.OnScale_Y)
  self:AddDelegateListener(self.Beveling_X.OnValueChanged, self.OnSliderValueChangedX)
  self:AddDelegateListener(self.Beveling_Y.OnValueChanged, self.OnSliderValueChangedY)
  self:AddDelegateListener(self.RenderOpacityValue.OnValueChanged, self.OnRenderOpacityValueChanged)
  self:AddButtonListener(self.BtnAddUIScale, self.OnClickAddUIScale)
  self:AddButtonListener(self.BtnReduceUIScale, self.OnClickReduceUIScale)
  self:AddButtonListener(self.BtnAddUIOffset, self.OnClickAddUIOffset)
  self:AddButtonListener(self.BtnReduceUIOffset, self.OnClickReduceUIOffset)
  self:AddButtonListener(self.BtnExportModifyData, self.OnClickExportModifyData)
  self:AddButtonListener(self.CloseBtn_1, self.OnClickOpenConfirmTips)
  self:AddButtonListener(self.BtnReturn, self.OnClickReturnToolPanel)
  self:AddButtonListener(self.BtnClose, self.OnClickCloseToolPanel)
  self:AddButtonListener(self.BtnExportModifyData_3, self.OnClickBtnExportModifyData_3)
  self:AddButtonListener(self.BtnExportModifyData_2, self.OnClickBtnExportModifyData_2)
  self:AddButtonListener(self.BtnExportModifyData_1, self.OnClickBtnExportModifyData_1)
  self:AddButtonListener(self.BtnAddProjectionOffset, self.OnClickBtnAddProjectionOffset)
  self:AddButtonListener(self.BtnReduceProjectionOffset, self.OnClickBtnReduceProjectionOffset)
  self:AddButtonListener(self.BtnAddProjectionScale, self.OnClickBtnAddProjectionScale)
  self:AddButtonListener(self.BtnReduceProjectionScale, self.OnClickBtnReduceProjectionScale)
end

function UMG_PetUIAdjust_DebugPanel_C:OnClickReversedImage(_IsOn)
  local PetVisualParam = self.CurPetAdjust.defaultInfo and self.CurPetAdjust.newInfo
  if 1 ~= PetVisualParam.res_horizontal_flip_data then
    self.CurPetAdjust.newInfo.res_horizontal_flip_data = 1
  else
    self.CurPetAdjust.newInfo.res_horizontal_flip_data = 0
  end
  _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.SetPetUIScaleAndOffsetAndImageRevert, true, PetVisualParam.res_horizontal_flip_data, PetVisualParam.Scale)
end

function UMG_PetUIAdjust_DebugPanel_C:OnChooseModifyAxis_X(_IsOn)
  self:OnChooseModifyAxis(AdjustOffsetAxis.Axis_X, _IsOn)
end

function UMG_PetUIAdjust_DebugPanel_C:OnChooseModifyAxis_Y(_IsOn)
  self:OnChooseModifyAxis(AdjustOffsetAxis.Axis_Y, _IsOn)
end

function UMG_PetUIAdjust_DebugPanel_C:OnModifyScaleFactor(txtContent, commitMethod)
  self.PetUIScaleFactorValue = self:ModifyFactor(self.PetUIScaleFactor, self.PetUIScaleFactorValue)
end

function UMG_PetUIAdjust_DebugPanel_C:OnModifyOffsetFactor(txtContent, commitMethod)
end

function UMG_PetUIAdjust_DebugPanel_C:OnClickAddUIScale()
  self:ModifyUIScale(true)
end

function UMG_PetUIAdjust_DebugPanel_C:OnClickReduceUIScale()
  self:ModifyUIScale(false)
end

function UMG_PetUIAdjust_DebugPanel_C:OnClickAddUIOffset()
  self:ModifyUIOffset(true)
end

function UMG_PetUIAdjust_DebugPanel_C:OnClickReduceUIOffset()
  self:ModifyUIOffset(false)
end

function UMG_PetUIAdjust_DebugPanel_C:OnChooseModifyAxis(_Axis, _IsOn)
  if not _IsOn then
    self.CurModifyAxis = AdjustOffsetAxis.None
    return
  end
  local AxisToCtrl = {
    [AdjustOffsetAxis.Axis_X] = self.CheckBoxModifyAxis_X,
    [AdjustOffsetAxis.Axis_Y] = self.CheckBoxModifyAxis_Y
  }
  self.CurModifyAxis = _Axis
  for _TmpAxis, _TmpCtrl in pairs(AxisToCtrl) do
    _TmpCtrl:SetIsChecked(_TmpAxis == _Axis)
  end
end

function UMG_PetUIAdjust_DebugPanel_C:ModifyUIScale(_Add)
  local PetVisualParam = self.CurPetAdjust and self.CurPetAdjust.newInfo
  if not PetVisualParam then
    self:LogError("PetVisualParam == nil")
    return
  end
  local ScaleFactor = _Add and self.PetUIScaleFactorValue or -self.PetUIScaleFactorValue
  PetVisualParam.Scale = math.max(PetVisualParam.Scale + ScaleFactor, 0)
  self:RefreshUI()
  _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.SetPetUIScaleAndOffsetAndImageRevert, false, PetVisualParam.res_horizontal_flip_data, PetVisualParam.Scale, PetVisualParam.res_offset)
end

function UMG_PetUIAdjust_DebugPanel_C:ModifyUIOffset(_Add)
  local PetVisualParam = self.CurPetAdjust and self.CurPetAdjust.newInfo
  if not PetVisualParam then
    self:LogError("PetVisualParam == nil")
    return
  end
  if self.CurModifyAxis == AdjustOffsetAxis.None then
    self:LogError("\230\156\170\230\140\135\229\174\154\231\188\150\232\190\145\229\157\144\230\160\135\232\189\180")
    return
  end
  local OffsetFactor = _Add and tonumber(self.PetUIOffsetFactor:GetText()) or -tonumber(self.PetUIOffsetFactor:GetText())
  if self.CurModifyAxis == AdjustOffsetAxis.Axis_X then
    PetVisualParam.CurModifyAxis = AdjustOffsetAxis.Axis_X
    PetVisualParam.res_offset.X = PetVisualParam.res_offset.X + OffsetFactor
  elseif self.CurModifyAxis == AdjustOffsetAxis.Axis_Y then
    PetVisualParam.CurModifyAxis = AdjustOffsetAxis.Axis_Y
    PetVisualParam.res_offset.Y = PetVisualParam.res_offset.Y + OffsetFactor
  end
  self:RefreshUI()
  _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.SetPetUIScaleAndOffsetAndImageRevert, false, PetVisualParam.res_horizontal_flip_data, PetVisualParam.Scale, PetVisualParam.res_offset, PetVisualParam.CurModifyAxis)
end

function UMG_PetUIAdjust_DebugPanel_C:RefreshPetVisualParam(_NewPetVisualParam)
  self:SavePetParamChange()
  local ExistParamChange = _NewPetVisualParam and _NewPetVisualParam.id and self.PetAdjustChangelist[_NewPetVisualParam.id]
  if ExistParamChange then
    self.CurPetAdjust = ExistParamChange
    local defaultParam = ExistParamChange.defaultInfo
    local newParam = ExistParamChange.newInfo
    if newParam.res_horizontal_flip_data ~= defaultParam.res_horizontal_flip_data or newParam.Scale ~= defaultParam.Scale or newParam.res_offset ~= defaultParam.res_offset then
      _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.SetPetUIScaleAndOffsetAndImageRevert, false, newParam.res_horizontal_flip_data, newParam.Scale, newParam.res_offset, AdjustOffsetAxis.None)
    end
    self:UpdateProjectionIconInfo(newParam, defaultParam)
  else
    self.CurPetAdjust = {}
    self.CurPetAdjust.id = _NewPetVisualParam.id
    self.CurPetAdjust.name = _NewPetVisualParam.name
    self.CurPetAdjust.defaultInfo = _NewPetVisualParam
    self.CurPetAdjust.newInfo = {}
    self.CurPetAdjust.newInfo.id = _NewPetVisualParam.id
    self.CurPetAdjust.newInfo.res_horizontal_flip_data = _NewPetVisualParam.res_horizontal_flip_data
    self.CurPetAdjust.newInfo.Scale = _NewPetVisualParam.Scale
    local res_offset = UE4.FVector2D(_NewPetVisualParam.res_offset.X, _NewPetVisualParam.res_offset.Y)
    self.CurPetAdjust.newInfo.res_offset = res_offset
    local shadow_offset = UE4.FVector2D(_NewPetVisualParam.shadow_offset.X, _NewPetVisualParam.shadow_offset.Y)
    local shadow_angle = UE4.FVector2D(_NewPetVisualParam.shadow_angle.X, _NewPetVisualParam.shadow_angle.Y)
    local shadow_ui_percentage = UE4.FVector2D(FormatFloat(_NewPetVisualParam.shadow_ui_percentage.X), FormatFloat(_NewPetVisualParam.shadow_ui_percentage.Y))
    self.CurPetAdjust.newInfo.is_display_shadow = _NewPetVisualParam.is_display_shadow
    self.CurPetAdjust.newInfo.shadow_horizontal_flip_data = _NewPetVisualParam.shadow_horizontal_flip_data
    self.CurPetAdjust.newInfo.shadow_vertical_flip_data = _NewPetVisualParam.shadow_vertical_flip_data
    self.CurPetAdjust.newInfo.shadow_ui_percentage = shadow_ui_percentage
    self.CurPetAdjust.newInfo.shadow_offset = shadow_offset
    self.CurPetAdjust.newInfo.shadow_angle = shadow_angle
    self.CurPetAdjust.newInfo.shadow_opacity = _NewPetVisualParam.shadow_opacity
  end
  self:RefreshUI()
  self:RefreshNewUI()
end

function UMG_PetUIAdjust_DebugPanel_C:SavePetParamChange()
  if not (self.CurPetAdjust and self.CurPetAdjust.defaultInfo) or not self.CurPetAdjust.newInfo then
    return
  end
  self.PetAdjustChangelist[self.CurPetAdjust.id] = self.CurPetAdjust
end

function UMG_PetUIAdjust_DebugPanel_C:ModifyFactor(_Ctrl, _CurValue)
  if nil == _Ctrl then
    return
  end
  local InputValue = tonumber(_Ctrl:GetText())
  if nil == InputValue then
    _Ctrl:SetText(_CurValue)
  end
  return InputValue or _CurValue
end

function UMG_PetUIAdjust_DebugPanel_C:RefreshUI()
  local PetVisualParam = self.CurPetAdjust and self.CurPetAdjust.newInfo
  if PetVisualParam then
    self.PetUIScale:SetText(PetVisualParam.Scale)
    self.PetUIOffset:SetText(FormatVector(PetVisualParam.res_offset))
    self.CheckBoxModifyIsRevert:SetIsChecked(1 == PetVisualParam.res_horizontal_flip_data and true or false)
  end
end

function UMG_PetUIAdjust_DebugPanel_C:RefreshNewUI()
  local PetVisualParam = self.CurPetAdjust and self.CurPetAdjust.newInfo
  if PetVisualParam then
    self.CheckBoxProjection:SetIsChecked(1 == PetVisualParam.is_display_shadow and true or false)
    self.CheckBoxFlipHorizontal:SetIsChecked(1 == PetVisualParam.shadow_horizontal_flip_data and true or false)
    self.CheckBoxFlipVertical:SetIsChecked(1 == PetVisualParam.shadow_vertical_flip_data and true or false)
    self.PetProjectionScale:SetText(string.format("%.3f:%.3f", PetVisualParam.shadow_ui_percentage.X, PetVisualParam.shadow_ui_percentage.Y))
    self.PetProjectionOffset:SetText(string.format("%d:%d", PetVisualParam.shadow_offset.X, PetVisualParam.shadow_offset.Y))
    self.BevelingOffsetX:SetText(PetVisualParam.shadow_angle.X)
    self.Beveling_X:SetValue(PetVisualParam.shadow_angle.X)
    self.BevelingOffsetY:SetText(PetVisualParam.shadow_angle.Y)
    self.Beveling_Y:SetValue(PetVisualParam.shadow_angle.Y)
    self.RenderOpacityOffset:SetText(PetVisualParam.shadow_opacity)
    self.RenderOpacityValue:SetValue(PetVisualParam.shadow_opacity)
  end
end

function UMG_PetUIAdjust_DebugPanel_C:RefreshOffsetInfo(_Param)
  if self:GetCharacterDesignSketchIsChecked() then
    self.CurPetAdjust.newInfo.res_offset = _Param
    self.PetUIOffset:SetText(FormatVector(_Param))
  else
    self.CurPetAdjust.newInfo.shadow_offset = _Param
    self:SetPetProjectionOffset()
  end
end

local function SaveJsonFile(Filename, Table)
  local Filepath = string.format("%s%s.json", UE4.UBlueprintPathsLibrary.ProjectSavedDir(), Filename)
  Filepath = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(Filepath)
  local Content = rapidjson.encode(Table)
  local Success = UE4.UNRCStatics.WriteToFile(Filepath, Content)
  return Success, Filepath
end

function UMG_PetUIAdjust_DebugPanel_C:OnClickExportModifyData()
  self:SavePetParamChange()
  local pet_base_change = {}
  for _id, _petParamChange in pairs(self.PetAdjustChangelist) do
    local defaultParam = _petParamChange.defaultInfo
    local newParam = _petParamChange.newInfo
    local _PetBaseConf = _G.DataConfigManager:GetPetbaseConf(_petParamChange.id)
    local PetBaseConf = _G.BinDataUtils.BinDataUnboxing(_PetBaseConf, true)
    local cur_change = {}
    if newParam.res_horizontal_flip_data and newParam.res_horizontal_flip_data ~= defaultParam.res_horizontal_flip_data then
      table.insert(cur_change, {
        seg = "res_horizontal_flip_data",
        value = newParam.res_horizontal_flip_data
      })
      PetBaseConf.res_horizontal_flip_data = newParam.res_horizontal_flip_data
    end
    if newParam.Scale and newParam.Scale ~= defaultParam.Scale then
      table.insert(cur_change, {
        seg = "res_ui_percentage",
        value = newParam.Scale
      })
      PetBaseConf.Scale = newParam.Scale
    end
    if newParam.res_offset and newParam.res_offset ~= defaultParam.res_offset then
      table.insert(cur_change, {
        seg = "res_offset",
        value = FormatVector(newParam.res_offset)
      })
      PetBaseConf.res_offset = {
        FormatFloat(newParam.res_offset.X),
        FormatFloat(newParam.res_offset.Y)
      }
    end
    if newParam.is_display_shadow and newParam.is_display_shadow ~= defaultParam.is_display_shadow then
      table.insert(cur_change, {
        seg = "is_display_shadow",
        value = newParam.is_display_shadow
      })
      PetBaseConf.is_display_shadow = newParam.is_display_shadow
    end
    if newParam.shadow_horizontal_flip_data and newParam.shadow_horizontal_flip_data ~= defaultParam.shadow_horizontal_flip_data then
      table.insert(cur_change, {
        seg = "shadow_horizontal_flip_data",
        value = newParam.is_display_shadow
      })
      PetBaseConf.shadow_horizontal_flip_data = newParam.shadow_horizontal_flip_data
    end
    if newParam.shadow_vertical_flip_data and newParam.shadow_vertical_flip_data ~= defaultParam.shadow_vertical_flip_data then
      table.insert(cur_change, {
        seg = "shadow_vertical_flip_data",
        value = newParam.shadow_vertical_flip_data
      })
      PetBaseConf.shadow_vertical_flip_data = newParam.shadow_vertical_flip_data
    end
    if newParam.shadow_ui_percentage and newParam.shadow_ui_percentage ~= defaultParam.shadow_ui_percentage then
      table.insert(cur_change, {
        seg = "shadow_ui_percentage",
        value = FormatVector(newParam.shadow_ui_percentage)
      })
      PetBaseConf.shadow_ui_percentage = {
        FormatFloat(newParam.shadow_ui_percentage.X),
        FormatFloat(newParam.shadow_ui_percentage.Y)
      }
    end
    if newParam.shadow_offset and newParam.shadow_offset ~= defaultParam.shadow_offset then
      table.insert(cur_change, {
        seg = "shadow_offset",
        value = FormatVector(newParam.shadow_offset)
      })
      PetBaseConf.shadow_offset = {
        FormatFloat(newParam.shadow_offset.X),
        FormatFloat(newParam.shadow_offset.Y)
      }
    end
    if newParam.shadow_angle and newParam.shadow_angle ~= defaultParam.shadow_angle then
      table.insert(cur_change, {
        seg = "shadow_angle",
        value = FormatVector(newParam.shadow_angle)
      })
      PetBaseConf.shadow_angle = {
        FormatFloat(newParam.shadow_angle.X),
        FormatFloat(newParam.shadow_angle.Y)
      }
    end
    if newParam.shadow_opacity and newParam.shadow_opacity ~= defaultParam.shadow_opacity then
      table.insert(cur_change, {
        seg = "shadow_opacity",
        value = newParam.shadow_opacity
      })
      PetBaseConf.shadow_opacity = newParam.shadow_opacity
    end
    if next(cur_change) then
      table.insert(pet_base_change, {
        key_name = "id",
        key_value = _id,
        changes = cur_change
      })
    end
    local npcTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.PETBASE_CONF)
    npcTable:SaveData(_petParamChange.id, PetBaseConf)
  end
  if next(pet_base_change) then
    local Success, Filepath = SaveJsonFile("pet_base_change", pet_base_change)
    if Success then
      UE.UNRCStatics.ExecConsoleCommand(string.format("py update_conf.py %s %s %s", "pet", "PETBASE_CONF.yaml", Filepath))
    else
      self:LogError("\229\134\153\229\133\165\229\143\152\230\155\180\233\133\141\231\189\174\229\136\176pet_base_change\229\164\177\232\180\165!")
    end
  end
end

function UMG_PetUIAdjust_DebugPanel_C:OnClickOpenConfirmTips()
  self:SetAdjustOpMode(AdjustOpMode.ConfirmTips)
end

function UMG_PetUIAdjust_DebugPanel_C:SetAdjustOpMode(_OpMode)
  if _OpMode == AdjustOpMode.AdjustPetModel then
    self.AdjustPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ConfirmTips:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.AdjustPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ConfirmTips:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_PetUIAdjust_DebugPanel_C:OnClickReturnToolPanel(_OpMode)
  self:SetAdjustOpMode(AdjustOpMode.AdjustPetModel)
end

function UMG_PetUIAdjust_DebugPanel_C:OnClickCloseToolPanel(_OpMode)
  self:DoClose()
  _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.GetPetVisualParam, false)
end

function UMG_PetUIAdjust_DebugPanel_C:OnClickCheckBoxProjection()
  local PetVisualParam = self.CurPetAdjust.defaultInfo and self.CurPetAdjust.newInfo
  if 1 ~= PetVisualParam.is_display_shadow then
    self.CurPetAdjust.newInfo.is_display_shadow = 1
  else
    self.CurPetAdjust.newInfo.is_display_shadow = 0
  end
  _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.SetUIParamByOperationType, HandbookModuleEnum.UIEditorOperationType.is_display_shadow, self.CurPetAdjust.newInfo.is_display_shadow)
end

function UMG_PetUIAdjust_DebugPanel_C:OnChooseCheckBoxFlipHorizontal()
  local PetVisualParam = self.CurPetAdjust.defaultInfo and self.CurPetAdjust.newInfo
  if 1 ~= PetVisualParam.shadow_horizontal_flip_data then
    self.CurPetAdjust.newInfo.shadow_horizontal_flip_data = 1
  else
    self.CurPetAdjust.newInfo.shadow_horizontal_flip_data = 0
  end
  _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.SetUIParamByOperationType, HandbookModuleEnum.UIEditorOperationType.shadow_horizontal_flip_data, self.CurPetAdjust.newInfo.shadow_horizontal_flip_data)
end

function UMG_PetUIAdjust_DebugPanel_C:OnChooseCheckBoxFlipVertical()
  local PetVisualParam = self.CurPetAdjust.defaultInfo and self.CurPetAdjust.newInfo
  if 1 ~= PetVisualParam.shadow_vertical_flip_data then
    self.CurPetAdjust.newInfo.shadow_vertical_flip_data = 1
  else
    self.CurPetAdjust.newInfo.shadow_vertical_flip_data = 0
  end
  _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.SetUIParamByOperationType, HandbookModuleEnum.UIEditorOperationType.shadow_vertical_flip_data, self.CurPetAdjust.newInfo.shadow_vertical_flip_data)
end

function UMG_PetUIAdjust_DebugPanel_C:OnCheckBoxProjection_X()
  if self.CheckBoxProjection_X:IsChecked() then
    self.CheckBoxProjection_Y:SetIsChecked(false)
  end
end

function UMG_PetUIAdjust_DebugPanel_C:OnCheckBoxProjection_Y()
  if self.CheckBoxProjection_Y:IsChecked() then
    self.CheckBoxProjection_X:SetIsChecked(false)
  end
end

function UMG_PetUIAdjust_DebugPanel_C:OnCharacterDesignSketch()
  if self.CharacterDesignSketch:IsChecked() or self.CharacterDesignSketch_1:IsChecked() then
    self.DropShadow:SetIsChecked(false)
    self.DropShadow_1:SetIsChecked(false)
    self.CharacterDesignSketch:SetIsChecked(true)
    self.CharacterDesignSketch_1:SetIsChecked(true)
  end
end

function UMG_PetUIAdjust_DebugPanel_C:OnDropShadow()
  if self.DropShadow:IsChecked() or self.DropShadow_1:IsChecked() then
    self.CharacterDesignSketch:SetIsChecked(false)
    self.CharacterDesignSketch_1:SetIsChecked(false)
    self.DropShadow:SetIsChecked(true)
    self.DropShadow_1:SetIsChecked(true)
  end
end

function UMG_PetUIAdjust_DebugPanel_C:OnScale_X()
  if self.Scale_X:IsChecked() then
    self.Scale_Y:SetIsChecked(false)
  end
end

function UMG_PetUIAdjust_DebugPanel_C:OnScale_Y()
  if self.Scale_Y:IsChecked() then
    self.Scale_X:SetIsChecked(false)
  end
end

function UMG_PetUIAdjust_DebugPanel_C:GetCharacterDesignSketchIsChecked()
  return self.CharacterDesignSketch:IsChecked()
end

function UMG_PetUIAdjust_DebugPanel_C:OnClickBtnReduceProjectionScale()
  local IsScale_X = self.Scale_X:IsChecked()
  local IsScale_Y = self.Scale_Y:IsChecked()
  local PetVisualParam = self.CurPetAdjust.defaultInfo and self.CurPetAdjust.newInfo
  if PetVisualParam.shadow_ui_percentage then
    local a = tonumber(string.format("%.3f", tonumber(self.PetProjectionScaleFactor:GetText())))
    if IsScale_X then
      self.CurPetAdjust.newInfo.shadow_ui_percentage.X = self.CurPetAdjust.newInfo.shadow_ui_percentage.X - a
    end
    if IsScale_Y then
      self.CurPetAdjust.newInfo.shadow_ui_percentage.Y = self.CurPetAdjust.newInfo.shadow_ui_percentage.Y - a
    end
    self:SetPetProjectionScale()
    _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.SetUIParamByOperationType, HandbookModuleEnum.UIEditorOperationType.shadow_ui_percentage, self:GetNewProjectionScale())
  end
end

function UMG_PetUIAdjust_DebugPanel_C:OnClickBtnAddProjectionScale()
  local IsScale_X = self.Scale_X:IsChecked()
  local IsScale_Y = self.Scale_Y:IsChecked()
  local PetVisualParam = self.CurPetAdjust.defaultInfo and self.CurPetAdjust.newInfo
  if PetVisualParam.shadow_ui_percentage then
    if IsScale_X then
      self.CurPetAdjust.newInfo.shadow_ui_percentage.X = self.CurPetAdjust.newInfo.shadow_ui_percentage.X + tonumber(string.format("%.3f", tonumber(self.PetProjectionScaleFactor:GetText())))
    end
    if IsScale_Y then
      self.CurPetAdjust.newInfo.shadow_ui_percentage.Y = self.CurPetAdjust.newInfo.shadow_ui_percentage.Y + tonumber(string.format("%.3f", tonumber(self.PetProjectionScaleFactor:GetText())))
    end
    self:SetPetProjectionScale()
    _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.SetUIParamByOperationType, HandbookModuleEnum.UIEditorOperationType.shadow_ui_percentage, self:GetNewProjectionScale())
  end
end

function UMG_PetUIAdjust_DebugPanel_C:OnClickBtnReduceProjectionOffset()
  local IsChecked_X = self.CheckBoxProjection_X:IsChecked()
  local IsChecked_Y = self.CheckBoxProjection_Y:IsChecked()
  local PetVisualParam = self.CurPetAdjust.defaultInfo and self.CurPetAdjust.newInfo
  if PetVisualParam.shadow_offset then
    if IsChecked_X then
      self.CurPetAdjust.newInfo.shadow_offset.X = self.CurPetAdjust.newInfo.shadow_offset.X - tonumber(string.format("%.3f", tonumber(self.PetProjectionOffsetFactor:GetText())))
    end
    if IsChecked_Y then
      self.CurPetAdjust.newInfo.shadow_offset.Y = self.CurPetAdjust.newInfo.shadow_offset.Y - tonumber(string.format("%.3f", tonumber(self.PetProjectionOffsetFactor:GetText())))
    end
    self:SetPetProjectionOffset()
    _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.SetUIParamByOperationType, HandbookModuleEnum.UIEditorOperationType.shadow_offset, self.CurPetAdjust.newInfo.shadow_offset)
  end
end

function UMG_PetUIAdjust_DebugPanel_C:OnClickBtnAddProjectionOffset()
  local IsChecked_X = self.CheckBoxProjection_X:IsChecked()
  local IsChecked_Y = self.CheckBoxProjection_Y:IsChecked()
  local PetVisualParam = self.CurPetAdjust.defaultInfo and self.CurPetAdjust.newInfo
  if PetVisualParam.shadow_offset then
    if IsChecked_X then
      self.CurPetAdjust.newInfo.shadow_offset.X = self.CurPetAdjust.newInfo.shadow_offset.X + tonumber(string.format("%.3f", tonumber(self.PetProjectionOffsetFactor:GetText())))
    end
    if IsChecked_Y then
      self.CurPetAdjust.newInfo.shadow_offset.Y = self.CurPetAdjust.newInfo.shadow_offset.Y + tonumber(string.format("%.3f", tonumber(self.PetProjectionOffsetFactor:GetText())))
    end
    self:SetPetProjectionOffset()
    _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.SetUIParamByOperationType, HandbookModuleEnum.UIEditorOperationType.shadow_offset, self.CurPetAdjust.newInfo.shadow_offset)
  end
end

function UMG_PetUIAdjust_DebugPanel_C:OnClickBtnExportModifyData_1()
  self.AdjustPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.NewAdjustPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.DropShadow_1:SetIsChecked(false)
  self.CharacterDesignSketch_1:SetIsChecked(true)
  self.CharacterDesignSketch:SetIsChecked(true)
end

function UMG_PetUIAdjust_DebugPanel_C:OnClickBtnExportModifyData_2()
  self:OnClickExportModifyData()
end

function UMG_PetUIAdjust_DebugPanel_C:OnClickBtnExportModifyData_3()
  self.AdjustPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NewAdjustPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.DropShadow:SetIsChecked(true)
  self.CharacterDesignSketch:SetIsChecked(false)
end

function UMG_PetUIAdjust_DebugPanel_C:OnSliderValueChangedX(value)
  local PetVisualParam = self.CurPetAdjust.defaultInfo and self.CurPetAdjust.newInfo
  if PetVisualParam.shadow_angle then
    self.CurPetAdjust.newInfo.shadow_angle.X = math.floor(value)
    self:SetBevelingOffsetX()
    _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.SetUIParamByOperationType, HandbookModuleEnum.UIEditorOperationType.shadow_angle, self.CurPetAdjust.newInfo.shadow_angle)
  end
end

function UMG_PetUIAdjust_DebugPanel_C:OnSliderValueChangedY(value)
  local PetVisualParam = self.CurPetAdjust.defaultInfo and self.CurPetAdjust.newInfo
  if PetVisualParam.shadow_angle then
    self.CurPetAdjust.newInfo.shadow_angle.Y = math.floor(value)
    self:SetBevelingOffsetY()
    _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.SetUIParamByOperationType, HandbookModuleEnum.UIEditorOperationType.shadow_angle, self.CurPetAdjust.newInfo.shadow_angle)
  end
end

function UMG_PetUIAdjust_DebugPanel_C:OnRenderOpacityValueChanged(value)
  local PetVisualParam = self.CurPetAdjust.defaultInfo and self.CurPetAdjust.newInfo
  if PetVisualParam.shadow_opacity then
    self.CurPetAdjust.newInfo.shadow_opacity = tonumber(string.format("%.3f", value))
    self:SetRenderOpacityValue()
    _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.SetUIParamByOperationType, HandbookModuleEnum.UIEditorOperationType.shadow_opacity, self.CurPetAdjust.newInfo.shadow_opacity)
  end
end

function UMG_PetUIAdjust_DebugPanel_C:SetPetProjectionScale()
  self.PetProjectionScale:SetText(string.format("%.3f:%.3f", self.CurPetAdjust.newInfo.shadow_ui_percentage.X, self.CurPetAdjust.newInfo.shadow_ui_percentage.Y))
end

function UMG_PetUIAdjust_DebugPanel_C:SetPetProjectionOffset()
  self.PetProjectionOffset:SetText(string.format("%d:%d", self.CurPetAdjust.newInfo.shadow_offset.X, self.CurPetAdjust.newInfo.shadow_offset.Y))
end

function UMG_PetUIAdjust_DebugPanel_C:SetBevelingOffsetX()
  self.BevelingOffsetX:SetText(self.CurPetAdjust.newInfo.shadow_angle.X)
end

function UMG_PetUIAdjust_DebugPanel_C:SetBevelingOffsetY()
  self.BevelingOffsetY:SetText(self.CurPetAdjust.newInfo.shadow_angle.Y)
end

function UMG_PetUIAdjust_DebugPanel_C:SetRenderOpacityValue()
  self.RenderOpacityOffset:SetText(self.CurPetAdjust.newInfo.shadow_opacity)
end

function UMG_PetUIAdjust_DebugPanel_C:GetNewProjectionScale()
  local NewScale = UE4.FVector2D(self.CurPetAdjust.newInfo.shadow_ui_percentage.X, self.CurPetAdjust.newInfo.shadow_ui_percentage.Y)
  local IsChecked_X = self.CheckBoxFlipHorizontal:IsChecked()
  local IsChecked_Y = self.CheckBoxFlipVertical:IsChecked()
  if IsChecked_X then
    NewScale.X = -NewScale.X
  end
  if IsChecked_Y then
    NewScale.Y = -NewScale.Y
  end
  return NewScale
end

function UMG_PetUIAdjust_DebugPanel_C:UpdateProjectionIconInfo(newParam, defaultParam)
  if newParam.is_display_shadow ~= defaultParam.is_display_shadow or newParam.shadow_horizontal_flip_data ~= defaultParam.shadow_horizontal_flip_data or newParam.shadow_vertical_flip_data ~= defaultParam.shadow_vertical_flip_data or newParam.shadow_ui_percentage ~= defaultParam.shadow_ui_percentage or newParam.shadow_offset ~= defaultParam.shadow_offset or newParam.shadow_angle ~= defaultParam.shadow_angle or newParam.shadow_opacity ~= defaultParam.shadow_opacity then
    _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.UpdateProjectionIconInfo, newParam)
  end
end

return UMG_PetUIAdjust_DebugPanel_C
