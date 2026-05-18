local UMG_NpcInfo_CommonNPC_C = _G.NRCPanelBase:Extend("UMG_NpcInfo_CommonNPC_C")

function UMG_NpcInfo_CommonNPC_C:OnActive()
end

function UMG_NpcInfo_CommonNPC_C:OnDeactive()
end

function UMG_NpcInfo_CommonNPC_C:OnAddEventListener()
end

function UMG_NpcInfo_CommonNPC_C:OnConstruct()
end

function UMG_NpcInfo_CommonNPC_C:OnDestruct()
end

function UMG_NpcInfo_CommonNPC_C:OnEnable(selector, props)
  if 0 == selector then
    self:_UpdateSelector1(props)
  elseif 1 == selector then
    self:_UpdateSelector2(props)
  elseif 2 == selector then
    self:_UpdateSelector3(props)
  end
end

function UMG_NpcInfo_CommonNPC_C:OnDisable()
end

function UMG_NpcInfo_CommonNPC_C:_UpdateSelector1(_props)
  self.HeadIconSwitcher:SetActiveWidgetIndex(_props.headIconIndex)
  if _props.isHeadIcon then
    self.headIcon:SetPath(_props.headIconPath)
  else
    self:SetPetIcon(_props)
  end
  if not self.iconPath then
    self.npcName:SetText(_props.name)
    self.npcDesc:SetText(_props.desc)
  else
    local name = _G.DataConfigManager:GetLocalizationConf("map_jianying_icon_name")
    local desc = _G.DataConfigManager:GetLocalizationConf("map_jianying_icon_description")
    if name and desc then
      self.npcName:SetText(name.msg)
      self.npcDesc:SetText(desc.msg)
    end
  end
  self.Switcher1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if _props.bShowCatchTime and not self.iconPath then
    self.Switcher1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if _props.petCircadian == _G.Enum.PetCircadian.PC_ALLDAY then
      self.Switcher1:SetActiveWidgetIndex(0)
    elseif _props.petCircadian == _G.Enum.PetCircadian.PC_DAY then
      self.Switcher1:SetActiveWidgetIndex(1)
    elseif _props.petCircadian == _G.Enum.PetCircadian.PC_NIGHT then
      self.Switcher1:SetActiveWidgetIndex(2)
    else
      self.Switcher1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if string.IsNilOrEmpty(_props.ownerName) then
    self.MutualVisits:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.MutualVisits:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_NpcInfo_CommonNPC_C:_UpdateSelector2(_props)
  self.npcName:SetText(_props.name)
  self.npcDesc:SetText(_props.desc)
  self:_SetWidgetActive(self.List_1, _props.shouldActivateList)
  self.List_1:InitGridView({
    _props.listContent
  })
  self:_SetWidgetActive(self.headIcon, true)
  self.headIcon:SetPath(_props.iconPath)
end

function UMG_NpcInfo_CommonNPC_C:_UpdateSelector3(_props)
  self.npcName:SetText(_props.name)
  self.npcDesc:SetText(_props.desc)
  self.HeadIconSwitcher:SetActiveWidgetIndex(_props.headIconIndex)
  if _props.isHeadIcon then
    self.headIcon:SetPath(_props.headIconPath)
  else
    self.Node_4:SetPath(_props.headIconPath)
  end
  self.CycleChallenge:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.NRCText_Title:SetText(_props.subtitle)
  self.CycleChallenge_Icon:SetPath(_props.cycleChallengeIconPath)
  if _props.scheduleText then
    self.Progress:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TextSchedule:SetText(_props.scheduleText)
  else
    self.Progress:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.TextStarNumber:SetText(_props.starNumberText)
  self.TaskAwardList_1:InitGridView(_props.displayItems)
  if _props.starText then
    self.NRCText:SetText(_props.starText)
  end
  if _props.starIcon then
    self.NRCImage_83:SetPath(_props.starIcon)
  end
end

function UMG_NpcInfo_CommonNPC_C:_SetWidgetActive(_uiItem, _isShow)
  if _uiItem then
    if _isShow then
      _uiItem:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      _uiItem:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_NpcInfo_CommonNPC_C:GetTextTimeWidget()
  return Text_Time_2
end

function UMG_NpcInfo_CommonNPC_C:SetPetIcon(_props)
  self.Icon_Mask:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.wenHao:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if _props.state then
    if _props.state == _G.ProtoEnum.PetHandbookStatus.PHS_NOT_FOUND then
      self.iconPath = _props.headIconPath
      self:SetUnFoundIcon()
    elseif not _props.isFound then
      self.Node_4:SetPath(_props.headIconPath)
      self.Icon_Mask:SetPath(_props.headIconPath)
      self.Icon_Mask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Node_4:SetPath(_props.headIconPath)
    end
  else
    self.Node_4:SetPath(_props.headIconPath)
  end
end

function UMG_NpcInfo_CommonNPC_C:SetUnFoundIcon()
  self.wenHao:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local materialPath = "MaterialInstanceConstant'/Game/NewRoco/Modules/System/TeamBattle/Res/MI_UI_Silhouettew.MI_UI_Silhouettew'"
  self.Node_4:SwitchToSetBrushFromMaterialInstanceMode(true)
  self:LoadPanelRes(materialPath, 255, self.OnLoadIconMaterialSucceed, self.OnLoadIconMaterialFail, nil)
end

function UMG_NpcInfo_CommonNPC_C:OnLoadIconMaterialSucceed(_, asset)
  if self.iconPath and asset then
    self.Node_4.MaterialInstance = asset
    self.Node_4:SetBrushFromMaterial(asset)
    self:LoadPanelRes(self.iconPath, 255, self.OnLoadImageResSucc, nil, nil)
  end
end

function UMG_NpcInfo_CommonNPC_C:OnLoadIconMaterialFail()
  if self.iconPath ~= "" then
    self.Node_4:SetPath(self.iconPath)
  end
end

function UMG_NpcInfo_CommonNPC_C:OnLoadImageResSucc(req, asset)
  local material = self.Node_4:GetDynamicMaterial()
  material:SetTextureParameterValue("SpriteTexture", asset)
end

return UMG_NpcInfo_CommonNPC_C
