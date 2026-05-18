local UMG_Announcement_C = _G.NRCPanelBase:Extend("UMG_Announcement_C")

function UMG_Announcement_C:OnActive(NoticeList)
  Log.Info("UMG_Announcement_C:OnActive")
  _G.NRCAudioManager:PlaySound2DAuto(40001002, "UMG_Announcement_C:OnActive")
  NRCProfilerLog:NRCPanelRequireRes(true, self.panelName)
  self:SetCommonTitle()
  self.NoticeList = NoticeList
  self:InitNoticeContent()
  if UE.UAsyncSaveGameHandle then
    if not UEPath.ANNOUNCEMENT_SAVE_GAME or UEPath.ANNOUNCEMENT_SAVE_GAME == "" then
      Log.Error("UMG_Announcement_C:OnActive ANNOUNCEMENT_SAVE_GAME path is invalid")
      return
    end
    if self.AsyncSaveGameHandle and self.AsyncSaveGameHandle:IsValid() then
      self.AsyncSaveGameHandle.Completed:Remove(self, self.OnAsyncLoadSaveGameSlotFinish)
      UnLua.Unref(self.AsyncSaveGameHandle)
      self.AsyncSaveGameHandle = nil
    end
    self.AsyncSaveGameHandle_Ref = nil
    self.AsyncSaveGameHandle = NewObject(UE.UAsyncSaveGameHandle, UE.UNRCPlatformGameInstance.GetInstance(), "AnnouncementRedPoint")
    if not self.AsyncSaveGameHandle or not self.AsyncSaveGameHandle:IsValid() then
      Log.Error("UMG_Announcement_C:OnActive Failed to create AsyncSaveGameHandle")
      return
    end
    self.AsyncSaveGameHandle_Ref = UnLua.Ref(self.AsyncSaveGameHandle)
    self.AsyncSaveGameHandle.Completed:Add(self, self.OnAsyncLoadSaveGameSlotFinish)
    self.AsyncSaveGameHandle:AsyncLoadByRawClassPath(UEPath.ANNOUNCEMENT_SAVE_GAME, "AnnouncementRedPoint")
  end
end

function UMG_Announcement_C:OnAsyncLoadSaveGameSlotFinish(saveData, bResult)
  Log.Info("UMG_Announcement_C:OnAsyncLoadSaveGameSlotFinish", bResult)
  if bResult then
    self.SaveData = saveData
    self.SaveData_Ref = UnLua.Ref(self.SaveData)
    self:OnLoadSaveDataSuccess()
  else
    Log.Warning("UMG_Announcement_C:OnAsyncLoadSaveGameSlotFinish failed")
  end
  self:CleanupAsyncSaveGameHandle()
end

function UMG_Announcement_C:OnDeactive()
  Log.Info("UMG_Announcement_C:OnDeactive")
  if self.SaveData and self.SaveData:IsValid() then
    UnLua.Unref(self.SaveData)
    self.SaveData = nil
  end
  self.SaveData_Ref = nil
  self:CleanupAsyncSaveGameHandle()
end

function UMG_Announcement_C:CleanupAsyncSaveGameHandle()
  if self.AsyncSaveGameHandle and self.AsyncSaveGameHandle:IsValid() then
    self.AsyncSaveGameHandle.Completed:Remove(self, self.OnAsyncLoadSaveGameSlotFinish)
    UnLua.Unref(self.AsyncSaveGameHandle)
    self.AsyncSaveGameHandle = nil
  end
  self.AsyncSaveGameHandle_Ref = nil
end

function UMG_Announcement_C:OnAddEventListener()
  self:AddButtonListener(self.NRCButton_1, self.OnClickNRCButton_1)
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnClickCloseBtn)
end

function UMG_Announcement_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_Announcement_C:OnDestruct()
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  end
end

function UMG_Announcement_C:OnAnimationFinished(anim)
  if anim == self.Page_Out then
    self:DoClose()
  end
end

function UMG_Announcement_C:OnClickNRCButton_1()
end

function UMG_Announcement_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_Announcement_C:OnClickCloseBtn()
  _G.NRCAudioManager:PlaySound2DAuto(40008006, "UMG_Announcement_C:OnClickCloseBtn")
  if _G.GlobalConfig.DebugOpenUI then
    self:DoClose()
    return
  end
  for i, Notice in ipairs(self.NoticeList) do
    if not Notice.bShowRedPoint and self.SaveData and self.SaveData:IsValid() then
      self.SaveData.RedPointDic:Add(Notice.ID, true)
    end
  end
  if self.SaveData and self.SaveData:IsValid() then
    UE4.UGameplayStatics.SaveGameToSlot(self.SaveData, "AnnouncementRedPoint", 0)
  end
  _G.NRCModuleManager:DoCmd(LoginModuleCmd.SetSelectTabIndex, 0)
  self:PlayAnimation(self.Page_Out)
end

function UMG_Announcement_C:OnSwitcherSwitcher(SwitcherIndex)
  self.Switcher:SetActiveWidgetIndex(SwitcherIndex)
end

function UMG_Announcement_C:InitNoticeContent()
  self.Title:SetText("")
  self.NxRichText_134:SetText("")
  self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Announcement_C:SetNoticeContent(Notice)
  self.ItemList_2:EndInertialScrolling()
  self.ItemList_2:ScrollToStart()
  self:PlayAnimation(self.Change)
  self.Title:SetText(Notice.Title)
  self.NxRichText_134:SetText(Notice.Content)
  if Notice.bSetCenter then
    self.NxRichText_134:SetJustification(UE4.ETextJustify.Center)
  else
    self.NxRichText_134:SetJustification(UE4.ETextJustify.Left)
  end
  if self.SaveData and self.SaveData:IsValid() then
    self.SaveData.OnlyOnceDic:Add(Notice.ID, true)
    UE4.UGameplayStatics.SaveGameToSlot(self.SaveData, "AnnouncementRedPoint", 0)
    self:Log("Save OnlyOnce PopUp ID:", Notice.ID)
  end
end

function UMG_Announcement_C:OnLoadSaveDataSuccess()
  NRCProfilerLog:NRCPanelRequireRes(false, self.panelName)
  if _G.GlobalConfig.DebugOpenUI then
    return
  end
  if not self.NoticeList then
    return
  end
  self.Switcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  for i, Notice in ipairs(self.NoticeList) do
    Notice.bShowRedPoint = not self.SaveData.RedPointDic:Find(Notice.ID)
  end
  self:PlayAnimation(self.Page_In)
  self.NoticeNum = #self.NoticeList
  if self.NoticeNum > 0 then
    self:OnSwitcherSwitcher(0)
    self.ItemList:InitGridView(self.NoticeList)
    self.ItemList:SelectItemByIndex(0)
    self:SetNoticeContent(self.NoticeList[1])
  else
    self:OnSwitcherSwitcher(1)
  end
end

function UMG_Announcement_C:OnLoadFailed(Request, Message)
  Log.Warning("amonsu:UMG_Announcement_C \233\162\132\229\138\160\232\189\189\232\181\132\230\186\144\229\164\177\232\180\165", Message)
  _G.NRCResourceManager:UnLoadRes(Request)
end

return UMG_Announcement_C
