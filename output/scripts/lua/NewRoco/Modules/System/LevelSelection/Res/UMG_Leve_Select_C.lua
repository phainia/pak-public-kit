local LevelSelectionEnum = require("NewRoco.Modules.System.LevelSelection.LevelSelectionEnum")
local LevelSelectionModuleEvent = require("NewRoco.Modules.System.LevelSelection.LevelSelectionModuleEvent")
local MagicManualUtils = require("NewRoco.Modules.System.MagicManual.MagicManualUtils")
local UMG_Leve_Select_C = _G.NRCPanelBase:Extend("UMG_Leve_Select_C")

function UMG_Leve_Select_C:OnConstruct()
  self.data = self.module:GetData("LevelSelectionModuleData")
  self.boss_challenge_data = nil
  self.petTypeIcons = {
    self.petTypeIcon1,
    self.petTypeIcon2
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
  self.ChallengeLevelData = nil
  self.LevelDataList = {}
  self.npcAction = nil
  self:OnAddEventListener()
  self:SetCommonTitle()
  _G.NRCAudioManager:BatchSetState("UI_Music;UI_Music;UI_Type;ShouLing_Battle")
  self:PlayAnimation(self.Open)
end

function UMG_Leve_Select_C:OnDestruct()
  _G.NRCAudioManager:BatchSetState("UI_Music;None")
  if self.npcAction then
    self.npcAction:Finish()
    self.npcAction = nil
  end
end

function UMG_Leve_Select_C:OnActive(npcAction)
  self.npcAction = npcAction
  self.BossChallengeEventActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, Enum.ActivityType.ATP_BOSS_CHALLENGE_EVENT)
  if self.BossChallengeEventActivityObject and self.BossChallengeEventActivityObject[1] then
    self.BossChallengeEventActivityObject[1]:BindActivityTimeLeft(self.Time.TimeRemaining)
    self.boss_challenge_data = self.BossChallengeEventActivityObject[1]:GetBossChallengeData()
    self.BagPth = self.BossChallengeEventActivityObject[1]:GetBagPath()
    self.BossPath = self.BossChallengeEventActivityObject[1]:GetBossPath()
    self:CopyNPCLevels()
    self:SetLevelList()
    self:SetPanelInfo()
    self.RedDot:SetupKey(371, self.BossChallengeEventActivityObject[1]:GetBossActivityId())
  else
    Log.Error("\230\178\161\230\156\137\233\166\150\233\162\134\232\167\146\230\150\151\230\149\176\230\141\174,\232\175\183\230\159\165\231\156\139\229\142\159\229\155\160")
  end
end

function UMG_Leve_Select_C:OnDeactive()
end

function UMG_Leve_Select_C:OnAddEventListener()
  self:AddButtonListener(self.CharacterButton, self.OnClickCharacterButton)
  self:AddButtonListener(self.RewardBtn, self.OnClickRewardBtn)
  self:AddButtonListener(self.ParticularsBtn.btnLevelUp, self.OnClickParticularsBtn)
  self:AddButtonListener(self.btnClose.btnClose, self.OnClosePanel)
  self:AddButtonListener(self.Challenge.btnLevelUp, self.OnChallenge)
  self:RegisterEvent(self, LevelSelectionModuleEvent.SelectBossLevelEvent, self.OnSelectBossLevel)
  self:RegisterEvent(self, LevelSelectionModuleEvent.SelectCameraShotItemEvent, self.OnSelectCameraShotItemEvent)
end

function UMG_Leve_Select_C:CopyNPCLevels()
  local LevelList = {}
  if self.boss_challenge_data then
    for i, level in ipairs(self.boss_challenge_data.levels) do
      level.DefeatState = nil
      table.insert(LevelList, level)
    end
    self.LevelDataList = LevelList
  else
    Log.Error("UMG_Leve_Select_C:CopyNPCLevels  boss challenge data is nil")
  end
end

function UMG_Leve_Select_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_Leve_Select_C:SetLevelList()
  for i, level in ipairs(self.LevelDataList) do
    if i < self:FindFinishIndex() then
      level.DefeatState = LevelSelectionEnum.DefeatState.Defeated
    elseif i == self:FindFinishIndex() then
      level.DefeatState = LevelSelectionEnum.DefeatState.NotDefeated
    else
      level.DefeatState = LevelSelectionEnum.DefeatState.Unlocked
    end
    level.Text = _G.DataConfigManager:GetBossChallengeConf(level.challenge_id).number
  end
  self.LeveList:InitList(self.LevelDataList)
  local Index = self:FindUnlockedStateIndex()
  self.LeveList:SelectItemByIndex(Index)
end

function UMG_Leve_Select_C:FindUnlockedStateIndex()
  local Index = 0
  for i, module in ipairs(self.LevelDataList) do
    if module.DefeatState == LevelSelectionEnum.DefeatState.NotDefeated then
      Index = i
    end
  end
  if Index > 0 then
    Index = Index - 1
  end
  return Index
end

function UMG_Leve_Select_C:FindFinishIndex()
  for i, level in ipairs(self.LevelDataList) do
    if not level.is_finish then
      return i
    end
  end
  return #self.LevelDataList + 1
end

function UMG_Leve_Select_C:OnSelectCameraShotItemEvent(_ChallengeLevelData)
  if self.SelectTabAudio then
    _G.NRCAudioManager:PlaySound2DAuto(1078, "UMG_Leve_BattleSilhouette_C:OnSelectCameraShotItemEvent")
  else
    self.SelectTabAudio = true
  end
  self.ChallengeLevelData = _ChallengeLevelData
  local BossChallengeConf = _G.DataConfigManager:GetBossChallengeConf(_ChallengeLevelData.challenge_id)
  local BattleConf = _G.DataConfigManager:GetBattleConf(BossChallengeConf.battle)
  if BattleConf and BattleConf.npc_battle_list and BattleConf.npc_battle_list[1] and BattleConf.npc_battle_list[1].pos1_1st and BattleConf.npc_battle_list[1].pos1_1st[1] then
    local MonsterConf = _G.DataConfigManager:GetMonsterConf(BattleConf.npc_battle_list[1].pos1_1st[1])
    if MonsterConf then
      self.TextClass:SetText(string.format(LuaText.umg_petskilltemple2_1, MonsterConf.new_level[1]))
    end
  end
  local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(BossChallengeConf.petbase)
  if PetBaseConf then
    self.TextName:SetText(PetBaseConf.name)
    local AttrListInfo = self:GetPetAttrList(PetBaseConf.id)
    self.Attr:InitGridView(AttrListInfo)
  end
end

function UMG_Leve_Select_C:SetPanelInfo()
  local BossChallengeEventConf = _G.DataConfigManager:GetBossChallengeEventConf(self.boss_challenge_data.event_id)
  if BossChallengeEventConf then
    local BossChallengeEventStarNum = MagicManualUtils.GetNPCChallengeEventStarNum(BossChallengeEventConf)
    local FinishBossChallengeEventSchedule = MagicManualUtils.GetFinishBossChallengeEventSchedule(self.boss_challenge_data, true)
    self.TextClaimProgress:SetText(string.format("%d/%d", FinishBossChallengeEventSchedule, BossChallengeEventStarNum))
    local Text = _G.DataConfigManager:GetLocalizationConf("challenge_title_2").msg
    if self.BagPth then
      self.NRCImage_1:SetPath(self.BagPth)
    end
    if self.BossPath then
      self.pet:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.pet:SetPath(self.BossPath)
    end
  end
  self.ScheduleItem:SetWidgetIndex(1)
end

function UMG_Leve_Select_C:OnSelectBossLevel(ChallengeLevel)
  local BossChallengeConf = _G.DataConfigManager:GetBossChallengeConf(ChallengeLevel.challenge_id)
  local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(BossChallengeConf.petbase)
  if PetBaseConf then
    self.TextName:SetText(PetBaseConf.name)
    self:updatePetTypeIcon(PetBaseConf.unit_type)
    self.TextClass:SetText(string.format(LuaText.umg_petskilltemple2_1, BossChallengeConf.level))
  end
end

function UMG_Leve_Select_C:GetPetAttrList(petbaseId)
  local petbaseConf = _G.DataConfigManager:GetPetbaseConf(petbaseId)
  local attrList = {}
  if petbaseConf then
    local attr = petbaseConf.unit_type
    for i = 1, #attr do
      local attrId = attr[i]
      local conf = _G.DataConfigManager:GetTypeDictionary(attrId)
      if conf then
        table.insert(attrList, {
          Path = conf.type_icon,
          Name = conf.short_name
        })
      end
    end
  end
  return attrList
end

function UMG_Leve_Select_C:OnClickCharacterButton()
  if self.boss_challenge_data and self.boss_challenge_data.event_id then
    _G.NRCAudioManager:PlaySound2DAuto(40008034, "UMG_Leve_Select_C:OnClickParticularsBtn")
    local BattleRuleId = _G.DataConfigManager:GetBossChallengeEventConf(self.boss_challenge_data.event_id).rule
    _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.OpenPlayDetails, BattleRuleId)
  else
    Log.Debug("boss_challenge_data\228\184\141\229\173\152\229\156\168")
  end
end

function UMG_Leve_Select_C:OnClickParticularsBtn()
  _G.NRCAudioManager:PlaySound2DAuto(40008034, "UMG_Leve_Select_C:OnClickParticularsBtn")
  local titleText = _G.DataConfigManager:GetLocalizationConf("challenge_title_4").msg
  local contentStr = _G.DataConfigManager:GetLocalizationConf("challenge_text_8").msg
  local Context = DialogContext()
  Context:SetTitle(titleText):SetContent(contentStr):SetContentTextJustify(UE4.ETextJustify.Left):SetMode(DialogContext.Mode.NotBtn):SetCloseOnOK(true):SetCallback(self, self.OnDescDialogClosed)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenLongDialog, Context)
end

function UMG_Leve_Select_C:OnDescDialogClosed()
end

function UMG_Leve_Select_C:OnClosePanel()
  self:PlayAnimation(self.Close)
end

function UMG_Leve_Select_C:OnClickRewardBtn()
  _G.NRCAudioManager:PlaySound2DAuto(40008034, "UMG_Leve_Select_C:OnClickRewardBtn")
  _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.OpenLeveClearanceReward, ProtoEnum.ActivityType.ATP_BOSS_CHALLENGE_EVENT)
end

function UMG_Leve_Select_C:OnChallenge()
  _G.NRCAudioManager:PlaySound2DAuto(40008034, "UMG_Leve_Select_C:OnClickRewardBtn")
  if self.ChallengeLevelData and self.ChallengeLevelData.challenge_id then
    _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.OnCmdOpenBattleBossPanel, self.ChallengeLevelData.challenge_id)
  else
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\230\178\161\230\156\137\232\167\163\233\148\129")
  end
end

function UMG_Leve_Select_C:OnAnimationFinished(Anim)
  if Anim == self.Close then
    self:DoClose()
  end
end

return UMG_Leve_Select_C
