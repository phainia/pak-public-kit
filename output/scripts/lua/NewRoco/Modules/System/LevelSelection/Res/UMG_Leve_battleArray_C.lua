local LevelSelectionEnum = require("NewRoco.Modules.System.LevelSelection.LevelSelectionEnum")
local LevelSelectionModuleEvent = require("NewRoco.Modules.System.LevelSelection.LevelSelectionModuleEvent")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_Leve_battleArray_C = _G.NRCPanelBase:Extend("UMG_Leve_battleArray_C")

function UMG_Leve_battleArray_C:OnActive(panelType, battleId)
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  end
  self:PlayAnimation(self.Open)
  self.Hint:SetBtnText(LuaText.challenge_text_37)
  self.Hint:SetTitleTextAndIcon(nil, nil, nil, nil, LuaText.challenge_text_12)
  self.Hint:SetTitleTextColor("f4eee1FF")
  self.Hint:SetShowLockIcon(false)
  self.Hint:SetClickAble(false)
  self.NRCText_96:SetText(LuaText.challenge_text_25)
  self.NRCText:SetText(LuaText.challenge_text_26)
  self.NRCText_3:SetText(LuaText.challenge_text_27)
  self.Title1:SetSubtitle(LuaText.challenge_title_1)
  self.Title2:SetSubtitle(LuaText.challenge_title_2)
  self:SetCommonTitle()
  _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdSetCacheTeamData, nil)
  local BossChallengeEventActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, Enum.ActivityType.ATP_BOSS_CHALLENGE_EVENT)
  local npcChallengeEventActivityObject = _G.NRCModuleManager:DoCmd(ActivityModuleCmd.GetActivityInstByType, Enum.ActivityType.ATP_NPC_CHALLENGE_EVENT)
  self.curPanelType = panelType
  self.battleId = battleId
  self.boss_challenge_data = BossChallengeEventActivityObject[1] and BossChallengeEventActivityObject[1]:GetBossChallengeData() or nil
  self.npc_challenge_data = npcChallengeEventActivityObject[1] and npcChallengeEventActivityObject[1]:GetNpcChallengeData() or nil
  self.silhouetteLevelInfoDic = {}
  if self.curPanelType == LevelSelectionEnum.BattlePanel.Silhouette then
    self.curActiveId = npcChallengeEventActivityObject[1]:GetActivityId()
    local conf = self:GetCurrentNpcChallengeConf()
    self.NRCText_1:SetText(string.format("%s\194\183%s", conf.topic, LuaText.challenge_text_24))
    self.UMG_Leve_World3D:SetVisibility(UE4.ESlateVisibility.Visible)
    if conf.avatar == _G.Enum.OpponentType.OT_PLAYER then
      _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdZoneGetNpcChallengeImageReq, self.curActiveId, conf.avatar_param)
    else
      local moduleId = _G.DataConfigManager:GetNpcConf(conf.avatar_param).model_conf
      self.UMG_Leve_World3D:SetModule(moduleId)
    end
    if self.npc_challenge_data then
      for i, info in pairs(self.npc_challenge_data.modules) do
        if conf and info.module_id == conf.module_id then
          self:LoadSubPanel(i)
        end
      end
    end
    self:OnConfirmSelected(self.module.data.curNpcTeamData)
    self.Switcher_BG:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.CanvasPanel_0:SetRenderOpacity(1)
    self.CanvasPanel_0:SetVisibility(UE4.ESlateVisibility.Visible)
    local conf = self:GetCurrentBossChallengeConf()
    self.NRCText_1:SetText(string.format("%s\194\183%s", conf.topic, LuaText.challenge_text_24))
    self.UMG_Leve_World3D:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.curActiveId = BossChallengeEventActivityObject and BossChallengeEventActivityObject[1]:GetActivityId() or 0
    local BagPth = BossChallengeEventActivityObject and BossChallengeEventActivityObject[1]:GetBagPath() or ""
    local BossPath = BossChallengeEventActivityObject and BossChallengeEventActivityObject[1]:GetBossPath() or ""
    self.NRCImage_5:SetPath(BagPth)
    self.pet:SetPath(BossPath)
    self.pet:SetVisibility(UE4.ESlateVisibility.Visible)
    self:OnConfirmSelected(self.module.data.curBossTeamData)
    self.Switcher_BG:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Switcher_BG:SetActiveWidgetIndex(0)
  end
  self.bossLevelInfoDic = {}
  if self.npc_challenge_data then
    for i, info in pairs(self.npc_challenge_data.modules) do
      for _, challengeLevel in pairs(info.levels) do
        self.silhouetteLevelInfoDic[challengeLevel.challenge_id] = challengeLevel
      end
    end
  end
  if self.boss_challenge_data then
    for _, challengeLevel in pairs(self.boss_challenge_data.levels) do
      self.bossLevelInfoDic[challengeLevel.challenge_id] = challengeLevel
    end
  end
  self.Button_82:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:ShowDefaultInfo()
  self:ShowDescribeContent()
end

function UMG_Leve_battleArray_C:OnShowView()
  self:PlayAnimation(self.Open)
end

function UMG_Leve_battleArray_C:LoadSubPanel(_SubPanel, ...)
  local UmgLoader = _SubPanel and self.UmgLoaders and self.UmgLoaders[_SubPanel]
  if UmgLoader then
    UmgLoader:LoadPanel(nil, ...)
  end
end

function UMG_Leve_battleArray_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:Set_MainTitle()
  self.Title2:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg("PaperSprite'/Game/NewRoco/Modules/System/LevelSelection/Raw/Frames/img_biaoti_png.img_biaoti_png'")
  self.Title2:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(LuaText.challenge_title_1)
  self.Title2:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_Leve_battleArray_C:ShowDefaultInfo()
  self.Switcher_Title:SetActiveWidgetIndex(self.curPanelType)
  self.NRCSwitcher_2:SetActiveWidgetIndex(self.curPanelType)
  if self.curPanelType == LevelSelectionEnum.BattlePanel.Silhouette then
    local listData = self:GetSilhouetteLastGameTarget()
    local conf = self:GetCurrentNpcChallengeConf()
    local battleId = conf.battle
    local battleConf = _G.DataConfigManager:GetBattleConf(battleId)
    local hp = {}
    for i = 1, battleConf.rival_available_HP do
      table.insert(hp, i)
    end
    self.FinishList:InitGridView(listData)
    self.PlayerName:settext(conf.name)
    self.HPList:InitGridView(hp)
    local activityId = self.curActiveId
    local baseId = _G.DataConfigManager:GetActivityConf(activityId).base_id[1]
    local npcChallengeEventConf = _G.DataConfigManager:GetNpcChallengeEventConf(baseId)
    self.ruleId = npcChallengeEventConf.rule[1]
  elseif self.curPanelType == LevelSelectionEnum.BattlePanel.Boss then
    local listData = self:GetBossLastGameTarget()
    local conf = self:GetCurrentBossChallengeConf()
    self.FinishList:InitGridView(listData)
    self.PlayerName:settext(conf.name)
    local BattleConf = _G.DataConfigManager:GetBattleConf(conf.battle)
    if BattleConf then
      if BattleConf.npc_battle_list and BattleConf.npc_battle_list[1] and BattleConf.npc_battle_list[1].pos1_1st and BattleConf.npc_battle_list[1].pos1_1st[1] then
        local MonsterConf = _G.DataConfigManager:GetMonsterConf(BattleConf.npc_battle_list[1].pos1_1st[1])
        if MonsterConf then
          self.Class:settext(string.format(LuaText.umg_pass_awarditem1_1, MonsterConf.new_level[1]))
        end
      end
    else
      self.Class:settext(string.format(LuaText.umg_pass_awarditem1_1, conf.level))
    end
    local AttrListInfo = self:GetPetAttrList(conf.petbase)
    self.Attr:InitGridView(AttrListInfo)
    local activityId = self.curActiveId
    local baseId = _G.DataConfigManager:GetActivityConf(activityId).base_id[1]
    local bossChallengeEventConf = _G.DataConfigManager:GetBossChallengeEventConf(baseId)
    self.ruleId = bossChallengeEventConf.rule[1]
  end
  self:OnSwitcherNRCSwitcher_0(self.curPanelType)
end

function UMG_Leve_battleArray_C:ShowDescribeContent()
  if self.curPanelType == LevelSelectionEnum.BattlePanel.Silhouette then
    local conf = self:GetCurrentNpcChallengeConf()
    local bagConf = _G.DataConfigManager:GetBagItemConf(conf.player_magic_item)
    local battleTeamListInfo = self:GetBattleTeamList(conf.battle)
    self.OpponentLineUp:InitGridView(battleTeamListInfo)
    self.Icon_1:SetPath(bagConf.icon)
    local ruleConf = _G.DataConfigManager:GetBattleRuleConf(self.ruleId)
    local battleRuleConf = _G.DataConfigManager:GetBattleRuleConf(conf.rule[1] or 10001)
    self.TextSkill:SetText(battleRuleConf.title or "rule\232\161\168\230\178\161\233\133\141\230\160\135\233\162\152")
    self.SkillIcon:SetPath(battleRuleConf.icon)
    self.NRCTextDes_1:SetText(battleRuleConf.desc)
    self.NRCTextDes:SetText(ruleConf.desc)
    self.MyTeam:SetTeamType(conf.type, LevelSelectionEnum.BattlePanel.Silhouette, self.curActiveId)
  elseif self.curPanelType == LevelSelectionEnum.BattlePanel.Boss then
    local conf = self:GetCurrentBossChallengeConf()
    local activityId = self.curActiveId
    local baseId = _G.DataConfigManager:GetActivityConf(activityId).base_id[1]
    local bossChallengeEventConf = _G.DataConfigManager:GetBossChallengeEventConf(baseId)
    local ruleId = bossChallengeEventConf.rule[1]
    local desc = _G.DataConfigManager:GetBattleRuleConf(ruleId).desc
    local ruleTitleList1 = {}
    local ruleTitleList2 = {}
    if conf.rule ~= nil and #conf.rule > 0 then
      for i = 1, #conf.rule do
        local ruleConf = _G.DataConfigManager:GetBattleRuleConf(conf.rule[i] or 10001)
        table.insert(ruleTitleList1, {
          ruleConf = ruleConf,
          petbaseId = conf.petbase
        })
      end
      for i = 1, #conf.description do
        local description = conf.description[i]
        table.insert(ruleTitleList2, {des = description})
      end
    end
    self.TitleList:InitGridView(ruleTitleList1)
    self.DescribeList:InitGridView(ruleTitleList2)
    self.NRCTextDes_2:SetText(desc)
    self.MyTeam:SetTeamType(conf.type, LevelSelectionEnum.BattlePanel.Boss, self.curActiveId)
    if self.boss_challenge_data then
      self.MyTeam:SetTeamBuffRule(self.boss_challenge_data.buff_rule_id)
    end
  end
end

function UMG_Leve_battleArray_C:OnOpenBattleTeamView()
  self.NRCSwitcher_1:SetActiveWidgetIndex(1)
  _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdOpenBattleTeamPanel, self.curPanelType)
  self.Button_82:SetVisibility(UE4.ESlateVisibility.Visible)
  self.UMG_Leve_World3D:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Leve_battleArray_C:OnEnableTeamButton(isEnable)
  self.MyTeam:EnableTeamButton(isEnable)
end

function UMG_Leve_battleArray_C:OnCloseBattleTeamView()
  self.NRCSwitcher_1:SetActiveWidgetIndex(0)
  self.MyTeam:UnSelectTeam()
  self.MyTeam:ClearItemSelect()
  self.Button_82:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:IsHideRight(false)
  self.UMG_Leve_World3D:SetVisibility(self.curPanelType == LevelSelectionEnum.BattlePanel.Silhouette and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self.pet:SetVisibility(self.curPanelType == LevelSelectionEnum.BattlePanel.Boss and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
end

function UMG_Leve_battleArray_C:OnConfirmSelected(teamInfo)
  self.MyTeam:OnConfirmSelected(teamInfo)
end

function UMG_Leve_battleArray_C:OnSaveBattleTeamSucceed()
  self:OnUpdateMyTeamInfo()
  self:ChangReminderBtnEnable()
end

function UMG_Leve_battleArray_C:OnApplicationBattleTeamSucceed()
  self.Button_82:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.MyTeam:UnSelectTeam()
  self.UMG_Leve_World3D:SetVisibility(self.curPanelType == LevelSelectionEnum.BattlePanel.Silhouette and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self.pet:SetVisibility(self.curPanelType == LevelSelectionEnum.BattlePanel.Boss and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self:OnUpdateMyTeamInfo()
  self:ChangReminderBtnEnable()
  _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdCloseBattleTeamPanel)
end

function UMG_Leve_battleArray_C:OnChangeSelectPet(petGidDic)
  self.MyTeam:OnChangeSelectPet(petGidDic)
  self:ChangReminderBtnEnable()
end

function UMG_Leve_battleArray_C:ChangReminderBtnEnable()
  local isEnableBtn = true
  if UE4.UObject.IsValid(self.MyTeam) then
    if self.MyTeam.curTeamInfo then
      local teams = self.MyTeam.curTeamInfo.teams
      for key, team in pairs(teams) do
        if 0 == team.pet_gid then
          isEnableBtn = false
          break
        end
      end
    else
      isEnableBtn = false
    end
  else
    isEnableBtn = false
  end
  self.Switcher:SetActiveWidgetIndex(isEnableBtn and 0 or 1)
end

function UMG_Leve_battleArray_C:OnUpdateTeamBloodMagic()
  local teamInfo = {}
  if self.curPanelType == LevelSelectionEnum.BattlePanel.Silhouette then
    teamInfo = self.module.data.curNpcTeamData
  else
    teamInfo = self.module.data.curBossTeamData
  end
  self.MyTeam:OnUpdateBloodMagic(teamInfo, self.curTabIndex)
end

function UMG_Leve_battleArray_C:OnUpdateMyTeamInfo()
  local teamInfo = {}
  if self.curPanelType == LevelSelectionEnum.BattlePanel.Silhouette then
    teamInfo = self.module.data.curNpcTeamData
  else
    teamInfo = self.module.data.curBossTeamData
  end
  self.MyTeam:ShowPetList(teamInfo)
end

function UMG_Leve_battleArray_C:OnReplaceRuleSucceed(rule_id)
  self.MyTeam:OnUpdateRuleBuff(rule_id)
end

function UMG_Leve_battleArray_C:OnTriggerModuleMove(isRight)
  if isRight then
    self.UMG_Leve_World3D:MoveCenter()
  else
    self.UMG_Leve_World3D:MoveResest()
  end
end

function UMG_Leve_battleArray_C:OnLeaderTraitCloseUpdate()
  local count = self.TitleList:GetItemCount()
  for i = 0, count - 1 do
    local item = self.TitleList:GetItemByIndex(i)
    item:ChangeNormalAim()
  end
end

function UMG_Leve_battleArray_C:OnOpenTeamCompiler(isOpenCompiler)
  if isOpenCompiler then
    self.MyTeam:ShowCover()
  else
    self.MyTeam:SelectTeam()
  end
end

function UMG_Leve_battleArray_C:OnModuleLoadFinish()
  self:PlayAnimation(self.Open)
  self.CanvasPanel_0:SetRenderOpacity(1)
  self.CanvasPanel_0:SetVisibility(UE4.ESlateVisibility.Visible)
  self.module:ShowOrHideBattleSilhouette(false)
end

function UMG_Leve_battleArray_C:OnUpdateChallengeImage(battleAppearanceInfo)
  if battleAppearanceInfo then
    self.UMG_Leve_World3D:SetModule(nil, battleAppearanceInfo)
    local conf = self:GetCurrentNpcChallengeConf()
    if conf.name == nil or conf.name == "" then
      self.PlayerName:settext(battleAppearanceInfo.name)
    end
  else
    self:OnModuleLoadFinish()
  end
end

function UMG_Leve_battleArray_C:CloseBattleTeamView()
end

function UMG_Leve_battleArray_C:OnClosePanel()
  self.isClose = true
  self:PlayAnimation(self.Close)
  self.pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Leve_battleArray_C:ShowBattleTeamView()
  _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdOpenBattleTeamPanel, self.curPanelType)
end

function UMG_Leve_battleArray_C:OnBattleTeamViewClassLoaded(resRequest, viewClass)
  local newView = UE4.UWidgetBlueprintLibrary.Create(UE4Helper.GetCurrentWorld(), viewClass)
  self:DynamicAddChildView(newView)
  local contentSlot = self.Team:AddChild(newView)
  if contentSlot then
    local anchors = UE4.FAnchors()
    anchors.Minimum = UE4.FVector2D(0, 0)
    anchors.Maximum = UE4.FVector2D(1, 1)
    contentSlot:SetAnchors(anchors)
    contentSlot:SetOffsets(UE4.FMargin())
    contentSlot:SetAlignment(UE4.FVector2D(0.5, 0.5))
  end
  newView:OnInit()
  newView:OnOpenPanel(self.curPanelType)
  self.BattleTeamView = newView
end

function UMG_Leve_battleArray_C:GetCurrentNpcChallengeConf()
  local conf = _G.DataConfigManager:GetNpcChallengeConf(self.battleId)
  if nil == conf then
    Log.Error("npc challenge conf is nil, battleId = ", self.battleId)
  end
  return conf
end

function UMG_Leve_battleArray_C:GetCurrentBossChallengeConf()
  local conf = _G.DataConfigManager:GetBossChallengeConf(self.battleId)
  if nil == conf then
    Log.Error("boss challenge conf is nil, battleId = ", self.battleId)
  end
  return conf
end

function UMG_Leve_battleArray_C:GetSilhouetteLastGameTarget()
  local targetInfos = {}
  if self.silhouetteLevelInfoDic[self.battleId] and self.silhouetteLevelInfoDic[self.battleId].targets then
    targetInfos = self.silhouetteLevelInfoDic[self.battleId].targets
  else
    if _G.GlobalConfig.DebugOpenUI then
      return {}
    end
    if self:GetCurrentNpcChallengeConf().target ~= nil then
      local targets = self:GetCurrentNpcChallengeConf().target
      for i = 1, targets do
        local targetId = targets[i]
        local targetInfo = {}
        targetInfo.target_id = targetId
        targetInfo.is_finish = false
        table.insert(targetInfos, targetInfo)
      end
    end
  end
  return targetInfos
end

function UMG_Leve_battleArray_C:GetBossLastGameTarget()
  local targetInfos = {}
  if self.bossLevelInfoDic[self.battleId] and self.bossLevelInfoDic[self.battleId].targets then
    targetInfos = self.bossLevelInfoDic[self.battleId].targets
  else
    if _G.GlobalConfig.DebugOpenUI then
      return {}
    end
    local targets = self:GetCurrentBossChallengeConf().target
    for i = 1, targets do
      local targetId = targets[i]
      local targetInfo = {}
      targetInfo.target_id = targetId
      targetInfo.is_finish = false
      table.insert(targetInfos, targetInfo)
    end
  end
  return targetInfos
end

function UMG_Leve_battleArray_C:GetPetAttrList(petbaseId)
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

function UMG_Leve_battleArray_C:GetBattleTeamList(battleId)
  local battleConf = _G.DataConfigManager:GetBattleConf(battleId)
  local teamList = {}
  if battleConf then
    local team = battleConf.npc_battle_list[1]
    if team then
      for i = 1, 6 do
        local monsterId = team[string.format("pos%d_1st", i)][1]
        local monsterConf = _G.DataConfigManager:GetMonsterConf(monsterId)
        if monsterConf then
          local info = {}
          info.base_conf_id = monsterConf.base_id
          info.level = monsterConf.level
          info.isLevelTeam = true
          table.insert(teamList, info)
        end
      end
    end
  end
  return teamList
end

function UMG_Leve_battleArray_C:OnDeactive()
end

function UMG_Leve_battleArray_C:OnChageSelectTab(index)
  self.curTabIndex = index
  if 1 == index then
    self.MyTeam:UnSelectTeam()
    if self.curPanelType == LevelSelectionEnum.BattlePanel.Silhouette then
      self:OnConfirmSelected(self.module.data.curNpcTeamData)
    else
      self:OnConfirmSelected(self.module.data.curBossTeamData)
    end
    self:OnEnableTeamButton(false)
  else
    self.MyTeam:SelectTeam()
    self.MyTeam:OnLeaveStorehouseSaved()
    self:OnEnableTeamButton(true)
  end
end

function UMG_Leve_battleArray_C:OnAddEventListener()
  self:AddButtonListener(self.ParticularsBtn.btnLevelUp, self.OnClickParticularsBtn)
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnClickCloseBtn)
  self:AddButtonListener(self.Reminder.btnLevelUp, self.OnClickReminder)
  self:AddButtonListener(self.Button_82, self.OnClickCloseBtn)
  self:AddButtonListener(self.GlobalShutdown, self.ResetDescText)
  self.NRCTextDes.OnRichTextClick:Add(self, self.OnDescTextClicked)
  self:RegisterEvent(self, LevelSelectionModuleEvent.OnOpenBattleTeamView, self.OnOpenBattleTeamView)
  self:RegisterEvent(self, LevelSelectionModuleEvent.OnConfirmSelected, self.OnConfirmSelected)
  self:RegisterEvent(self, LevelSelectionModuleEvent.OnSaveBattleTeamSucceed, self.OnSaveBattleTeamSucceed)
  self:RegisterEvent(self, LevelSelectionModuleEvent.OnApplicationBattleTeamSucceed, self.OnApplicationBattleTeamSucceed)
  self:RegisterEvent(self, LevelSelectionModuleEvent.OnChangeBattleTab, self.OnChageSelectTab)
  self:RegisterEvent(self, LevelSelectionModuleEvent.OnChangeMainTeamSelectPet, self.OnChangeSelectPet)
  self:RegisterEvent(self, LevelSelectionModuleEvent.OnUpdateTeamBloodMagic, self.OnUpdateTeamBloodMagic)
  self:RegisterEvent(self, LevelSelectionModuleEvent.OnReplaceRuleSucceed, self.OnReplaceRuleSucceed)
  self:RegisterEvent(self, LevelSelectionModuleEvent.OnTriggerModuleMove, self.OnTriggerModuleMove)
  self:RegisterEvent(self, LevelSelectionModuleEvent.LeaderTraitCloseUpdate, self.OnLeaderTraitCloseUpdate)
  self:RegisterEvent(self, LevelSelectionModuleEvent.OnOpenTeamCompiler, self.OnOpenTeamCompiler)
  self:RegisterEvent(self, LevelSelectionModuleEvent.OnModuleLoadFinish, self.OnModuleLoadFinish)
  self:RegisterEvent(self, LevelSelectionModuleEvent.UpdateChallengeImage, self.OnUpdateChallengeImage)
  _G.NRCEventCenter:RegisterEvent("UMG_Leve_battleArray_C", self, PetUIModuleEvent.PetTeamManagementSelChanged, self.OnPetTeamManagementSelChanged)
  _G.NRCEventCenter:RegisterEvent("UMG_Leve_battleArray_C", self, LevelSelectionModuleEvent.OnIsHideArrayRight, self.IsHideRight)
end

function UMG_Leve_battleArray_C:OnConstruct()
  self:SetChildViews(self.MyTeam, self.UMG_Leve_World3D)
  self.UmgLoaders = {
    self.LevelBgXue1,
    self.LevelBgXue2,
    self.LevelBgCastle1,
    self.LevelBgCastle2
  }
  self.curTabIndex = nil
  self.CanvasPanel_0:SetRenderOpacity(0)
  self.CanvasPanel_0:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self:OnAddEventListener()
end

function UMG_Leve_battleArray_C:OnDestruct()
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  end
  _G.NRCEventCenter:UnRegisterEvent(self, LevelSelectionModuleEvent.OnIsHideArrayRight, self.IsHideRight)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.PetTeamManagementSelChanged, self.OnPetTeamManagementSelChanged)
end

function UMG_Leve_battleArray_C:OnPetTeamManagementSelChanged(selectedTeamIdx)
  if selectedTeamIdx then
    self:OnUpdateMyTeamInfo()
  end
end

function UMG_Leve_battleArray_C:OnAnimationFinished(anim)
  if anim == self.Close and self.isClose then
    self:DoClose()
    if self.curPanelType == LevelSelectionEnum.BattlePanel.Boss then
      _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.CloseLeveSelect)
    end
  end
end

function UMG_Leve_battleArray_C:OnSwitcherNRCSwitcher_145(SwitcherIndex)
  self.NRCSwitcher_145:SetActiveWidgetIndex(SwitcherIndex)
end

function UMG_Leve_battleArray_C:OnSwitcherNRCSwitcher_0(SwitcherIndex)
  self.NRCSwitcher_0:SetActiveWidgetIndex(SwitcherIndex)
end

function UMG_Leve_battleArray_C:OnClickParticularsBtn()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_Leve_BattleSilhouette_C:OnClickCharacterButton")
  local Ctx = _G.DialogContext()
  Ctx:SetTitle(LuaText.challenge_title_1)
  Ctx:SetContent(LuaText.challenge_text_7)
  Ctx:SetClickAnywhereClose(true)
  Ctx:SetMode(_G.DialogContext.Mode.OK)
  local rightText = LuaText.teambattlemodule_8
  Ctx:SetButtonText(rightText, "")
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenLongDialog, Ctx)
end

function UMG_Leve_battleArray_C:OnClickCloseBtn()
  _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdCloseBattleArrayPanel)
end

function UMG_Leve_battleArray_C:OnDescTextClicked(id)
  local descNote = _G.DataConfigManager:GetDescNoteConf(tonumber(id))
  self.GlobalShutdown:SetVisibility(UE4.ESlateVisibility.Visible)
  local descText = string.format("\227\128\144%s\227\128\145\n%s", descNote.note, descNote.desc)
end

function UMG_Leve_battleArray_C:ResetDescText()
  self.GlobalShutdown:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Leve_battleArray_C:OnClickReminder()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_Leve_BattleSilhouette_C:OnClickCharacterButton")
  if self.curPanelType == LevelSelectionEnum.BattlePanel.Silhouette then
    if self.module.data.curNpcTeamData == nil or nil == self.module.data.curNpcTeamData.teams or #self.module.data.curNpcTeamData.teams < 6 then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\231\178\190\231\129\181\228\184\141\232\182\179\230\151\160\230\179\149\229\135\186\230\136\152")
      return
    end
  elseif nil == self.module.data.curBossTeamData or nil == self.module.data.curBossTeamData.teams or #self.module.data.curBossTeamData.teams < 6 then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\231\178\190\231\129\181\228\184\141\232\182\179\230\151\160\230\179\149\229\135\186\230\136\152")
    return
  end
  if nil ~= self.MyTeam.curTeamInfo and nil ~= self.MyTeam.curTeamInfo.teams then
    for i, team in pairs(self.MyTeam.curTeamInfo.teams) do
      if 0 == team.pet_gid then
        _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\231\178\190\231\129\181\228\184\141\232\182\179\230\151\160\230\179\149\229\135\186\230\136\152")
        return
      end
    end
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\231\178\190\231\129\181\228\184\141\232\182\179\230\151\160\230\179\149\229\135\186\230\136\152")
    return
  end
  if self:IsShowTips() == false then
    self:GoToBattle()
  end
end

function UMG_Leve_battleArray_C:IsShowTips()
  local isNotEquipMagic = self.MyTeam.curTeamInfo.magicGid == nil or 0 == self.MyTeam.curTeamInfo.magicGid
  local isNotEquipRule = nil == self.MyTeam.curSelectRuleId or 0 == self.MyTeam.curSelectRuleId
  local isShowTips = false
  local str = ""
  if self.curPanelType == LevelSelectionEnum.BattlePanel.Silhouette then
    if isNotEquipMagic then
      isShowTips = true
      str = LuaText.challenge_text_14
    end
  elseif isNotEquipMagic and isNotEquipRule then
    isShowTips = true
    str = LuaText.challenge_text_15
  elseif isNotEquipRule then
    isShowTips = true
    str = LuaText.challenge_text_13
  elseif isNotEquipMagic then
    isShowTips = true
    str = LuaText.challenge_text_14
  end
  if isShowTips then
    local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
    local title = LuaText.player_unstuck_confirm_title
    local des = str
    local leftText = LuaText.instancemodule_2
    local rightText = LuaText.instancemodule_1
    local Context = DialogContext()
    Context:SetTitle(title):SetContent(des):SetMode(DialogContext.Mode.OK_CANCEL):SetCallback(self, self.TipsSucceed):SetClickAnywhereClose(true):SetCloseOnCancel(true):SetButtonText(rightText, leftText)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Context)
  end
  return isShowTips
end

function UMG_Leve_battleArray_C:TipsSucceed(isOk)
  if isOk then
    self:GoToBattle()
  end
end

function UMG_Leve_battleArray_C:GoToBattle()
  if self.curPanelType == LevelSelectionEnum.BattlePanel.Silhouette then
    _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdCloseBattleTeamPanel)
    _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdOpenLevelFirstPublishPanel, self.battleId, self.curActiveId)
  else
    local conf = self:GetCurrentBossChallengeConf()
    _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdStartBattle, self.curActiveId, conf.id)
    _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdCloseBattleArrayPanel)
    _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.OnCmdCloseBattleSilhouettePanel)
    _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.CloseLeveSelect)
  end
  self:PlayAnimation(self.Close)
  self.pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Leve_battleArray_C:OnSwitcherSwitcher_Title(SwitcherIndex)
  self.Switcher_Title:SetActiveWidgetIndex(SwitcherIndex)
end

function UMG_Leve_battleArray_C:OnSwitcherNRCSwitcher_54(SwitcherIndex)
  self.NRCSwitcher_54:SetActiveWidgetIndex(SwitcherIndex)
end

function UMG_Leve_battleArray_C:IsHideRight(isHide)
  self.CanvasPanel_37:SetVisibility(isHide and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  self.MyTeam:SetVisibility(isHide and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
end

return UMG_Leve_battleArray_C
