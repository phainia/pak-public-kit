local UMG_PetTeam_Main_C = _G.NRCPanelBase:Extend("UMG_PetTeam_Main_C")
local PVPRankedMatchModuleEvent = require("NewRoco.Modules.System.PVPQualifier.PVPRankedMatchModuleEvent")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local BattleUIModuleCmd = reload("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")

function UMG_PetTeam_Main_C:OnActive(TeamType, Caller, CallBack, openType)
  self.curTeamType = TeamType
  self.Caller = Caller
  self.CallBack = CallBack
  self.openType = openType
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.PetTeam:SetParent(self)
  self:RefreshUI()
  if openType == PetUIModuleEnum.OpenTeamReplaceType.PvpQualifier then
    self.PetTeam:SetBtnCloseState(PetUIModuleEnum.PetTeamShowType.HidePetsUis, true)
  else
    self.PetTeam:SetBtnCloseState(PetUIModuleEnum.PetTeamShowType.Normal, true)
  end
  self:SetProgressPercent(0.2)
end

function UMG_PetTeam_Main_C:OnDeactive()
  _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.OnCmdTryReshowUmgPVPQualifier)
end

function UMG_PetTeam_Main_C:OnConstruct()
  UE4.UNRCQualityLibrary.SwitchNRCGameShadowMode(2)
  self:SetChildViews(self.PetTeam)
  self:OnAddEventListener()
  self.isFirstRun = true
  self.MainPanel:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.ProgressPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:SetProgressPercent(0.1)
end

function UMG_PetTeam_Main_C:OnDestruct()
  UE4.UNRCQualityLibrary.SwitchNRCGameShadowMode(0)
  UE4Helper.SetEnableWorldRendering(nil, nil, "UMG_PetTeam_Main")
  self:OnRemoveEventListener()
  if self.Caller and self.CallBack then
    self.CallBack(self.Caller)
  end
end

function UMG_PetTeam_Main_C:OnClickChangeTeam(isRight)
  local teamId = self.curTeamIdx
  if isRight then
    teamId = (teamId + 1) % 8
  else
    teamId = (teamId + 7) % 8
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_PetTeam_Main_C:OnClickChangeTeam")
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetMainTeams, teamId, self.curTeamType)
end

function UMG_PetTeam_Main_C:SetProgressPercent(percent)
  if percent >= 1 then
    self:PlayOpenAnimation()
  end
end

function UMG_PetTeam_Main_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn1, self.OnCloseBtnClick)
  _G.NRCEventCenter:RegisterEvent("UMG_PetTeam_Main_C", self, PetUIModuleEvent.PetTeamManagementSelChanged, self.OnPetTeamManagementSelChanged)
  self:RegisterEvent(self, PetUIModuleEvent.PetTeamManagementModifyTeamName, self.OnPetTeamManagementModifyTeamName)
  _G.NRCEventCenter:RegisterEvent("UMG_PVPQualifier_C", self, PetUIModuleEvent.PetTeamEquipPetMagicRsp, self.OnPetTeamEquipPetMagicRsp)
  _G.NRCEventCenter:RegisterEvent("UMG_PetTeam_Main_C", self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnected)
  _G.NRCEventCenter:RegisterEvent("UMG_PetTeam_Main_C", self, _G.NRCGlobalEvent.ON_CONNECTED, self.OnConnected)
  _G.NRCEventCenter:RegisterEvent("UMG_PetTeam_Main_C", self, PVPRankedMatchModuleEvent.SetPvpInfoQueryData, self.OnSetPvpInfoQueryData)
end

function UMG_PetTeam_Main_C:OnRemoveEventListener()
  self:RemoveButtonListener(self.CloseBtn1, self.OnCloseBtnClick)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.PetTeamManagementSelChanged, self.OnPetTeamManagementSelChanged)
  self:UnRegisterEvent(self, PetUIModuleEvent.PetTeamManagementModifyTeamName, self.OnPetTeamManagementModifyTeamName)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.PetTeamEquipPetMagicRsp, self.OnPetTeamEquipPetMagicRsp)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnected)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_CONNECTED, self.OnConnected)
  _G.NRCEventCenter:UnRegisterEvent(self, PVPRankedMatchModuleEvent.SetPvpInfoQueryData, self.OnSetPvpInfoQueryData)
end

function UMG_PetTeam_Main_C:OnPcClose()
  self:OnCloseBtnClick()
end

function UMG_PetTeam_Main_C:OnConnected()
  UE4Helper.SetEnableWorldRendering(nil, nil, "UMG_PetTeam_Main")
  self:DoClose()
end

function UMG_PetTeam_Main_C:OnDisconnected()
  UE4Helper.SetEnableWorldRendering(nil, nil, "UMG_PetTeam_Main")
  self:DoClose()
end

function UMG_PetTeam_Main_C:OnPetTeamEquipPetMagicRsp()
  self:RefreshUIFromCmd()
end

function UMG_PetTeam_Main_C:OnSetPvpInfoQueryData(IsResetTrialPetData)
  if self.curTeamType and self.curTeamType == Enum.PlayerTeamType.PTT_PVP_BATTLE_4 then
    self:RefreshUI(self.curTeamIdx, true, IsResetTrialPetData)
  end
end

function UMG_PetTeam_Main_C:OnPetTeamManagementModifyTeamName()
  local teamInfo = self.module:GetPetTeamUITeamInfo(self.curTeamType)
  self.PetTeamInfo = teamInfo
  if not teamInfo then
    Log.Error("UMG_PetTeam_Main_C:InitUI: PlayerTeamInfo is empty!")
    return
  end
  local curTeamIdx = teamInfo.main_team_idx
  self.curTeamIdx = curTeamIdx
  if teamInfo.teams ~= nil and nil ~= curTeamIdx then
    teamInfo = teamInfo.teams[curTeamIdx + 1]
  end
  self.PetTeam:SetTeamNameText(curTeamIdx, teamInfo, self.curTeamType)
end

function UMG_PetTeam_Main_C:PlayOpenAnimation()
  self.MainPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.PetTeam:PlayShowAnim()
end

function UMG_PetTeam_Main_C:OnPetTeamSetBtnCloseStateFromCmd(State)
  self.PetTeam:SetBtnCloseState(State)
end

function UMG_PetTeam_Main_C:RefreshUIFromCmd()
  self:RefreshUI(self.curTeamIdx)
end

function UMG_PetTeam_Main_C:RefreshUI(selTeamIdx, forceUpdate, IsResetTrialPetData)
  local teamInfo = self.module:GetPetTeamUITeamInfo(self.curTeamType)
  self.PetTeamInfo = teamInfo
  if not teamInfo then
    Log.Error("UMG_PetTeam_Main_C:InitUI: PlayerTeamInfo is empty!")
    return
  end
  self.isFirstRun = false
  local curTeamIdx = teamInfo.main_team_idx
  self.curTeamIdx = curTeamIdx
  if teamInfo.teams ~= nil and nil ~= curTeamIdx then
    teamInfo = teamInfo.teams[curTeamIdx + 1]
  end
  self.PetTeam:SetTeamData(curTeamIdx, teamInfo, self.curTeamType, forceUpdate, IsResetTrialPetData)
  self.CloseBtn1:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_PetTeam_Main_C:OpenTeamManagementUI()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1284, "UMG_PetTeam_Main_C:OpenTeamManagementUI")
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetTeamManagementPanel, self.curTeamType, self.curTeamIdx, false)
  self.PetTeam:SetBtnCloseState(PetUIModuleEnum.PetTeamShowType.HideUis)
  self.PetTeam:ShowRightBottom(false)
end

function UMG_PetTeam_Main_C:CloseTeamManagementUI(selTeamIdx)
end

function UMG_PetTeam_Main_C:OpenPetWarehouseUI(petGid, slotId)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1286, "UMG_PetTeam_Main_C:OpenPetWarehouseUI")
  self.curWarehoseMode = 0
  self.PetTeam:ShowRightBottom(false)
  self.PetTeam:MoveCameraToSlot(slotId)
  self.PetTeam:SetBtnCloseState(PetUIModuleEnum.PetTeamShowType.HidePetsUis)
end

function UMG_PetTeam_Main_C:PVPPetInfoOpenPetWarehouseUI()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1286, "UMG_PetTeam_Main_C:OpenPetWarehouseUI")
  self.curWarehoseMode = 0
  self.PetTeam:ShowRightBottom(false)
  self.PetTeam:MoveCameraToSlot(self.module.curSlotId)
  self.PetTeam:SetBtnCloseState(PetUIModuleEnum.PetTeamShowType.HidePetsUis)
end

function UMG_PetTeam_Main_C:ClosePetWarehouseUI()
  self.PetTeam:ShowRightBottom(true)
  if 0 == self.curWarehoseMode then
    self.PetTeam:MoveCameraToSlot(0)
  else
    self:SetPetTeamPanelHitTestVisible(true)
  end
  self.PetTeam:SetBtnCloseState(PetUIModuleEnum.PetTeamShowType.Normal)
end

function UMG_PetTeam_Main_C:OnWarehouseOutFinished()
end

function UMG_PetTeam_Main_C:SetPetTeamPanelHitTestVisible(bVisible)
  self.PetTeam:SetPanelHitTestVisible(bVisible)
end

function UMG_PetTeam_Main_C:OpenFastFormationUI()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1286, "UMG_PetTeam_Main_C:OpenFastFormationUI")
  self.curWarehoseMode = 1
  self.PetTeam:ShowRightBottom(false)
  self.PetTeam:SetBtnCloseState(PetUIModuleEnum.PetTeamShowType.HidePetsUis)
end

function UMG_PetTeam_Main_C:OnPetTeamManagementSelChanged(selectedTeamIdx)
  if selectedTeamIdx then
    self:RefreshUI(selectedTeamIdx)
  end
end

function UMG_PetTeam_Main_C:OnCloseBtnClick()
  local flag = _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.CheckIsAnyUmgIsOpening)
  if flag then
    return
  end
  if self.PetTeam:IsAnimationPlaying(self.PetTeam.Out) then
    return
  end
  if self.openType == PetUIModuleEnum.OpenTeamReplaceType.PvpQualifier then
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.ClosePetTeamReplacePanel)
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1008, "UMG_PetTeam_Main_C:OnCloseBtnClick")
  self:UIClose()
end

function UMG_PetTeam_Main_C:OnClose()
  UE4Helper.SetEnableWorldRendering(nil, nil, "UMG_PetTeam_Main")
end

function UMG_PetTeam_Main_C:UIClose()
  self:CancelDelay()
  self.PetTeam:SetAllNameTagVisState(false)
  self.PetTeam:BindToAnimationFinished(self.PetTeam.Out, {
    self,
    self.OnOutFinished
  })
  self.PetTeam:PlayAnimation(self.PetTeam.Out)
  UE4Helper.SetEnableWorldRendering(nil, nil, "UMG_PetTeam_Main")
end

function UMG_PetTeam_Main_C:OnOutFinished()
  self.module.IsPetMainOpenPvPTeam = false
  self:DoClose()
end

function UMG_PetTeam_Main_C:ChangeMainTeam()
  local petTeamInfo = self.PetTeamInfo
  if not petTeamInfo then
    return
  end
  local curTeamIdx = self.curTeamIdx
  if curTeamIdx then
    local gidList = petTeamInfo.teams[curTeamIdx + 1].pet_infos
    if gidList and #gidList > 0 then
      petTeamInfo.main_team_idx = curTeamIdx
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetMainTeams, curTeamIdx, self.module.data.OpenTeamType)
      if self.module.data.OpenTeamType ~= _G.ProtoEnum.PlayerTeamType.PTT_PVP_BATTLE_1 then
        local petListData = {}
        for _, v in ipairs(gidList) do
          local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(v.pet_gid)
          table.insert(petListData, petData)
        end
        local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
        _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(MainUIModuleEvent.UI_Refresh_MainPet, 1, petListData)
      else
        _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.ChangePVPMatchTeam, curTeamIdx)
      end
    end
  end
end

function UMG_PetTeam_Main_C:AsyncLoadSceneOver()
  UE4Helper.SetEnableWorldRendering(false, nil, "UMG_PetTeam_Main")
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.OnCmdHideUmgPVPQualifier)
end

return UMG_PetTeam_Main_C
