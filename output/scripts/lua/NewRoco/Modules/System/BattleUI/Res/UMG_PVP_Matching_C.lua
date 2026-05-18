local PetUtils = require("NewRoco.Utils.PetUtils")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local UMG_PVP_Matching_C = _G.NRCPanelBase:Extend("UMG_PVP_Matching_C")
UMG_PVP_Matching_C.MatchType = {
  ONE_PVP = 1,
  TWO_PVP = 2,
  PRACTICE_PVP = 3
}

function UMG_PVP_Matching_C:OnConstruct()
  if GlobalConfig.NewPVPStyle == false then
    self.State:SetActiveWidgetIndex(0)
  else
    self.State:SetActiveWidgetIndex(1)
  end
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseButtonClicked)
  self:AddButtonListener(self.PVP_Single.Btn, self.OnOnePVPClick)
  self:AddButtonListener(self.PVP_Single1.Btn, self.OnTwoPVPClick)
  self:AddButtonListener(self.UMG_Btn2.btnLevelUp, self.OnClickCancel)
  self:AddButtonListener(self.Btn_Lift.btnLevelUp, self.OnBtnTeamClick)
  self:AddButtonListener(self.Btn_Matching.btnLevelUp, self.OpenWarningTips)
  self:AddButtonListener(self.CloseTipBtn, self.OnCloseTipBtnClicked)
  self:AddButtonListener(self.Btn_SkillAdjustment.btnLevelUp, self.OnSkillChangeBtnClicked)
  self:AddButtonListener(self.Btn_Global, self.OnBtnGlobalClicked)
  _G.ZoneServer:AddProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_SCENE_MATCH_NOTIFY, self.StartMatch)
  self.Btn_Lift:SetBtnText(LuaText.umg_pvp_matching_1)
  self.Btn_Lift:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_duiwupeizhi_png.img_duiwupeizhi_png'")
  self.Btn_SkillAdjustment:SetBtnText(LuaText.umg_pvp_matching_2)
  self.Btn_SkillAdjustment:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_jinengtiaozheng_png.img_jinengtiaozheng_png'")
  self.ShowPVPChooseTeam = false
  self.IsFirstOpenPanel = true
  self.petListData = {}
  self.curSelectMatchType = UMG_PVP_Matching_C.MatchType.ONE_PVP
  self:ShowPVPChooseTeamPanel(false)
  self.Battle_ChangePetConfirm.CloseBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_PVP_Matching_C:OnDestruct()
  self:RemoveAllButtonListener()
  self:CancelDelay()
  _G.ZoneServer:RemoveProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_SCENE_MATCH_NOTIFY, self.StartMatch)
end

function UMG_PVP_Matching_C:OnActive(matchNum, IsPetTeamBack)
  self.matchTime = 0
  self.dTime = 0
  self.isClick = false
  self.matchState = 0
  self.isClose = false
  self.isSingle = false
  self.SkillPetGid = 0
  self.bShowTips = false
  if _G.DataModelMgr.PlayerDataModel:GetPlayerPvPPetTeamInfo() then
    self.curTeamIndex = _G.DataModelMgr.PlayerDataModel:GetPlayerPvPPetTeamInfo().main_team_idx or 0
  else
    self.curTeamIndex = 0
  end
  self.UMG_Common_BIconPar:Open()
  self.PVP_Single.Text:SetText(LuaText.umg_pvp_matching_3)
  self.PVP_Single1.Text:SetText(LuaText.umg_pvp_matching_4)
  self.UMG_Btn2.Title_1:SetText(LuaText.umg_pvp_matching_5)
  self.UMG_Btn2.Title_2:SetText(LuaText.umg_pvp_matching_5)
  self.InTheMatch:SetText(LuaText.umg_pvp_matching_6)
  self.TimeTitle:SetText(self:TransformTime(0))
  if IsPetTeamBack then
    self.IsFirstOpenPanel = false
  end
  self:SetPanelInfo()
  if IsPetTeamBack then
  else
    self:StopAllAnimations()
    _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
    self:PlayAnimation(self.Open1)
    self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  end
  if matchNum then
    self:ShowMatch(matchNum)
  else
    self.MatchCanvas:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  self:DelaySeconds(0.5, function()
    UE4Helper.SetEnableWorldRendering(false)
  end)
end

function UMG_PVP_Matching_C:IsMatching()
  return 1 == self.matchState or 2 == self.matchState
end

function UMG_PVP_Matching_C:IsMatchSucess()
  return 3 == self.matchState
end

function UMG_PVP_Matching_C:ShowMatch(matchNum)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1291, "UMG_PVP_Matching_C:ShowMatch")
  self.MatchCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.UMG_Btn2.Title_1:SetText(LuaText.umg_pvp_matching_5)
  self.UMG_Btn2.Title_2:SetText(LuaText.umg_pvp_matching_5)
  self.InTheMatch:SetText(LuaText.umg_pvp_matching_6)
  self.TimeTitle:SetText(self:TransformTime(0))
  self.matchState = math.min(matchNum, 2)
  self.matchTime = 0
  self.dTime = 0
  self.startServerTime = _G.ZoneServer:GetServerTime() / 1000
  if 1 == self.matchState then
    self.PVP_Single:StopAllAnimations()
    self.PVP_Single:PlayAnimation(self.PVP_Single.Press)
  else
    self.PVP_Single1:StopAllAnimations()
    self.PVP_Single1:PlayAnimation(self.PVP_Single1.Press)
  end
end

function UMG_PVP_Matching_C:ShowPVPChooseTeamPanel(bShow)
  if bShow then
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetTeamManagementPanel, self.curTeamIndex, true)
  else
  end
end

function UMG_PVP_Matching_C:OpenWarningTips()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1011, "UMG_PVP_Matching_C:OpenWarningTips")
  local tips = ""
  local leftBtn = ""
  local rightBtn = ""
  local Type = -1
  local teamInfo = {}
  if _G.DataModelMgr.PlayerDataModel:GetPlayerPvPPetTeamInfo() then
    teamInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPvPPetTeamInfo().teams[self.curTeamIndex + 1]
  end
  local IsCanPVP = _G.NRCModeManager:DoCmd(TipsModuleCmd.GetIsCanPVP)
  if self.curSelectMatchType == UMG_PVP_Matching_C.MatchType.ONE_PVP and not IsCanPVP then
    self:OpenAntiAddiction()
    return
  end
  if teamInfo.pet_infos == nil or 0 == #teamInfo.pet_infos then
    if self.curSelectMatchType ~= UMG_PVP_Matching_C.MatchType.PRACTICE_PVP then
    else
    end
    Type = 0
    tips = LuaText.umg_pvp_matching_7
    leftBtn = LuaText.umg_pvp_matching_5
    rightBtn = LuaText.umg_pvp_matching_8
    local dataList = {
      tipText = tips,
      leftBtnText = leftBtn,
      rightBtnText = rightBtn,
      PVPShowType = Type
    }
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Tips_ShowCommonWarning, dataList)
  elseif #teamInfo.pet_infos > 0 and #teamInfo.pet_infos < 6 then
    if self.curSelectMatchType ~= UMG_PVP_Matching_C.MatchType.PRACTICE_PVP then
      Type = 1
      tips = LuaText.umg_pvp_matching_9
      leftBtn = LuaText.umg_pvp_matching_5
      rightBtn = LuaText.umg_pvp_matching_10
      local dataList = {
        tipText = tips,
        leftBtnText = leftBtn,
        rightBtnText = rightBtn,
        PVPShowType = Type
      }
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Tips_ShowCommonWarning, dataList)
    else
      self:OnBtnMatchingClick(true)
    end
  else
    self:OnBtnMatchingClick(true)
  end
end

function UMG_PVP_Matching_C:ShowRightTips(bShow, petgid, bNotPlaySound)
  self.SkillPetGid = petgid
  if bShow then
    if not bNotPlaySound then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1083, "UMG_PVP_Matching_C:ShowRightTips Show")
    end
    self.bShowTips = true
    self.Popup:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Btn_Global:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Battle_ChangePetConfirm:SetPetInfo(nil, petgid)
    self.Battle_ChangePetConfirm:ShowInPetWarehouse()
    self.Battle_ChangePetConfirm:SetVisibility(UE4.ESlateVisibility.Visible)
    self.CloseBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    if not bNotPlaySound then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1076, "UMG_PVP_Matching_C:ShowRightTips UnShow")
    end
    self.bShowTips = false
    self.Popup:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn_Global:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Battle_ChangePetConfirm:Hide(true, false)
    self.CloseBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_PVP_Matching_C:OnCloseTipBtnClicked()
  self:ShowRightTips(false)
end

function UMG_PVP_Matching_C:OnSkillChangeBtnClicked()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1014, "UMG_PVP_Matching_C:OnSkillChangeBtnClicked")
  local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.SkillPetGid)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetOpenPanelPetData, petData, 2, true)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1014, "UMG_LobbyMain_C:OnBtnPetHeadClick")
  NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPanelPetMain, {
    subPanelIndex = 4,
    callback = self.OnUMGLoadFinished
  })
  self:ShowRightTips(false)
end

function UMG_PVP_Matching_C:OnBtnGlobalClicked()
  self.bShowTips = not self.bShowTips
  self:ShowRightTips(self.bShowTips)
end

function UMG_PVP_Matching_C:OnOnePVPClick()
  if not self.isClick and not self.isClose then
    self.isClick = true
    local req = ProtoMessage:newZoneGmMatchStartReq()
    req.act_id = 307001
    req.team_aim_num = 1
    req.rand_pet = false
    req.pve = false
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_MATCH_START_REQ, req, self, self.OnPvPCallBack, false, true)
    self:DelaySeconds(5, self.SetClickState, self)
  end
end

function UMG_PVP_Matching_C:OnPvPCallBack(rsp)
  if rsp.ret_info.ret_code == _G.ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_PLAYER_PVP_MATCH_BANNED then
    self:OpenAntiAddiction()
  end
  if rsp.ret_info.ret_code == _G.ProtoEnum.MOBA_RET.SceneErr.ERR_SCENE_FUNCTION_BANNED then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, _G.DataConfigManager:GetLocalizationConf("online_behavior_forbid").msg)
  end
end

function UMG_PVP_Matching_C:OpenAntiAddiction()
  local instruction = {}
  local GlobalConfig = _G.DataConfigManager:GetGlobalConfig("pvp_match_banned_text")
  instruction.msg = GlobalConfig.str
  instruction.title = GlobalConfig.title
  instruction.modal = 0
  self.isClick = false
  _G.NRCModeManager:DoCmd(TipsModuleCmd.OpenAntiAddiction, instruction)
end

function UMG_PVP_Matching_C:OnTwoPVPClick()
  if not self.isClick and not self.isClose then
    self.isClick = true
    local req = ProtoMessage:newZoneGmFightTrainReq()
    req.rand_battle = true
    _G.ZoneServer:Send(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_FIGHT_TRAIN_REQ, req)
    self:DelaySeconds(5, self.SetClickState, self)
  end
end

function UMG_PVP_Matching_C:OnPracticePVPClick()
  if not self.isClick and not self.isClose then
    self.isClick = true
    local req = ProtoMessage:newZoneGmFightTrainReq()
    req.rand_battle = false
    _G.ZoneServer:Send(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_FIGHT_TRAIN_REQ, req)
    self:DelaySeconds(5, self.SetClickState, self)
  end
end

function UMG_PVP_Matching_C:StartMatch(_rsp)
  if _rsp.state == ProtoEnum.PvpMatchState.PMS_MATCHING then
    local battleConfig = _G.DataConfigManager:GetBattleConf(_rsp.match_info.act_id)
    if battleConfig then
      self:ShowMatch(battleConfig.challanger_unit_num)
    else
      self:ShowMatch(1)
    end
  end
end

function UMG_PVP_Matching_C:SetClickState()
  if self.isClick then
    self.isClick = false
  end
end

function UMG_PVP_Matching_C:TransformTime(time)
  local minute = math.floor(time / 60)
  time = math.floor(time % 60)
  if minute < 10 then
    minute = "0" .. minute
  end
  if time < 10 then
    time = "0" .. time
  end
  return minute .. ":" .. time
end

function UMG_PVP_Matching_C:OnTick(deltaTime)
  if self:IsMatching() then
    self.dTime = self.dTime + deltaTime
    if self.dTime > 1 then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1273, "UMG_PVP_Matching_C:OnTick")
      self.matchTime = self.matchTime + 1
      self.dTime = 0
      local curServerTime = _G.ZoneServer:GetServerTime() / 1000
      local serverMatchTime = math.floor(curServerTime - self.startServerTime)
      self.matchTime = math.max(serverMatchTime, self.matchTime)
      self.TimeTitle:SetText(self:TransformTime(self.matchTime))
    end
  end
end

function UMG_PVP_Matching_C:OnClickCancel()
  if self:IsMatching() then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1006, "UMG_PVP_Matching_C:OnClickCancel")
    local req = ProtoMessage:newZoneSceneMatchCancelReq()
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_MATCH_CANCEL_REQ, req, self, self.CancelRsp)
    self:DelaySeconds(5, self.SetClickState, self)
  end
end

function UMG_PVP_Matching_C:OnBtnTeamClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1281, "UMG_PVP_Matching_C:OnBtnTeamClick")
  self:ShowRightTips(false, nil, true)
  if _G.GlobalConfig.IsDemoCapture then
    function self.panelData.OpenCmd()
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPvPPetTeamPanel)
    end
    
    self:DoClose()
  else
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPvPPetTeamPanel)
    self:DelaySeconds(1, function()
      self:DoClose()
    end)
  end
end

function UMG_PVP_Matching_C:OnBtnMatchingClick(bCanMatch)
  if bCanMatch and _G.DataModelMgr.PlayerDataModel:IsVisitState() then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, _G.DataConfigManager:GetLocalizationConf("online_behavior_forbid").msg)
    return
  end
  if self.curSelectMatchType == UMG_PVP_Matching_C.MatchType.ONE_PVP then
    if bCanMatch then
      self:OnOnePVPClick()
    else
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPvPPetTeamPanel)
    end
  elseif self.curSelectMatchType == UMG_PVP_Matching_C.MatchType.TWO_PVP then
    if bCanMatch then
      self:OnTwoPVPClick()
    else
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPvPPetTeamPanel)
    end
  elseif self.curSelectMatchType == UMG_PVP_Matching_C.MatchType.PRACTICE_PVP then
    if bCanMatch then
      self:OnPracticePVPClick()
    else
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPvPPetTeamPanel)
    end
  end
end

function UMG_PVP_Matching_C:GetPanelInfoByType(selectedType)
  local picPath1, picPath2, picPathBig, titleText, rightDesc, btnDesc
  if selectedType == self.MatchType.ONE_PVP then
    picPath1 = _G.DataConfigManager:GetBattleGlobalConfig("battle_solo_picture_0").str
    picPath2 = _G.DataConfigManager:GetBattleGlobalConfig("battle_solo_picture_1").str
    picPathBig = _G.DataConfigManager:GetBattleGlobalConfig("battle_solo_picture_big").str
    titleText = _G.DataConfigManager:GetBattleGlobalConfig("battle_solo_title").str
    rightDesc = _G.DataConfigManager:GetBattleGlobalConfig("battle_solo_depict").str
    btnDesc = _G.DataConfigManager:GetBattleGlobalConfig("battle_solo_button").str
  elseif selectedType == self.MatchType.TWO_PVP then
    picPath1 = _G.DataConfigManager:GetBattleGlobalConfig("battle_pair_picture_0").str
    picPath2 = _G.DataConfigManager:GetBattleGlobalConfig("battle_pair_picture_1").str
    picPathBig = _G.DataConfigManager:GetBattleGlobalConfig("battle_pair_picture_big").str
    titleText = _G.DataConfigManager:GetBattleGlobalConfig("battle_pair_title").str
    rightDesc = _G.DataConfigManager:GetBattleGlobalConfig("battle_pair_depict").str
    btnDesc = _G.DataConfigManager:GetBattleGlobalConfig("battle_pair_button").str
  elseif selectedType == self.MatchType.PRACTICE_PVP then
    picPath1 = _G.DataConfigManager:GetBattleGlobalConfig("battle_practice_picture_0").str
    picPath2 = _G.DataConfigManager:GetBattleGlobalConfig("battle_practice_picture_1").str
    picPathBig = _G.DataConfigManager:GetBattleGlobalConfig("battle_practice_picture_big").str
    titleText = _G.DataConfigManager:GetBattleGlobalConfig("battle_practice_title").str
    rightDesc = _G.DataConfigManager:GetBattleGlobalConfig("battle_practice_depict").str
    btnDesc = _G.DataConfigManager:GetBattleGlobalConfig("battle_practice_button").str
  end
  return picPath1, picPath2, picPathBig, titleText, rightDesc, btnDesc
end

function UMG_PVP_Matching_C:SetPanelInfo()
  local pvpTypeList = {}
  local picPath1, picPath2, picPathBig, titleText, rightDesc, btnDesc
  picPath1, picPath2, picPathBig, titleText, rightDesc, btnDesc = self:GetPanelInfoByType(UMG_PVP_Matching_C.MatchType.ONE_PVP)
  table.insert(pvpTypeList, {
    picPath1 = picPath1,
    picPath2 = picPath2,
    titleName = titleText,
    pvpType = UMG_PVP_Matching_C.MatchType.ONE_PVP
  })
  picPath1, picPath2, picPathBig, titleText, rightDesc, btnDesc = self:GetPanelInfoByType(UMG_PVP_Matching_C.MatchType.TWO_PVP)
  table.insert(pvpTypeList, {
    picPath1 = picPath1,
    picPath2 = picPath2,
    titleName = titleText,
    pvpType = UMG_PVP_Matching_C.MatchType.TWO_PVP
  })
  picPath1, picPath2, picPathBig, titleText, rightDesc, btnDesc = self:GetPanelInfoByType(UMG_PVP_Matching_C.MatchType.PRACTICE_PVP)
  table.insert(pvpTypeList, {
    picPath1 = picPath1,
    picPath2 = picPath2,
    titleName = titleText,
    pvpType = UMG_PVP_Matching_C.MatchType.PRACTICE_PVP
  })
  self.Model_List:InitGridView(pvpTypeList)
  self:SetPanelInfoByType(UMG_PVP_Matching_C.MatchType.ONE_PVP)
  if 2 == GlobalConfig.OpenMainPanelFromDebugBtn then
    self.Model_List:SelectItemByIndex(1)
  elseif 3 == GlobalConfig.OpenMainPanelFromDebugBtn then
    self.Model_List:SelectItemByIndex(2)
  else
    self.Model_List:SelectItemByIndex(0)
  end
  self:RefreshPetTeamList(self.curTeamIndex)
end

function UMG_PVP_Matching_C:SetPanelInfoByType(selectedType)
  local picPath1, picPath2, picPathBig, titleText, rightDesc, btnDesc = self:GetPanelInfoByType(selectedType)
  BattleUtils.SetPvpScoreIcon(self.Star)
  self.BigPic:SetPath(picPathBig)
  self.Title_3:SetText(titleText)
  self.Title_Describe:SetText(rightDesc)
  self.Btn_Matching:SetBtnText(btnDesc)
  self.BigPicAnim:SetPic2Path(picPathBig, titleText)
  local picPath12, picPath22, picPathBig2, titleText2, rightDesc2, btnDesc2 = self:GetPanelInfoByType(self.curSelectMatchType)
  if selectedType ~= self.curSelectMatchType then
    self.BigPicAnim:OnSelectChange(picPathBig2, picPathBig, titleText2, titleText)
  end
  local points = 0
  if selectedType == UMG_PVP_Matching_C.MatchType.ONE_PVP then
    self.Points:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    points = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.ProtoEnum.VisualItem.VI_PVP_SCORE_1) or 0
  elseif selectedType == UMG_PVP_Matching_C.MatchType.TWO_PVP then
    self.Points:SetVisibility(UE4.ESlateVisibility.Collapsed)
    points = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.ProtoEnum.VisualItem.VI_PVP_SCORE_2) or 0
  else
    self.Points:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.Title_Integral:SetText(points)
  self.curSelectMatchType = selectedType
end

function UMG_PVP_Matching_C:RefreshPetTeamList(curTeamIdx)
  local teamInfo = {}
  local PVPTeams = _G.DataModelMgr.PlayerDataModel:GetPlayerPvPPetTeamInfo()
  if PVPTeams and PVPTeams.teams then
    teamInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPvPPetTeamInfo().teams[curTeamIdx + 1]
  else
    teamInfo = {}
  end
  self.curTeamIndex = curTeamIdx
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetMainTeams, curTeamIdx, _G.ProtoEnum.PlayerTeamType.PTT_PVP_BATTLE_1)
  local petListData = {}
  for i = 1, 6 do
    if teamInfo.pet_infos and teamInfo.pet_infos[i] then
      table.insert(petListData, {
        petGid = teamInfo.pet_infos[i].pet_gid,
        IsFirstOpenPanel = self.IsFirstOpenPanel
      })
    else
      table.insert(petListData, {
        petGid = 0,
        IsFirstOpenPanel = self.IsFirstOpenPanel
      })
    end
  end
  self.petListData = petListData
  self.PetList:InitGridView(petListData)
  local activedResonances = PetUtils.GetPetTeamActivedResonances(teamInfo, self.IsFirstOpenPanel)
  self.ShiNengList:InitGridView(activedResonances)
  self.IsFirstOpenPanel = false
  self.TitleTeam:SetText(LuaText.umg_pvp_matching_11 .. curTeamIdx + 1)
end

function UMG_PVP_Matching_C:UpdatePetList(_openPetData)
  for i, pet in ipairs(self.petListData) do
    pet.IsFirstOpenPanel = self.IsFirstOpenPanel
    if _openPetData.gid == pet.petGid then
      local Item = self.PetList:GetItemByIndex(i - 1)
      Item:SetupUI()
    end
  end
end

function UMG_PVP_Matching_C:CancelRsp(rsp)
  self:CloseMatch()
end

function UMG_PVP_Matching_C:CloseMatch()
  if self:IsMatching() then
    if 1 == self.matchState then
      self.PVP_Single:StopAllAnimations()
      self.PVP_Single:PlayAnimation(self.PVP_Single.Cancel)
    else
      self.PVP_Single1:StopAllAnimations()
      self.PVP_Single1:PlayAnimation(self.PVP_Single1.Cancel)
    end
    self.matchState = 0
    self:OnCloseMatch()
  end
end

function UMG_PVP_Matching_C:MatchSuccess()
  self.matchState = 3
  self.isClick = true
  self.TimeTitle:SetText("")
  self.InTheMatch:SetText(LuaText.umg_pvp_matching_12)
  self.UMG_Btn2:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_PVP_Matching_C:OnCloseButtonClicked()
  if not self.isClose then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1008, "UMG_PVP_Matching_C:OnCloseButtonClicked")
    self.isClose = true
    self.matchState = 0
    self:StopAllAnimations()
    self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self:PlayAnimation(self.Close_)
    self:OnCloseMatch()
    self.UMG_Common_BIconPar:Close()
    UE4Helper.SetEnableWorldRendering(true)
    self.module:SendZonePvpUiControlReq(false)
    _G.NRCEventCenter:DispatchEvent(MainUIModuleEvent.OnMainUISubPanelClosed, false)
  end
end

function UMG_PVP_Matching_C:OnAnimationFinished(Animation)
  if Animation == self.Close_ then
    self:DoClose()
  elseif Animation == self.Close then
  elseif Animation == self.Open1 then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:SetAnimationCurrentTime(self.Open1, 0.55)
  end
end

function UMG_PVP_Matching_C:OnCloseMatch()
  self.MatchCanvas:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.isClick = false
end

return UMG_PVP_Matching_C
