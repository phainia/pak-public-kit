local rapidjson = require("rapidjson")
local UMG_CardDebugPanel_C = _G.NRCPanelBase:Extend("UMG_CardDebugPanel_C")

function UMG_CardDebugPanel_C:OnConstruct()
  self.cardPanel = nil
  self.scale = nil
  self.positionX = nil
  self.positionY = nil
  self.bFlip = false
  self.init_scale = nil
  self.init_positionX = nil
  self.init_positionY = nil
  self.init_bFlip = false
  self.changeData = {}
  self.baseId = nil
  self.iconPath = nil
end

function UMG_CardDebugPanel_C:OnSliderChange(value)
  self.scale = value
  self:ChangeScale()
end

function UMG_CardDebugPanel_C:ChangeScale()
  if self.cardPanel then
    if self.bFlip then
      self.cardPanel:SetIconScaleAndPosition(UE4.FVector2D(-self.scale, self.scale))
    else
      self.cardPanel:SetIconScaleAndPosition(UE4.FVector2D(self.scale, self.scale))
    end
  end
end

function UMG_CardDebugPanel_C:SetCardPanel(panel, baseId)
  self.cardPanel = panel
  self:InitDebugPanel(baseId)
  self.slider.OnValueChanged:Add(self, self.OnSliderChange)
  self.XTextBox.OnTextCommitted:Add(self, self.OnXTextBoxChange)
  self.YTextBox.OnTextCommitted:Add(self, self.OnYTextBoxChange)
  self.TextBox_Pet.OnTextCommitted:Add(self, self.OnPetChange)
  self:AddButtonListener(self.Button_419, self.OnBtnClicked)
  self:AddButtonListener(self.Export, self.OnExportClicked)
  self:AddButtonListener(self.Hide, self.HidePanel)
  self.MutationType.OnSelectionChanged:Add(self, self.ChangeMutationType)
end

function UMG_CardDebugPanel_C:ChangeMutationType()
  local materialPath
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.baseId)
  local petPicture = {
    petBaseConf.JL_res,
    petBaseConf.JL_shiny_res
  }
  if 0 == self.MutationType:GetSelectedIndex() then
    self.cardPanel.Icon1:SwitchToSetBrushFromMaterialInstanceMode(false)
    self.cardPanel.Icon1:SetPath(petPicture[1])
  elseif 1 == self.MutationType:GetSelectedIndex() then
    self.cardPanel.iconPath = petPicture[1]
    self.cardPanel.Icon1:SwitchToSetBrushFromMaterialInstanceMode(true)
    materialPath = "MaterialInstanceConstant'/Game/ArtRes/UI/TUI/Materials/MI_UI_PetDazzleCloseUp.MI_UI_PetDazzleCloseUp'"
  elseif 2 == self.MutationType:GetSelectedIndex() then
    self.cardPanel.iconPath = petPicture[1]
    self.cardPanel.Icon1:SwitchToSetBrushFromMaterialInstanceMode(true)
    materialPath = _G.DataConfigManager:GetHiddenGlassConf(1).pet_art_mat_path
  elseif 3 == self.MutationType:GetSelectedIndex() then
    self.cardPanel.Icon1.MaterialInstance = nil
    self.cardPanel.Icon1:SwitchToSetBrushFromMaterialInstanceMode(false)
    self.cardPanel.Icon1:SetPath(petPicture[2])
  elseif 4 == self.MutationType:GetSelectedIndex() then
    self.cardPanel.iconPath = petPicture[1]
    self.cardPanel.Icon1:SwitchToSetBrushFromMaterialInstanceMode(true)
    materialPath = "MaterialInstanceConstant'/Game/ArtRes/UI/TUI/Materials/MI_UI_InnerLineCloseUp.MI_UI_InnerLineCloseUp'"
  elseif 5 == self.MutationType:GetSelectedIndex() then
    self.cardPanel.iconPath = petPicture[2]
    self.cardPanel.Icon1:SwitchToSetBrushFromMaterialInstanceMode(true)
    materialPath = "MaterialInstanceConstant'/Game/ArtRes/UI/TUI/Materials/MI_UI_PetDazzleCloseUp.MI_UI_PetDazzleCloseUp'"
  elseif 6 == self.MutationType:GetSelectedIndex() then
    self.cardPanel.iconPath = petPicture[2]
    self.cardPanel.Icon1:SwitchToSetBrushFromMaterialInstanceMode(true)
    materialPath = _G.DataConfigManager:GetHiddenGlassConf(1).pet_art_mat_path
  end
  if materialPath then
    self.cardPanel:LoadPanelRes(materialPath, 255, self.cardPanel.OnLoadIconMaterialSucceed)
  end
end

function UMG_CardDebugPanel_C:InitDebugPanel(baseId)
  self.baseId = baseId
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(baseId)
  self.slider:SetValue(petBaseConf.card_res_ui_percentage)
  local offset = petBaseConf.card_res_offset
  self.XTextBox:SetText(offset[1])
  self.YTextBox:SetText(offset[2])
  self.TextBox_Pet:SetText(baseId)
  self.scale = petBaseConf.card_res_ui_percentage
  self.init_scale = self.scale
  self.positionX = offset[1]
  self.init_positionX = self.positionX
  self.positionY = offset[2]
  self.init_positionY = self.positionY
  self.bFlip = 1 == petBaseConf.card_res_horizontal_flip_data
  self.init_bFlip = self.bFlip
  self.MutationType:SetSelectedIndex(0)
end

function UMG_CardDebugPanel_C:OnPetChange()
  local newBaseId = self:ModifyFactor(self.TextBox_Pet, self.baseId)
  self:SetPet(newBaseId)
end

function UMG_CardDebugPanel_C:SetPet(baseId)
  self:SaveChange()
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(baseId)
  if self.cardPanel and petBaseConf then
    self.cardPanel.Icon1:SetPath(petBaseConf.JL_res)
    local percentage = petBaseConf.card_res_ui_percentage
    local offset = petBaseConf.card_res_offset
    if 1 == petBaseConf.card_res_horizontal_flip_data then
      self.cardPanel:SetIconScaleAndPosition(UE4.FVector2D(-percentage, percentage), UE4.FVector2D(offset[1], offset[2]))
    else
      self.cardPanel:SetIconScaleAndPosition(UE4.FVector2D(percentage, percentage), UE4.FVector2D(offset[1], offset[2]))
    end
    self:InitDebugPanel(baseId)
  end
end

function UMG_CardDebugPanel_C:SaveChange()
  local changeData = {}
  if self.init_scale ~= self.scale then
    changeData.scale = self.scale
  end
  if self.init_positionX ~= self.positionX or self.init_positionY ~= self.positionY then
    changeData.position = UE4.FVector2D(self.positionX, self.positionY)
  end
  if self.init_bFlip ~= self.bFlip then
    changeData.bFlip = self.bFlip
  end
  if next(changeData) then
    self.changeData[self.baseId] = changeData
  end
end

function UMG_CardDebugPanel_C:OnBtnClicked()
  self.bFlip = not self.bFlip
  self:ChangeScale()
end

function UMG_CardDebugPanel_C:OnXTextBoxChange()
  self.positionX = self:ModifyFactor(self.XTextBox, self.positionX)
  self:ChangePosition()
end

function UMG_CardDebugPanel_C:OnYTextBoxChange()
  self.positionY = self:ModifyFactor(self.YTextBox, self.positionY)
  self:ChangePosition()
end

function UMG_CardDebugPanel_C:ChangePosition()
  if self.cardPanel then
    self.cardPanel:SetIconScaleAndPosition(nil, UE4.FVector2D(self.positionX, self.positionY))
  end
end

function UMG_CardDebugPanel_C:ModifyFactor(_Ctrl, _CurValue)
  if nil == _Ctrl then
    return
  end
  local InputValue = tonumber(_Ctrl:GetText())
  if nil == InputValue then
    _Ctrl:SetText(_CurValue)
  end
  return InputValue or _CurValue
end

local function SaveJsonFile(Filename, Table)
  local Filepath = string.format("%s%s.json", UE4.UBlueprintPathsLibrary.ProjectSavedDir(), Filename)
  Filepath = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(Filepath)
  local Content = rapidjson.encode(Table)
  local Success = UE4.UNRCStatics.WriteToFile(Filepath, Content)
  return Success, Filepath
end

local function FormatFloat(_value)
  local formatted = string.format("%.4f", _value or 0)
  formatted = string.gsub(formatted, "0+$", "")
  formatted = string.gsub(formatted, "%.$", "")
  return formatted
end

local function FormatVector(_vector)
  return string.format("%s;%s", FormatFloat(_vector.X), FormatFloat(_vector.Y))
end

function UMG_CardDebugPanel_C:OnExportClicked()
  self:SaveChange()
  for id, changeData in pairs(self.changeData) do
    local cur_change = {}
    local pet_base_change = {}
    if changeData.scale then
      table.insert(cur_change, {
        seg = "card_res_ui_percentage",
        value = changeData.scale
      })
    end
    if changeData.position then
      table.insert(cur_change, {
        seg = "card_res_offset",
        value = FormatVector(changeData.position)
      })
    end
    if changeData.bFlip ~= nil then
      local flip
      if changeData.bFlip then
        flip = 1
      else
        flip = 0
      end
      table.insert(cur_change, {
        seg = "card_res_horizontal_flip_data",
        value = flip
      })
    end
    if next(cur_change) then
      table.insert(pet_base_change, {
        key_name = "id",
        key_value = id,
        changes = cur_change
      })
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
  if next(self.changeData) then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\228\191\174\230\148\185\229\183\178\229\175\188\229\135\186\229\136\176\229\175\185\229\186\148yaml")
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\230\151\160\228\191\174\230\148\185")
  end
  self.changeData = {}
end

function UMG_CardDebugPanel_C:HidePanel()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_CardDebugPanel_C:OnDestruct()
  self.slider.OnValueChanged:Remove(self, self.OnSliderChange)
  self.XTextBox.OnTextCommitted:Remove(self, self.OnXTextBoxChange)
  self.YTextBox.OnTextCommitted:Remove(self, self.OnYTextBoxChange)
  self.TextBox_Pet.OnTextCommitted:Remove(self, self.OnPetChange)
  self:RemoveButtonListener(self.Button_419)
  self:RemoveButtonListener(self.Export)
  self:RemoveButtonListener(self.Hide)
  self.MutationType.OnSelectionChanged:Remove(self, self.ChangeMutationType)
end

return UMG_CardDebugPanel_C
