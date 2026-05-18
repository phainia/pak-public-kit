local UMG_TaskGuidanceBetweenChapters_C = _G.NRCPanelBase:Extend("UMG_TaskGuidanceBetweenChapters_C")

function UMG_TaskGuidanceBetweenChapters_C:OnActive(teach_id, action)
  if not teach_id then
    return
  end
  self.teach_id = teach_id
  self.action = action
  local teachConf = _G.DataConfigManager:GetTeachConf(teach_id, true)
  if teachConf and teachConf.list_type == Enum.TeachGuideType.TGT_IMG then
    local styleIndex = #teachConf.guide_struct
    self.NRCSwitcher_Style:SetActiveWidgetIndex(styleIndex - 1)
    for i = 1, #teachConf.guide_struct do
      local teachItemConf = teachConf.guide_struct[i]
      local teachingBg = self["TeachingBg_" .. styleIndex .. i]
      if teachingBg then
        local Icon = "Texture2D'/Game/NewRoco/Modules/System/TeachingManual/Raw/Icon/"
        local iconPath
        if UE.UGameplayStatics.GetGameInstance(self):IsPCMode() then
          iconPath = string.format("%s%s", Icon, teachItemConf.bg_PC)
        else
          iconPath = string.format("%s%s", Icon, teachItemConf.bg)
        end
        teachingBg:SetPath(iconPath)
      end
      local titleText = self["TitleText_" .. styleIndex .. i]
      if titleText then
        if UE.UGameplayStatics.GetGameInstance(self):IsPCMode() then
          titleText:SetText(teachItemConf.title_PC)
        else
          titleText:SetText(teachItemConf.title)
        end
      end
      local dialogueText = self["DialogueText_" .. styleIndex .. i]
      if dialogueText then
        if UE.UGameplayStatics.GetGameInstance(self):IsPCMode() then
          dialogueText:SetText(teachItemConf.text_PC)
        else
          dialogueText:SetText(teachItemConf.text)
        end
      end
    end
    local animIndex = #teachConf.guide_struct
    local anim = self["In_" .. animIndex]
    if anim then
      self:PlayAnimation(anim)
    end
  end
end

function UMG_TaskGuidanceBetweenChapters_C:OnDeactive()
end

function UMG_TaskGuidanceBetweenChapters_C:OnAddEventListener()
end

function UMG_TaskGuidanceBetweenChapters_C:OnConstruct()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnClickCloseBtn)
end

function UMG_TaskGuidanceBetweenChapters_C:OnDestruct()
end

function UMG_TaskGuidanceBetweenChapters_C:OnAnimationFinished(anim)
  if anim == self.Out then
    self.action:Finish(true, nil)
    self.action = nil
    self:DoClose()
  end
end

function UMG_TaskGuidanceBetweenChapters_C:OnClickCloseBtn()
  if self.bClose then
    return
  end
  self.bClose = true
  _G.NRCAudioManager:PlaySound2DAuto(40008006, "UMG_TaskGuidanceBetweenChapters_C:OnClickCloseBtn")
  self:SetPanelReadyToClosed()
  self:PlayAnimation(self.Out)
end

return UMG_TaskGuidanceBetweenChapters_C
