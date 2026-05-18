local UMG_ScrapbookPanel_C = _G.NRCPanelBase:Extend("UMG_ScrapbookPanel_C")

function UMG_ScrapbookPanel_C:OnActive(_PageId)
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
    self:OnAddEventListener()
    self.TaskCanvasPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    return
  end
  self.data = self.module:GetData("TaskModuleData")
  self.scrapBookList = self.data.ScrapBookList
  self.collectListItems = {}
  self.clueList = {}
  self.clew_stage = {}
  self.mapMarker = {}
  self.newMarker = {}
  self.newMapHead = {}
  self.newNameTag = {}
  self.curMarker = nil
  self.bIsLineUp = false
  self.allLines = {
    self.Line1,
    self.Line2,
    self.Line3,
    self.Line4,
    self.Line5,
    self.Line6
  }
  self.allLineLinkAnim = {
    self.Line_link1,
    self.Line_link2,
    self.Line_link3,
    self.Line_link4,
    self.Line_link5,
    self.Line_link6
  }
  self.clue1Items = {
    {
      MapMarker = self.mapMarker1,
      Head = self.Head1,
      NameTag = self.NameTag1
    },
    {
      MapMarker = self.mapMarker2,
      Head = self.Head2,
      NameTag = self.NameTag2
    },
    {
      MapMarker = self.mapMarker3,
      Head = self.Head3,
      NameTag = self.NameTag3
    },
    {
      MapMarker = self.mapMarker4,
      Head = self.Head4,
      NameTag = self.NameTag4
    },
    {
      MapMarker = self.mapMarker5,
      Head = self.Head5,
      NameTag = self.NameTag5
    }
  }
  self.clue2Items = {
    {
      NameTag = self.NameTag2_1
    },
    {
      NameTag = self.NameTag2_2
    },
    {
      NameTag = self.NameTag2_3
    },
    {
      NameTag = self.NameTag2_4
    }
  }
  self.clue3Items = {
    {
      Expert = self.Expert1,
      NameTag = self.NameTag3_1
    },
    {
      Expert = self.Expert2,
      NameTag = self.NameTag3_2
    },
    {
      Expert = self.Expert3,
      NameTag = self.NameTag3_3
    },
    {
      Expert = self.Expert4,
      NameTag = self.NameTag3_4
    }
  }
  self.clue4Items = {
    {
      Search = self.Search1,
      Envelope = self.Envelope1,
      Content_Text = self.Content_Text1
    },
    {
      Search = self.Search2,
      Envelope = self.Envelope2,
      Content_Text = self.Content_Text2
    },
    {
      Search = self.Search3,
      Envelope = self.Envelope3,
      Content_Text = self.Content_Text3
    }
  }
  self.lineIndex = 1
  self.mapHeadIndex = 1
  self.lineData = {}
  self.RedDotIndex = nil
  self.firstInPageIndex = nil
  self.cluePageIndex = _PageId
  local pageIndex = self:GetPageIndex()
  self.cluePageIndex = self.scrapBookList[pageIndex].id
  self.firstInPageIndex = self.cluePageIndex
  self.CanvasPanel_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:SetBtnArrow()
  self:SetInfo()
  self:OnAddEventListener()
  _G.NRCAudioManager:PlaySound2DAuto(1117, "UMG_ScrapbookPanel_C:OnActive")
  self:PlayAnimation(self.In)
end

function UMG_ScrapbookPanel_C:SetInfo()
  self:SendZoneSetBookReadedReq(self.cluePageIndex)
  self:SetUpCollectList()
  local scrapBookConf = _G.DataConfigManager:GetTaleNotebookKeliConf(self.cluePageIndex)
  local clewStage = {}
  local pageIndex = self:GetPageIndex()
  for i = 1, #self.scrapBookList do
    if 1 == self.scrapBookList[i].id then
      for j = 1, #self.scrapBookList[i].BookData.notebook_keli_data.clews do
        table.insert(clewStage, self.scrapBookList[i].BookData.notebook_keli_data.clews[j])
      end
    end
  end
  self.clew_stage = clewStage
  self.previousPageIndex = pageIndex - 1
  if self.previousPageIndex > 0 and self.scrapBookList[self.previousPageIndex] then
    self.Btn1:ShowOrHideBtnArrow(true)
    self.previousPageId = self.previousPageIndex
    if self.previousPageId then
      self.Btn1.RedDot:SetupKey(246, {
        ProtoEnum.TaleTaskType.TALE_NOTEBOOK_KELI,
        self.scrapBookList[self.previousPageIndex].id
      })
      self.perviousRedDotIndex = self.scrapBookList[self.previousPageIndex].id
    end
  else
    self.Btn1:ShowOrHideBtnArrow(false)
  end
  self.nextPageIndex = pageIndex + 1
  if self.nextPageIndex <= 4 and self.scrapBookList[self.nextPageIndex] then
    self.Btn2:ShowOrHideBtnArrow(true)
    self.nextPageId = self.nextPageIndex
    if self.nextPageId then
      self.Btn2.RedDot:SetupKey(246, {
        ProtoEnum.TaleTaskType.TALE_NOTEBOOK_KELI,
        self.scrapBookList[self.nextPageIndex].id
      })
      self.nextRedDotIndex = self.scrapBookList[self.nextPageIndex].id
    end
  else
    self.Btn2:ShowOrHideBtnArrow(false)
  end
  self.ClueSwitcher:SetActiveWidgetIndex(self.scrapBookList[pageIndex].id - 1)
  if 4 == self.scrapBookList[pageIndex].id then
    self.TaskCanvasPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.TaskCanvasPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self.Task_Desc:SetText(scrapBookConf.list_title)
  if not self.scrapBookList[pageIndex].BookData.notebook_keli_data.to_do_done then
  else
    local clueCount = 0
    for i = 1, #self.scrapBookList[pageIndex].BookData.notebook_keli_data.to_do_done do
      if self.scrapBookList[pageIndex].BookData.notebook_keli_data.to_do_done[i] == true then
        clueCount = clueCount + 1
      end
    end
    local clueText = string.format(LuaText.notebook_keli_clue_text, clueCount, #self.scrapBookList[pageIndex].BookData.notebook_keli_data.to_do_done)
    self.Task_Desc_2:SetText(clueText)
  end
  self.Badge:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:RefreshBlackBarContent(pageIndex)
  local clue1 = _G.DataConfigManager:GetTaleNotebookKeliConf(1)
  self.clueList = clue1.clew_done
  self:SetUpClue1()
  self:SetUpClue2()
  self:SetUpClue3()
  self:SetUpClue4()
  if 1 == self.scrapBookList[pageIndex].id then
    self:LineUpClues()
  end
end

function UMG_ScrapbookPanel_C:RefreshCluePageInfo()
  local scrapBookConf = _G.DataConfigManager:GetTaleNotebookKeliConf(self.cluePageIndex)
  if 1 == self.cluePageIndex and not self.bIsLineUp then
    self:LineUpClues()
  end
  local pageIndex = self:GetPageIndex()
  self.previousPageIndex = pageIndex - 1
  if self.previousPageIndex > 0 and self.scrapBookList[self.previousPageIndex] then
    self.Btn1:ShowOrHideBtnArrow(true)
    self.previousPageId = self.previousPageIndex
    if self.previousPageId then
      self.perviousRedDotIndex = self.scrapBookList[self.previousPageIndex].id
    end
  else
    self.Btn1:ShowOrHideBtnArrow(false)
  end
  self.nextPageIndex = pageIndex + 1
  if self.nextPageIndex <= 4 and self.scrapBookList[self.nextPageIndex] then
    self.Btn2:ShowOrHideBtnArrow(true)
    self.nextPageId = self.nextPageIndex
    if self.nextPageId then
      self.nextRedDotIndex = self.scrapBookList[self.nextPageIndex].id
    end
  else
    self.Btn2:ShowOrHideBtnArrow(false)
  end
  self.ClueSwitcher:SetActiveWidgetIndex(self.scrapBookList[pageIndex].id - 1)
  if 4 == self.scrapBookList[pageIndex].id then
    self.TaskCanvasPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.TaskCanvasPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self:SetUpCollectList(true)
  if 2 == self.ClueSwitcher:GetActiveWidgetIndex() + 1 then
    local scrapBookListPageInfo, scrapBookIndex = self:GetTargetScrapBookListPageInfo(2)
    for i = 1, #self.clue2Items do
      if self.clue2Items[i].NameTag:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
        self.clue2Items[i].NameTag:SetVisibility(UE4.ESlateVisibility.Hidden)
        if self.scrapBookList[scrapBookIndex].BookData.notebook_keli_data.clews[i].is_new == true then
          self.clue2Items[i].NameTag:PlayInDelayAnimation(true)
          self.scrapBookList[scrapBookIndex].BookData.notebook_keli_data.clews[i].is_new = false
        else
          self.clue2Items[i].NameTag:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        end
      end
    end
  elseif 3 == self.ClueSwitcher:GetActiveWidgetIndex() + 1 then
    self:PlayExpertInAnim()
  else
    self:PlayNameTagInAnim()
  end
  self:RefreshBlackBarContent(pageIndex)
  self.Task_Desc:SetText(scrapBookConf.list_title)
  if not self.scrapBookList[pageIndex].BookData.notebook_keli_data.to_do_done then
  else
    local clueCount = 0
    for i = 1, #self.scrapBookList[pageIndex].BookData.notebook_keli_data.to_do_done do
      if true == self.scrapBookList[pageIndex].BookData.notebook_keli_data.to_do_done[i] then
        clueCount = clueCount + 1
      end
    end
    local clueText = string.format(LuaText.notebook_keli_clue_text, clueCount, #self.scrapBookList[pageIndex].BookData.notebook_keli_data.to_do_done)
    self.Task_Desc_2:SetText(clueText)
  end
end

function UMG_ScrapbookPanel_C:RefreshBlackBarContent(pageIndex)
  local blackTextData = self.scrapBookList[pageIndex].BookData.notebook_keli_data.black_text
  local scrapBookConf = _G.DataConfigManager:GetTaleNotebookKeliConf(self.cluePageIndex)
  local stage = blackTextData.stage
  if stage and 0 ~= stage then
    local list_num = 0
    local black_text = ""
    local trace_task_id = 0
    if scrapBookConf.black_done_new then
      list_num = #scrapBookConf.black_done_new
      local item = scrapBookConf.black_done_new[stage]
      black_text = item and item.black_text_new or ""
      trace_task_id = item and item.trace_task_new or ""
    else
      list_num = #scrapBookConf.page_black_list_unlock_by_dia
      black_text = scrapBookConf.black_text[stage] or ""
    end
    self.TextDone:SetText(black_text)
    if stage == list_num then
      self.Badge:SetPath(scrapBookConf.medal_res)
      self.Badge:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if blackTextData.is_new == true then
        self:PlayAnimation(self.Badge_get)
        blackTextData.is_new = false
      end
    else
      self.Badge:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    local bShowTraceBtn = false
    if trace_task_id > 0 then
      local foundTask = self.data:FindTaskInTaskMap(function(taskObject)
        local taskInfo = taskObject.Info
        return trace_task_id == taskInfo.id and taskInfo.state == ProtoEnum.EMTaskState.EM_TASK_STATE_OPEN
      end)
      if foundTask then
        bShowTraceBtn = true
      end
    end
    if bShowTraceBtn then
      self.Btn6:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      local TrackingTask = _G.NRCModuleManager:DoCmd(_G.TaskModuleCmd.GetTrackTask)
      local TrackingTaskID = TrackingTask and TrackingTask.Info.id or 0
      local bTracking = TrackingTaskID == trace_task_id
      self:RefreshTraceBtnText(bTracking)
    else
      self.Btn6:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.TextDone:SetText("")
    self.Badge:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn6:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ScrapbookPanel_C:DoTraceTask(traceTaskId)
  if traceTaskId > 0 then
    self.module:OnCmdTraceByTaskID(traceTaskId)
  else
    local text = LuaText.task_track_error7
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, text)
  end
end

function UMG_ScrapbookPanel_C:DoCancelTraceTask(Task)
  self.module:DoTraceTask(Task.Info, false)
end

function UMG_ScrapbookPanel_C:RefreshTraceBtnText(bTracking)
  self.Btn6:SetBtnText(bTracking and LuaText.umg_npcinfo_3 or LuaText.umg_npcinfo_1)
end

function UMG_ScrapbookPanel_C:GetPageIndex()
  local pageIndex = 1
  for i = 1, #self.scrapBookList do
    if self.scrapBookList[i].id == self.cluePageIndex then
      pageIndex = i
      break
    end
  end
  return pageIndex
end

function UMG_ScrapbookPanel_C:GetTargetScrapBookListPageInfo(pageIndex)
  local scrapBookListPageInfo, scrapBookListIndex
  for i = 1, #self.scrapBookList do
    if self.scrapBookList[i].id == pageIndex then
      scrapBookListPageInfo = self.scrapBookList[i]
      scrapBookListIndex = i
      break
    end
  end
  return scrapBookListPageInfo, scrapBookListIndex
end

function UMG_ScrapbookPanel_C:OnEnable()
  UE4Helper.SetDesiredShowCursor(true, "UMG_ScrapbookPanel_C")
end

function UMG_ScrapbookPanel_C:OnDisable()
  UE4Helper.ReleaseDesiredShowCursor("UMG_ScrapbookPanel_C")
end

function UMG_ScrapbookPanel_C:SetBtnArrow()
  local CommonBtnArrowData1 = {}
  CommonBtnArrowData1.Call = self
  CommonBtnArrowData1.btnHandler = self.NextPage
  CommonBtnArrowData1.modeIndex = 4
  self.Btn2:SetBtnInfo(CommonBtnArrowData1)
  local CommonBtnArrowData2 = {}
  CommonBtnArrowData2.Call = self
  CommonBtnArrowData2.btnHandler = self.PreviousPage
  CommonBtnArrowData2.modeIndex = 3
  self.Btn1:SetBtnInfo(CommonBtnArrowData2)
end

function UMG_ScrapbookPanel_C:SetUpCollectList(bIsRefrsh)
  local scrapBookConf = _G.DataConfigManager:GetTaleNotebookKeliConf(self.cluePageIndex)
  local pageIndex = self:GetPageIndex()
  if not self.scrapBookList[pageIndex].BookData.notebook_keli_data.to_do_done then
  else
    if bIsRefrsh then
      table.clear(self.collectListItems)
    end
    for i = 1, #self.scrapBookList[pageIndex].BookData.notebook_keli_data.to_do_done do
      table.insert(self.collectListItems, {
        scrapBookConf.list_done[i],
        isDone = self.scrapBookList[pageIndex].BookData.notebook_keli_data.to_do_done[i]
      })
    end
    self.CollectList:InitList(self.collectListItems)
  end
end

function UMG_ScrapbookPanel_C:PlayCollectListAnim()
  for i = 1, self.CollectList:GetItemCount() do
    local item = self.CollectList:GetItemByIndex(i - 1)
    item:PlayGetAnimation()
  end
end

function UMG_ScrapbookPanel_C:PlayNameTagInAnim()
  local switcherIndex = self.ClueSwitcher:GetActiveWidgetIndex()
  if 0 == switcherIndex then
    if not self.bIsLineUp then
      for i = 1, #self.clue1Items do
        if self.clue1Items[i].NameTag:GetVisibility() ~= UE4.ESlateVisibility.Collapsed and self.clew_stage[i].is_new == false then
          self.clue1Items[i].NameTag:PlayInAnimation()
        end
      end
    end
  elseif 1 == switcherIndex then
    for i = 1, #self.clue2Items do
      if self.clue2Items[i].NameTag:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
        self.clue2Items[i].NameTag:PlayInAnimation()
      end
    end
  elseif 2 == switcherIndex then
    local scrapBookListPageInfo, scrapBookIndex = self:GetTargetScrapBookListPageInfo(3)
    for i = 1, #self.clue3Items do
      if self.clue3Items[i].NameTag:GetVisibility() ~= UE4.ESlateVisibility.Collapsed and scrapBookListPageInfo and false == scrapBookListPageInfo.BookData.notebook_keli_data.clews[i].is_new then
        self.clue3Items[i].NameTag:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      elseif self.clue3Items[i].NameTag:GetVisibility() ~= UE4.ESlateVisibility.Collapsed and scrapBookListPageInfo and scrapBookListPageInfo.BookData.notebook_keli_data.clews[i].is_new == true then
        self.clue3Items[i].NameTag:PlayNewInAnimation()
        if scrapBookIndex then
          self.scrapBookList[scrapBookIndex].BookData.notebook_keli_data.clews[i].is_new = false
        end
      end
    end
  end
end

function UMG_ScrapbookPanel_C:PlayNameTagNewInAnim()
  if self.newNameTag[1] then
    self.newNameTag[1]:PlayNewInAnimation()
  end
  table.remove(self.newNameTag, 1)
end

function UMG_ScrapbookPanel_C:PlayMapHeadNewInAnim()
  if self.curMarker then
    self.curMarker.MarkPoint:SetVisibility(UE4.ESlateVisibility.Collapsed)
    table.remove(self.newMarker, 1)
  elseif self.newMarker[1] then
    self.newMarker[1].MarkPoint:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.newMapHead[1] then
    self.newMapHead[1]:PlayNewInAnimation()
  end
  table.remove(self.newMapHead, 1)
end

function UMG_ScrapbookPanel_C:PlayExpertInAnim()
  for i = 1, #self.clue3Items do
    if self.clue3Items[i].Expert:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
      self.clue3Items[i].Expert:PlayInAnimation()
    end
  end
end

function UMG_ScrapbookPanel_C:SendZoneSetBookReadedReq(RedDotIndex)
  self.module:SendZoneSetBookReadedReq(ProtoEnum.TaleTaskType.TALE_NOTEBOOK_KELI, RedDotIndex)
end

function UMG_ScrapbookPanel_C:OnDeactive()
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  end
end

function UMG_ScrapbookPanel_C:ClosePanel()
  if self:IsAnimationPlaying(self.Out) then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(1143, "UMG_ScrapbookPanel_C:OnActive")
  self:PlayAnimation(self.Out)
end

function UMG_ScrapbookPanel_C:SetUpClue1()
  for i = 1, #self.clue1Items do
    self.clue1Items[i].Head:SetBgColor(i)
    self.clue1Items[i].Head.matchIndex = i
  end
  for i = 1, #self.clue3Items do
    self.clue3Items[i].Expert.matchIndex = i
  end
  self.MapMarker5.MarkPoint:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local scrapBookListPageInfo = self:GetTargetScrapBookListPageInfo(1)
  if scrapBookListPageInfo then
    local clewStageCount = 0
    for i = 1, #self.clew_stage do
      if 0 ~= self.clew_stage[i].stage and self.clew_stage[i].is_new == false then
        clewStageCount = clewStageCount + 1
      end
    end
    for i = 1, #self.clue1Items do
      if self.clueList[i] then
        if self.clueList[i].clew_text then
          self.clue1Items[i].NameTag.NRCText:SetText(self.clueList[i].clew_text[1])
          self.clue1Items[i].NameTag.Bg_Clue2:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.clue1Items[i].NameTag.Spacer_Clue2:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.clue1Items[i].NameTag.Spacer_Clue3:SetVisibility(UE4.ESlateVisibility.Collapsed)
          if self.clue1Items[i].NameTag.NRCText:GetText() == "" then
            self.clue1Items[i].NameTag:SetVisibility(UE4.ESlateVisibility.Collapsed)
          end
        elseif not self.clueList[i].clew_text and 5 == i then
          self.clue1Items[i].NameTag:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
        if self.clueList[i].clew_res then
          self.clue1Items[i].Head.Head:SetPath(self.clueList[i].clew_res[1])
        end
        if 0 ~= self.clew_stage[i].stage and self.clew_stage[i].is_new == false then
          if 5 ~= i then
            self.clue1Items[i].NameTag:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          end
          self.clue1Items[i].Head.index = self.mapHeadIndex
          self.clue1Items[i].Head.limit = clewStageCount
          self.clue1Items[i].NameTag.index = self.mapHeadIndex
          self.clue1Items[i].NameTag.limit = clewStageCount
          if 5 ~= i then
            self.clue1Items[i].Head:PlayInAnimation()
          end
          self.clue1Items[i].MapMarker.Slot:SetZOrder(3)
          self.clue1Items[i].MapMarker.MarkPoint:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.clue1Items[i].MapMarker.LinkPoint:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          if 5 ~= i then
            table.insert(self.mapMarker, self.clue1Items[i].MapMarker)
          end
          self.mapHeadIndex = self.mapHeadIndex + 1
        elseif 0 ~= self.clew_stage[i].stage and self.clew_stage[i].is_new == true then
          self.clue1Items[i].Head:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.clue1Items[i].NameTag.index = nil
          table.insert(self.newMapHead, self.clue1Items[i].Head)
          if 5 ~= i then
            table.insert(self.newMarker, self.clue1Items[i].MapMarker)
            table.insert(self.newNameTag, self.clue1Items[i].NameTag)
          end
        elseif 0 == self.clew_stage[i].stage then
          self.clue1Items[i].NameTag:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.clue1Items[i].Head:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      else
        self.clue1Items[i].NameTag:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.clue1Items[i].Head:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
end

function UMG_ScrapbookPanel_C:SetUpClue2()
  local scrapBookListPageInfo = self:GetTargetScrapBookListPageInfo(2)
  if scrapBookListPageInfo then
    local scrapBookConf = _G.DataConfigManager:GetTaleNotebookKeliConf(2)
    for i = 1, #self.clue2Items do
      if scrapBookListPageInfo.BookData.notebook_keli_data.clews[i] and 0 ~= scrapBookListPageInfo.BookData.notebook_keli_data.clews[i].stage then
        if scrapBookConf.clew_done[i].clew_text then
          self.clue2Items[i].NameTag.NRCText:SetText(scrapBookConf.clew_done[i].clew_text[1])
          self.clue2Items[i].NameTag.Bg:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.clue2Items[i].NameTag.Bg_Clue2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          self.clue2Items[i].NameTag.Spacer_Clue1:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.clue2Items[i].NameTag.Spacer_Clue2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          self.clue2Items[i].NameTag.Spacer_Clue3:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      else
        self.clue2Items[i].NameTag:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
end

function UMG_ScrapbookPanel_C:SetUpClue3()
  local scrapBookListPageInfo = self:GetTargetScrapBookListPageInfo(3)
  if scrapBookListPageInfo then
    local clewStageCount = 0
    for i = 1, #scrapBookListPageInfo.BookData.notebook_keli_data.clews do
      local clew = scrapBookListPageInfo.BookData.notebook_keli_data.clews[i]
      if 0 ~= clew.stage then
        clewStageCount = clewStageCount + 1
      end
    end
    local scrapBookConf = _G.DataConfigManager:GetTaleNotebookKeliConf(3)
    for i = 1, #self.clue3Items do
      local picturePath = string.format("Texture2D'/Game/NewRoco/Modules/System/Task/Raw/NewTask1/Textures/img_Photo%s.img_Photo%s'", i, i)
      self.clue3Items[i].Expert.Picture:SetPath(picturePath)
      if scrapBookListPageInfo.BookData.notebook_keli_data.clews[i] and 0 ~= scrapBookListPageInfo.BookData.notebook_keli_data.clews[i].stage then
        self.clue3Items[i].Expert.index = i
        self.clue3Items[i].Expert.limit = clewStageCount
        if scrapBookConf.clew_done[i].clew_text then
          self.clue3Items[i].NameTag:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          self.clue3Items[i].NameTag.NRCText:SetText(scrapBookConf.clew_done[i].clew_text[1])
          self.clue3Items[i].NameTag.Bg_Clue2:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.clue3Items[i].NameTag.Spacer_Clue1:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.clue3Items[i].NameTag.Spacer_Clue2:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.clue3Items[i].NameTag.Spacer_Clue3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        end
      else
        self.clue3Items[i].NameTag:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
end

function UMG_ScrapbookPanel_C:SetUpClue4()
  local scrapBookListPageInfo = self:GetTargetScrapBookListPageInfo(4)
  if scrapBookListPageInfo then
    local scrapBookConf = _G.DataConfigManager:GetTaleNotebookKeliConf(4)
    for i = 1, #self.clue4Items do
      if scrapBookListPageInfo.BookData.notebook_keli_data.clews[i] and 0 ~= scrapBookListPageInfo.BookData.notebook_keli_data.clews[i].stage then
        local stage = scrapBookListPageInfo.BookData.notebook_keli_data.clews[i].stage
        self.clue4Items[i].Content_Text:SetText(scrapBookConf.clew_done[i].clew_text[stage])
        if scrapBookConf.clew_done[i].clew_res then
          self.clue4Items[i].Envelope:SetPath(scrapBookConf.clew_done[i].clew_res[1])
        end
        self.clue4Items[i].Search:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        self.clue4Items[i].Content_Text:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.clue4Items[i].Envelope:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.clue4Items[i].Search:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  end
end

function UMG_ScrapbookPanel_C:LineUpClues()
  self.bIsLineUp = true
  local distance, angle, X
  if #self.mapMarker - 1 >= 1 then
    for i = 1, #self.mapMarker - 1 do
      for j = i + 1, #self.mapMarker do
        distance, angle, X = self:GetShorTestLengthAndAngleByCoords(self:GetSizeInfo(self.mapMarker[i]), self:GetSizeInfo(self.mapMarker[j]))
        table.insert(self.lineData, {
          distance = distance,
          angle = angle,
          Pos = X
        })
      end
    end
  end
  self:SetLineAndLink()
end

function UMG_ScrapbookPanel_C:LineUpNewClues()
  table.clear(self.lineData)
  local distance, angle, X
  if self.newMarker[1] then
    for i = 1, #self.mapMarker do
      distance, angle, X = self:GetShorTestLengthAndAngleByCoords(self:GetSizeInfo(self.mapMarker[i]), self:GetSizeInfo(self.newMarker[1]))
      table.insert(self.lineData, {
        distance = distance,
        angle = angle,
        Pos = X
      })
    end
  end
  self:SetLineAndPlayNewAnim()
end

function UMG_ScrapbookPanel_C:SetLineAndLink()
  for i = 1, #self.lineData do
    self:SetLineWidgetData(self.allLines[self.lineIndex], self.lineData[i].Pos, self.lineData[i].distance, self.lineData[i].angle)
    if self.lineIndex <= #self.allLines then
      self.allLines[self.lineIndex]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    self.lineIndex = self.lineIndex + 1
  end
  if 4 == #self.lineData then
    self.MapMarker5.MarkPoint:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_ScrapbookPanel_C:SetLineAndPlayNewAnim()
  if self.lineData[1] then
    for i = 1, #self.lineData do
      self:SetLineWidgetData(self.allLines[self.lineIndex], self.lineData[i].Pos, self.lineData[i].distance, self.lineData[i].angle)
      self:PlayAnimation(self.allLineLinkAnim[self.lineIndex])
      if self.lineIndex <= #self.allLines then
        self.allLines[self.lineIndex]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      self.lineIndex = self.lineIndex + 1
    end
    self.curMarker = self.newMarker[1]
    table.insert(self.mapMarker, self.newMarker[1])
  elseif self.newMarker[1] then
    self.newMarker[1].Slot:SetZOrder(3)
    self.newMarker[1].LinkPoint:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    table.insert(self.mapMarker, self.newMarker[1])
    table.remove(self.newMarker, 1)
    self:PlayNameTagNewInAnim()
  end
end

function UMG_ScrapbookPanel_C:GetSizeInfo(widget)
  local Size = UE4.FVector2D(0, 0)
  local CanvasPosition = widget.Slot:GetPosition()
  Size.X = CanvasPosition.X
  Size.Y = CanvasPosition.Y
  return Size
end

function UMG_ScrapbookPanel_C:SetLineWidgetData(LineWidget, Pos, distance, angle)
  if LineWidget then
    local Size = UE4.FVector2D(distance, LineWidget.Slot:GetSize().Y)
    LineWidget.Slot:SetSize(Size)
    LineWidget:SetRenderTransformAngle(angle)
    LineWidget.Slot:SetPosition(UE4.FVector2D(Pos.X, Pos.Y))
  end
end

function UMG_ScrapbookPanel_C:GetLengthAndAngleByCoords(Vector_1, Vector_2, LengthAndAngle)
  local dx = Vector_2.X - Vector_1.X
  local dy = Vector_2.Y - Vector_1.Y
  local distance = math.sqrt(dx * dx + dy * dy)
  local angle = math.atan(dy, dx) * 180 / math.pi
  local newVector = UE4.FVector2D((Vector_2.X + Vector_1.X) / 2, (Vector_2.Y + Vector_1.Y) / 2)
  table.insert(LengthAndAngle, {
    distance = distance,
    angle = angle,
    X = newVector
  })
  return LengthAndAngle
end

function UMG_ScrapbookPanel_C:GetShorTestLengthAndAngleByCoords(Vector_1, Vector_2)
  local LengthAndAngle = {}
  LengthAndAngle = self:GetLengthAndAngleByCoords(Vector_1, Vector_2, LengthAndAngle)
  table.sort(LengthAndAngle, function(a, b)
    return a.distance < b.distance
  end)
  return LengthAndAngle[1].distance + LengthAndAngle[1].distance / 10, LengthAndAngle[1].angle, LengthAndAngle[1].X
end

function UMG_ScrapbookPanel_C:OnAddEventListener()
  self:AddButtonListener(self.BtnClose, self.ClosePanel)
  self:AddButtonListener(self.Btn6.btnLevelUp, self.OnClick_TraceButton)
end

function UMG_ScrapbookPanel_C:OnClick_TraceButton()
  local traceTaskId = 0
  do
    local pageIndex = self:GetPageIndex()
    local blackTextData = self.scrapBookList[pageIndex].BookData.notebook_keli_data.black_text
    local scrapBookConf = _G.DataConfigManager:GetTaleNotebookKeliConf(self.cluePageIndex)
    local stage = blackTextData.stage
    if scrapBookConf.black_done_new then
      local item = scrapBookConf.black_done_new[stage]
      traceTaskId = item and item.trace_task_new or 0
    end
  end
  local TrackingTask = _G.NRCModuleManager:DoCmd(_G.TaskModuleCmd.GetTrackTask)
  local TrackingTaskID = TrackingTask and TrackingTask.Info.id or 0
  local bTracking = TrackingTaskID == traceTaskId
  if bTracking then
    self:DoCancelTraceTask(TrackingTask)
  else
    self:DoTraceTask(traceTaskId)
  end
  self:RefreshTraceBtnText(not bTracking)
end

function UMG_ScrapbookPanel_C:SetEnableClick(CanClick)
  self.Btn2.btnLevelUp:SetIsEnabled(CanClick)
  self.Btn1.btnLevelUp:SetIsEnabled(CanClick)
end

function UMG_ScrapbookPanel_C:PreviousPage()
  local pageIndex = self:GetPageIndex()
  self.cluePageIndex = self.scrapBookList[pageIndex - 1].id
  self:SetEnableClick(false)
  self:SendZoneSetBookReadedReq(self.perviousRedDotIndex)
  self:RefreshCluePageInfo()
  _G.NRCAudioManager:PlaySound2DAuto(1248, "UMG_ScrapbookPanel_C:PreviousPage")
  self:PlayAnimation(self.Change)
  self:PlayAnimation(self.TaskCanvasPanel_change)
end

function UMG_ScrapbookPanel_C:NextPage()
  local pageIndex = self:GetPageIndex()
  self.cluePageIndex = self.scrapBookList[pageIndex + 1].id
  self:SetEnableClick(false)
  self:SendZoneSetBookReadedReq(self.nextRedDotIndex)
  self:RefreshCluePageInfo()
  _G.NRCAudioManager:PlaySound2DAuto(1248, "UMG_ScrapbookPanel_C:NextPage")
  self:PlayAnimation(self.Change)
  self:PlayAnimation(self.TaskCanvasPanel_change)
end

function UMG_ScrapbookPanel_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    self:DoClose()
  elseif Anim == self.Change and 1 ~= self.cluePageIndex then
    self:SetEnableClick(true)
  elseif Anim == self.Change and 1 == self.cluePageIndex then
    self:PlayMapHeadNewInAnim()
    self:SetEnableClick(true)
  elseif Anim == self.In and 1 == self.firstInPageIndex then
    self:PlayMapHeadNewInAnim()
  elseif Anim == self.In and (2 == self.firstInPageIndex or 3 == self.firstInPageIndex) then
    self:PlayNameTagInAnim()
  elseif Anim == self.allLineLinkAnim[1] or Anim == self.allLineLinkAnim[2] or Anim == self.allLineLinkAnim[3] or Anim == self.allLineLinkAnim[4] or Anim == self.allLineLinkAnim[5] then
    self.curMarker.Slot:SetZOrder(3)
    self.curMarker.LinkPoint:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.curMarker:PlayGetAnimation()
  elseif Anim == self.Line_link6 and 0 ~= self.clew_stage[5].stage and self.clew_stage[5].is_new == true then
    if self._animationFinishedTimerId then
      _G.DelayManager:CancelDelayById(self._animationFinishedTimerId)
      self._animationFinishedTimerId = nil
    end
    self._animationFinishedTimerId = _G.DelayManager:DelaySeconds(0.3, function()
      self._animationFinishedTimerId = nil
      self.curMarker.Slot:SetZOrder(3)
      self.MapMarker5.MarkPoint:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.MapMarker5.LinkPoint:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self:ShowLastMapMarker()
    end)
  end
end

function UMG_ScrapbookPanel_C:ShowLastMapMarker()
  self.MapMarker5:PlayGetAnimation()
end

function UMG_ScrapbookPanel_C:PlayNameTagAnimOnClicked(matchIndex, cluePage)
  if 1 == cluePage then
    self.clue1Items[matchIndex].NameTag:OnTagClicked()
  elseif 2 == cluePage then
    self.clue2Items[matchIndex].NameTag:OnTagClicked()
  elseif 3 == cluePage then
    self.clue3Items[matchIndex].NameTag:OnTagClicked()
  end
end

function UMG_ScrapbookPanel_C:OnDestruct()
  if self._animationFinishedTimerId then
    _G.DelayManager:CancelDelayById(self._animationFinishedTimerId)
    self._animationFinishedTimerId = nil
  end
end

return UMG_ScrapbookPanel_C
