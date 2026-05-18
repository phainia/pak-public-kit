local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local JsonUtils = require("Common.JsonUtils")
local WeeklyChallengeBattleModuleEnum = require("NewRoco.Modules.System.WeeklyChallengeBattle.WeeklyChallengeBattleModuleEnum")
local UMG_Activity_Fight_C = Base:Extend("UMG_Activity_Fight_C")

function UMG_Activity_Fight_C:BindUIElements()
  local uiElements = {}
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.timeRemaining = self.Text_TimeRemaining
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  uiElements.closeAnimName = "Out"
  return uiElements
end

function UMG_Activity_Fight_C:OnConstruct()
  self:SetChildViews(self.UMG_WeeklyChallengeBattle_World3D)
  self.UMG_WeeklyChallengeBattle_World3D:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CyclicalChallengeItemObject = nil
  self.petTypeIcons = {
    self.petTypeIcon1,
    self.petTypeIcon2_1
  }
  self.petTypeText = {
    {
      self.BG,
      self.Text
    },
    {
      self.Bg_1,
      self.Text_1
    }
  }
  Base.OnConstruct(self)
  self:OnAddEventListener()
  self:InitInfo()
end

function UMG_Activity_Fight_C:OnDestruct()
  Base.OnDestruct(self)
end

function UMG_Activity_Fight_C:OnActive()
end

function UMG_Activity_Fight_C:InitInfo()
  self.includeActivities = self.activityInst:GetIncludeActivities()
  self.TabList1_1:InitGridView(self.includeActivities)
  self.TabList1_1:SelectItemByIndex(0)
  if not self.includeActivities or 0 == #self.includeActivities then
    return
  end
  local earliest_time
  local earliest_index = -1
  for i, activity in ipairs(self.includeActivities) do
    local current_end_time = activity:GetActivityEndTime()
    if -1 == earliest_index or earliest_time > current_end_time then
      earliest_time = current_end_time
      earliest_index = i - 1
    end
  end
  if -1 ~= earliest_index then
    local Item = self.TabList1_1:GetItemByIndex(earliest_index)
    if Item then
      Item:IsShowSandClock(true)
    end
  end
end

function UMG_Activity_Fight_C:OnDeactive()
end

function UMG_Activity_Fight_C:OnAddEventListener()
  self:AddButtonListener(self.CharacterButton, self.OnClickCharacterButton)
  self:AddButtonListener(self.ParticularsBtn, self.OnClickParticularsBtn)
  self:AddButtonListener(self.ExamineBtn, self.OnClickExamineBtn)
  self:AddButtonListener(self.Btn_Claimable.btnLevelUp, self.OnViewDetailsInfo)
  self:RegisterEvent(self, ActivityModuleEvent.SelectCyclicalChallengeTabEvent, self.OnSelectCyclicalChallengeTabEvent)
end

function UMG_Activity_Fight_C:OnSelectCyclicalChallengeTabEvent(CyclicalChallengeItemObject, index)
  if not CyclicalChallengeItemObject then
    Log.Debug("CyclicalChallengeItemObject\228\184\141\229\173\152\229\156\168\232\175\183\230\159\165\231\156\139\229\142\159\229\155\160")
    return
  end
  if CyclicalChallengeItemObject == self.CyclicalChallengeItemObject then
    return
  end
  self.activityInst:SwitchSelectActivity(CyclicalChallengeItemObject:GetActivityId())
  self:ReBindUIElements()
  self.CyclicalChallengeItemObject = CyclicalChallengeItemObject
  local Conf = CyclicalChallengeItemObject:GetCyclicalChallengeConf()
  self.Text_Title:SetText(Conf.topic)
  if Conf.type then
    self.AttrList:SetVisibility(UE4.ESlateVisibility.Visible)
    self.AttrList:InitGridView(Conf.type)
  else
    self.AttrList:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local ActivityConf = self.CyclicalChallengeItemObject:GetActivityConf()
  if ActivityConf.prompt_text then
    self.Text_Describe:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Text_Describe:SetText(ActivityConf.prompt_text)
  else
    self.Text_Describe:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:SetBattlePlayRewardList(CyclicalChallengeItemObject:GetCyclicalChallengeConf())
  local ActivityType = CyclicalChallengeItemObject:GetActivityType()
  self.CharacterButton:SetVisibility(UE4.ESlateVisibility.Visible)
  if ActivityType == Enum.ActivityType.ATP_NPC_CHALLENGE_EVENT then
    self.VerticalBox_77:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasPanel_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCImage_1:SetPath("Texture2D'/Game/NewRoco/Modules/System/LevelSelection/Raw/Textures/img_heiye_bg.img_heiye_bg'")
    self.NRCImage_1.Brush.ImageSize = UE.FVector2D(2048, 1536)
  elseif ActivityType == Enum.ActivityType.ATP_BOSS_CHALLENGE_EVENT then
    self.VerticalBox_77:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(Conf.petbase)
    if PetBaseConf then
      self.TextName:SetText(PetBaseConf.name)
      self:updatePetTypeIcon(PetBaseConf.unit_type)
    end
    self.CanvasPanel_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.pet:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.pet:SetPath(self.CyclicalChallengeItemObject:GetBossPath())
    self.NRCImage_1:SetPath(self.CyclicalChallengeItemObject:GetBagPath())
    self.NRCImage_1.Brush.ImageSize = UE.FVector2D(2048, 1536)
  elseif ActivityType == Enum.ActivityType.ATP_WEEKLY_CHALLENGE_EVENT then
    self.VerticalBox_77:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasPanel_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local imagePath = "Texture2D'/Game/NewRoco/Modules/System/LevelSelection/Raw/Textures/img_xueshanheiye.img_xueshanheiye'"
    local challengeConf = _G.DataConfigManager:GetWeeklyChallengeConf(Conf.challenge_id[1])
    if challengeConf then
      local photoConf = _G.DataConfigManager:GetWeeklyPhotoConf(challengeConf.photo)
      if photoConf then
        if photoConf.background and "" ~= photoConf then
          Log.Info("\233\128\154\232\191\135background\229\143\130\230\149\176\232\142\183\229\143\150\232\131\140\230\153\175")
          local batch, number = self:_GetBatchAndNumberFromCurtainName(photoConf.background)
          imagePath = string.format(UEPath.WeeklyChallengeBattleBackground, batch, number, batch, number)
        elseif photoConf.res_name and "" ~= photoConf.res_name then
          Log.Info("\233\128\154\232\191\135\229\144\136\231\133\167\230\149\176\230\141\174\232\142\183\229\143\150\232\131\140\230\153\175")
          local json = JsonUtils.LoadSavedFromStarLight(photoConf.res_name or "PhotoEditorJson", {})
          if json and json[1] and json[2] then
            local curtainName = json[1][2]
            local batch, number = self:_GetBatchAndNumberFromCurtainName(curtainName)
            imagePath = string.format(UEPath.WeeklyChallengeBattleBackground, batch, number, batch, number)
          else
            Log.Error("Json\232\142\183\229\143\150\229\164\177\232\180\165")
          end
        end
      else
        Log.Error("UMG_Activity_Fight_C:OnSelectCyclicalChallengeTabEvent photoConf\228\184\186\231\169\186")
      end
    else
      Log.Error("UMG_Activity_Fight_C:OnSelectCyclicalChallengeTabEvent challengeConf\228\184\186\231\169\186")
    end
    self.NRCImage_1:SetPath(imagePath)
    self.NRCImage_1.Brush.ImageSize = UE.FVector2D(2048, 1536)
    self.CharacterButton:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.UMG_WeeklyChallengeBattle_World3D:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    _G.NRCViewBase:DelayFrames(1, function()
      self:_LoadRival(CyclicalChallengeItemObject)
    end)
  end
end

function UMG_Activity_Fight_C:SetBattlePlayRewardList(ChallengeEventConf)
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
  self.AwardList:InitList(RewardList)
  ActivityUtils.AdjustCtrlSize(self.RrwardBG, {
    180,
    340,
    490,
    650,
    702
  }, #RewardList)
  if #RewardList > 4 then
    self.AwardList.Slot:SetAutoSize(false)
  else
    self.AwardList.Slot:SetAutoSize(true)
  end
end

function UMG_Activity_Fight_C:updatePetTypeIcon(_dicTypes)
  local attrDatas = {}
  for i = #_dicTypes, 1, -1 do
    local petType = _dicTypes[i]
    local typeDic = _G.DataConfigManager:GetTypeDictionary(petType)
    if typeDic then
      table.insert(attrDatas, {
        Name = typeDic.short_name,
        Path = typeDic.type_icon
      })
    end
  end
  self.Attr:InitGridView(attrDatas)
end

function UMG_Activity_Fight_C:OnClickCharacterButton()
  if self.CyclicalChallengeItemObject then
    local ActivityType = self.CyclicalChallengeItemObject:GetActivityType()
    local CyclicalChallengeConf = self.CyclicalChallengeItemObject:GetCyclicalChallengeConf()
    _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.OpenPlayDetails, CyclicalChallengeConf and CyclicalChallengeConf.rule)
  end
end

function UMG_Activity_Fight_C:OnViewDetailsInfo()
  _G.NRCAudioManager:PlaySound2DAuto(1003, "UMG_PetInfoMain_C:OnViewDetailsInfo")
  local ActivityType = self.CyclicalChallengeItemObject:GetActivityType()
  local ChildTableIndex = "MMT_STAR_WAR"
  if ActivityType == Enum.ActivityType.ATP_WEEKLY_CHALLENGE_EVENT then
    ChildTableIndex = "MMT_STAR_WAR"
  elseif ActivityType == Enum.ActivityType.ATP_NPC_CHALLENGE_EVENT then
    ChildTableIndex = "MMT_BATTLE_THEATER"
  elseif ActivityType == Enum.ActivityType.ATP_BOSS_CHALLENGE_EVENT then
    ChildTableIndex = "MMT_CHAMPION_DUEL"
  end
  _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.OpenMagicManualByIndex, ChildTableIndex)
end

function UMG_Activity_Fight_C:OnClickExamineBtn()
end

function UMG_Activity_Fight_C:OnClickParticularsBtn()
end

function UMG_Activity_Fight_C:_GetBatchAndNumberFromCurtainName(fileName)
  local batch, number = string.match(fileName, "^MI_Curtain_(.-)_(.-)_Skeletal$")
  return batch, number
end

function UMG_Activity_Fight_C:_LoadRival(weeklyChallengeObj)
  local challengeData = weeklyChallengeObj:GetWeeklyChallengeData()
  if not challengeData then
    Log.Error("UMG_Activity_Fight_C:_LoadRival \232\142\183\229\143\150challenge data\229\164\177\232\180\165")
    return
  end
  local eventConf = _G.DataConfigManager:GetWeeklyChallengeEventConf(challengeData.event_id)
  if not eventConf then
    Log.Error("UMG_Activity_Fight_C:_LoadRival \232\142\183\229\143\150event conf\229\164\177\232\180\165")
    return
  end
  local challengeConf = _G.DataConfigManager:GetWeeklyChallengeConf(eventConf.challenge_id[1])
  if not challengeConf then
    Log.Error("UMG_Activity_Fight_C:_LoadRival \232\142\183\229\143\150challenge conf\229\164\177\232\180\165")
    return
  end
  local npcConf = _G.DataConfigManager:GetNpcConf(challengeConf.npc)
  if not npcConf then
    Log.Error("UMG_Activity_Fight_C:_LoadRival \232\142\183\229\143\150NpcConf\229\164\177\232\180\165")
    return
  end
  self.UMG_WeeklyChallengeBattle_World3D:SetModule(npcConf.model_conf, nil, true)
end

return UMG_Activity_Fight_C
