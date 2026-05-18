local MagicManualUtils = require("NewRoco/Modules/System/MagicManual/MagicManualUtils")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local NPCShopUIModuleEnum = require("NewRoco.Modules.System.NPCShopUI.NPCShopUIModuleEnum")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local JsonUtils = require("Common.JsonUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local UMG_ChallengePlaySubPanel_C = _G.NRCPanelBase:Extend("UMG_ChallengePlaySubPanel_C")

local function FormatTimeFromTimestamp(timestamp)
  if not timestamp then
    Log.Error("\230\151\182\233\151\180\230\149\176\230\141\174\231\188\186\229\164\177")
    return
  end
  local hour, min, day
  day = timestamp // 86400
  hour = (timestamp - 86400 * day) // 3600
  local timeStr = string.format(LuaText.common_countdown_display_3, day, hour)
  return timeStr
end

function UMG_ChallengePlaySubPanel_C:OnConstruct()
  self:SetChildViews(self.Time)
end

function UMG_ChallengePlaySubPanel_C:OnDestruct()
end

function UMG_ChallengePlaySubPanel_C:OnEnable(module)
  self.module = module
  self.data = self.module.data
  self.npc_challenge_data = nil
  self.boss_challenge_data = nil
  self.weekly_challenge_data = nil
  self.NPCChallengeEventActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, Enum.ActivityType.ATP_NPC_CHALLENGE_EVENT)
  if self.NPCChallengeEventActivityObject and self.NPCChallengeEventActivityObject[1] then
    self.npc_challenge_data = self.NPCChallengeEventActivityObject[1]:GetNpcChallengeData()
  end
  self.BossChallengeEventActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, Enum.ActivityType.ATP_BOSS_CHALLENGE_EVENT)
  if self.BossChallengeEventActivityObject and self.BossChallengeEventActivityObject[1] then
    self.boss_challenge_data = self.BossChallengeEventActivityObject[1]:GetBossChallengeData()
    self.MagicManualPath = self.BossChallengeEventActivityObject[1]:GetMagicManualPath()
  end
  self.WeeklyChallengeEventActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, Enum.ActivityType.ATP_WEEKLY_CHALLENGE_EVENT)
  if self.WeeklyChallengeEventActivityObject and self.WeeklyChallengeEventActivityObject[1] then
    self.weekly_challenge_data = self.WeeklyChallengeEventActivityObject[1]:GetWeeklyChallengeData()
  end
  self.SelectTabData = nil
  self.Btn_Transmit:SetBtnText(LuaText.TASK_GOTO)
  local BattlePlayTask = {}
  if self.weekly_challenge_data then
    local WeeklyChallengeEventConf = _G.DataConfigManager:GetWeeklyChallengeEventConf(self.weekly_challenge_data.event_id)
    local WeeklyChallengeEventStarNum = MagicManualUtils.GetWeeklyChallengeStarNum(self.weekly_challenge_data)
    local FinishWeeklyChallengeEventSchedule = self.weekly_challenge_data.challenge_info.highest_cheer_point or 0
    local challengeConf = _G.DataConfigManager:GetWeeklyChallengeConf(WeeklyChallengeEventConf.challenge_id[1])
    local imagePath = "Texture2D'/Game/NewRoco/Modules/System/WeeklyChallengeBattle/Raw/Textures/Curtain_001_02_Bg2.Curtain_001_02_Bg2'"
    if challengeConf then
      local photoConf = _G.DataConfigManager:GetWeeklyPhotoConf(challengeConf.photo)
      if photoConf then
        if photoConf.background and photoConf.background ~= "" then
          local batch, number = self:_GetBatchAndNumberFromCurtainName(photoConf.background)
          imagePath = string.format(UEPath.WeeklyChallengeBattleHandBookImage, batch, number, batch, number)
        else
          local json = JsonUtils.LoadSavedFromStarLight(photoConf.res_name or "PhotoEditorJson", {})
          if json and json[1] and json[1][2] then
            local curtainName = json[1][2]
            local batch, number = self:_GetBatchAndNumberFromCurtainName(curtainName)
            imagePath = string.format(UEPath.WeeklyChallengeBattleHandBookImage, batch, number, batch, number)
          else
            Log.Error("Json\232\142\183\229\143\150\229\164\177\232\180\165")
          end
        end
      else
        Log.Error("UMG_ChallengePlaySubPanel_C:OnEnable \232\142\183\229\143\150photoConf\229\164\177\232\180\165")
      end
    else
      Log.Error("UMG_ChallengePlaySubPanel_C:OnEnable \232\142\183\229\143\150WeeklyChallengeConf\229\164\177\232\180\165")
    end
    local activityId = self.WeeklyChallengeEventActivityObject[1]:GetActivityId()
    local challengeId = WeeklyChallengeEventConf.challenge_id[1]
    _G.NRCModuleManager:DoCmd(_G.WeeklyChallengeBattleModuleCmd.ResetPetStateReq, activityId, challengeId)
    table.insert(BattlePlayTask, {
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/Activity/Raw/Frames/img_Starlight_png.img_Starlight_png'",
      Icon_1 = "PaperSprite'/Game/NewRoco/Modules/System/Activity/Raw/Frames/img_Starlight_png.img_Starlight_png'",
      ChallengeIcon = imagePath,
      TaskTypeName = WeeklyChallengeEventConf.topic,
      Text_Content_1 = "1/20",
      FinishChallengeEventStarNum = FinishWeeklyChallengeEventSchedule,
      AllChallengeEventStarNum = WeeklyChallengeEventStarNum,
      TabType = self.data.BattlePlayTaskType.StarlightDuel,
      activityId = self.WeeklyChallengeEventActivityObject and self.WeeklyChallengeEventActivityObject[1] and self.WeeklyChallengeEventActivityObject[1]:GetActivityId(),
      EndTime = self.WeeklyChallengeEventActivityObject[1]:GetActivityEndTime()
    })
  end
  if self.npc_challenge_data then
    local NpcChallengeEventConf = _G.DataConfigManager:GetNpcChallengeEventConf(self.npc_challenge_data.event_id)
    local NPCChallengeEventStarNum = MagicManualUtils.GetNPCChallengeEventStarNum(NpcChallengeEventConf)
    local FinishNPCChallengeEventSchedule = MagicManualUtils.GetFinishNPCChallengeEventSchedule(self.npc_challenge_data, true)
    table.insert(BattlePlayTask, {
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Frames/img_jianying_png.img_jianying_png'",
      Icon_1 = "PaperSprite'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Frames/img_jianying_png.img_jianying_png'",
      ChallengeIcon = "PaperSprite'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Frames/img_chengbao_png.img_chengbao_png'",
      TaskTypeName = _G.DataConfigManager:GetLocalizationConf("challenge_title_1").msg,
      Text_Content_1 = "1/10",
      FinishChallengeEventStarNum = FinishNPCChallengeEventSchedule,
      AllChallengeEventStarNum = NPCChallengeEventStarNum,
      TabType = self.data.BattlePlayTaskType.BattleSilhouette,
      activityId = self.NPCChallengeEventActivityObject and self.NPCChallengeEventActivityObject[1] and self.NPCChallengeEventActivityObject[1]:GetActivityId(),
      EndTime = self.NPCChallengeEventActivityObject[1]:GetActivityEndTime()
    })
  end
  if self.boss_challenge_data then
    local BossChallengeEventConf = _G.DataConfigManager:GetBossChallengeEventConf(self.boss_challenge_data.event_id)
    local BossChallengeEventStarNum = MagicManualUtils.GetNPCChallengeEventStarNum(BossChallengeEventConf)
    local FinishBossChallengeEventSchedule = MagicManualUtils.GetFinishBossChallengeEventSchedule(self.boss_challenge_data, true)
    table.insert(BattlePlayTask, {
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Frames/img_jiaodou_png.img_jiaodou_png'",
      Icon_1 = "PaperSprite'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Frames/img_jiaodou_png.img_jiaodou_png'",
      ChallengeIcon = "PaperSprite'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Frames/img_emolang_png.img_emolang_png'",
      TaskTypeName = _G.DataConfigManager:GetLocalizationConf("challenge_title_2").msg,
      Text_Content_1 = "1/20",
      FinishChallengeEventStarNum = FinishBossChallengeEventSchedule,
      AllChallengeEventStarNum = BossChallengeEventStarNum,
      TabType = self.data.BattlePlayTaskType.Chieftain,
      activityId = self.BossChallengeEventActivityObject and self.BossChallengeEventActivityObject[1] and self.BossChallengeEventActivityObject[1]:GetActivityId(),
      EndTime = self.BossChallengeEventActivityObject[1]:GetActivityEndTime()
    })
  end
  if BattlePlayTask and #BattlePlayTask > 0 then
    self.challengeTabList = BattlePlayTask
    self.TabList1_1:InitGridView(BattlePlayTask)
    if self.module.ChildTableIndex and self.module.ChildTableIndex > 0 then
      self:SelectTabBySubTabIndex(self.module.ChildTableIndex)
    else
      self.TabList1_1:SelectItemByIndex(0)
    end
    if 1 == #BattlePlayTask then
      self.TabList1_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if #BattlePlayTask >= 2 then
      local soonest_index = 1
      local soonest_end_time = BattlePlayTask[1].EndTime
      for i = 2, #BattlePlayTask do
        if soonest_end_time > BattlePlayTask[i].EndTime then
          soonest_end_time = BattlePlayTask[i].EndTime
          soonest_index = i
        end
      end
      local Item = self.TabList1_1:GetItemByIndex(soonest_index - 1)
      if Item then
        Item:IsShowSandClock(true)
      end
      self.img_Tabbg_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.img_Tabbg_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  self:PlayAnimation(self.Change)
  self.module.ChildTableIndex = 0
  self:OnAddEventListener()
end

function UMG_ChallengePlaySubPanel_C:SelectTabBySubTabIndex(TabIndex)
  if self.challengeTabList and #self.challengeTabList > 0 then
    local index = 0
    for i, v in ipairs(self.challengeTabList) do
      if v.TabType == TabIndex then
        index = i - 1
      end
    end
    self.TabList1_1:SelectItemByIndex(index)
  end
end

function UMG_ChallengePlaySubPanel_C:SetScheduleList(SelectTabData)
  local ScheduleList = {}
  if SelectTabData.TabType == self.data.BattlePlayTaskType.BattleSilhouette then
    local NpcChallengeEventConf = _G.DataConfigManager:GetNpcChallengeEventConf(self.npc_challenge_data.event_id)
    local FinishChallengeEventSchedule = MagicManualUtils.GetFinishNPCChallengeEventSchedule(self.npc_challenge_data, false)
    local FinishChallengeEventStar = MagicManualUtils.GetFinishNPCChallengeEventSchedule(self.npc_challenge_data, true)
    local NPCChallengeEventSchedule = MagicManualUtils.GetNPCChallengeEventSchedule(NpcChallengeEventConf)
    local ChallengeEventStarNum = MagicManualUtils.GetNPCChallengeEventStarNum(NpcChallengeEventConf)
    table.insert(ScheduleList, {
      ScheduleText = "\232\191\155\229\186\166",
      FinishChallengeEventStarNum = FinishChallengeEventSchedule,
      ChallengeEventSchedule = NPCChallengeEventSchedule
    })
    table.insert(ScheduleList, {
      ScheduleText = "\230\152\159\230\149\176",
      FinishChallengeEventStarNum = FinishChallengeEventStar,
      ChallengeEventSchedule = ChallengeEventStarNum
    })
    if self.NPCChallengeEventActivityObject and self.NPCChallengeEventActivityObject[1] then
      self.Btn_Transmit.RedDot:SetupKey(370, self.NPCChallengeEventActivityObject[1]:GetNpcActivityId())
    else
      self.Btn_Transmit.RedDot:SetupKey(0)
    end
    self.Department_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Frames/img_beijing3_png.img_beijing3_png'")
  elseif SelectTabData.TabType == self.data.BattlePlayTaskType.Chieftain then
    local BossChallengeEventConf = _G.DataConfigManager:GetBossChallengeEventConf(self.boss_challenge_data.event_id)
    local FinishChallengeEventSchedule = MagicManualUtils.GetFinishBossChallengeEventSchedule(self.boss_challenge_data, false)
    local FinishChallengeEventStar = MagicManualUtils.GetFinishBossChallengeEventSchedule(self.boss_challenge_data, true)
    local NPCChallengeEventSchedule = MagicManualUtils.GetBossChallengeEventSchedule(BossChallengeEventConf)
    local ChallengeEventStarNum = MagicManualUtils.GetNPCChallengeEventStarNum(BossChallengeEventConf)
    table.insert(ScheduleList, {
      ScheduleText = "\232\191\155\229\186\166",
      FinishChallengeEventStarNum = FinishChallengeEventSchedule,
      ChallengeEventSchedule = NPCChallengeEventSchedule
    })
    table.insert(ScheduleList, {
      ScheduleText = "\230\152\159\230\149\176",
      FinishChallengeEventStarNum = FinishChallengeEventStar,
      ChallengeEventSchedule = ChallengeEventStarNum
    })
    if self.BossChallengeEventActivityObject and self.BossChallengeEventActivityObject[1] then
      self.Btn_Transmit.RedDot:SetupKey(370, self.BossChallengeEventActivityObject[1]:GetBossActivityId())
    else
      self.Btn_Transmit.RedDot:SetupKey(0)
    end
    if self.MagicManualPath then
      self.Department_4:SetPath(self.MagicManualPath)
    end
    self.Department_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Frames/img_beijing4_png.img_beijing4_png'")
  elseif SelectTabData.TabType == self.data.BattlePlayTaskType.StarlightDuel then
    local FinishChallengeEventSchedule = self.weekly_challenge_data.challenge_info.highest_cheer_point or 0
    local TotalStarNum = MagicManualUtils.GetWeeklyChallengeStarNum(self.weekly_challenge_data)
    table.insert(ScheduleList, {
      ScheduleText = _G.LuaText.weekly_challenge_text_20,
      FinishChallengeEventStarNum = FinishChallengeEventSchedule,
      ChallengeEventSchedule = TotalStarNum,
      bShouldShowStar = true,
      starIconPath = "PaperSprite'/Game/NewRoco/Modules/System/WeeklyChallengeBattle/Raw/Frames/img_CheerIcon1_png.img_CheerIcon1_png'"
    })
    if self.WeeklyChallengeEventActivityObject and self.WeeklyChallengeEventActivityObject[1] then
      self.Btn_Transmit.RedDot:SetupKey(370, self.WeeklyChallengeEventActivityObject[1]:GetWeeklyChallengeActivityId())
      self.RedDot_1:SetupKey(371, self.WeeklyChallengeEventActivityObject[1]:GetWeeklyChallengeActivityId())
    else
      self.Btn_Transmit.RedDot:SetupKey(0)
      self.RedDot_1:SetupKey(0)
    end
    self.Department_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/MagicManual/Raw/MagicManual/Frames/img_beijing4_png.img_beijing4_png'")
  end
  self.Schedule_List:InitGridView(ScheduleList)
  local item = self.Schedule_List:GetItemByIndex(0)
  if item then
    item.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ChallengePlaySubPanel_C:SetBattlePlayRewardList(ChallengeEventConf)
  local RewardList = {}
  for i, reward in ipairs(ChallengeEventConf.show_reward) do
    local rewards = _G.NRCCommonItemIconData()
    rewards.itemType = reward.item_type
    rewards.itemId = reward.item_id
    rewards.itemNum = reward.item_count
    rewards.bShowNum = true
    rewards.bShowTip = true
    table.insert(RewardList, rewards)
  end
  self.FlowerSeed_ItemIist:InitGridView(RewardList)
end

function UMG_ChallengePlaySubPanel_C:SetWeeklyChallengeRewardList(ChallengeEventConf)
  local rewardMap = {}
  for k, reward in ipairs(ChallengeEventConf.star_reward) do
    local rewardConf = _G.DataConfigManager:GetRewardConf(reward.reward)
    if rewardConf and rewardConf.RewardItem and #rewardConf.RewardItem > 0 then
      for k1, item in ipairs(rewardConf.RewardItem) do
        if not rewardMap[item.Id] then
          rewardMap[item.Id] = {
            count = 0,
            itemType = item.Type
          }
        end
        rewardMap[item.Id].count = rewardMap[item.Id].count + item.Count
      end
    end
  end
  local RewardList = {}
  for k, v in pairs(rewardMap) do
    if 0 ~= v.count then
      local rewards = _G.NRCCommonItemIconData()
      rewards.itemType = v.itemType
      rewards.itemId = k
      rewards.itemNum = v.count
      rewards.bShowNum = true
      rewards.bShowTip = true
      table.insert(RewardList, rewards)
    end
  end
  self.FlowerSeed_ItemIist:InitGridView(RewardList)
end

function UMG_ChallengePlaySubPanel_C:OnSelectGamePlayTabTypeEvent(SelectTabData)
  self.SelectTabData = SelectTabData
  self.Department_4:SetPath(SelectTabData.ChallengeIcon)
  self.HorizontalBox_26:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local Text = _G.DataConfigManager:GetLocalizationConf("challenge_title_1").msg
  local Text_1 = _G.DataConfigManager:GetLocalizationConf("challenge_title_2").msg
  self.CharacterButton:SetVisibility(UE4.ESlateVisibility.Visible)
  self.RedDot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Btn_shopping:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.MoneyBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Starlight:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Time:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if SelectTabData.TabType == self.data.BattlePlayTaskType.BattleSilhouette then
    local NpcChallengeEventConf = _G.DataConfigManager:GetNpcChallengeEventConf(self.npc_challenge_data.event_id)
    self:SetBattlePlayRewardList(NpcChallengeEventConf)
    self.TextTitle:SetText(Text)
    self.NPCChallengeEventActivityObject[1]:GetActivityStartTime()
    self:SetScheduleList(SelectTabData)
    self.Time:InitializeData(self.NPCChallengeEventActivityObject[1]:GetActivityTimeLeft(), nil, true)
    self.Time:ShowCountDown()
  elseif SelectTabData.TabType == self.data.BattlePlayTaskType.Chieftain then
    local BossChallengeEventConf = _G.DataConfigManager:GetBossChallengeEventConf(self.boss_challenge_data.event_id)
    self:SetBattlePlayRewardList(BossChallengeEventConf)
    self.TextTitle:SetText(Text_1)
    self:SetScheduleList(SelectTabData)
    self.Time:InitializeData(self.BossChallengeEventActivityObject[1]:GetActivityTimeLeft(), nil, true)
    self.Time:ShowCountDown()
  elseif SelectTabData.TabType == self.data.BattlePlayTaskType.StarlightDuel then
    self.Btn_shopping:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.MoneyBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Starlight:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local WeeklyChallengeEventConf = _G.DataConfigManager:GetWeeklyChallengeEventConf(self.weekly_challenge_data.event_id)
    local typeList = ActivityUtils.CreatePetCommonAttrListData(WeeklyChallengeEventConf.type, nil, false, nil)
    for i, attrData in ipairs(typeList) do
      attrData.ShowTips = true
      attrData.typeId = WeeklyChallengeEventConf.type[i]
    end
    self.Attr:InitGridView(typeList)
    if not WeeklyChallengeEventConf.show_reward or 0 == #WeeklyChallengeEventConf.show_reward then
      self:SetWeeklyChallengeRewardList(WeeklyChallengeEventConf)
    else
      self:SetBattlePlayRewardList(WeeklyChallengeEventConf)
    end
    self:SetStarlightRelativeInfo()
    self.TextTitle:SetText(WeeklyChallengeEventConf.topic)
    self:SetScheduleList(SelectTabData)
    self.Time:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:InitializeStarlightTime()
    self.CharacterButton:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.RedDot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:UpdateAppearanceRate()
  self:PlayAnimation(self.Change)
end

function UMG_ChallengePlaySubPanel_C:OnUpdateAppearanceRate()
  if self.NPCChallengeEventActivityObject and self.NPCChallengeEventActivityObject[1] then
    self.npc_challenge_data = self.NPCChallengeEventActivityObject[1]:GetNpcChallengeData()
  end
  if self.BossChallengeEventActivityObject and self.BossChallengeEventActivityObject[1] then
    self.boss_challenge_data = self.BossChallengeEventActivityObject[1]:GetBossChallengeData()
  end
  self:UpdateAppearanceRate()
end

function UMG_ChallengePlaySubPanel_C:UpdateAppearanceRate()
  if self.SelectTabData.TabType == self.data.BattlePlayTaskType.BattleSilhouette then
    if self.npc_challenge_data.pet_use_rate and #self.npc_challenge_data.pet_use_rate > 0 then
      self.AppearanceRate:InitGridView(self.npc_challenge_data.pet_use_rate)
      self.NRCSwitcher_66:SetActiveWidgetIndex(0)
    else
      self.NRCSwitcher_66:SetActiveWidgetIndex(1)
    end
  elseif self.SelectTabData.TabType == self.data.BattlePlayTaskType.Chieftain then
    if self.boss_challenge_data.pet_use_rate and #self.boss_challenge_data.pet_use_rate > 0 then
      self.AppearanceRate:InitGridView(self.boss_challenge_data.pet_use_rate)
      self.NRCSwitcher_66:SetActiveWidgetIndex(0)
    else
      self.NRCSwitcher_66:SetActiveWidgetIndex(1)
    end
  elseif self.SelectTabData.TabType == self.data.BattlePlayTaskType.StarlightDuel then
    if self.weekly_challenge_data and self.weekly_challenge_data.pet_use_rate and #self.weekly_challenge_data.pet_use_rate > 0 then
      self.AppearanceRate:InitGridView(self.weekly_challenge_data.pet_use_rate)
      self.NRCSwitcher_66:SetActiveWidgetIndex(0)
    else
      self.NRCSwitcher_66:SetActiveWidgetIndex(1)
    end
  end
end

function UMG_ChallengePlaySubPanel_C:OnDisable()
  if self.NPCChallengeEventActivityObject[1] then
  end
  self:OnRemoveEventListener()
end

function UMG_ChallengePlaySubPanel_C:OnDetails()
  _G.NRCAudioManager:PlaySound2DAuto(40001001, "UMG_ChallengePlaySubPanel_C:OnDetails")
  local titleText, contentStr
  if self.SelectTabData.TabType == self.data.BattlePlayTaskType.BattleSilhouette then
    titleText = _G.DataConfigManager:GetLocalizationConf("challenge_title_3").msg
    contentStr = _G.DataConfigManager:GetLocalizationConf("challenge_text_7").msg
  elseif self.SelectTabData.TabType == self.data.BattlePlayTaskType.Chieftain then
    titleText = _G.DataConfigManager:GetLocalizationConf("challenge_title_4").msg
    contentStr = _G.DataConfigManager:GetLocalizationConf("challenge_text_8").msg
  elseif self.SelectTabData.TabType == self.data.BattlePlayTaskType.StarlightDuel then
    titleText = _G.LuaText.weekly_challenge_text_10
    contentStr = _G.LuaText.weekly_challenge_text_9
  end
  local Context = DialogContext()
  Context:SetTitle(titleText):SetContent(contentStr):SetContentTextJustify(UE4.ETextJustify.Left):SetMode(DialogContext.Mode.NotBtn):SetCloseOnOK(true)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenLongDialog, Context)
end

function UMG_ChallengePlaySubPanel_C:OnClickCharacterButton()
  _G.NRCAudioManager:PlaySound2DAuto(40001001, "UMG_ChallengePlaySubPanel_C:OnClickCharacterButton")
  local BattleRuleId
  if self.SelectTabData.TabType == self.data.BattlePlayTaskType.BattleSilhouette then
    BattleRuleId = _G.DataConfigManager:GetNpcChallengeEventConf(self.npc_challenge_data.event_id).rule
  elseif self.SelectTabData.TabType == self.data.BattlePlayTaskType.Chieftain then
    BattleRuleId = _G.DataConfigManager:GetBossChallengeEventConf(self.boss_challenge_data.event_id).rule
  elseif self.SelectTabData.TabType == self.data.BattlePlayTaskType.StarlightDuel then
    BattleRuleId = _G.DataConfigManager:GetWeeklyChallengeEventConf(self.weekly_challenge_data.event_id).rule
  end
  _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.OpenPlayDetails, BattleRuleId)
end

function UMG_ChallengePlaySubPanel_C:OnBtn_Transmit()
  local Flags = false
  local Text
  if self.SelectTabData.TabType == self.data.BattlePlayTaskType.BattleSilhouette then
    Flags = _G.DataModelMgr.PlayerDataModel:IsAssignStoryFlags(Enum.PlayerStoryFlagEnum.PSF_DIA_DUIZHANJUCHANG)
    Text = _G.DataConfigManager:GetLocalizationConf("challenge_tips_4").msg
  elseif self.SelectTabData.TabType == self.data.BattlePlayTaskType.Chieftain then
    Flags = _G.DataModelMgr.PlayerDataModel:IsAssignStoryFlags(Enum.PlayerStoryFlagEnum.PSF_DIA_JUSHOUJUEDOU)
    Text = _G.DataConfigManager:GetLocalizationConf("challenge_tips_5").msg
  elseif self.SelectTabData.TabType == self.data.BattlePlayTaskType.StarlightDuel then
    local battleGlobalConf = _G.DataConfigManager:GetBattleGlobalConfig("weekly_challenge_unlock_task", true)
    if not battleGlobalConf or 0 == battleGlobalConf.num then
      Flags = true
    else
      Flags = false
    end
    Text = _G.LuaText.weekly_challenge_text_18
  end
  if not Flags then
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, Text)
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(40001001, "UMG_ChallengePlaySubPanel_C:OnClickCharacterButton")
  local WorldMapConfId
  if self.SelectTabData.TabType == self.data.BattlePlayTaskType.BattleSilhouette then
    WorldMapConfId = 700000
  elseif self.SelectTabData.TabType == self.data.BattlePlayTaskType.Chieftain then
    WorldMapConfId = 700001
  elseif self.SelectTabData.TabType == self.data.BattlePlayTaskType.StarlightDuel then
    WorldMapConfId = 700002
  end
  local NpcData = _G.NRCModuleManager:DoCmd(BigMapModuleCmd.GetNpcDataByWorldMapConfId, WorldMapConfId)
  if NpcData then
    local bBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.GetFunctionState, Enum.PlayerFunctionBanType.PFBT_UI_TELEPORT, true, true)
    if bBan then
      return
    end
    _G.NRCModuleManager:DoCmd(BigMapModuleCmd.SendWorldMapTeleportReq, NpcData.entry_id)
    _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.TeleportChallenge, WorldMapConfId)
  else
    Log.Warning("\230\178\161\230\156\137NpcData\230\149\176\230\141\174,\232\175\183\230\159\165\231\156\139\229\142\159\229\155\160")
  end
end

function UMG_ChallengePlaySubPanel_C:OnAddEventListener()
  if self.IsAddButtonListener then
    return
  end
  self.IsAddButtonListener = true
  self:AddButtonListener(self.Btn_details.btnLevelUp, self.OnDetails)
  self:AddButtonListener(self.CharacterButton, self.OnClickCharacterButton)
  self:AddButtonListener(self.Btn_Transmit.btnLevelUp, self.OnBtn_Transmit)
  self:AddButtonListener(self.RewardBtn_1, self.OnStarlightRewardButtonClick)
  self:AddButtonListener(self.Btn_shopping.btnLevelUp, self.OnStarlightShoppingBtnClick)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnPlayerDataUpdate)
end

function UMG_ChallengePlaySubPanel_C:OnRemoveEventListener()
  self.IsAddButtonListener = false
  self:RemoveButtonListener(self.Btn_details.btnLevelUp)
  self:RemoveButtonListener(self.CharacterButton)
  self:RemoveButtonListener(self.Btn_Transmit.btnLevelUp)
  self:RemoveButtonListener(self.RewardBtn_1)
  self:RemoveButtonListener(self.Btn_shopping.btnLevelUp)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnPlayerDataUpdate)
end

function UMG_ChallengePlaySubPanel_C:_GetBatchAndNumberFromCurtainName(fileName)
  if not fileName then
    Log.Error("UMG_ChallengePlaySubPanel_C:_GetBatchAndNumberFromCurtainName fileName is nil")
    return nil, nil
  end
  local batch, number = string.match(fileName, "^MI_Curtain_(.-)_(.-)_Skeletal$")
  return batch, number
end

function UMG_ChallengePlaySubPanel_C:SetStarlightRelativeInfo()
  self.MoneyBtn:InitGridView(BattleUtils.GetPvpScoreItemInfo())
  local WeeklyChallengeEventActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, Enum.ActivityType.ATP_WEEKLY_CHALLENGE_EVENT)
  if not WeeklyChallengeEventActivityObject or not WeeklyChallengeEventActivityObject[1] then
    self.TextClaimProgress_1:SetText("0/12")
    return
  end
  local weeklyChallengeData = WeeklyChallengeEventActivityObject[1]:GetWeeklyChallengeData()
  local totalStarNum = MagicManualUtils.GetWeeklyChallengeStarNum(weeklyChallengeData)
  local finishedStarNum = weeklyChallengeData.challenge_info.highest_cheer_point or 0
  self.TextClaimProgress_1:SetText(string.format("%s/%s", finishedStarNum, totalStarNum))
end

function UMG_ChallengePlaySubPanel_C:OnStarlightRewardButtonClick()
  local rewardList = _G.NRCModuleManager:DoCmd(_G.WeeklyChallengeBattleModuleCmd.GetCurrentEventRewardList)
  _G.NRCModuleManager:DoCmd(_G.WeeklyChallengeBattleModuleCmd.OpenRewardClaimPopupPanel, rewardList, false)
end

function UMG_ChallengePlaySubPanel_C:OnStarlightShoppingBtnClick()
  _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.SetNpcShopOpenType, NPCShopUIModuleEnum.OpenNPCShopFormType.MagicManualMain)
  _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.FinishNPCActionOpenShop, nil, 2006)
end

function UMG_ChallengePlaySubPanel_C:OnPlayerDataUpdate()
  self:SetStarlightRelativeInfo()
end

function UMG_ChallengePlaySubPanel_C:InitializeStarlightTime()
  self.Timestamp = self.WeeklyChallengeEventActivityObject[1]:GetActivityTimeLeft()
  local timeStr = FormatTimeFromTimestamp(self.Timestamp)
  self.Text_Time:SetText(timeStr)
  self:CancelDelay()
end

function UMG_ChallengePlaySubPanel_C:OnDownTime()
  self.Timestamp = self.Timestamp - 1
  self.Text_Time:SetText(FormatTimeFromTimestamp(self.Timestamp))
  self.DelayId = self:DelaySeconds(1, function()
    self:OnDownTime()
  end)
  if self.Timestamp <= 0 then
    self:CancelDelay()
  end
end

return UMG_ChallengePlaySubPanel_C
