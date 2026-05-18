local UIUtils = require("NewRoco.Utils.UIUtils")
local PetTeamUtils = require("NewRoco.Modules.System.PetUI.Res.PetTeam.PetTeamUtils")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_FriendTeamPanel_C = _G.NRCPanelBase:Extend("UMG_FriendTeamPanel_C")

function UMG_FriendTeamPanel_C:OnConstruct()
  self.data = self.module:GetData("PetUIModuleData")
  local maxInputConfig = _G.DataConfigManager:GetGlobalConfig("share_pet_search_word_limit", true)
  self.maxInputLength = maxInputConfig and maxInputConfig.num or 10
  self:OnAddEventListener()
  UIUtils.SafeSetVisibility(self.BtnRefresh, UE4.ESlateVisibility.Collapsed, true)
end

function UMG_FriendTeamPanel_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_FriendTeamPanel_C:OnActive(teamType, bOpenFromActivity)
  _G.NRCAudioManager:PlaySound2DAuto(40006003, "UMG_FriendTeamPanel_C:OnDoubtBtnClicked")
  self.bOpenFromActivity = bOpenFromActivity
  if bOpenFromActivity then
    self.NRCSwitcher_143:SetActiveWidgetIndex(1)
    self.BtnRefresh:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Explanation:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.LineupFriends:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CaptureBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCScaleBox_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.NRCSwitcher_143:SetActiveWidgetIndex(0)
    self.TeamType = teamType or Enum.PlayerTeamType.PTT_INVALID
    if self.TeamType == Enum.PlayerTeamType.PTT_INVALID then
      Log.ErrorFormat("UMG_FriendTeamPanel_C:OnActive called with invalid team type: %s", tostring(self.TeamType))
    end
  end
  self:UpdateUIInfo()
end

function UMG_FriendTeamPanel_C:OnDeactive()
  if self.module then
    if self.bOpenFromActivity then
      self.data:SetShiningWeekendTeamOpenIndex()
    else
      self.module:TryRefreshPetTeamPanel()
    end
  end
end

function UMG_FriendTeamPanel_C:OnAddEventListener()
  self:RegisterEvent(self, PetUIModuleEvent.UpdateFriendPetTeamList, self.UpdateUIInfo)
  _G.NRCEventCenter:RegisterEvent("UMG_FriendTeamPanel_C", self, PetUIModuleEvent.PetTeamManagementSelChanged, self.OnPetTeamManagementSelChanged)
  self.InputBox.OnTextChanged:Add(self, self.OnTextChanged)
  self.InputBox.OnTextEndTransaction:Add(self, self.OnTextEndTransaction)
  self:AddButtonListener(self.Btn_Search.btnLevelUp, self.OnSearchButtonClicked)
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseBtnClicked)
  self:AddButtonListener(self.Btn_paste, self.OnPastBtnClicked)
  self:AddButtonListener(self.Btn_Delete, self.OnClearInputBoxBtnClicked)
  self:AddButtonListener(self.Btn2.btnLevelUp, self.OnDoubtBtnClicked)
end

function UMG_FriendTeamPanel_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, PetUIModuleEvent.UpdateFriendPetTeamList)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.PetTeamManagementSelChanged, self.OnPetTeamManagementSelChanged)
end

function UMG_FriendTeamPanel_C:OnPetTeamManagementSelChanged()
  self:UpdateUIInfo()
end

function UMG_FriendTeamPanel_C:UpdateUIInfo()
  if self.bOpenFromActivity then
    local recommendTeamList = self.data:GetRecommendPetTeamList()
    if recommendTeamList then
      UIUtils.SafeSetVisibility(self.FriendItemList_1, UE4.ESlateVisibility.Visible)
      self.FriendItemList_1:InitList(recommendTeamList)
    else
      UIUtils.SafeSetVisibility(self.FriendItemList_1, UE4.ESlateVisibility.Collapsed)
      self.FriendItemList_1:Clear()
    end
  else
    local friendPetTeamResultInfo = self.data:GetFriendPetTeamResultInfo()
    local petTeamList = self.data:GetSortedFriendPetTeamList()
    if petTeamList and #petTeamList > 0 then
      UIUtils.SafeSetVisibility(self.Empty, UE4.ESlateVisibility.Collapsed)
      UIUtils.SafeSetVisibility(self.Content, UE4.ESlateVisibility.Visible)
      local keepScrollOffset = friendPetTeamResultInfo.ReqPageIndex > 0
      local scrollOffset = self.FriendItemList:GetScrollOffset()
      UIUtils.SafeSetVisibility(self.FriendItemList, UE4.ESlateVisibility.Visible)
      self.FriendItemList:InitList(petTeamList)
      if keepScrollOffset then
        self.FriendItemList:NRCSetScrollOffset(scrollOffset)
      end
    else
      UIUtils.SafeSetVisibility(self.Empty, UE4.ESlateVisibility.Visible)
      UIUtils.SafeSetVisibility(self.Content, UE4.ESlateVisibility.Collapsed)
      UIUtils.SafeSetVisibility(self.FriendItemList, UE4.ESlateVisibility.Collapsed)
      self.FriendItemList:Clear()
    end
    local curMirrorNum, MaxMirrorNum = PetTeamUtils.GetMirrorTeamNumByTeamType(self.TeamType)
    self.LineupFriends:InitNum(curMirrorNum, MaxMirrorNum, LuaText.share_pet_mirror_team_num)
  end
  self:RefreshCommonTitle(self.TeamType)
end

function UMG_FriendTeamPanel_C:RefreshCommonTitle(teamType)
  if self.bOpenFromActivity then
    local titleConf = _G.DataConfigManager:GetTitleConf("RecommendedLineup1")
    self.Title:SetBaseInfo(titleConf.head_icon, titleConf.subtitle[1].subtitle, titleConf.title)
  else
    local allBattleTypeConf = _G.DataConfigManager:GetAllByName("BATTLE_TYPE_CONF")
    for i, v in pairs(allBattleTypeConf) do
      if v.player_team_type == teamType then
        self.Title:Set_MainTitle(v.name)
        break
      end
    end
  end
end

function UMG_FriendTeamPanel_C:OnTextChanged()
  if self._isPinYin then
    return
  end
  local text = self.InputBox:GetSelectedText()
  if text and "" ~= text then
    self._isPinYin = true
    return
  end
  local NewInput = self.InputBox:GetText()
  local MaxCount = self.maxInputLength
  local MaxContent, CurrentNum = string.GetSubStr(NewInput, MaxCount)
  if NewInput and NewInput ~= MaxContent then
    NewInput = MaxContent
    self.InputBox:SetText(MaxContent)
    local tips = _G.DataConfigManager:GetLocalizationConf("chat_message_send_empty_tips3").msg
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tips)
  end
  if NewInput and "" ~= NewInput then
    self:SetPastDeleteUI(true)
  else
    self:SetPastDeleteUI(false)
    if self.data:IsFriendPetTeamSearching() then
      self.module:OnZonePetTeamFriendGetListReq(self.TeamType, 0, "")
    end
  end
end

function UMG_FriendTeamPanel_C:SetPastDeleteUI(hasInput)
  if hasInput then
    self.NRCSwitcher_91:SetActiveWidgetIndex(1)
  else
    self.NRCSwitcher_91:SetActiveWidgetIndex(0)
  end
end

function UMG_FriendTeamPanel_C:OnTextEndTransaction()
  self._isPinYin = false
  self:OnTextChanged()
end

function UMG_FriendTeamPanel_C:OnSearchButtonClicked()
  _G.NRCAudioManager:PlaySound2DAuto(40008005, "UMG_FriendTeamPanel_C:OnSearchButtonClicked")
  local searchText = self.InputBox:GetText()
  if searchText and "" ~= searchText then
    self.module:OnZonePetTeamFriendGetListReq(self.TeamType, 0, searchText)
  else
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.share_pet_search_empty_content)
  end
end

function UMG_FriendTeamPanel_C:OnCloseBtnClicked()
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_FriendTeamPanel_C:OnCloseBtnClicked")
  self:PlayAnimation(self.Out)
end

function UMG_FriendTeamPanel_C:OnDoubtBtnClicked()
  _G.NRCAudioManager:PlaySound2DAuto(41401011, "UMG_FriendTeamPanel_C:OnDoubtBtnClicked")
  local titleText = LuaText.share_pet_notice_title
  local contentStr = _G.LuaText.share_pet_help_text
  local Context = DialogContext()
  Context:SetTitle(titleText):SetContent(contentStr):SetMode(DialogContext.Mode.NotBtn):SetCloseOnOK(true):SetClickAnywhereClose(true)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenLongDialog, Context)
end

function UMG_FriendTeamPanel_C:OnClearInputBoxBtnClicked()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_FriendTeamPanel_C:OnClearInputBoxBtnClicked")
  self.InputBox:SetText("")
end

function UMG_FriendTeamPanel_C:OnPastBtnClicked()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_FriendTeamPanel_C:OnPastBtnClicked")
  local Text = UE4.UNRCStatics.ClipboardPaste()
  self.InputBox:SetText(Text)
end

return UMG_FriendTeamPanel_C
