local TeachingManualModuleEvent = require("NewRoco.Modules.System.TeachingManual.TeachingManualModuleEvent")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local UMG_TeachingManual_C = _G.NRCPanelBase:Extend("UMG_TeachingManual_C")

function UMG_TeachingManual_C:OnConstruct()
  _G.DataModelMgr.PlayerDataModel:AddPanelMusic(Enum.MusicApplyType.MAT_UI, Enum.InterfaceType.IT_TEACH)
  local StateGroup = _G.DataModelMgr.PlayerDataModel:GetStateGroupByApplyEnum(Enum.MusicApplyType.MAT_UI, Enum.InterfaceType.IT_TEACH)
  if StateGroup then
    _G.NRCAudioManager:BatchSetState(StateGroup)
  end
  self.data = self.module:GetData("TeachingManualModuleData")
  self.GuideStruct = {}
  self.SelectTeachListIndex = 0
  self.IsPlayIn_2 = true
  self.animTime = 0.25
  self.lastTeachListIndex = 0
  self.bShouldScroll = true
  self.bCanInteract = true
  self.soundPlayed = false
  self.curQuickJumpCmd = nil
  self:OnAddEventListener()
  self:SetCommonTitle()
  self.QuickJumpBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local teachConf = _G.DataConfigManager:GetAllByName("TEACH_TAB_CONF")
  self.AllTabs:InitGridView(teachConf)
  self:BindInputAction()
  self.ScrollPageController:SetPageChangeHandler(self.OnPageChangeHandle, self)
end

function UMG_TeachingManual_C:OnDestruct()
  self.module.HasNewTeach = false
  _G.DataModelMgr.PlayerDataModel:RemovePanelMusic(Enum.MusicApplyType.MAT_UI, Enum.InterfaceType.IT_TEACH)
  _G.NRCEventCenter:DispatchEvent(MainUIModuleEvent.UI_Refresh_TeachRed)
  _G.NRCModuleManager:DoCmd(_G.TeachingManualModuleCmd.ResetTeachId)
end

function UMG_TeachingManual_C:OnActive()
  self.firstSelectItem = true
  if self.data.NewDataTableIndex > -1 then
    self.AllTabs:SelectItemByIndex(self.data.NewDataTableIndex - 1)
    self.data.NewDataTableIndex = -1
  else
    self.AllTabs:SelectItemByIndex(0)
  end
  self:PlayAnimation(self.Page_In)
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "LobbyMain").TASKITEM
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "MainUIModule", "LobbyMain", touchReasonType)
  if _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.ShouldDisableForNow) then
    _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.OnLobbyMainInnerSubPanelLoaded)
  end
end

function UMG_TeachingManual_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_GuideUI")
  if mappingContext then
    mappingContext:BindAction("IA_CloseGuideUI", self, "OnPcClose")
    mappingContext:BindAction("IA_CloseGuideQuick", self, "OnPcClose")
  end
end

function UMG_TeachingManual_C:UnBindInputAction()
  local mappingContext = self:GetInputMappingContext("IMC_GuideUI")
  if mappingContext then
    mappingContext:UnBindAction("IA_CloseGuideUI")
    mappingContext:UnBindAction("IA_CloseGuideQuick")
  end
end

function UMG_TeachingManual_C:OnPcClose()
  if self:GetVisibility() ~= UE4.ESlateVisibility.Visible and self:GetVisibility() ~= UE4.ESlateVisibility.SelfHitTestInvisible then
    return
  end
  self:OnCloseBtn()
end

function UMG_TeachingManual_C:OnPageChangeHandle(_page)
  self.bCanInteract = true
  self.SelectTeachListIndex = _page + 1
  self.bShouldScroll = false
  local item = self.Dot_List:GetSelectedItem()
  if item then
    item:SelectInfo(false)
  end
  if self.soundPlayed then
    self.firstSelectViewPic = true
  else
    self.firstSelectViewPic = false
  end
  self.Dot_List:SelectItemByIndex(_page)
  item = self.Dot_List:GetSelectedItem()
  if item then
    item:SelectInfo(true)
  end
  self.soundPlayed = false
end

function UMG_TeachingManual_C:UpdateInfoByTeachManualTab(_TabIndex)
  _G.NRCAudioManager:PlaySound2DAuto(1004, "UMG_LevelMain_C:OnSystemIconClicked")
  local ScrollOffset = self.ItemList_3:GetScrollOffset()
  if ScrollOffset then
    self.data:SetCurTeachManualScrollOffset(ScrollOffset)
  end
  local TeachTabConf = _G.DataConfigManager:GetTeachTabConf(_TabIndex)
  self.data:SetSelectTeachManualTab(_TabIndex)
  local ManualList = self.data:GetManualListByTeachManualIndex(_TabIndex)
  self:RefreshCommonTitle(_TabIndex)
  if #ManualList.TeachList <= 0 then
    self.DialogCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Picture:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn_Left:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn_Right:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Dot_List:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ItemList_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.UnlockText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.QuickJumpBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  else
    self.DialogCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Picture:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ItemList_3:SetVisibility(UE4.ESlateVisibility.Visible)
    self.UnlockText:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.QuickJumpBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  local LastNum = self.ItemList_3:GetItemCount()
  for i = 1, LastNum do
    local Item = self.ItemList_3:GetItemByIndex(i - 1)
    if Item and Item.DelayId then
      DelayManager:CancelDelayById(Item.DelayId)
      Item.DelayId = nil
      Item:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  self.ItemList_3:ClearSelection()
  self.ItemList_3:InitList(ManualList.TeachList)
  local SelectIndex = ManualList.TeachIndex
  if -1 == ManualList.TeachIndex then
    SelectIndex = 0
  end
  ScrollOffset = self.ItemList_3:GetDesiredScrollOffsetByIndex(SelectIndex)
  self.ItemList_3:SelectItemByIndex(SelectIndex)
  self.ItemList_3:SetScrollOffset(ScrollOffset)
  self.data:SetTeachSelectIndex(_TabIndex, 0)
end

function UMG_TeachingManual_C:OnDeactive()
  GlobalConfig.OpenMainPanelFromDebugBtn = 0
end

function UMG_TeachingManual_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseBtn)
  self:AddButtonListener(self.Btn_Left, self.OnBtnLeft)
  self:AddButtonListener(self.Btn_Right, self.OnBtnRight)
  self:RegisterEvent(self, TeachingManualModuleEvent.SelectTeachManualTab, self.OnSelectTeachManualTab)
  self:RegisterEvent(self, TeachingManualModuleEvent.SelectTeachListIndex, self.OnSelectTeachListIndex)
  self:RegisterEvent(self, TeachingManualModuleEvent.SelectViewPicture, self.OnPreselectViewPicture)
  self:AddButtonListener(self.QuickJumpBtn.btnLevelUp, self.OnQuickJumpBtnClicked)
end

function UMG_TeachingManual_C:RefreshCommonTitle(_TabIndex)
  if 1 == _TabIndex then
    if self.titleConf and self.titleConf.subtitle then
      self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
    end
  elseif 2 == _TabIndex then
    if self.titleConf and self.titleConf.subtitle then
      self.Title1:SetSubtitle(self.titleConf.subtitle[2].subtitle)
    end
  elseif 3 == _TabIndex then
    if self.titleConf and self.titleConf.subtitle then
      self.Title1:SetSubtitle(self.titleConf.subtitle[3].subtitle)
    end
  elseif 4 == _TabIndex then
    if self.titleConf and self.titleConf.subtitle then
      self.Title1:SetSubtitle(self.titleConf.subtitle[4].subtitle)
    end
  elseif 5 == _TabIndex and self.titleConf and self.titleConf.subtitle then
    self.Title1:SetSubtitle(self.titleConf.subtitle[5].subtitle)
  end
end

function UMG_TeachingManual_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_TeachingManual_C:OnSelectTeachManualTab(_TabIndex)
  local SelectTeachManualIndex = _G.NRCModeManager:DoCmd(TeachingManualModuleCmd.GetSelectTeachManualIndex)
  self.IsPlayIn_2 = false
  self:PlayAnimation(self.In_1)
  if 2 == GlobalConfig.OpenMainPanelFromDebugBtn then
    _TabIndex = 2
  elseif 3 == GlobalConfig.OpenMainPanelFromDebugBtn then
    _TabIndex = 3
  elseif 4 == GlobalConfig.OpenMainPanelFromDebugBtn then
    _TabIndex = 4
  end
  self.SkipAudioSelectTeachList = false
  self:UpdateInfoByTeachManualTab(_TabIndex)
end

function UMG_TeachingManual_C:OnSelectTeachListIndex(TeachConf)
  if self.SkipAudioSelectTeachList then
    _G.NRCAudioManager:PlaySound2DAuto(1001, "UMG_LevelMain_C:OnSystemIconClicked")
  else
    self.SkipAudioSelectTeachList = true
  end
  local GuideStruct = TeachConf.guide_struct
  self.Picture:InitList(GuideStruct)
  self.Picture:SetScrollOffset(0.0)
  self.ScrollPageController:SetValidItemTotalNum(#GuideStruct)
  self.Dot_List:InitGridView(GuideStruct)
  self.GuideStruct = GuideStruct
  self.SelectTeachListIndex = 0
  self.Dot_List:SelectItemByIndex(self.SelectTeachListIndex)
  self:InitTeachingContent(GuideStruct[1])
  if not self.firstSelectItem then
    self:RefreshSelectItemState()
  end
  if 1 == #GuideStruct then
    self.Dot_List:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Dot_List:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.IsPlayIn_2 then
    self:PlayAnimation(self.In_2)
  end
  self.IsPlayIn_2 = true
end

function UMG_TeachingManual_C:InitRewardInfo(rewardId)
end

function UMG_TeachingManual_C:InitTeachingContent(guideStruct)
  self:SetPanelRightInfo()
  if self.module:IsPCMode() then
    self.Title:SetText(guideStruct.title_PC)
    self.Dialogue:SetText(guideStruct.text_PC)
  else
    self.Title:SetText(guideStruct.title)
    self.Dialogue:SetText(guideStruct.text)
  end
  self.Dot_List:SelectItemByIndex(0)
  local item = self.Dot_List:GetItemByIndex(0)
  if item then
    item:SelectInfo(true)
  end
  self:UpdateQuickJumpBtnState(guideStruct)
end

function UMG_TeachingManual_C:RefreshSelectItemState()
  local selectItem = self.ItemList_3:GetSelectedItem()
  if not selectItem then
    return
  end
  local TeachConf = selectItem.data.TeachList
  if selectItem.data and selectItem.data.Status ~= ProtoEnum.PlayerTeachInfo.TeachStatus.READED then
    selectItem:SetReadState()
    self:SetPlayerTeachReadedReq(selectItem.data.TeachList.id)
  elseif TeachConf.reward_id and 0 ~= TeachConf.reward_id then
    self:InitRewardInfo(TeachConf.reward_id)
  end
end

function UMG_TeachingManual_C:SetPlayerTeachReadedReq(TeachId)
  if self.waitForTeachRewardRsp then
    return
  end
  self.waitForTeachRewardRsp = true
  local req = _G.ProtoMessage:newZoneSetPlayerTeachReadedReq()
  req.teach_id = TeachId
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SET_PLAYER_TEACH_READED_REQ, req, self, self.OnZoneSetPlayerTeachReadedRsp, false, true)
end

function UMG_TeachingManual_C:OnZoneSetPlayerTeachReadedRsp(Rsp)
  if 0 == Rsp.ret_info.ret_code then
    local selectItem = self.ItemList_3:GetSelectedItem()
    if Rsp.ret_info.goods_reward then
    end
    selectItem:SetReadState()
  elseif Rsp.ret_info.ret_code == 1045 then
    Log.Debug("\233\135\141\229\164\141\233\162\134\229\165\150")
  else
    local key = string.format("Error_Code_%d", Rsp.ret_info.ret_code)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText[key])
  end
  self.waitForTeachRewardRsp = false
end

function UMG_TeachingManual_C:RefreshTabRedPoint()
  local num = #self.data.TeachManualList
  for i = 1, num do
    local TeachList = self.data.TeachManualList[i].TeachList
    for j = 1, #TeachList do
      if TeachList[j].Status ~= ProtoEnum.PlayerTeachInfo.TeachStatus.READED then
        break
      end
      if j == #TeachList then
      end
    end
  end
end

function UMG_TeachingManual_C:OnPreselectViewPicture(GuideStruct, CurPictureIndex)
  self:OnSelectViewPicture(GuideStruct, CurPictureIndex)
  self.soundPlayed = true
end

function UMG_TeachingManual_C:OnSelectViewPicture(GuideStruct, CurPictureIndex, bIsBtnClicked)
  local totalAnimTime = self.animTime * math.abs(self.SelectTeachListIndex - (CurPictureIndex - 1))
  if 0 == totalAnimTime then
    self:UpdateQuickJumpBtnState(GuideStruct)
    return
  end
  if self.firstSelectViewPic then
    self.firstSelectViewPic = false
  else
  end
  if self.ScrollPageController:IsScrolling() then
    return
  end
  self.SelectTeachListIndex = CurPictureIndex - 1
  if self.module:IsPCMode() then
    self.Title:SetText(GuideStruct.title_PC)
    self.Dialogue:SetText(GuideStruct.text_PC)
  else
    self.Title:SetText(GuideStruct.title)
    self.Dialogue:SetText(GuideStruct.text)
  end
  if self.bShouldScroll then
    self.ScrollPageController:ScrollToPage(self.SelectTeachListIndex, totalAnimTime)
  else
    _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_MagicManual_Task_Tads_C:SelectTaskType")
  end
  if not self.bShouldScroll and not bIsBtnClicked then
    self.bShouldScroll = true
  end
  self:UpdateQuickJumpBtnState(GuideStruct)
  self:SetPanelRightInfo()
end

function UMG_TeachingManual_C:SetPanelRightInfo()
  if 1 == #self.GuideStruct then
    self.Btn_Right:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn_Left:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif self.SelectTeachListIndex >= #self.GuideStruct - 1 then
    self.Btn_Right:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn_Left:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif 0 == self.SelectTeachListIndex then
    self:UpdateRightBtnRed()
    self.Btn_Right:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Btn_Left:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self:UpdateRightBtnRed()
    self.Btn_Right:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Btn_Left:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_TeachingManual_C:UpdateRightBtnRed()
end

function UMG_TeachingManual_C:OnBtnLeft()
  if not self.bCanInteract then
    return
  end
  self.bCanInteract = false
  local index = self.SelectTeachListIndex - 1
  if index <= 0 then
    index = 0
  end
  self.IsPlayIn_2 = false
  self:OnSelectViewPicture(self.GuideStruct[index + 1], index + 1, true)
  self.soundPlayed = true
end

function UMG_TeachingManual_C:btnLeftOnPressed()
  self:PlayAnimationTimeRange(self.Sel_Btn_Left, 0, 0.08)
end

function UMG_TeachingManual_C:btnLeftOnReleased()
  self:PlayAnimationTimeRange(self.Sel_Btn_Left, 0.08)
end

function UMG_TeachingManual_C:btnRightOnPressed()
  self:PlayAnimationTimeRange(self.Sel_Btn_Right, 0, 0.08)
end

function UMG_TeachingManual_C:btnRightOnReleased()
  self:PlayAnimationTimeRange(self.Sel_Btn_Right, 0.08)
end

function UMG_TeachingManual_C:OnBtnRight()
  if not self.bCanInteract then
    return
  end
  self.bCanInteract = false
  local index = self.SelectTeachListIndex + 1
  if self.GuideStruct and index >= #self.GuideStruct - 1 then
    index = #self.GuideStruct - 1
  end
  if index < 0 then
    index = 0
    Log.Error("\228\191\157\230\138\164\230\156\186\229\136\182,\233\128\137\228\184\173\230\128\129\230\156\137\233\151\174\233\162\152,\232\175\183\230\159\165\231\156\139\233\128\137\228\184\173\230\128\129\233\128\187\232\190\145")
  end
  self.IsPlayIn_2 = false
  self:OnSelectViewPicture(self.GuideStruct[index + 1], index + 1, true)
  self.soundPlayed = true
end

function UMG_TeachingManual_C:OnCloseBtn()
  self:UnBindInputAction()
  _G.NRCAudioManager:PlaySound2DAuto(1008, "UMG_LevelMain_C:OnSystemIconClicked")
  self:OnClose()
end

function UMG_TeachingManual_C:OnAnimationFinished(Animation)
  if Animation == self.Page_Out then
    self.data:InitializeListSelect()
    _G.NRCEventCenter:DispatchEvent(MainUIModuleEvent.OnMainUISubPanelClosed, false)
    self:DoClose()
  elseif Animation == self.Page_In then
    if self.firstSelectItem then
      self.firstSelectItem = false
      self:RefreshSelectItemState()
    end
    self:PlayAnimation(self.loop)
  end
end

function UMG_TeachingManual_C:UpdateQuickJumpBtnState(guideStruct)
  self.curQuickJumpCmd = self:GetGuideStructCmd(guideStruct)
  if self.curQuickJumpCmd and not string.IsNilOrEmpty(self.curQuickJumpCmd) then
    self.QuickJumpBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.QuickJumpBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_TeachingManual_C:GetGuideStructCmd(guideStruct)
  if not guideStruct then
    return nil
  end
  local cmd
  if self.module:IsPCMode() then
    cmd = guideStruct.cmd_PC
    if string.IsNilOrEmpty(cmd) then
      cmd = guideStruct.cmd
    end
  else
    cmd = guideStruct.cmd
    if string.IsNilOrEmpty(cmd) then
      cmd = guideStruct.cmd_PC
    end
  end
  return cmd
end

function UMG_TeachingManual_C:OnQuickJumpBtnClicked()
  if not self.curQuickJumpCmd or string.IsNilOrEmpty(self.curQuickJumpCmd) then
    return
  end
  _G.NRCModuleManager:DoCmd(_G.TeachingManualModuleCmd.JumpToRelatedFunction, self.curQuickJumpCmd)
end

return UMG_TeachingManual_C
