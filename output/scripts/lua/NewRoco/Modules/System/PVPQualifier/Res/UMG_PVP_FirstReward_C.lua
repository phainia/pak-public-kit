local PVPRankedMatchModuleUtils = require("NewRoco.Modules.System.PVPQualifier.PVPRankedMatchModuleUtils")
local CommonModuleEvent = reload("NewRoco.Modules.System.Common.CommonModuleEvent")
local UMG_PVP_FirstReward_C = _G.NRCPanelBase:Extend("UMG_PVP_FirstReward_C")
local PVPRankedMatchModuleEvent = require("NewRoco.Modules.System.PVPQualifier.PVPRankedMatchModuleEvent")
local ShareUIModuleEvent = reload("NewRoco.Modules.System.ShareUI.ShareUIModuleEvent")

function UMG_PVP_FirstReward_C:OnActive()
  _G.NRCAudioManager:PlaySound2DAuto(40004001, "UMG_PVP_FirstReward_C:OnActive")
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
    self:OnAddEventListener()
    self:PlayAnimation(self.In)
    return
  end
  self:OnAddEventListener()
  self:SetCommonTitle()
  self:InitData()
  self:RefreshUI()
  self:CheckShareIsOpen()
  if self.ShareIsOpen then
    _G.NRCModuleManager:DoCmd(_G.ShareUIModuleCmd.CheckRewardStateEntrance, self.shareBaseId)
  end
end

function UMG_PVP_FirstReward_C:OnDeactive()
  _G.NRCAudioManager:PlaySound2DAuto(40008006, "UMG_PVP_FirstReward_C:OnDeactive")
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(Enum.UILayerType.UI_LAYER_MAIN)
    return
  end
  self:OnRemoveEventListener()
  self:CancelShareDelayId()
  self.ShareUIReward:CancelShareDelayId()
end

function UMG_PVP_FirstReward_C:OnAddEventListener()
  self:AddButtonListener(self.btnClose.btnClose, self.OnClickClose)
  self:AddButtonListener(self.DetailsBtn.btnLevelUp, self.OpenActivityDescription)
  self:AddButtonListener(self.ShareBtn.btnLevelUp, self.OnShareBtnClick)
  _G.NRCModuleManager:GetModule("CommonModule"):RegisterEvent(self, CommonModuleEvent.SelectTab, self.OnSelectedTabIndex)
  _G.NRCModuleManager:GetModule("PVPRankedMatchModule"):RegisterEvent(self, PVPRankedMatchModuleEvent.SetPvpSeasonRecordData, self.OnSetPvpSeasonRecordData)
  _G.NRCEventCenter:RegisterEvent("UMG_PVP_FirstReward_C", self, NRCGlobalEvent.OnComboBoxSelectChanged, self.OnSeasonRecordSelected)
  _G.NRCEventCenter:RegisterEvent(self.name, self, ShareUIModuleEvent.SHOW_ENTRANCE_REWARD, self.CheckShowShareReward)
  self.SpineFlag.AnimationStart:Add(self, self.OnSpineAnimationStart)
end

function UMG_PVP_FirstReward_C:OnRemoveEventListener()
  self:RemoveButtonListener(self.btnClose.btnClose, self.OnClickClose)
  self:RemoveButtonListener(self.DetailsBtn.btnLevelUp, self.OpenActivityDescription)
  _G.NRCModuleManager:GetModule("CommonModule"):UnRegisterEvent(self, CommonModuleEvent.SelectTab)
  _G.NRCModuleManager:GetModule("PVPRankedMatchModule"):UnRegisterEvent(self, PVPRankedMatchModuleEvent.SetPvpSeasonRecordData)
  _G.NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.OnComboBoxSelectChanged, self.OnSeasonRecordSelected)
  _G.NRCEventCenter:UnRegisterEvent(self, ShareUIModuleEvent.SHOW_ENTRANCE_REWARD, self.CheckShowShareReward)
  self.SpineFlag.AnimationStart:Clear()
end

function UMG_PVP_FirstReward_C:OpenActivityDescription()
  local titleText = _G.DataConfigManager:GetLocalizationConf("PVP_rank_character7").msg
  local contentStr = _G.DataConfigManager:GetLocalizationConf("PVP_rank_character6").msg
  local Context = DialogContext()
  Context:SetTitle(titleText):SetContent(contentStr):SetContentTextJustify(UE4.ETextJustify.Left):SetMode(DialogContext.Mode.NotBtn):SetCloseOnOK(true):SetCallback(self, self.OnActivityDescDialogClosed)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenLongDialog, Context)
end

function UMG_PVP_FirstReward_C:OnActivityDescDialogClosed()
end

function UMG_PVP_FirstReward_C:OnShareBtnClick()
  if self.ShareDataSnapshot then
    local sharePartId = _G.NRCModuleManager:DoCmd(ShareUIModuleCmd.GetSharePartIdByShareBaseId, self.shareBaseId)
    if sharePartId then
      local data = {
        shareBaseId = self.shareBaseId,
        sharePartId = sharePartId,
        extraData = self.ShareDataSnapshot
      }
      _G.NRCModuleManager:DoCmd(ShareUIModuleCmd.OpenShareUIPanel, data)
    end
  end
end

function UMG_PVP_FirstReward_C:OnTick(deltaTime)
  if self.SpineFlag then
    self.SpineFlag:Tick(deltaTime, false)
  end
end

function UMG_PVP_FirstReward_C:OnLogin()
end

function UMG_PVP_FirstReward_C:OnConstruct()
  self.ShareDataSnapshot = {}
  self.ShareBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_PVP_FirstReward_C:OnDestruct()
end

function UMG_PVP_FirstReward_C:OnAnimationFinished(anim)
  if anim == self.In then
    self:StopAllAnimations()
    self:PlayAnimation(self.Loop, 0, 0)
    self.Tab:SelectItemByIndex(0)
  end
end

function UMG_PVP_FirstReward_C:OnSpineAnimationStart(entry)
  PVPRankedMatchModuleUtils.OnFlagSpineAnimationStart(entry)
end

function UMG_PVP_FirstReward_C:OnClickClose()
  _G.NRCAudioManager:PlaySound2DAuto(1008, "UMG_PVP_FirstReward_C:OnClickClose")
  if _G.GlobalConfig.DebugOpenUI then
  else
    _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.ShowUmgPVPQualifier)
  end
  self:DoClose()
end

function UMG_PVP_FirstReward_C:InitData()
  self.data = self.module:GetData("PVPRankedMatchModuleData")
  self.dataList = self.data:GetCurStarReward()
  self.season_record_data = {}
  self:SetTitle(self.data:GetCurSeasonId())
end

function UMG_PVP_FirstReward_C:RefreshUI()
  self.Tab:InitGridView({
    {
      icon = "PaperSprite'/Game/NewRoco/Modules/System/PVPQualifier/Raw/Frames/img_tabicon1_png.img_tabicon1_png'",
      select_icon = "PaperSprite'/Game/NewRoco/Modules/System/PVPQualifier/Raw/Frames/img_tabicon1_select_png.img_tabicon1_select_png'"
    },
    {
      icon = "PaperSprite'/Game/NewRoco/Modules/System/PVPQualifier/Raw/Frames/img_tabicon2_png.img_tabicon2_png'",
      select_icon = "PaperSprite'/Game/NewRoco/Modules/System/PVPQualifier/Raw/Frames/img_tabicon2_select_png.img_tabicon2_select_png'"
    }
  })
  self.NRCImage_4:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TextQuantity_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.PVPQualifier_Star:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.RankName:SetText("")
  self.GridView:Clear()
  self.Popup_Downward:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Popup_Downward:SetAutoCheckClose(true)
  self.AccessAuthorityBtn.OnClicked:Add(self, self.OnAccessAuthorityBtnClick)
  self.SpineFlag:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:StopAllAnimations()
  self:PlayAnimation(self.In)
end

function UMG_PVP_FirstReward_C:OnSelectedTabIndex(index)
  if 1 == index then
    self:ShowInSpineWidget(PVPRankedMatchModuleUtils.GetSelfRankStar())
    self:RefreshSeasonReward()
    self.NRCText_7:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SeasonReward:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.SeasonRecord:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ShareBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:SetTitle(self.data:GetCurSeasonId())
  else
    self.NRCImage_4:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TextQuantity_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.PVPQualifier_Star:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCText_7:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.SeasonReward:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.ShareIsOpen then
      self.ShareBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    self.SeasonRecord:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if not self.sort_season_datas then
      self.sort_season_datas = self.data:GetSortSeasonDatas()
      self.Popup_Downward.List_title:InitList(self.sort_season_datas)
      if #self.sort_season_datas > 0 then
        self.Popup_Downward.List_title:SelectItemByIndex(0)
      else
        self:RefreshNoneSeasonData()
      end
    elseif self.season_record_index then
      self.Popup_Downward.List_title:SelectItemByIndex(self.season_record_index)
    else
      self:RefreshNoneSeasonData()
    end
  end
end

function UMG_PVP_FirstReward_C:RefreshSeasonReward()
  if self.dataList and self.GridView:GetItemCount() <= 0 then
    self.GridView:InitGridView(self.dataList)
  end
  self.RankName:SetText(PVPRankedMatchModuleUtils.GetCurRankName())
  local curRankConf = PVPRankedMatchModuleUtils.GetSelfPVPRankConf()
  self.TextQuantity_1:SetText(string.format("%d/%d", curRankConf.star_num, curRankConf.star_total))
  self:UpdateStarUI()
end

function UMG_PVP_FirstReward_C:UpdateStarUI()
  self.PVPQualifier_Star:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local curRankConf = PVPRankedMatchModuleUtils.GetSelfPVPRankConf()
  if PVPRankedMatchModuleUtils.IsSelfMaxRankStar() then
    self.NRCImage_4:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TextQuantity_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.PVPQualifier_Star:SwitcherStarIndex(0)
  else
    self.NRCImage_4:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TextQuantity_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TextQuantity_1:SetText(string.format("%d/%d", curRankConf.star_num, curRankConf.star_total))
    self.PVPQualifier_Star:SwitcherStarIndex(curRankConf.star_num)
  end
end

function UMG_PVP_FirstReward_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_PVP_FirstReward_C:SetTitle(season_id)
  local season_conf = _G.DataConfigManager:GetPvpRankSeasonConf(season_id)
  if season_conf then
    self.Title1:Set_MainTitle(season_conf.name)
  end
end

function UMG_PVP_FirstReward_C:ShowInSpineWidget(rank_star, is_dan_grading)
  if self.ShareDataSnapshot then
    self.ShareDataSnapshot.rank_star = rank_star
  end
  is_dan_grading = is_dan_grading or false
  rank_star = PVPRankedMatchModuleUtils.CorrectionRankStar(rank_star)
  local top_master_info = self.data:GetTopMaster()
  local is_top_master = top_master_info.type == _G.ProtoEnum.PVP_RANK_MASTER_TYPE.PVP_RANK_MASTER_TYPE_TOP_MASTER
  local incomingGradeAnimConf = self.data:GetGradingAnimConfig(rank_star, is_top_master, is_dan_grading)
  self.SpineFlag:SetToSetupPose()
  self.SpineFlag:SetAnimation(0, incomingGradeAnimConf.show, false)
  self.SpineFlag:AddAnimation(0, incomingGradeAnimConf.loop, true, 0)
  self.SpineFlag:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_PVP_FirstReward_C:ReceiveSeasonReward()
  _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.SendZoneGetPvpRankSeasonRewardReq)
end

function UMG_PVP_FirstReward_C:RefreshNoneSeasonData()
  self.AccessAuthorityBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Options:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NRCText_54:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.DataSwitcher:SetActiveWidgetIndex(1)
  self.NRCText_7:SetText(_G.DataConfigManager:GetLocalizationConf("PVP_rank_character4").msg)
  self:UpdateRank(1)
end

function UMG_PVP_FirstReward_C:RefreshSeasonRecord(record_season_data)
  self.ShareDataSnapshot.TableDatas = self.data:GetSortSeasonDatas()
  self.ShareDataSnapshot.TableIndex = self.season_record_index
  if not (self.sort_season_data and record_season_data) or record_season_data.season_id ~= self.sort_season_data.id then
    return
  end
  self.ShareDataSnapshot.CurSeasonData = record_season_data
  self:SetTitle(self.sort_season_data.id)
  local is_dan_grading = false
  local timestamp = PVPRankedMatchModuleUtils.GetTimestampFromTimeStr(self.sort_season_data.end_time)
  local cur_timestamp = _G.ZoneServer:GetServerTime() / 1000
  if timestamp <= cur_timestamp then
    self.NRCText_7:SetText(_G.DataConfigManager:GetLocalizationConf("PVP_rank_character5").msg)
    is_dan_grading = true
  else
    self.NRCText_7:SetText(_G.DataConfigManager:GetLocalizationConf("PVP_rank_character4").msg)
  end
  if record_season_data.battle_cnt and record_season_data.battle_cnt > 0 then
    self.DataSwitcher:SetActiveWidgetIndex(0)
    self.SeasonMatchesText:SetText(tostring(record_season_data.battle_cnt))
    self.VictoriesText:SetText(tostring(record_season_data.win_count))
    self.WinningRateText:SetText(tostring(math.floor(record_season_data.win_count / record_season_data.battle_cnt * 100)) .. "%")
    self.HighestWinningStreakText:SetText(tostring(record_season_data.max_win_streak))
    local pet_use_info = {
      {},
      {},
      {},
      {},
      {},
      {}
    }
    for i, v in ipairs(record_season_data.pet_use_info) do
      pet_use_info[i] = v
    end
    self.PetList:InitGridView(pet_use_info)
    if record_season_data.magic_used then
      self.MagicList:InitGridView(record_season_data.magic_used)
    end
  end
  local rank_star = 1
  if record_season_data.rank_star then
    rank_star = record_season_data.rank_star
  end
  self:UpdateRank(rank_star, is_dan_grading)
end

function UMG_PVP_FirstReward_C:UpdateRank(rank_star, is_dan_grading)
  is_dan_grading = is_dan_grading or false
  self:ShowInSpineWidget(rank_star, is_dan_grading)
  local rank_conf = PVPRankedMatchModuleUtils.GetPvpRankConf(rank_star)
  if rank_conf then
    self.RankName:SetText(rank_conf.name)
  end
end

function UMG_PVP_FirstReward_C:OnSetPvpSeasonRecordData(data)
  self.season_record_data[data.season_id] = data
  self:RefreshSeasonRecord(data)
end

function UMG_PVP_FirstReward_C:OnAccessAuthorityBtnClick()
  if #self.sort_season_datas <= 0 then
    return
  end
  if self.Popup_Downward:GetVisibility() == UE4.ESlateVisibility.Collapsed then
    self.Popup_Downward:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Popup_Downward:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PVP_FirstReward_C:OnSeasonRecordSelected(index, data_list)
  self.season_record_index = index - 1
  self.sort_season_data = data_list[index]
  self.AccessAuthorityText:SetText(self.sort_season_data.name)
  local s_year, s_month, s_day, hour, min, sec = string.match(self.sort_season_data.start_time, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
  local e_year, e_month, e_day = string.match(self.sort_season_data.end_time, "(%d+)%-(%d+)%-(%d+)")
  self.NRCText_54:SetText(string.format("%s.%s.%s-%s.%s.%s", s_year, s_month, s_day, e_year, e_month, e_day))
  self.Popup_Downward:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.DataSwitcher:SetActiveWidgetIndex(1)
  self.PetList:Clear()
  self.MagicList:Clear()
  local timestamp = PVPRankedMatchModuleUtils.GetTimestampFromTimeStr(self.sort_season_data.start_time)
  local cur_timestamp = _G.ZoneServer:GetServerTime() / 1000
  if timestamp <= cur_timestamp then
    if self.season_record_data[self.sort_season_data.id] == nil then
      _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.SendPVPSeasonRecordQueryReq, self.sort_season_data.id)
    else
      self:RefreshSeasonRecord(self.season_record_data[self.sort_season_data.id])
    end
  else
    self:RefreshSeasonRecord()
  end
end

function UMG_PVP_FirstReward_C:CheckShowShareReward(data)
  if data.shareBaseId == self.shareBaseId and 0 == data.rewardGetState then
    local function cb()
      self.ShareUIReward:Init({
        shareBaseId = data.shareBaseId,
        
        isUpAnim = true
      })
    end
    
    self.shareDelayId = _G.DelayManager:DelayFrames(1, cb, self)
  end
end

function UMG_PVP_FirstReward_C:CancelShareDelayId()
  if self.shareDelayId then
    _G.DelayManager:CancelDelayById(self.shareDelayId)
    self.shareDelayId = nil
  end
end

function UMG_PVP_FirstReward_C:CheckShareIsOpen()
  self.shareBaseId = _G.Enum.ShareButtonType.SBT_PVP_RECORD
  self.ShareIsOpen = _G.NRCModuleManager:DoCmd(ShareUIModuleCmd.CheckIsOpen, self.shareBaseId)
end

return UMG_PVP_FirstReward_C
