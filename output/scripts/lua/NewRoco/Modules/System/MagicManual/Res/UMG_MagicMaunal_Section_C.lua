local MagicManualModuleEvent = reload("NewRoco.Modules.System.MagicManual.MagicManualModuleEvent")
local UMG_MagicMaunal_Section_C = _G.NRCPanelBase:Extend("UMG_MagicMaunal_Section_C")

function UMG_MagicMaunal_Section_C:OnConstruct()
end

function UMG_MagicMaunal_Section_C:OnActive(_param, text, IsNextChapter, ...)
  if IsNextChapter then
    self.canClose = true
    self.NRCSwitcher_33:SetActiveWidgetIndex(1)
    _G.NRCAudioManager:PlaySound2DAuto(1220002028, "UMG_MagicMaunal_Section_C:OnBtnCloseClick")
    self:PlayAnimation(self.In)
  else
    self.canClose = false
    self.NRCSwitcher_33:SetActiveWidgetIndex(0)
    self.NRCTitle_1:SetText(text)
    self:SetDatas(_param)
    self.TimeText:SetText(string.sub(os.date("%Y", math.floor(_G.ZoneServer:GetServerTime() / 1000)), 3, 4) .. os.date(".%m.%d", math.floor(_G.ZoneServer:GetServerTime() / 1000)))
    _G.NRCAudioManager:PlaySound2DAuto(1220002029, "UMG_MagicMaunal_Section_C:OnBtnCloseClick")
    self:PlayAnimation(self.In)
    self:OnAddEventListener()
  end
  self.IsOutAnimFinish = false
end

function UMG_MagicMaunal_Section_C:SetShowBg(_petId)
end

function UMG_MagicMaunal_Section_C:OnDeactive()
end

function UMG_MagicMaunal_Section_C:SetDatas(RewardsList)
  if RewardsList and #RewardsList > 0 then
    self.ItemList:InitList(RewardsList)
  else
    self.ItemList:Clear()
  end
end

function UMG_MagicMaunal_Section_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseRenamePanel, self.OnBtnCloseClick)
end

function UMG_MagicMaunal_Section_C:OnBtnCloseClick()
  if self:IsAnimationPlaying(self.Out) or self:IsAnimationPlaying(self.In) or self.IsOutAnimFinish then
    return
  end
  self:PlayAnimation(self.Out)
end

function UMG_MagicMaunal_Section_C:OnPcClose()
  self:OnBtnCloseClick()
end

function UMG_MagicMaunal_Section_C:OnAnimationFinished(anim)
  if anim == self.Out then
    if not self.canClose then
      self.IsOutAnimFinish = true
      self.data = self.module:GetData("MagicManualModuleData")
      local uiData = {}
      if self.module.ManaulChildIndex == self.data.ManualTaskType.SeasonManual then
        local nextChapterData = self.data:GetNextSeasonManaulChapterData()
        if nextChapterData and nextChapterData.chapterConfData then
          local UIConf = self.data:GetSeasonChapterData()
          if UIConf and UIConf.theme_color4 then
            uiData.themeColor = UIConf.theme_color4
          end
          uiData.chapterNumber = self.data:TranslateCurChapterName(nextChapterData.chapterConfData.chapter_num)
          uiData.chapterName = nextChapterData.chapterConfData.chapter_name
          uiData.panelName = "SeasonChapterBegin"
          uiData.id = nextChapterData.chapterConfData.id
          _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.CacheChapterBeginUIDataToFile, uiData)
        end
        _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.OnOpenSeasonManualPanel)
      else
        self:DispatchEvent(MagicManualModuleEvent.UpdateMagicManualNextChapterPanel)
        local NextChapterId = self.data:SetNextChapterInfo()
        if NextChapterId then
          uiData.chapterNumber = NextChapterId.ChapterIdName
          uiData.chapterName = NextChapterId.ChapterName
          uiData.chapterRibbon = NextChapterId.ChapterRibbon
          uiData.id = NextChapterId.id
          uiData.panelName = "ChapterBegin"
          _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.OpenChapterBeginUI, uiData, true)
        end
      end
      self:DoClose()
    else
      self:DoClose()
    end
  end
end

return UMG_MagicMaunal_Section_C
