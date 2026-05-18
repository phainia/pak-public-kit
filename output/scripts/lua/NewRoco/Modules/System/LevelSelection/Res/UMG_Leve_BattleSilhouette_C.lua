local MagicManualUtils = require("NewRoco.Modules.System.MagicManual.MagicManualUtils")
local LevelSelectionEnum = require("NewRoco.Modules.System.LevelSelection.LevelSelectionEnum")
local LevelSelectionModuleEvent = require("NewRoco.Modules.System.LevelSelection.LevelSelectionModuleEvent")
local UMG_Leve_BattleSilhouette_C = _G.NRCPanelBase:Extend("UMG_Leve_BattleSilhouette_C")

function UMG_Leve_BattleSilhouette_C:OnConstruct()
  self.data = self.module:GetData("LevelSelectionModuleData")
  self.NPCChallengeEventActivityObject = nil
  self.npc_challenge_data = nil
  self.ChallengeLevelData = nil
  self.SelectLevelIndex = nil
  self.OldSelectLevelIndex = nil
  self.SelectLevelData = nil
  self.IsClose = false
  self.LevelList = {}
  self.BgPathList = {
    self.LevelBgXue1,
    self.LevelBgXue2,
    self.LevelBgCastle1,
    self.LevelBgCastle2
  }
  self.ChallengeTextList = {
    _G.DataConfigManager:GetLocalizationConf("challenge_text_16").msg,
    _G.DataConfigManager:GetLocalizationConf("challenge_text_17").msg,
    _G.DataConfigManager:GetLocalizationConf("challenge_text_18").msg,
    _G.DataConfigManager:GetLocalizationConf("challenge_text_19").msg
  }
  self.npcAction = nil
  self.FirstOpen = true
  self.IsShow = true
  self:OnAddEventListener()
  _G.NRCAudioManager:PlaySound2DAuto(1256, "UMG_Leve_BattleSilhouette_C:OnConstruct")
end

function UMG_Leve_BattleSilhouette_C:OnDestruct()
  _G.NRCAudioManager:BatchSetState("UI_Music;None")
  if self.npcAction then
    self.npcAction:Finish()
    self.npcAction = nil
  end
end

function UMG_Leve_BattleSilhouette_C:OnActive(npcAction, index)
  self.npcAction = npcAction
  self:SetSwitcherIndex(index)
  self.NPCChallengeEventActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, Enum.ActivityType.ATP_NPC_CHALLENGE_EVENT)
  if self.NPCChallengeEventActivityObject and self.NPCChallengeEventActivityObject[1] then
    self.NPCChallengeEventActivityObject[1]:BindActivityTimeLeft(self.Time.TimeRemaining)
    self.npc_challenge_data = self.NPCChallengeEventActivityObject[1]:GetNpcChallengeData()
    self.ActivityId = self.NPCChallengeEventActivityObject[1]:GetNpcActivityId()
    if self.npc_challenge_data then
      self:SetPanelInfo()
    else
      Log.Error("\230\178\161\230\156\137\229\175\185\230\136\152\229\137\170\229\189\177\230\149\176\230\141\174,\232\175\183\230\159\165\231\156\139\229\142\159\229\155\160")
      return
    end
  else
    Log.Error("\230\178\161\230\156\137\229\175\185\230\136\152\229\137\170\229\189\177\230\149\176\230\141\174,\232\175\183\230\159\165\231\156\139\229\142\159\229\155\160")
    return
  end
  self:SetCommonTitle()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Leve_BattleSilhouette_C:ChildPanelLoadSucceed()
  if self.IsShow then
    if self.FirstOpen then
      self:PlayAnimation(self.World_open)
      self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.FirstOpen = false
    else
      _G.NRCAudioManager:PlaySound2DAuto(1256, "UMG_Leve_BattleSilhouette_C:ChildPanelLoadSucceed")
      self:PlayAnimation(self.Open)
      self:PlayChildAnim()
    end
  end
end

function UMG_Leve_BattleSilhouette_C:ShowOrHidePanel(IsShow)
  if IsShow then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.IsShow = IsShow
end

function UMG_Leve_BattleSilhouette_C:OnDisable()
end

function UMG_Leve_BattleSilhouette_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_Leve_BattleSilhouette_C:OnDeactive()
  if self.NPCChallengeEventActivityObject and self.NPCChallengeEventActivityObject[1] then
    self.NPCChallengeEventActivityObject[1]:UnBindActivityTimeLeft(self.Time.TimeRemaining)
  end
end

function UMG_Leve_BattleSilhouette_C:OnAddEventListener()
  self:AddButtonListener(self.CharacterButton, self.OnClickCharacterButton)
  self:AddButtonListener(self.ParticularsBtn.btnLevelUp, self.OnClickParticularsBtn)
  self:AddButtonListener(self.btnClose.btnClose, self.OnCloseBtn)
  self:AddButtonListener(self.RewardBtn, self.OnRewardBtn)
  self:AddButtonListener(self.StartTheShow.btnLevelUp, self.OnOpenSilhoutte)
  self:RegisterEvent(self, LevelSelectionModuleEvent.SelectLevelTabEvent, self.OnSelectLevelTabEvent)
  self:RegisterEvent(self, LevelSelectionModuleEvent.SelectCameraShotItemEvent, self.OnSelectCameraShotItemEvent)
end

function UMG_Leve_BattleSilhouette_C:SetPanelInfo()
  local NpcChallengeEventConf = _G.DataConfigManager:GetNpcChallengeEventConf(self.npc_challenge_data.event_id)
  local NPCChallengeEventStarNum = MagicManualUtils.GetNPCChallengeEventStarNum(NpcChallengeEventConf)
  local FinishNPCChallengeEventSchedule = MagicManualUtils.GetFinishNPCChallengeEventSchedule(self.npc_challenge_data, true)
  self.TextClaimProgress:SetText(string.format("%d/%d", FinishNPCChallengeEventSchedule, NPCChallengeEventStarNum))
  self.ScheduleItem:SetWidgetIndex(1)
  local Text = _G.DataConfigManager:GetLocalizationConf("challenge_title_1").msg
  self:CopyNPCModules()
  self:SetCameraShotList()
  if self.NPCChallengeEventActivityObject and self.NPCChallengeEventActivityObject[1] then
    self.RedDot:SetupKey(371, self.NPCChallengeEventActivityObject[1]:GetNpcActivityId())
  end
end

function UMG_Leve_BattleSilhouette_C:SetCameraShotList()
  for i, module in ipairs(self.LevelList) do
    local DefeatState = LevelSelectionEnum.DefeatState.Unlocked
    local UnlockedState = LevelSelectionEnum.UnlockedState.Unlocked
    module.ChallengeText = self.ChallengeTextList[i]
    for j, level in ipairs(module.levels) do
      local NpcChallengeConf = _G.DataConfigManager:GetNpcChallengeConf(level.challenge_id)
      if level.is_finish then
        DefeatState = LevelSelectionEnum.DefeatState.Defeated
        UnlockedState = LevelSelectionEnum.UnlockedState.locked
      elseif level.is_unlock then
        DefeatState = LevelSelectionEnum.DefeatState.NotDefeated
        UnlockedState = LevelSelectionEnum.UnlockedState.locked
      end
      level.DefeatState = DefeatState
      level.Text = NpcChallengeConf.number
    end
    module.UnlockedState = UnlockedState
    module.ActivityId = self.ActivityId
  end
  Log.Debug(self.ActivityId, "UMG_Leve_BattleSilhouette_C:SetCameraShotList")
  Log.Dump(self.LevelList, 4, "UMG_Leve_BattleSilhouette_C:SetCameraShotList")
  self.Tab:InitGridView(self.LevelList)
  self.SelectLevelIndex = self:FindUnlockedStateIndex()
  self.Tab:SelectItemByIndex(self.SelectLevelIndex)
end

function UMG_Leve_BattleSilhouette_C:SetModuleUnlockReadEd()
  for i, Level in ipairs(self.LevelList) do
    local Item = self.Tab:GetItemByIndex(i - 1)
    if Item then
      Item:PlayUnlockReadEd()
    end
  end
end

function UMG_Leve_BattleSilhouette_C:CopyNPCModules()
  local LevelList = {}
  for i, module in ipairs(self.npc_challenge_data.modules) do
    module.UnlockedState = LevelSelectionEnum.DefeatState.Unlocked
    table.insert(LevelList, module)
  end
  self.LevelList = LevelList
end

function UMG_Leve_BattleSilhouette_C:OnSelectLevelTabEvent(SelectLevelData, Index)
  if SelectLevelData.UnlockedState == LevelSelectionEnum.UnlockedState.Unlocked then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.challenge_text_29)
    self.Tab:SelectItemByIndex(self.SelectLevelIndex - 1)
    return
  end
  if self.SelectLevelIndex == Index then
    return
  end
  self.SelectLevelData = SelectLevelData
  self.SelectLevelIndex = Index
  if self.FirstOpen then
    self:SetSelectPanelInfo()
  elseif not self:IsAnimationPlaying(self.World_open) then
    self:PlayAnimation(self.Close)
  end
end

function UMG_Leve_BattleSilhouette_C:SetSelectPanelInfo()
  if self.NPCChallengeEventActivityObject and self.NPCChallengeEventActivityObject[1] and self.SelectLevelData then
    self.CameraShot:InitList(self.SelectLevelData.levels)
    local FindDefeatStateIndex = self:FindDefeatStateIndex(self.SelectLevelData)
    self.ChallengeLevelData = nil
    self:SwitchBg()
  else
    Log.Error("\230\178\161\230\156\137\229\175\185\230\136\152\229\137\170\229\189\177\230\149\176\230\141\174,\232\175\183\230\159\165\231\156\139\229\142\159\229\155\160")
  end
end

function UMG_Leve_BattleSilhouette_C:FindUnlockedStateIndex()
  local Index = 0
  for i, moduleList in ipairs(self.LevelList) do
    if moduleList.UnlockedState == LevelSelectionEnum.UnlockedState.locked then
      Index = i - 1
    end
  end
  return Index
end

function UMG_Leve_BattleSilhouette_C:FindDefeatStateIndex(SelectLevelData)
  local Index = 0
  for i, level in ipairs(SelectLevelData.levels) do
    if level.DefeatState == LevelSelectionEnum.DefeatState.NotDefeated then
      Index = i
      break
    end
  end
  if Index > 0 then
    Index = Index - 1
  end
  return Index
end

function UMG_Leve_BattleSilhouette_C:SwitchBg()
  if self.OldSelectLevelIndex then
    self:UnLoadSubPanel(self.OldSelectLevelIndex, false)
  end
  if self.BgPathList and self.BgPathList[self.SelectLevelIndex] then
    self:LoadSubPanel(self.SelectLevelIndex)
  end
  self.OldSelectLevelIndex = self.SelectLevelIndex
end

function UMG_Leve_BattleSilhouette_C:LoadSubPanel(_SubPanel, ...)
  local UmgLoader = _SubPanel and self.BgPathList and self.BgPathList[_SubPanel]
  if UmgLoader then
    UmgLoader:LoadPanel(nil, ...)
  end
end

function UMG_Leve_BattleSilhouette_C:PlayChildAnim()
  local UmgLoader = self.SelectLevelIndex and self.BgPathList and self.BgPathList[self.SelectLevelIndex]
  if UmgLoader then
    local Panel = UmgLoader:GetPanel()
    Panel:PlayOpen()
  end
end

function UMG_Leve_BattleSilhouette_C:UnLoadSubPanel(_SubPanel, _forceUnload, ...)
  local UmgLoader = _SubPanel and self.BgPathList and self.BgPathList[_SubPanel]
  if UmgLoader then
    return UmgLoader:UnLoadPanel(_forceUnload, ...)
  end
end

function UMG_Leve_BattleSilhouette_C:OnSelectCameraShotItemEvent(_ChallengeLevelData)
  _G.NRCAudioManager:PlaySound2DAuto(1078, "UMG_Leve_BattleSilhouette_C:OnSelectCameraShotItemEvent")
  self.ChallengeLevelData = _ChallengeLevelData
end

function UMG_Leve_BattleSilhouette_C:IsFinishTargets(targets)
  if targets and #targets > 0 then
    for k, _ in ipairs(targets) do
      if not _.is_finish then
        return false
      end
    end
    return true
  end
  return false
end

function UMG_Leve_BattleSilhouette_C:GetFastUnlockLevelIndex()
  for i, module in ipairs(self.npc_challenge_data.modules) do
    for j, level in ipairs(module.levels) do
      if self.npc_challenge_data.perfect_level_number and level.level_number == self.npc_challenge_data.perfect_level_number then
        return i
      end
    end
  end
  return 0
end

function UMG_Leve_BattleSilhouette_C:OnClickCharacterButton()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_Leve_BattleSilhouette_C:OnClickCharacterButton")
  local BattleRuleId = _G.DataConfigManager:GetNpcChallengeEventConf(self.npc_challenge_data.event_id).rule
  _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.OpenPlayDetails, BattleRuleId)
end

function UMG_Leve_BattleSilhouette_C:OnClickParticularsBtn()
  local titleText = _G.DataConfigManager:GetLocalizationConf("challenge_title_3").msg
  local contentStr = _G.DataConfigManager:GetLocalizationConf("challenge_text_7").msg
  local Context = DialogContext()
  Context:SetTitle(titleText):SetContent(contentStr):SetContentTextJustify(UE4.ETextJustify.Left):SetClickAnywhereClose(true):SetMode(DialogContext.Mode.NotBtn):SetCloseOnOK(true):SetCallback(self, self.OnDescDialogClosed)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenLongDialog, Context)
end

function UMG_Leve_BattleSilhouette_C:OnDescDialogClosed()
end

function UMG_Leve_BattleSilhouette_C:OnRewardBtn()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Leve_BattleSilhouette_C:OnRewardBtn")
  _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.OpenLeveClearanceReward, ProtoEnum.ActivityType.ATP_NPC_CHALLENGE_EVENT)
end

function UMG_Leve_BattleSilhouette_C:OnOpenSilhoutte()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_Leve_BattleSilhouette_C:OnClickCharacterButton")
  if self.ChallengeLevelData and self.ChallengeLevelData.challenge_id then
    _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.OnCmdOpenBattleSilhouettePanel, self.ChallengeLevelData.challenge_id)
  else
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\230\178\161\230\156\137\233\128\137\228\184\173\229\175\185\229\186\148\229\133\179\229\141\161")
  end
end

function UMG_Leve_BattleSilhouette_C:SetSwitcherIndex(index)
  if index then
    self.Switcher:SetActiveWidgetIndex(index)
  else
    self.Switcher:SetActiveWidgetIndex(0)
  end
end

function UMG_Leve_BattleSilhouette_C:OnCloseBtn()
  if self:IsPlayingAnimation() then
    return
  end
  self.IsClose = true
  self:PlayAnimation(self.World_close)
end

function UMG_Leve_BattleSilhouette_C:OnAnimationFinished(Anim)
  if Anim == self.Close or Anim == self.World_close then
    if self.IsClose then
      if self.SelectLevelIndex then
        self:UnLoadSubPanel(self.SelectLevelIndex, false)
      end
      self:DoClose()
    else
      self:SetSelectPanelInfo()
    end
  elseif Anim == self.World_open then
    _G.NRCAudioManager:BatchSetState("UI_Music;UI_Music;UI_Type;DuiZhan_Theater")
    self:PlayAnimation(self.Open)
    self:PlayChildAnim()
  elseif Anim == self.Open then
    self:SetModuleUnlockReadEd()
  end
end

return UMG_Leve_BattleSilhouette_C
