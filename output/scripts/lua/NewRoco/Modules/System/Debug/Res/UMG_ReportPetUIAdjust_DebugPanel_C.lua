local UMG_ReportPetUIAdjust_DebugPanel_C = _G.NRCPanelBase:Extend("UMG_ReportPetUIAdjust_DebugPanel_C")
local rapidjson = require("rapidjson")
local AdjustOpMode = {AdjustPetModel = 1, ConfirmTips = 2}
local AdjustOffsetAxis = {
  None = 0,
  Axis_X = 1,
  Axis_Y = 2
}

local function FormatFloat(_value)
  local formatted = string.format("%.4f", _value or 0)
  formatted = string.gsub(formatted, "0+$", "")
  formatted = string.gsub(formatted, "%.$", "")
  return formatted
end

local function FormatVector(_vector)
  return string.format("%s;%s", FormatFloat(_vector.X), FormatFloat(_vector.Y))
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnConstruct()
  self.PetUIScaleFactorValue = 0.05
  self.PetUIOffsetFactorValue = 1
  self.CurModifyAxis = AdjustOffsetAxis.None
  self.CurPetAdjust = nil
  self.IsNeedReverted = false
  self.PetAdjustChangelist = {}
  self:OnChooseModifyAxis(AdjustOffsetAxis.Axis_X, true)
  self:OnAddEventListener()
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnDestruct()
  self.CheckBoxModifyIsRevert.OnCheckStateChanged:Remove(self, self.OnClickReversedImage)
  self.CheckBoxModifyAxis_X.OnCheckStateChanged:Remove(self, self.OnChooseModifyAxis_X)
  self.CheckBoxModifyAxis_Y.OnCheckStateChanged:Remove(self, self.OnChooseModifyAxis_Y)
  self.SpecialCheckBox.OnCheckStateChanged:Remove(self, self.OnChangeBG)
  self.PetUIScaleFactor.OnTextCommitted:Remove(self, self.OnModifyScaleFactor)
  self.PetUIOffsetFactor.OnTextCommitted:Remove(self, self.OnModifyOffsetFactor)
  self.PetID.OnTextCommitted:Remove(self, self.OnPetIDChange)
  self.MutationType.OnSelectionChanged:Remove(self, self.ChangeMutationType)
  self.GlassValue.OnTextCommitted:Remove(self, self.OnGlassValueChange)
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnActive()
  self:SetAdjustOpMode(AdjustOpMode.AdjustPetModel)
  self.PetUIScaleFactor:SetText(self.PetUIScaleFactorValue)
  self.PetUIOffsetFactor:SetText(self.PetUIOffsetFactorValue)
end

function UMG_ReportPetUIAdjust_DebugPanel_C:GetPetInfo(id)
  local PetParam = {}
  PetParam.id = id
  local _petBaseCfg = _G.DataConfigManager:GetPetbaseConf(PetParam.id)
  PetParam.name = _petBaseCfg.name
  PetParam.report_res_horizontal_flip_data = _petBaseCfg.report_res_horizontal_flip_data
  local UIScale = _petBaseCfg.report_res_ui_percentage and _petBaseCfg.report_res_ui_percentage > 0 and _petBaseCfg.report_res_ui_percentage or 1
  PetParam.Scale = UIScale
  if _petBaseCfg.report_res_offset and next(_petBaseCfg.report_res_offset) then
    local offsetConf = _petBaseCfg.report_res_offset
    PetParam.report_res_offset = UE4.FVector2D(offsetConf[1] or 0, offsetConf[2] or 0)
  else
    PetParam.report_res_offset = UE4.FVector2D(0, 0)
  end
  return PetParam
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnDeactive()
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnAddEventListener()
  self.CheckBoxModifyIsRevert.OnCheckStateChanged:Add(self, self.OnClickReversedImage)
  self.CheckBoxModifyAxis_X.OnCheckStateChanged:Add(self, self.OnChooseModifyAxis_X)
  self.CheckBoxModifyAxis_Y.OnCheckStateChanged:Add(self, self.OnChooseModifyAxis_Y)
  self.SpecialCheckBox.OnCheckStateChanged:Add(self, self.OnChangeBG)
  self.PetUIScaleFactor.OnTextCommitted:Add(self, self.OnModifyScaleFactor)
  self.PetUIOffsetFactor.OnTextCommitted:Add(self, self.OnModifyOffsetFactor)
  self.PetID.OnTextCommitted:Add(self, self.OnPetIDChange)
  self.MutationType.OnSelectionChanged:Add(self, self.ChangeMutationType)
  self.GlassValue.OnTextCommitted:Add(self, self.OnGlassValueChange)
  self:AddButtonListener(self.BtnAddUIScale, self.OnClickAddUIScale)
  self:AddButtonListener(self.BtnReduceUIScale, self.OnClickReduceUIScale)
  self:AddButtonListener(self.BtnAddUIOffset, self.OnClickAddUIOffset)
  self:AddButtonListener(self.BtnReduceUIOffset, self.OnClickReduceUIOffset)
  self:AddButtonListener(self.BtnExportModifyData, self.OnClickExportModifyData)
  self:AddButtonListener(self.CloseBtn_1, self.OnClickOpenConfirmTips)
  self:AddButtonListener(self.BtnReturn, self.OnClickReturnToolPanel)
  self:AddButtonListener(self.BtnClose, self.OnClickCloseToolPanel)
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnClickReversedImage(_IsOn)
  if self.CurPetAdjust then
    local PetReportParamInfo = self.CurPetAdjust.defaultInfo and self.CurPetAdjust.newInfo
    if _IsOn then
      self.CurPetAdjust.newInfo.report_res_horizontal_flip_data = 1
    else
      self.CurPetAdjust.newInfo.report_res_horizontal_flip_data = 0
    end
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GMSetPetUIScaleAndOffsetAndImageRevert, true, PetReportParamInfo.report_res_horizontal_flip_data, PetReportParamInfo.Scale)
  end
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnChooseModifyAxis_X(_IsOn)
  self:OnChooseModifyAxis(AdjustOffsetAxis.Axis_X, _IsOn)
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnChooseModifyAxis_Y(_IsOn)
  self:OnChooseModifyAxis(AdjustOffsetAxis.Axis_Y, _IsOn)
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnModifyScaleFactor(txtContent, commitMethod)
  self.PetUIScaleFactorValue = self:ModifyFactor(self.PetUIScaleFactor, self.PetUIScaleFactorValue)
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnModifyOffsetFactor(txtContent, commitMethod)
  self.PetUIOffsetFactorValue = self:ModifyFactor(self.PetUIOffsetFactor, self.PetUIOffsetFactorValue)
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnClickAddUIScale()
  self:ModifyUIScale(true)
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnClickReduceUIScale()
  self:ModifyUIScale(false)
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnClickAddUIOffset()
  self:ModifyUIOffset(true)
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnClickReduceUIOffset()
  self:ModifyUIOffset(false)
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnChooseModifyAxis(_Axis, _IsOn)
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

function UMG_ReportPetUIAdjust_DebugPanel_C:ModifyUIScale(_Add)
  if self.CurPetAdjust then
    local PetReportParamInfo = self.CurPetAdjust and self.CurPetAdjust.newInfo
    if not PetReportParamInfo then
      self:LogError("PetReportParamInfo == nil")
      return
    end
    local ScaleFactor = _Add and self.PetUIScaleFactorValue or -self.PetUIScaleFactorValue
    PetReportParamInfo.Scale = math.max(PetReportParamInfo.Scale + ScaleFactor, 0)
    self:RefreshUI()
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GMSetPetUIScaleAndOffsetAndImageRevert, false, PetReportParamInfo.report_res_horizontal_flip_data, PetReportParamInfo.Scale, PetReportParamInfo.report_res_offset)
  end
end

function UMG_ReportPetUIAdjust_DebugPanel_C:ModifyUIOffset(_Add)
  if self.CurPetAdjust then
    local PetReportParamInfo = self.CurPetAdjust and self.CurPetAdjust.newInfo
    if not PetReportParamInfo then
      self:LogError("PetReportParamInfo == nil")
      return
    end
    if self.CurModifyAxis == AdjustOffsetAxis.None then
      self:LogError("\230\156\170\230\140\135\229\174\154\231\188\150\232\190\145\229\157\144\230\160\135\232\189\180")
      return
    end
    local OffsetFactor = _Add and self.PetUIOffsetFactorValue or -self.PetUIOffsetFactorValue
    if self.CurModifyAxis == AdjustOffsetAxis.Axis_X then
      PetReportParamInfo.CurModifyAxis = AdjustOffsetAxis.Axis_X
      PetReportParamInfo.report_res_offset.X = PetReportParamInfo.report_res_offset.X + OffsetFactor
    elseif self.CurModifyAxis == AdjustOffsetAxis.Axis_Y then
      PetReportParamInfo.CurModifyAxis = AdjustOffsetAxis.Axis_Y
      PetReportParamInfo.report_res_offset.Y = PetReportParamInfo.report_res_offset.Y + OffsetFactor
    end
    self:RefreshUI()
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GMSetPetUIScaleAndOffsetAndImageRevert, false, PetReportParamInfo.report_res_horizontal_flip_data, PetReportParamInfo.Scale, PetReportParamInfo.report_res_offset, PetReportParamInfo.CurModifyAxis)
  end
end

function UMG_ReportPetUIAdjust_DebugPanel_C:RefreshPetReportParamInfo(_NewPetReportParamInfo)
  local IsSwitchPet = true
  if self.CurPetAdjust and _NewPetReportParamInfo and self.CurPetAdjust.id == _NewPetReportParamInfo.id then
    IsSwitchPet = false
  end
  if IsSwitchPet then
    self:SavePetParamChange()
    local ExistParamChange = _NewPetReportParamInfo and _NewPetReportParamInfo.id and self.PetAdjustChangelist[_NewPetReportParamInfo.id]
    if ExistParamChange then
      self.CurPetAdjust = ExistParamChange
      local defaultParam = ExistParamChange.defaultInfo
      local newParam = ExistParamChange.newInfo
      if newParam.report_res_horizontal_flip_data ~= defaultParam.report_res_horizontal_flip_data or newParam.Scale ~= defaultParam.Scale or newParam.report_res_offset ~= defaultParam.report_res_offset then
        _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GMSetPetUIScaleAndOffsetAndImageRevert, false, newParam.report_res_horizontal_flip_data, newParam.Scale, newParam.report_res_offset, AdjustOffsetAxis.None)
      end
    else
      self.CurPetAdjust = {}
      self.CurPetAdjust.id = _NewPetReportParamInfo.id
      self.CurPetAdjust.name = _NewPetReportParamInfo.name
      self.CurPetAdjust.defaultInfo = _NewPetReportParamInfo
      self.CurPetAdjust.newInfo = {}
      self.CurPetAdjust.newInfo.id = _NewPetReportParamInfo.id
      self.CurPetAdjust.newInfo.report_res_horizontal_flip_data = _NewPetReportParamInfo.report_res_horizontal_flip_data
      self.CurPetAdjust.newInfo.Scale = _NewPetReportParamInfo.Scale
      self.CurPetAdjust.newInfo.report_res_offset = UE4.FVector2D(_NewPetReportParamInfo.report_res_offset.X, _NewPetReportParamInfo.report_res_offset.Y)
    end
  end
  self:RefreshUI()
end

function UMG_ReportPetUIAdjust_DebugPanel_C:SavePetParamChange()
  if not (self.CurPetAdjust and self.CurPetAdjust.defaultInfo) or not self.CurPetAdjust.newInfo then
    return
  end
  self.PetAdjustChangelist[self.CurPetAdjust.id] = self.CurPetAdjust
end

function UMG_ReportPetUIAdjust_DebugPanel_C:ModifyFactor(_Ctrl, _CurValue)
  if nil == _Ctrl then
    return
  end
  local InputValue = tonumber(_Ctrl:GetText())
  if nil == InputValue then
    _Ctrl:SetText(_CurValue)
  end
  return InputValue or _CurValue
end

function UMG_ReportPetUIAdjust_DebugPanel_C:RefreshUI()
  if self.CurPetAdjust then
    local PetReportParamInfo = self.CurPetAdjust and self.CurPetAdjust.newInfo
    if PetReportParamInfo then
      self.PetUIScale:SetText(PetReportParamInfo.Scale)
      self.PetUIOffset:SetText(FormatVector(PetReportParamInfo.report_res_offset))
      if 1 ~= PetReportParamInfo.report_res_horizontal_flip_data then
        self.CheckBoxModifyIsRevert:SetCheckedState(UE4.ECheckBoxState.Unchecked)
      else
        self.CheckBoxModifyIsRevert:SetCheckedState(UE4.ECheckBoxState.Checked)
      end
      self.SpecialCheckBox:SetCheckedState(UE4.ECheckBoxState.Unchecked)
    end
  end
end

local function SaveJsonFile(Filename, Table)
  local Filepath = string.format("%s%s.json", UE4.UBlueprintPathsLibrary.ProjectSavedDir(), Filename)
  Filepath = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(Filepath)
  local Content = rapidjson.encode(Table)
  local Success = UE4.UNRCStatics.WriteToFile(Filepath, Content)
  return Success, Filepath
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnClickExportModifyData()
  self:SavePetParamChange()
  local pet_base_change = {}
  for _id, _petParamChange in pairs(self.PetAdjustChangelist) do
    local defaultParam = _petParamChange.defaultInfo
    local newParam = _petParamChange.newInfo
    do
      local cur_change = {}
      if newParam.report_res_horizontal_flip_data and newParam.report_res_horizontal_flip_data ~= defaultParam.report_res_horizontal_flip_data then
        table.insert(cur_change, {
          seg = "report_res_horizontal_flip_data",
          value = newParam.report_res_horizontal_flip_data
        })
      end
      if newParam.Scale and newParam.Scale ~= defaultParam.Scale then
        table.insert(cur_change, {
          seg = "report_res_ui_percentage",
          value = newParam.Scale
        })
      end
      if newParam.report_res_offset and newParam.report_res_offset ~= defaultParam.report_res_offset then
        table.insert(cur_change, {
          seg = "report_res_offset",
          value = FormatVector(newParam.report_res_offset)
        })
      end
      if next(cur_change) then
        table.insert(pet_base_change, {
          key_name = "id",
          key_value = _id,
          changes = cur_change
        })
      end
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
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnClickOpenConfirmTips()
  self:SetAdjustOpMode(AdjustOpMode.ConfirmTips)
end

function UMG_ReportPetUIAdjust_DebugPanel_C:SetAdjustOpMode(_OpMode)
  if _OpMode == AdjustOpMode.AdjustPetModel then
    self.AdjustPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ConfirmTips:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.AdjustPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ConfirmTips:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnClickReturnToolPanel(_OpMode)
  self:SetAdjustOpMode(AdjustOpMode.AdjustPetModel)
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnClickCloseToolPanel(_OpMode)
  self:DoClose()
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnPetIDChange(txtContent, commitMethod)
  if not UE4.UNRCStatics.IsEditor() then
    return
  end
  if self.curPetID == tonumber(txtContent) then
    return
  end
  self.curPetID = tonumber(txtContent)
  local PetParam = self:GetPetInfo(tonumber(txtContent))
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GMChangePet, tonumber(txtContent))
  self:RefreshPetReportParamInfo(PetParam)
  self.MutationType:SetSelectedIndex(0)
  self.GlassValue:SetText(1)
  self.Mutation:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_ReportPetUIAdjust_DebugPanel_C:ChangeMutationType(SelectedItem, SelectionType)
  if self.curPetID then
    if 0 == self.MutationType:GetSelectedIndex() then
      _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GMChangePet, self.curPetID, nil, nil)
      self.Mutation:SetVisibility(UE4.ESlateVisibility.Collapsed)
    elseif 1 == self.MutationType:GetSelectedIndex() then
      local glass_info = {}
      glass_info.glass_type = _G.ProtoEnum.GlassType.GT_COMMON
      glass_info.glass_value = tonumber(self.GlassValue:GetText())
      _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GMChangePet, self.curPetID, _G.Enum.MutationDiffType.MDT_GLASS, glass_info)
      self.Mutation:SetVisibility(UE4.ESlateVisibility.Visible)
    elseif 2 == self.MutationType:GetSelectedIndex() then
      local glass_info = {}
      glass_info.glass_type = _G.ProtoEnum.GlassType.GT_HIDDEN
      glass_info.glass_value = tonumber(self.GlassValue:GetText())
      _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GMChangePet, self.curPetID, _G.Enum.MutationDiffType.MDT_GLASS, glass_info)
      self.Mutation:SetVisibility(UE4.ESlateVisibility.Visible)
    elseif 3 == self.MutationType:GetSelectedIndex() then
      _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GMChangePet, self.curPetID, _G.Enum.MutationDiffType.MDT_SHINING, nil)
      self.Mutation:SetVisibility(UE4.ESlateVisibility.Collapsed)
    elseif 4 == self.MutationType:GetSelectedIndex() then
      _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GMChangePet, self.curPetID, _G.Enum.MutationDiffType.MDT_CHAOS, nil)
      self.Mutation:SetVisibility(UE4.ESlateVisibility.Collapsed)
    elseif 5 == self.MutationType:GetSelectedIndex() then
      local glass_info = {}
      glass_info.glass_type = _G.ProtoEnum.GlassType.GT_COMMON
      glass_info.glass_value = tonumber(self.GlassValue:GetText())
      _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GMChangePet, self.curPetID, _G.Enum.MutationDiffType.MDT_SHINING + _G.Enum.MutationDiffType.MDT_GLASS, glass_info)
      self.Mutation:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  end
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnGlassValueChange(txtContent, commitMethod)
  self:ChangeMutationType()
end

function UMG_ReportPetUIAdjust_DebugPanel_C:OnChangeBG(_IsOn)
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GMChangePetReportBG, _IsOn)
end

return UMG_ReportPetUIAdjust_DebugPanel_C
