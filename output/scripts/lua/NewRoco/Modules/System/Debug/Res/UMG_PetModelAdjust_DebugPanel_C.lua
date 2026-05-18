local UMG_PetModelAdjust_DebugPanel_C = _G.NRCPanelBase:Extend("UMG_PetModelAdjust_DebugPanel_C")
local rapidjson = require("rapidjson")
local AdjustOpMode = {AdjustPetModel = 1, DrawLine = 2}
local AdjustOffsetAxis = {
  None = 0,
  Axis_X = 1,
  Axis_Y = 2,
  Axis_Z = 3
}

local function FormatFloat(_value)
  local formatted = string.format("%.4f", _value or 0)
  formatted = string.gsub(formatted, "0+$", "")
  formatted = string.gsub(formatted, "%.$", "")
  return formatted
end

local function FormatVector(_vector)
  return string.format("%s;%s;%s", FormatFloat(_vector.X), FormatFloat(_vector.Y), FormatFloat(_vector.Z))
end

function UMG_PetModelAdjust_DebugPanel_C:OnConstruct()
  self.PetModelScaleFactorValue = 0.05
  self.PetModelOffsetFactorValue = 1
  self.CurModifyAxis = AdjustOffsetAxis.None
  self.CurPetAdjust = nil
  self.PetAdjustChangelist = {}
  self.CheckBoxModifyAxis_X.OnCheckStateChanged:Add(self, self.OnChooseModifyAxis_X)
  self.CheckBoxModifyAxis_Y.OnCheckStateChanged:Add(self, self.OnChooseModifyAxis_Y)
  self.CheckBoxModifyAxis_Z.OnCheckStateChanged:Add(self, self.OnChooseModifyAxis_Z)
  self.PetModelScaleFactor.OnTextCommitted:Add(self, self.OnModifyScaleFactor)
  self.PetModelOffsetFactor.OnTextCommitted:Add(self, self.OnModifyOffsetFactor)
  self:AddButtonListener(self.BtnReduceModelScale, self.OnClickReduceModelScale)
  self:AddButtonListener(self.BtnAddModelScale, self.OnClickAddModelScale)
  self:AddButtonListener(self.BtnReduceModelOffset, self.OnClickReduceModelOffset)
  self:AddButtonListener(self.BtnAddModelOffset, self.OnClickAddModelOffset)
  self:AddButtonListener(self.BtnAddAnimToBlackList, self.OnClickAddAnimToBlackList)
  self:AddButtonListener(self.BtnOpenDrawLine, self.OnClickOpenDrawLine)
  self:AddButtonListener(self.BtnExportModifyData, self.OnClickExportModifyData)
  self:AddButtonListener(self.BtnCancelDrawLine, self.OnClickCancelDrawLine)
  self:AddButtonListener(self.BtnSaveDrawLine, self.OnClickSaveDrawLine)
end

function UMG_PetModelAdjust_DebugPanel_C:OnDestruct()
  self.CheckBoxModifyAxis_X.OnCheckStateChanged:Remove(self, self.OnChooseModifyAxis_X)
  self.CheckBoxModifyAxis_Y.OnCheckStateChanged:Remove(self, self.OnChooseModifyAxis_Y)
  self.CheckBoxModifyAxis_Z.OnCheckStateChanged:Remove(self, self.OnChooseModifyAxis_Z)
  self.PetModelScaleFactor.OnTextCommitted:Remove(self, self.OnModifyScaleFactor)
  self.PetModelOffsetFactor.OnTextCommitted:Remove(self, self.OnModifyOffsetFactor)
end

function UMG_PetModelAdjust_DebugPanel_C:OnActive()
  self:OnChooseModifyAxis(AdjustOffsetAxis.Axis_Z, true)
  self:SetAdjustOpMode(AdjustOpMode.AdjustPetModel)
  self.PetModelScaleFactor:SetText(self.PetModelScaleFactorValue)
  self.PetModelOffsetFactor:SetText(self.PetModelOffsetFactorValue)
  self:RefreshPetVisualParam(_G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GetPetVisualParam))
end

function UMG_PetModelAdjust_DebugPanel_C:OnDeactive()
end

function UMG_PetModelAdjust_DebugPanel_C:SavePetParamChange()
  if not (self.CurPetAdjust and self.CurPetAdjust.defaultInfo) or not self.CurPetAdjust.newInfo then
    return
  end
  self.PetAdjustChangelist[self.CurPetAdjust.id] = self.CurPetAdjust
end

function UMG_PetModelAdjust_DebugPanel_C:RefreshPetVisualParam(_NewPetVisualParam)
  local IsSwitchPet = true
  if self.CurPetAdjust and _NewPetVisualParam and self.CurPetAdjust.id == _NewPetVisualParam.id then
    IsSwitchPet = false
  end
  if IsSwitchPet then
    self:SavePetParamChange()
    local ExistParamChange = _NewPetVisualParam and _NewPetVisualParam.id and self.PetAdjustChangelist[_NewPetVisualParam.id]
    if ExistParamChange then
      self.CurPetAdjust = ExistParamChange
      local defaultParam = ExistParamChange.defaultInfo
      local newParam = ExistParamChange.newInfo
      if newParam.Scale ~= defaultParam.Scale or newParam.capsule_offset ~= defaultParam.capsule_offset then
        _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.SetPetModelScaleAndOffset, newParam.Scale, newParam.capsule_offset)
      end
      if ExistParamChange.newInfo.black_anim and next(ExistParamChange.newInfo.black_anim) then
        _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.AddPetModelBlackAnim, ExistParamChange.newInfo.black_anim)
      end
    else
      self.CurPetAdjust = {}
      self.CurPetAdjust.id = _NewPetVisualParam.id
      self.CurPetAdjust.name = _NewPetVisualParam.name
      self.CurPetAdjust.defaultInfo = _NewPetVisualParam
      self.CurPetAdjust.newInfo = {}
      self.CurPetAdjust.newInfo.id = _NewPetVisualParam.id
      self.CurPetAdjust.newInfo.EvolutionLevel = _NewPetVisualParam.EvolutionLevel
      self.CurPetAdjust.newInfo.Scale = _NewPetVisualParam.Scale
      self.CurPetAdjust.newInfo.capsule_offset = UE4.FVector(_NewPetVisualParam.capsule_offset.X, _NewPetVisualParam.capsule_offset.Y, _NewPetVisualParam.capsule_offset.Z)
      self.CurPetAdjust.newInfo.black_anim = {}
    end
  end
  self.CurPetAdjust.newInfo.cur_anim = _NewPetVisualParam.cur_anim
  self:RefreshUI()
end

function UMG_PetModelAdjust_DebugPanel_C:RefreshUI()
  local PetVisualParam = self.CurPetAdjust and self.CurPetAdjust.newInfo
  if PetVisualParam then
    self.PetBaseId:SetText(PetVisualParam.id)
    self.PetStrengthStage:SetText(PetVisualParam.EvolutionLevel)
    self.PetModelScale:SetText(PetVisualParam.Scale)
    self.PetModelOffset:SetText(FormatVector(PetVisualParam.capsule_offset))
    self.PetAnimName:SetText(PetVisualParam.cur_anim or "")
  end
end

function UMG_PetModelAdjust_DebugPanel_C:SetAdjustOpMode(_OpMode)
  self.CurOpMode = _OpMode
  if _OpMode == AdjustOpMode.AdjustPetModel then
    self.AdjustPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.DrawLinePanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.AdjustPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.DrawLinePanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_PetModelAdjust_DebugPanel_C:ModifyFactor(_Ctrl, _CurValue)
  if nil == _Ctrl then
    return
  end
  local InputValue = tonumber(_Ctrl:GetText())
  if nil == InputValue then
    _Ctrl:SetText(_CurValue)
  end
  return InputValue or _CurValue
end

function UMG_PetModelAdjust_DebugPanel_C:ModifyModelScale(_Add)
  local PetVisualParam = self.CurPetAdjust and self.CurPetAdjust.newInfo
  if not PetVisualParam then
    self:LogError("PetVisualParam == nil")
    return
  end
  local ScaleFactor = _Add and self.PetModelScaleFactorValue or -self.PetModelScaleFactorValue
  PetVisualParam.Scale = math.max(PetVisualParam.Scale + ScaleFactor, 0)
  self:RefreshUI()
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.SetPetModelScaleAndOffset, PetVisualParam.Scale, PetVisualParam.capsule_offset)
end

function UMG_PetModelAdjust_DebugPanel_C:OnChooseModifyAxis(_Axis, _IsOn)
  if not _IsOn or self.CurModifyAxis == _Axis then
    return
  end
  local AxisToCtrl = {
    [AdjustOffsetAxis.Axis_X] = self.CheckBoxModifyAxis_X,
    [AdjustOffsetAxis.Axis_Y] = self.CheckBoxModifyAxis_Y,
    [AdjustOffsetAxis.Axis_Z] = self.CheckBoxModifyAxis_Z
  }
  self.CurModifyAxis = _Axis
  for _TmpAxis, _TmpCtrl in pairs(AxisToCtrl) do
    _TmpCtrl:SetIsChecked(_TmpAxis == _Axis)
  end
end

function UMG_PetModelAdjust_DebugPanel_C:ModifyModelOffset(_Add)
  local PetVisualParam = self.CurPetAdjust and self.CurPetAdjust.newInfo
  if not PetVisualParam then
    self:LogError("PetVisualParam == nil")
    return
  end
  if self.CurModifyAxis == AdjustOffsetAxis.None then
    self:LogError("\230\156\170\230\140\135\229\174\154\231\188\150\232\190\145\229\157\144\230\160\135\232\189\180")
    return
  end
  local OffsetFactor = _Add and self.PetModelOffsetFactorValue or -self.PetModelOffsetFactorValue
  if self.CurModifyAxis == AdjustOffsetAxis.Axis_X then
    PetVisualParam.capsule_offset.X = PetVisualParam.capsule_offset.X + OffsetFactor
  elseif self.CurModifyAxis == AdjustOffsetAxis.Axis_Y then
    PetVisualParam.capsule_offset.Y = PetVisualParam.capsule_offset.Y + OffsetFactor
  elseif self.CurModifyAxis == AdjustOffsetAxis.Axis_Z then
    PetVisualParam.capsule_offset.Z = PetVisualParam.capsule_offset.Z + OffsetFactor
  end
  self:RefreshUI()
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.SetPetModelScaleAndOffset, PetVisualParam.Scale, PetVisualParam.capsule_offset)
end

function UMG_PetModelAdjust_DebugPanel_C:OnClickReduceModelScale()
  self:ModifyModelScale(false)
end

function UMG_PetModelAdjust_DebugPanel_C:OnClickAddModelScale()
  self:ModifyModelScale(true)
end

function UMG_PetModelAdjust_DebugPanel_C:OnModifyScaleFactor(txtContent, commitMethod)
  self.PetModelScaleFactorValue = self:ModifyFactor(self.PetModelScaleFactor, self.PetModelScaleFactorValue)
end

function UMG_PetModelAdjust_DebugPanel_C:OnChooseModifyAxis_X(_IsOn)
  self:OnChooseModifyAxis(AdjustOffsetAxis.Axis_X, _IsOn)
end

function UMG_PetModelAdjust_DebugPanel_C:OnChooseModifyAxis_Y(_IsOn)
  self:OnChooseModifyAxis(AdjustOffsetAxis.Axis_Y, _IsOn)
end

function UMG_PetModelAdjust_DebugPanel_C:OnChooseModifyAxis_Z(_IsOn)
  self:OnChooseModifyAxis(AdjustOffsetAxis.Axis_Z, _IsOn)
end

function UMG_PetModelAdjust_DebugPanel_C:OnClickReduceModelOffset()
  self:ModifyModelOffset(false)
end

function UMG_PetModelAdjust_DebugPanel_C:OnClickAddModelOffset()
  self:ModifyModelOffset(true)
end

function UMG_PetModelAdjust_DebugPanel_C:OnModifyOffsetFactor(txtContent, commitMethod)
  self.PetModelOffsetFactorValue = self:ModifyFactor(self.PetModelOffsetFactor, self.PetModelOffsetFactorValue)
end

function UMG_PetModelAdjust_DebugPanel_C:OnClickAddAnimToBlackList()
  local AnimName = self.PetAnimName:GetText()
  if not string.IsNilOrEmpty(AnimName) then
    self.CurPetAdjust.newInfo.black_anim[AnimName] = 1
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.AddPetModelBlackAnim, self.CurPetAdjust.newInfo.black_anim)
  end
end

function UMG_PetModelAdjust_DebugPanel_C:OnClickOpenDrawLine()
  self:SetAdjustOpMode(AdjustOpMode.DrawLine)
end

function UMG_PetModelAdjust_DebugPanel_C:HandleTouchStart(_MousePos)
  if self.CurOpMode ~= AdjustOpMode.DrawLine then
    return
  end
  self.TouchStartPos = _MousePos
end

function UMG_PetModelAdjust_DebugPanel_C:HandleTouchEnd(_MousePos)
  if self.CurOpMode ~= AdjustOpMode.DrawLine or not self.TouchStartPos then
    return
  end
  local deltaX = math.abs(_MousePos.X - self.TouchStartPos.X)
  local deltaY = math.abs(_MousePos.Y - self.TouchStartPos.Y)
  if deltaX > deltaY then
    self.DebugLines:Add(UE4.FVector(0, self.TouchStartPos.Y, 0))
  else
    self.DebugLines:Add(UE4.FVector(self.TouchStartPos.X, 0, 0))
  end
end

local function SaveJsonFile(Filename, Table)
  local Filepath = string.format("%s%s.json", UE4.UBlueprintPathsLibrary.ProjectSavedDir(), Filename)
  Filepath = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(Filepath)
  local Content = rapidjson.encode(Table)
  local Success = UE4.UNRCStatics.WriteToFile(Filepath, Content)
  return Success, Filepath
end

function UMG_PetModelAdjust_DebugPanel_C:OnClickExportModifyData()
  self:SavePetParamChange()
  local pet_base_change = {}
  local pet_blacklist_change = {}
  for _id, _petParamChange in pairs(self.PetAdjustChangelist) do
    local defaultParam = _petParamChange.defaultInfo
    local newParam = _petParamChange.newInfo
    do
      local cur_change = {}
      if newParam.Scale and newParam.Scale ~= defaultParam.Scale then
        table.insert(cur_change, {
          seg = "petpage_ui_percentage",
          value = newParam.Scale
        })
      end
      if newParam.capsule_offset and newParam.capsule_offset ~= defaultParam.capsule_offset then
        table.insert(cur_change, {
          seg = "petpage_capsule_offset",
          value = FormatVector(newParam.capsule_offset)
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
    if newParam.black_anim and next(newParam.black_anim) then
      local valid_anim_list = {
        Alert = true,
        Becute = true,
        Happy = true,
        Fear = true,
        Relax = true,
        Shock = true,
        Sad = true
      }
      local cur_blacklist_change = {}
      for _animName, _ in pairs(newParam.black_anim) do
        if valid_anim_list[_animName] then
          table.insert(cur_blacklist_change, {seg = _animName, value = 1})
        end
      end
      if not defaultParam.black_anim then
        table.insert(cur_blacklist_change, {
          seg = "name",
          value = _petParamChange.name
        })
        for _animName, _ in pairs(valid_anim_list) do
          if not newParam.black_anim[_animName] then
            table.insert(cur_blacklist_change, {seg = _animName, value = 0})
          end
        end
      end
      table.insert(pet_blacklist_change, {
        key_name = "id",
        key_value = _id,
        changes = cur_blacklist_change
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
  if next(pet_blacklist_change) then
    local Success, Filepath = SaveJsonFile("pet_blacklist_change", pet_blacklist_change)
    if Success then
      UE.UNRCStatics.ExecConsoleCommand(string.format("py update_conf.py %s %s %s", "pet", "PETPAGE_BLACKLIST.yaml", Filepath))
    else
      self:LogError("\229\134\153\229\133\165\229\143\152\230\155\180\233\133\141\231\189\174\229\136\176pet_blacklist_change\229\164\177\232\180\165!")
    end
  end
end

function UMG_PetModelAdjust_DebugPanel_C:OnClickSaveDrawLine()
  self:SetAdjustOpMode(AdjustOpMode.AdjustPetModel)
end

function UMG_PetModelAdjust_DebugPanel_C:OnClickCancelDrawLine()
  self.DebugLines:Clear()
  self:SetAdjustOpMode(AdjustOpMode.AdjustPetModel)
end

return UMG_PetModelAdjust_DebugPanel_C
