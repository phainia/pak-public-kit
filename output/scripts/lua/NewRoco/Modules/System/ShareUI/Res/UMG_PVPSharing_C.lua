local PVPRankedMatchModuleEvent = require("NewRoco.Modules.System.PVPQualifier.PVPRankedMatchModuleEvent")
local PVPRankedMatchModuleUtils = require("NewRoco.Modules.System.PVPQualifier.PVPRankedMatchModuleUtils")
local UMG_PVPSharing_C = _G.NRCPanelBase:Extend("UMG_PVPSharing_C")

function UMG_PVPSharing_C:OnActive()
end

function UMG_PVPSharing_C:OnDeactive()
end

function UMG_PVPSharing_C:OnAddEventListener()
  self:AddButtonListener(self.AccessAuthorityBtn, self.OnAccessAuthorityBtnClick)
  self.SpineFlag.AnimationStart:Add(self, self.OnSpineAnimationStart)
end

function UMG_PVPSharing_C:OnRemoveEventListener()
  self.SpineFlag.AnimationStart:Clear()
end

function UMG_PVPSharing_C:InitData(data, index, tableDatas, startNum)
  self.RankName:SetText("")
  self.TableDatas = tableDatas or {}
  self.TableIndex = index
  self.CruData = data
  self.StarNum = startNum
  local rank_conf = PVPRankedMatchModuleUtils.GetPvpRankConf(startNum)
  if rank_conf then
    self.RankName:SetText(rank_conf.name)
  end
  self.Popup_Downward.List_title:InitList(self.TableDatas)
  if not self.TableIndex then
    if self.TableDatas and #self.TableDatas > 0 then
      self.Popup_Downward.List_title:SelectItemByIndex(0)
    end
  else
    self.Popup_Downward.List_title:SelectItemByIndex(self.TableIndex)
  end
  self.SpineFlag:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:ShowPlayer()
end

function UMG_PVPSharing_C:OnConstruct()
  self.season_record_data = {}
  self:OnAddEventListener()
  _G.NRCModuleManager:GetModule("PVPRankedMatchModule"):RegisterEvent(self, PVPRankedMatchModuleEvent.SetPvpSeasonRecordData, self.OnSetPvpSeasonRecordData)
  _G.NRCEventCenter:RegisterEvent("UMG_PVPShare_C", self, NRCGlobalEvent.OnComboBoxSelectChanged, self.OnSeasonRecordSelected)
end

function UMG_PVPSharing_C:OnDestruct()
  self:OnRemoveEventListener()
  _G.NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.OnComboBoxSelectChanged, self.OnSeasonRecordSelected)
  _G.NRCModuleManager:GetModule("PVPRankedMatchModule"):UnRegisterEvent(self, PVPRankedMatchModuleEvent.SetPvpSeasonRecordData)
end

function UMG_PVPSharing_C:ShowPlayer()
  local PlayerInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo().brief_info
  local CardInfo = PlayerInfo.additional_data.card_brief_info
  local playerUin = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo().brief_info.uin
  local playerName = _G.DataModelMgr.PlayerDataModel:GetPlayerName()
  self.Grade:SetText(playerName)
  self.Grade_1:SetText(playerUin)
  if CardInfo then
    local CardIconConf = _G.DataConfigManager:GetCardIconConf(CardInfo.card_icon_selected)
    if CardIconConf then
      local AvatarPath = CardIconConf.icon_resource_path
      AvatarPath = string.format("%s%s.%s'", "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BigHeadIcon256/", AvatarPath, AvatarPath)
      self.HeadPortrait:SetPath(AvatarPath)
    end
  else
    Log.Debug("\230\178\161\230\156\137\233\187\152\232\174\164\229\144\141\231\137\135\229\164\180\229\131\143\230\149\176\230\141\174,\232\175\183\230\159\165\231\156\139\229\144\142\229\143\176\230\149\176\230\141\174")
  end
end

function UMG_PVPSharing_C:OnSetPvpSeasonRecordData(data)
  self.season_record_data[data.season_id] = data
  self:RefreshSeasonRecord(data)
end

function UMG_PVPSharing_C:OnAccessAuthorityBtnClick()
  if self.Popup_Downward:GetVisibility() == UE4.ESlateVisibility.Collapsed then
    self.Popup_Downward:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Popup_Downward:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PVPSharing_C:OnSeasonRecordSelected(index, data_list)
  self.season_record_index = index - 1
  self.sort_season_data = data_list[index]
  self.AccessAuthorityText:SetText(self.sort_season_data.name)
  local s_year, s_month, s_day, hour, min, sec = string.match(self.sort_season_data.start_time, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
  local e_year, e_month, e_day = string.match(self.sort_season_data.end_time, "(%d+)%-(%d+)%-(%d+)")
  self.NRCText_54:SetText(string.format("%s.%s.%s-%s.%s.%s", s_year, s_month, s_day, e_year, e_month, e_day))
  self.Popup_Downward:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.DataSwitcher:SetActiveWidgetIndex(1)
  self.SeasonMatchesText:SetText("0")
  self.VictoriesText:SetText("0")
  self.WinningRateText:SetText("0%")
  self.HighestWinningStreakText:SetText("0")
  self.PetList:Clear()
  self.PetList_1:Clear()
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

function UMG_PVPSharing_C:RefreshSeasonRecord(record_season_data)
  local rank_star = self.StarNum or 1
  if record_season_data and record_season_data.battle_cnt and record_season_data.battle_cnt > 0 then
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
    if record_season_data.pet_use_info and #record_season_data.pet_use_info > 0 then
      for i, v in ipairs(record_season_data.pet_use_info) do
        pet_use_info[i] = v
      end
    end
    self.PetList:InitGridView(pet_use_info)
    self.PetList_1:InitGridView(record_season_data.magic_used or {})
    rank_star = record_season_data.rank_star
  end
  self:ShowInSpineWidget(rank_star)
end

function UMG_PVPSharing_C:ShowInSpineWidget(rank_star, is_dan_grading)
  local PVPRankedMatchModuleData = _G.NRCModuleManager:GetModule("PVPRankedMatchModule"):GetData("PVPRankedMatchModuleData")
  is_dan_grading = is_dan_grading or false
  rank_star = PVPRankedMatchModuleUtils.CorrectionRankStar(rank_star)
  local top_master_info = PVPRankedMatchModuleData:GetTopMaster()
  local is_top_master = top_master_info.type == _G.ProtoEnum.PVP_RANK_MASTER_TYPE.PVP_RANK_MASTER_TYPE_TOP_MASTER
  local incomingGradeAnimConf = PVPRankedMatchModuleData:GetGradingAnimConfig(rank_star, is_top_master, is_dan_grading)
  self.SpineFlag:SetToSetupPose()
  self.SpineFlag:SetAnimation(0, incomingGradeAnimConf.show, false)
  self.SpineFlag:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_PVPSharing_C:OnSpineAnimationStart(entry)
  PVPRankedMatchModuleUtils.OnFlagSpineAnimationStart(entry)
end

function UMG_PVPSharing_C:OnTick(deltaTime)
  if self.SpineFlag then
    self.SpineFlag:Tick(deltaTime, true)
  end
end

return UMG_PVPSharing_C
