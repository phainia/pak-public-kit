local UMG_Level_FirstPublish_C = _G.NRCPanelBase:Extend("UMG_Level_FirstPublish_C")
local LevelSelectionModuleEvent = require("NewRoco.Modules.System.LevelSelection.LevelSelectionModuleEvent")

function UMG_Level_FirstPublish_C:OnActive(battleId, curActiveId)
  self.battleId = battleId
  self.curActiveId = curActiveId
  self:DispatchEvent(LevelSelectionModuleEvent.OnTriggerModuleMove, true)
  self:OnAddEventListener()
  self:SetCommonTitle()
  self:InitData()
  self:RefreshUI()
end

function UMG_Level_FirstPublish_C:OnDeactive()
  self:OnRemoveEventListener()
end

function UMG_Level_FirstPublish_C:OnAddEventListener()
  self:AddButtonListener(self.btnClose.btnClose, self.OnClickCloseBtn)
  self:AddButtonListener(self.ParticularsBtn.btnLevelUp, self.OnShowRuleTips)
  self:AddButtonListener(self.StartTheShow.btnLevelUp, self.OnClickBStartTheShow)
  _G.NRCEventCenter:RegisterEvent("UMG_Level_FirstPublish_C", self, LevelSelectionModuleEvent.SelectFirstPetEvent, self.OnSelectFirstPetEvent)
end

function UMG_Level_FirstPublish_C:OnRemoveEventListener()
  self:RemoveButtonListener(self.btnClose.btnClose, self.OnClickCloseBtn)
  self:RemoveButtonListener(self.ParticularsBtn.btnLevelUp, self.OnShowRuleTips)
  self:RemoveButtonListener(self.StartTheShow.btnLevelUp, self.OnClickBStartTheShow)
  _G.NRCEventCenter:UnRegisterEvent(self, LevelSelectionModuleEvent.SelectFirstPetEvent, self.OnSelectFirstPetEvent)
end

function UMG_Level_FirstPublish_C:OnPcClose()
  self:OnClickCloseBtn()
end

function UMG_Level_FirstPublish_C:OnSelectFirstPetEvent(petGid)
  self.curSelectPetId = petGid
end

function UMG_Level_FirstPublish_C:OnLogin()
end

function UMG_Level_FirstPublish_C:OnConstruct()
end

function UMG_Level_FirstPublish_C:OnDestruct()
end

function UMG_Level_FirstPublish_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title2:Set_MainTitle(self.titleConf.title)
  self.Title2:SetBg(self.titleConf.head_icon)
  self.Title2:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_Level_FirstPublish_C:OnAnimationFinished(anim)
  if self.Out == anim then
    _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.OnCmdOpenBattleSilhouettePanel, self.battleId)
    self:DispatchEvent(LevelSelectionModuleEvent.OnTriggerModuleMove, false)
    self:DoClose()
  end
end

function UMG_Level_FirstPublish_C:OnSwitcherSwitcher(SwitcherIndex)
  self.Switcher:SetActiveWidgetIndex(SwitcherIndex)
end

function UMG_Level_FirstPublish_C:OnClickBStartTheShow()
  BattleProfiler:CheckPoint(BattleProfilerCheckPoint.NPCChallenge)
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_Leve_BattleSilhouette_C:OnSelectCameraShotItemEvent")
  local conf = self:GetCurrentNpcChallengeConf()
  _G.NRCModuleManager:DoCmd(_G.LevelSelectionModuleCmd.OnCmdStartBattle, self.curActiveId, conf.id, conf.module_id, self.curSelectPetId)
  _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.CloseLeveBattleSilhouette)
  _G.NRCModuleManager:DoCmdAsync(nil, _G.BattleUIModuleCmd.OpenLoading)
  self:DoClose()
end

function UMG_Level_FirstPublish_C:OnShowRuleTips()
  local Ctx = _G.DialogContext()
  Ctx:SetTitle(LuaText.challenge_title_1)
  Ctx:SetContent(LuaText.challenge_text_7)
  Ctx:SetMode(_G.DialogContext.Mode.OK)
  Ctx:SetClickAnywhereClose(true)
  local rightText = LuaText.teambattlemodule_8
  Ctx:SetButtonText(rightText, "")
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenLongDialog, Ctx)
end

function UMG_Level_FirstPublish_C:OnClickCloseBtn()
  self:PlayAnimation(self.Out)
end

function UMG_Level_FirstPublish_C:InitData()
  self.teamInfos = self.module.data.curNpcTeamData
  self.mainTeamIdx = self.teamInfos.main_team_idx or 0
  self.teamInfosTeams = self.teamInfos.teams
  self.roleMagicGid = self.teamInfosTeams.role_magic_gid
end

function UMG_Level_FirstPublish_C:RefreshUI()
  self:PlayAnimation(self.In)
  self.PetList:InitGridView(self.teamInfosTeams)
  local conf = self:GetCurrentNpcChallengeConf()
  local bagConf = _G.DataConfigManager:GetBagItemConf(conf.player_magic_item)
  local battleTeamListInfo = self:GetBattleTeamList(conf.battle)
  if conf.name then
    self.Title:SetText(conf.name)
  else
    local battleAppearanceInfo = self.module.data.cacheSalonDataDic[conf.avatar_param]
    self.Title:SetText(battleAppearanceInfo.name)
  end
  if conf.text then
    self.ContentTip:SetText(LuaText[conf.text])
  else
    local battleAppearanceInfo = self.module.data.cacheSalonDataDic[conf.avatar_param]
    self.ContentTip:SetText(battleAppearanceInfo.sign)
  end
  self.PetList_1:InitGridView(battleTeamListInfo)
  self.Icon:SetPath(bagConf.icon)
  if #self.teamInfosTeams > 0 then
    self.PetList:SelectItemByIndex(0)
  end
end

function UMG_Level_FirstPublish_C:GetCurrentNpcChallengeConf()
  return _G.DataConfigManager:GetNpcChallengeConf(self.battleId)
end

function UMG_Level_FirstPublish_C:GetBattleTeamList(battleId)
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

return UMG_Level_FirstPublish_C
