local UIUtils = require("NewRoco.Utils.UIUtils")
local JsonUtils = require("Common.JsonUtils")
local PetTeamUtils = require("NewRoco.Modules.System.PetUI.Res.PetTeam.PetTeamUtils")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local AICoachModuleUtils = require("NewRoco.Modules.System.AICoachModule.AICoachModuleUtils")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local AICoachModuleEvent = require("NewRoco.Modules.System.AICoachModule.AICoachModuleEvent")
local rapidjson = require("rapidjson")
local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")
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

function UMG_FriendTeamPanel_C:OnActive(teamType, bOpenFromActivity, activityID)
  _G.NRCAudioManager:PlaySound2DAuto(40006003, "UMG_FriendTeamPanel_C:OnDoubtBtnClicked")
  self.isReverse = false
  self.bOpenFromActivity = bOpenFromActivity
  self.activityID = activityID
  local isAICoachOpen = _G.NRCModuleManager:DoCmd(_G.AICoachModuleCmd.GetIsCurrAICoachOpen)
  local isAIInWhiteList = _G.NRCModuleManager:DoCmd(_G.AICoachModuleCmd.GetIsPlayerInWhiteList)
  local isSystemOpen = _G.NRCModuleManager:DoCmd(_G.AICoachModuleCmd.GetSysAICoachSceneIsOpen, Enum.FunctionEntrance.FE_AI_COACH_TEAM)
  self.isShowAIEntry = isAICoachOpen and isAIInWhiteList and isSystemOpen
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
  self:PlayAnimation(self.In)
  self:UpdateUIInfo()
  self:OnUpdateAICoachInfo(bOpenFromActivity)
end

function UMG_FriendTeamPanel_C:OnDeactive()
  if self.module then
    if self.bOpenFromActivity then
      self.data:SetShiningWeekendTeamOpenIndex()
    else
      self.module:TryRefreshPetTeamPanel()
    end
  end
  if self.bOpenFromActivity and self.isShowAIEntry then
    self.AICoachGvoice1:OnDeactive()
    _G.NRCModuleManager:DoCmd(_G.AICoachModuleCmd.OnCloseAICoachByScene, Enum.AIcoachSceneType.AST_Group_Recommend)
  end
end

function UMG_FriendTeamPanel_C:OnAddEventListener()
  self:RegisterEvent(self, PetUIModuleEvent.UpdateFriendPetTeamList, self.UpdateUIInfo)
  _G.NRCEventCenter:RegisterEvent("UMG_FriendTeamPanel_C", self, PetUIModuleEvent.PetTeamManagementSelChanged, self.OnPetTeamManagementSelChanged)
  _G.NRCEventCenter:RegisterEvent("UMG_FriendTeamPanel_C", self, AICoachModuleEvent.OnNotifyAICoachTeamRecommend, self.OnNotifyAICoachTeamRecommend)
  _G.NRCEventCenter:RegisterEvent("UMG_FriendTeamPanel_C", self, AICoachModuleEvent.OnRecoverSceneAICoachState, self.OnRecoverSceneAICoachState)
  _G.NRCEventCenter:RegisterEvent("UMG_FriendTeamPanel_C", self, PetUIModuleEvent.UseAICoachRecommendTeam, self.UseAICoachRecommendTeam)
  _G.NRCEventCenter:RegisterEvent("UMG_FriendTeamPanel_C", self, FriendModuleEvent.OpenChatGvoicePanel, self.OnOpenAIRequest)
  _G.NRCEventCenter:RegisterEvent("UMG_FriendTeamPanel_C", self, FriendModuleEvent.OpenAIChatGvoicePanel, self.OnOpenAIRequestText)
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
  _G.NRCEventCenter:UnRegisterEvent(self, AICoachModuleEvent.OnNotifyAICoachTeamRecommend, self.OnNotifyAICoachTeamRecommend)
  _G.NRCEventCenter:UnRegisterEvent(self, AICoachModuleEvent.OnRecoverSceneAICoachState, self.OnRecoverSceneAICoachState)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.UseAICoachRecommendTeam, self.UseAICoachRecommendTeam)
  _G.NRCEventCenter:UnRegisterEvent(self, FriendModuleEvent.OpenChatGvoicePanel, self.OnOpenAIRequest)
  _G.NRCEventCenter:UnRegisterEvent(self, FriendModuleEvent.OpenAIChatGvoicePanel, self.OnOpenAIRequestText)
end

function UMG_FriendTeamPanel_C:OnPetTeamManagementSelChanged()
  self:UpdateUIInfo()
end

function UMG_FriendTeamPanel_C:OnRecoverSceneAICoachState(sceneType)
  if sceneType == Enum.AIcoachSceneType.AST_Group_Recommend then
    self.AICoachGvoice1:RecoverSceneAICoachState()
  end
end

function UMG_FriendTeamPanel_C:OnAnimationFinished(anim)
  if anim == self.In then
    self:PlayAnimation(self.Loop)
  elseif anim == self.Out then
    self:DoClose()
  end
end

function UMG_FriendTeamPanel_C:OnNotifyAICoachTeamRecommend(teamData)
  self.data:SetAICoachRecommendTeamUIData({
    teamData = teamData,
    activityID = self.activityID
  })
  local teamShareCode = NRCModuleManager:DoCmd(_G.PetUIModuleCmd.EncodeShareTeamCode, teamData.pet_team_info.pets, teamData.pet_team_info.role_magic_id, teamData.pet_team_info.team_type, teamData.team_name)
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenLoadPetTeamPanel, teamData.pet_team_info.team_type, -1, teamShareCode)
end

function UMG_FriendTeamPanel_C:UseAICoachRecommendTeam(teamData)
  self.data:SetAICoachRecommendTeamUIData({
    teamData = teamData,
    activityID = self.activityID
  })
end

function UMG_FriendTeamPanel_C:OnUpdateAICoachInfo(bOpenFromActivity)
  if bOpenFromActivity and self.isShowAIEntry then
    self.AICoachGvoice1:OnActive()
    self.AICoachGvoice1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.AICoachGvoice1:OnOpenAICoach(Enum.AIcoachSceneType.AST_Group_Recommend, true)
    self.AICoachGvoice1:SetAICoachClickCallback(self, self.OnOpenAIRequestText)
    _G.NRCModuleManager:DoCmd(_G.AICoachModuleCmd.OnOpenAICoachBySceneType, Enum.AIcoachSceneType.AST_Group_Recommend)
    self:PlayAICoachGuide()
    _G.NRCModuleManager:DoCmd(_G.AICoachModuleCmd.OnReportEvent, "team_recomm_page_expo")
  else
    self.AICoachGvoice1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_FriendTeamPanel_C:PlayAICoachGuide()
  local playerInfo = DataModelMgr.PlayerDataModel:GetPlayerInfo()
  local key = "AICoachGuideRecode" .. tostring(playerInfo.brief_info.uin)
  local CacheFile = JsonUtils.LoadSaved(key, {}) or {}
  if CacheFile and CacheFile.isGuide then
  else
    _G.NRCModuleManager:DoCmd(_G.GuidanceModuleCmd.StartLocalGuideGroup, 7002)
    JsonUtils.DumpSaved(key, {isGuide = true})
  end
end

function UMG_FriendTeamPanel_C:OnOpenAIRequestText()
  if self.module:HasPanel("AdjustTeam") then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(40002013, "UMG_FriendTeamPanel_C:OnOpenAIRequestText")
  self.AIChatGvoice:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.AIChatGvoice:OnInitialize()
end

function UMG_FriendTeamPanel_C:OnOpenAIRequest()
  if self.module:HasPanel("AdjustTeam") then
    return
  end
  local bGranted = UE.UNRCPermissionMgr.IfPermissionGranted(UE.ENRCPermissionType.RecordAudio)
  if RocoEnv.PLATFORM == "PLATFORM_WINDOWS" then
    bGranted = true
  end
  if bGranted then
    self.AIGvoice:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.AIGvoice:OnInitialize(nil, FriendEnum.VoiceInputScene.AICoach)
    self.AIGvoice:PlayerAnimIn()
    self.AIGvoice:StartActive()
    _G.NRCModuleManager:DoCmd(_G.AICoachModuleCmd.OnReportEvent, "team_recomm_coach_icon_click")
    _G.NRCModuleManager:DoCmd(_G.AICoachModuleCmd.SetAICoachTeamDiffJson, self:GetCurrTeamListData())
  else
    local IsFirstTime = UE.UNRCPermissionMgr.IsFirstTimeRequest(UE.ENRCPermissionType.RecordAudio)
    if IsFirstTime then
      self.RequestPermission = UE.UNRCPermissionMgr.RequestPermission(UE.ENRCPermissionType.RecordAudio, {
        self,
        function(_, bGranted)
          self.RequestPermission = nil
          if bGranted then
          else
            _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.chat_gvoice_microphone_premission_not_open)
          end
        end
      })
    else
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.chat_gvoice_microphone_premission_not_open)
    end
  end
end

function UMG_FriendTeamPanel_C:ReportRecommendTeamForAICoach(recommendTeamList)
  if self.isShowAIEntry and self.bOpenFromActivity then
    local teamList = {}
    for i, v in pairs(recommendTeamList) do
      local info = v
      if not info.pet_team_info then
        local code = self.module:RemoveCodeAnnotation(info.pet_team_share_id)
        info.pet_team_info = self.module:DecodeShareData(code)
        info.pet_team_info.team_type = _G.Enum.PlayerTeamType.PTT_PVP_BATTLE_4
      end
      table.insert(teamList, info)
    end
    local keyIndex = 1
    for i, v in pairs(teamList) do
      local key = ""
      local aiPlayerName = _G.DataConfigManager:GetGlobalConfigByKeyType("ai_coach_player_name", _G.DataConfigManager.ConfigTableId.GLOBAL_CONFIG).str
      local aiTeamName = _G.DataConfigManager:GetGlobalConfigByKeyType("ai_coach_team_name", _G.DataConfigManager.ConfigTableId.GLOBAL_CONFIG).str
      if v.player_name == aiPlayerName and v.team_name == aiTeamName then
        key = "coach_recom_team_pets"
      else
        key = string.format("recommand_team%d_pets", keyIndex)
        keyIndex = keyIndex + 1
      end
      _G.NRCModuleManager:DoCmd(_G.AICoachModuleCmd.OnReportRecommendTeam, key, v)
    end
  end
end

function UMG_FriendTeamPanel_C:GetCurrTeamListData()
  local teamList = {}
  local teamListData = {}
  local recommendTeamList = self.data:GetRecommendPetTeamList()
  for i, v in pairs(recommendTeamList) do
    local info = v
    if not info.pet_team_info then
      local code = self.module:RemoveCodeAnnotation(info.pet_team_share_id)
      info.pet_team_info = self.module:DecodeShareData(code)
      info.pet_team_info.team_type = _G.Enum.PlayerTeamType.PTT_PVP_BATTLE_4
    end
    table.insert(teamList, info)
  end
  for i, teamData in pairs(teamList) do
    local info = {}
    info.magicid = tostring(teamData.pet_team_info.role_magic_id or 0)
    info.team_id = tostring(teamData.team_id or 0)
    info.team_name = teamData.team_name or ""
    info.team_type = ""
    info.team_source = teamData.team_id >= 10000 and "ai" or "op"
    info.pets = {}
    for i, v in pairs(teamData.pet_team_info.pets) do
      local petInfo = {}
      petInfo.petbase_id = tostring(v.base_conf_id or 0)
      petInfo.bloodline = tostring(v.blood_id or 0)
      petInfo.nature_id = tostring(v.nature or 0)
      local talentList = AICoachModuleUtils.GetTalentValue(v.hp_talent, v.attack_talent, v.special_attack_talent, v.defense_talent, v.special_defense_talent, v.speed_talent)
      petInfo.talent_a_name = tostring(talentList[1] or 0)
      petInfo.talent_b_name = tostring(talentList[2] or 0)
      petInfo.talent_c_name = tostring(talentList[3] or 0)
      petInfo.skill_a_id = tostring(v.skills and v.skills[1] and v.skills[1].id or 0)
      petInfo.skill_b_id = tostring(v.skills and v.skills[2] and v.skills[2].id or 0)
      petInfo.skill_c_id = tostring(v.skills and v.skills[3] and v.skills[3].id or 0)
      petInfo.skill_d_id = tostring(v.skills and v.skills[4] and v.skills[4].id or 0)
      table.insert(info.pets, petInfo)
    end
    table.insert(teamListData, info)
  end
  local success, result = pcall(rapidjson.encode, teamListData)
  if not success then
    Log.Error("UMG_FriendTeamPanel_C.GetCurrTeamListData failed~")
    return nil
  end
  return result
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
