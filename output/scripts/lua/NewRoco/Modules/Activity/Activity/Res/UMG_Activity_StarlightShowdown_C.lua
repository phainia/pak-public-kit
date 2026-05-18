local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local WeeklyChallengeBattleModuleEvent = require("NewRoco.Modules.System.WeeklyChallengeBattle.WeeklyChallengeBattleModuleEvent")
local JsonUtils = require("Common.JsonUtils")
local UMG_Activity_StarlightShowdown_C = Base:Extend("UMG_Activity_StarlightShowdown_C")

function UMG_Activity_StarlightShowdown_C:BindUIElements()
  local uiElements = {}
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.timeRemaining = self.Text_TimeRemaining
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  return uiElements
end

function UMG_Activity_StarlightShowdown_C:OnConstruct()
  self:SetChildViews(self.UMG_WeeklyChallengeBattle_World3D)
  Base.OnConstruct(self)
  self:OnAddEventListener()
  self:InitInfo()
  self:PlayAnimation(self.In)
end

function UMG_Activity_StarlightShowdown_C:OnDestruct()
  Base.OnDestruct(self)
end

function UMG_Activity_StarlightShowdown_C:OnActive()
end

function UMG_Activity_StarlightShowdown_C:OnDeactive()
end

function UMG_Activity_StarlightShowdown_C:OnEnable(firstLoad)
  Base.OnEnable(self, firstLoad)
  self:RefreshRewardState()
end

function UMG_Activity_StarlightShowdown_C:OnAddEventListener()
  self:AddButtonListener(self.ParticularsBtn, self.OnClickParticularsBtn)
  self:AddButtonListener(self.Btn_Claimable.btnLevelUp, self.OnViewDetailsInfo)
  self:RegisterEvent(self, WeeklyChallengeBattleModuleEvent.OnActivityUpdate, self.OnActivityDataUpdate)
end

function UMG_Activity_StarlightShowdown_C:InitInfo()
  local _activityInst = self.activityInst
  if not _activityInst then
    Log.Error("UMG_Activity_StarlightShowdown_C:InitInfo activityInst is nil")
    return
  end
  self.Text_Title:SetText(_activityInst:GetActivityName())
  local promptText = _activityInst:GetActivityPromptText()
  if promptText and "" ~= promptText then
    self.Text_Describe:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Text_Describe:SetText(promptText)
  else
    self.Text_Describe:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:InitActivityContent()
end

function UMG_Activity_StarlightShowdown_C:InitActivityContent()
  local _activityInst = self.activityInst
  if not _activityInst then
    return
  end
  local weeklyChallengeConf = _activityInst:GetCyclicalChallengeConf()
  if not weeklyChallengeConf then
    Log.Warning("UMG_Activity_StarlightShowdown_C:InitActivityContent weeklyChallengeConf is nil")
    return
  end
  self.CanvasPanel_83:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:UpdateCheerPointDisplay()
  self:InitRecommendedTypes(weeklyChallengeConf)
  self:InitBackgroundImage(weeklyChallengeConf)
  self:InitRewardList(weeklyChallengeConf)
  self:_LoadRival()
  self.Btn_Claimable.RedDot:SetupKey(370, _activityInst:GetActivityId())
end

function UMG_Activity_StarlightShowdown_C:UpdateCheerPointDisplay()
  local _activityInst = self.activityInst
  if not _activityInst then
    return
  end
  local currentCheerPoint = _activityInst:GetWeeklyChallengeData().challenge_info.highest_cheer_point or 0
  local maxCheerPoint = self:GetMaxCheerPoint()
  if self.Text_Content_1 then
    self.Text_Content_1:SetText(string.format("%s/%s", currentCheerPoint, maxCheerPoint))
  end
end

function UMG_Activity_StarlightShowdown_C:GetMaxCheerPoint()
  local _activityInst = self.activityInst
  if not _activityInst then
    return 0
  end
  return _activityInst:GetWeeklyChallengeEventStarNum() or 0
end

function UMG_Activity_StarlightShowdown_C:InitRecommendedTypes(conf)
  if not (conf and conf.type) or not self.Attr then
    if self.Attr then
      self.Attr:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    return
  end
  local typeList = ActivityUtils.CreatePetCommonAttrListData(conf.type, nil, false, nil)
  for i, attrData in ipairs(typeList) do
    attrData.ShowTips = true
    attrData.typeId = conf.type[i]
  end
  if #typeList > 0 then
    self.Attr:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Attr:InitGridView(typeList)
  else
    self.Attr:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Activity_StarlightShowdown_C:InitBackgroundImage(conf)
  if not conf or not self.NRCImage_1 then
    return
  end
  local challengeId = conf.challenge_id and conf.challenge_id[1]
  if challengeId then
    local challengeConf = _G.DataConfigManager:GetWeeklyChallengeConf(challengeId)
    if challengeConf and challengeConf.photo then
      local photoConf = _G.DataConfigManager:GetWeeklyPhotoConf(challengeConf.photo)
      if photoConf then
        local curtainName = "MI_Curtain_001_03_Skeletal"
        if photoConf.background then
          curtainName = photoConf.background
          Log.Info(string.format("UMG_StarlightShowdownPanel_C:_InitEventBackground \228\189\191\231\148\168\233\133\141\231\189\174\232\161\168\230\168\161\230\157\191 %s", curtainName))
        else
          local json = JsonUtils.LoadSavedFromStarLight(photoConf.res_name or self.LoadJsonPath or "PhotoEditorJson", {})
          if json[1] and json[1][2] then
            curtainName = json[1][2]
          else
            Log.Error("\233\133\141\231\189\174\228\184\173\231\188\186\229\176\145\229\185\149\229\184\131\231\154\132\232\131\140\230\153\175\230\149\176\230\141\174\239\188\140\231\173\150\229\136\146\232\175\183\230\163\128\230\159\165\228\184\128\228\184\139")
          end
          Log.Info(string.format("UMG_StarlightShowdownPanel_C:_InitEventBackground \228\189\191\231\148\168\229\144\136\231\133\167\230\168\161\230\157\191 %s", curtainName))
        end
        local batch, number = self:_GetBatchAndNumberFromCurtainName(curtainName)
        local backgroundPath = string.format(UEPath.WeeklyChallengeBattleBackground, batch, number, batch, number)
        Log.Info(string.format("\229\138\160\232\189\189\232\131\140\230\153\175\232\181\132\230\186\144\232\183\175\229\190\132 %s", backgroundPath))
        self.NRCImage_1:SetPath(backgroundPath)
        return
      end
    end
  end
  local defaultPath = "Texture2D'/Game/NewRoco/Modules/System/LevelSelection/Raw/Textures/img_xueshanheiye.img_xueshanheiye'"
  self.NRCImage_1:SetPath(defaultPath)
  self.NRCImage_1.Brush.ImageSize = UE.FVector2D(2048, 1536)
end

function UMG_Activity_StarlightShowdown_C:_GetBatchAndNumberFromCurtainName(fileName)
  local batch, number = string.match(fileName, "^MI_Curtain_(.-)_(.-)_Skeletal$")
  return batch, number
end

function UMG_Activity_StarlightShowdown_C:InitRewardList(conf)
  if not (conf and conf.show_reward) or not self.AwardList then
    if self.RewardsPanel then
      self.RewardsPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    return
  end
  local rewardList = {}
  for _, reward in ipairs(conf.show_reward) do
    local rewards = _G.NRCCommonItemIconData()
    rewards.itemType = reward.item_type
    rewards.itemId = reward.item_id
    rewards.itemNum = reward.item_count
    rewards.bShowNum = true
    rewards.bShowTip = true
    table.insert(rewardList, rewards)
  end
  if #rewardList > 0 then
    self.RewardsPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.AwardList:InitList(rewardList)
    ActivityUtils.AdjustCtrlSize(self.RrwardBG, {
      206,
      362,
      520,
      672,
      702
    }, #rewardList)
    if #rewardList >= 5 then
      self.AwardList.Slot:SetAutoSize(false)
    else
      self.AwardList.Slot:SetAutoSize(true)
    end
  else
    self.RewardsPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Activity_StarlightShowdown_C:RefreshRewardState()
  if not self.BtnSwitcher then
    return
  end
  local hasAvailableReward = self:CheckHasAvailableReward()
  if hasAvailableReward then
    self.BtnSwitcher:SetActiveWidgetIndex(0)
  else
    self.BtnSwitcher:SetActiveWidgetIndex(1)
  end
end

function UMG_Activity_StarlightShowdown_C:CheckHasAvailableReward()
  local rewardList = _G.NRCModuleManager:DoCmd(_G.WeeklyChallengeBattleModuleCmd.GetCurrentEventRewardList)
  if not rewardList then
    return false
  end
  for _, reward in ipairs(rewardList) do
    if reward.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_UNCLAIMED then
      return true
    end
  end
  return false
end

function UMG_Activity_StarlightShowdown_C:OnActivityDataUpdate()
  self:UpdateCheerPointDisplay()
  self:RefreshRewardState()
end

function UMG_Activity_StarlightShowdown_C:OnViewDetailsInfo()
  _G.NRCAudioManager:PlaySound2DAuto(1003, "UMG_Activity_StarlightShowdown_C:OnViewDetailsInfo")
  _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.OpenMagicManualByIndex, "MMT_STAR_WAR")
end

function UMG_Activity_StarlightShowdown_C:_LoadRival()
  local _activityInst = self.activityInst
  if not _activityInst then
    Log.Error("UMG_Activity_StarlightShowdown_C:_LoadRival activityInst is nil")
    return
  end
  local challengeData = _activityInst:GetWeeklyChallengeData()
  if not challengeData then
    Log.Error("UMG_Activity_StarlightShowdown_C:_LoadRival \232\142\183\229\143\150challenge data\229\164\177\232\180\165")
    return
  end
  local weeklyChallengeConf = _activityInst:GetCyclicalChallengeConf()
  if not weeklyChallengeConf then
    Log.Error("UMG_Activity_StarlightShowdown_C:_LoadRival \232\142\183\229\143\150weekly challenge conf\229\164\177\232\180\165")
    return
  end
  local challengeConf = _G.DataConfigManager:GetWeeklyChallengeConf(weeklyChallengeConf.challenge_id[1])
  if not challengeConf then
    Log.Error("UMG_Activity_StarlightShowdown_C:_LoadRival \232\142\183\229\143\150challenge conf\229\164\177\232\180\165")
    return
  end
  local npcConf = _G.DataConfigManager:GetNpcConf(challengeConf.npc)
  if not npcConf then
    Log.Error("UMG_Activity_StarlightShowdown_C:_LoadRival \232\142\183\229\143\150NpcConf\229\164\177\232\180\165")
    return
  end
  self.UMG_WeeklyChallengeBattle_World3D:SetModule(npcConf.model_conf, nil, true, self._OnRivalLoadFinished, self)
end

function UMG_Activity_StarlightShowdown_C:_OnRivalLoadFinished()
end

function UMG_Activity_StarlightShowdown_C:OnClickParticularsBtn()
  local _activityInst = self.activityInst
  if _activityInst then
    local desc = _activityInst:GetActivityDesc()
    if desc and "" ~= desc then
      local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
      local context = DialogContext()
      context:SetTitle(_activityInst:GetActivityName())
      context:SetContent(desc)
      context:SetContentTextJustify(UE4.ETextJustify.Left)
      context:SetClickAnywhereClose(true)
      context:SetMode(DialogContext.Mode.NotBtn)
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenLongDialog, context)
    end
  end
end

return UMG_Activity_StarlightShowdown_C
