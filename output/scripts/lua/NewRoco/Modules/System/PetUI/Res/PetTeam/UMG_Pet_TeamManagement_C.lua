local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PVPRankedMatchModuleEvent = require("NewRoco.Modules.System.PVPQualifier.PVPRankedMatchModuleEvent")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local UMG_Pet_TeamManagement_C = _G.NRCPanelBase:Extend("UMG_Pet_TeamManagement_C")

function UMG_Pet_TeamManagement_C:OnActive(teamType, index, bPVP)
  self.bPVP = bPVP
  self.curTeamType = teamType
  self:SetCommonTitle()
  self:RefreshCommonTitle(teamType)
  if bPVP then
    self:RefreshUIPVP(index)
  else
    self:RefreshUI(index)
  end
end

function UMG_Pet_TeamManagement_C:OnDeactive()
end

function UMG_Pet_TeamManagement_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseBtnClick)
  self:AddButtonListener(self.BlankClose, self.OnCloseBtnClick)
  self:RegisterEvent(self, PetUIModuleEvent.PetTeamManagementModifyTeamName, self.RefreshCurTeamUI)
  _G.NRCEventCenter:RegisterEvent("UMG_Pet_TeamManagement_C", self, PetUIModuleEvent.PetTeamEquipPetMagicRsp, self.RefreshCurTeamUI)
  self:RegisterEvent(self, PetUIModuleEvent.PetEquipSkillFinished, self.OnPetEquipSkillFinished)
  _G.NRCEventCenter:RegisterEvent("UMG_Pet_TeamManagement_C", self, PVPRankedMatchModuleEvent.SetPvpInfoQueryData, self.OnSetPvpInfoQueryData)
end

function UMG_Pet_TeamManagement_C:OnModifyMainTeamIndex()
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetMainTeams, self.selectedTeamIdx, self.curTeamType)
end

function UMG_Pet_TeamManagement_C:OnOpenFastTeamModifyBtnClick()
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetTeamReplacePanel, self.curTeamType, self.selectedTeamIdx, nil, nil, PetUIModuleEnum.ModifyPetMode.QuickEdit)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ClosePetTeamManagementPanel)
end

function UMG_Pet_TeamManagement_C:OnRemoveEventListener()
  self:RemoveButtonListener(self.CloseBtn.btnClose, self.OnCloseBtnClick)
  self:RemoveButtonListener(self.BlankClose, self.OnCloseBtnClick)
  self:UnRegisterEvent(self, PetUIModuleEvent.PetTeamManagementModifyTeamName, self.RefreshCurTeamUI)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.PetTeamEquipPetMagicRsp, self.RefreshCurTeamUI)
  self:UnRegisterEvent(self, PetUIModuleEvent.PetEquipSkillFinished, self.OnPetEquipSkillFinished)
  _G.NRCEventCenter:UnRegisterEvent(self, PVPRankedMatchModuleEvent.SetPvpInfoQueryData, self.OnSetPvpInfoQueryData)
end

function UMG_Pet_TeamManagement_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_Pet_TeamManagement_C:RefreshCommonTitle(teamType)
  local allBattleTypeConf = _G.DataConfigManager:GetAllByName("BATTLE_TYPE_CONF")
  for i, v in pairs(allBattleTypeConf) do
    if v.player_team_type == teamType then
      self.Title1:Set_MainTitle(v.name)
      break
    end
  end
end

function UMG_Pet_TeamManagement_C:OnConstruct()
  self:InitUI()
  self:OnAddEventListener()
end

function UMG_Pet_TeamManagement_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_Pet_TeamManagement_C:OnAnimationFinished(anim)
end

function UMG_Pet_TeamManagement_C:SetParent(parent)
  self.Parent = parent
end

function UMG_Pet_TeamManagement_C:InitUI()
end

function UMG_Pet_TeamManagement_C:OnSetPvpInfoQueryData()
  if self.curTeamType and self.curTeamType == Enum.PlayerTeamType.PTT_PVP_BATTLE_4 then
    self:RefreshUI(self.curTeamIdx)
  end
end

function UMG_Pet_TeamManagement_C:OnPetEquipSkillFinished()
  self:UpdateLists()
end

function UMG_Pet_TeamManagement_C:UpdateLists()
  self.List:InitGridView(self.listData)
end

function UMG_Pet_TeamManagement_C:RefreshUI(curTeamIdx)
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  self:PlayAnimation(self.In)
  local listData = {}
  local teamInfo = self.module:GetPetTeamUITeamInfo(self.curTeamType)
  if teamInfo then
    local petTeams = teamInfo.teams
    local main_team_idx = teamInfo.main_team_idx
    local isMainTeam = false
    for i, team in ipairs(petTeams) do
      isMainTeam = i == main_team_idx + 1
      table.insert(listData, {
        isMainTeam = isMainTeam,
        team = team,
        idx = i - 1,
        parentView = self,
        teamType = self.curTeamType
      })
    end
  end
  self.listData = listData
  self.List:InitGridView(listData)
  self.List:SelectItemByIndex(curTeamIdx)
  self.selectedTeamIdx = curTeamIdx
  self.curTeamIdx = curTeamIdx
  local str = _G.DataConfigManager:GetBattleGlobalConfig("pvp_rank_character11").str
end

function UMG_Pet_TeamManagement_C:RefreshUIPVP(curTeamIdx)
  self.module = _G.NRCModuleManager:GetModule("PetUIModule")
  self.module.data.OpenTeamType = _G.ProtoEnum.PlayerTeamType.PTT_PVP_BATTLE_1
  self:RefreshUI(curTeamIdx)
end

function UMG_Pet_TeamManagement_C:RefreshCurTeamUI()
  local listData = {}
  local teamInfo = self.module:GetPetTeamUITeamInfo(self.curTeamType)
  if teamInfo then
    local petTeams = teamInfo.teams
    local main_team_idx = teamInfo.main_team_idx
    local isMainTeam = false
    for i, team in ipairs(petTeams) do
      isMainTeam = i == main_team_idx + 1
      table.insert(listData, {
        isMainTeam = isMainTeam,
        team = team,
        idx = i - 1,
        parentView = self,
        teamType = self.curTeamType
      })
    end
  end
  local totalCount = self.List:GetItemCount()
  for i = 1, #listData do
    if i <= totalCount then
      local item = self.List:GetItemByIndex(i - 1)
      item:OnItemNameUpdate(listData[i])
    end
  end
end

function UMG_Pet_TeamManagement_C:OnCloseBtnClick()
  if self:IsAnimationPlaying(self.Out) then
    return
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_Pet_TeamManagement_C:OnCloseBtnClick")
  if self.module.data.OpenTeamType == _G.ProtoEnum.PlayerTeamType.PTT_PVP_BATTLE_1 then
    _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.ChangePVPMatchTeam, self.curTeamIdx)
  end
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.PetTeamSetBtnCloseState, PetUIModuleEnum.PetTeamShowType.Normal)
  self:PlayAnimation(self.Out)
end

function UMG_Pet_TeamManagement_C:OnBackBtnClick()
  if self:IsAnimationPlaying(self.Out) then
    return
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1007, "UMG_Pet_TeamManagement_C:OnBackBtnClick")
  self:PlayAnimation(self.Out)
end

function UMG_Pet_TeamManagement_C:OnItemSelected(idx)
  self.selectedTeamIdx = idx
  self:OnModifyMainTeamIndex()
  if self.isTrueSelect then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1285, "UMG_Pet_TeamManagement_List_C:OnItemSelected")
  end
  self.isTrueSelect = true
end

function UMG_Pet_TeamManagement_C:OnAnimationFinished(anim)
  if anim == self.Out then
    self:DoClose()
  elseif anim == self.In then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
  end
end

return UMG_Pet_TeamManagement_C
