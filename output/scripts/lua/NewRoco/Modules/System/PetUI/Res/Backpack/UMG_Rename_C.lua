local TipsModuleEvent = require("NewRoco.Modules.System.TipsModule.TipsModuleEvent")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UIUtils = require("NewRoco.Utils.UIUtils")
local UMG_Rename_C = _G.NRCPanelBase:Extend("UMG_Rename_C")
local operatorMode = {
  ModifyPet = 1,
  ModifyTeamName = 2,
  ModifySharedTeamName = 3
}

function UMG_Rename_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
  self:SetBtnInfo()
end

function UMG_Rename_C:OnDestruct()
end

function UMG_Rename_C:OnActive(_Param, _Action, _mode)
  NRCPanelBase.OnActive(self, _Param, _Action)
  self:SetCommonPopUpInfo(self.PopUp3)
  self.Mode = _mode or 1
  if self.Mode == operatorMode.ModifyPet then
    _G.NRCModuleManager:DoCmd(_G.TeachingManualModuleCmd.OnZoneUnlockTeachConditionReq, ProtoEnum.TeachClientTrigger.CT_CHANGE_NAME)
  end
  self.Action = _Action
  self:LoadAnimation(0)
  self.Param = _Param
  self.petData = _Param
  self:OnAddEventListener()
  self:SetContext()
  self._isPinYin = true
  self.NameHint:SetText(LuaText.illegal_name_tips)
end

function UMG_Rename_C:OnDeactive()
end

function UMG_Rename_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  else
    CommonPopUpData.TitleText = _G.DataConfigManager:GetLocalizationConf("pet_nickname_ui_text").msg
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnBtnCancelClick
  CommonPopUpData.Btn_RightHandler = self.OnBtnOkClick
  CommonPopUpData.ClosePanelHandler = self.OnbtnCloseRenamePanelClick
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_Rename_C:OnAddEventListener()
  self:AddDelegateListener(self.UsernameDisplay.OnTextCommitted, self.OnTextCommitted)
  self:AddDelegateListener(self.UsernameDisplay.OnTextEndTransaction, self.OnTextEndTransaction)
  self:AddDelegateListener(self.UsernameDisplay.OnTextChanged, self.OnTextChanged)
end

function UMG_Rename_C:OnTextEndTransaction()
  self._isPinYin = false
  self:OnTextChanged(self.UsernameDisplay:GetText())
end

function UMG_Rename_C:SetContext()
  if self.Mode == operatorMode.ModifyPet then
    local petData = self.petData
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
    self.TexThint:SetText("")
    if "" ~= petData.name then
      if petData.name ~= nil then
        self.UsernameDisplay:SetText(petData.name)
      else
        self.UsernameDisplay:SetText(petBaseConf.name)
      end
    else
      self.UsernameDisplay:SetText(petBaseConf.name)
    end
    local titleStr = ""
    if self.Action then
      local str = _G.DataConfigManager:GetLocalizationConf("pet_nickname_firsttime_text").msg
      titleStr = string.format(str, self.petData.name)
      local cancelStr = _G.DataConfigManager:GetLocalizationConf("pet_nickname_btn_left").msg
      local okStr = _G.DataConfigManager:GetLocalizationConf("pet_nickname_btn_right").msg
      self.TexThint:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.TexThint:SetText(titleStr)
      self.PopUp3:SetBtnLeftText(cancelStr)
      self.PopUp3:SetBtnRightText(okStr)
    else
      titleStr = _G.DataConfigManager:GetLocalizationConf("pet_nickname_ui_text").msg
      self:SetTitle(titleStr)
    end
  elseif self.Mode == operatorMode.ModifyTeamName then
    self.PopUp3:SetBtnLeftText(LuaText.umg_rename_3)
    self.PopUp3:SetBtnRightText(LuaText.pet_nickname_btn_right)
    self.UsernameDisplay:SetText(self.Param.teamName)
    local name = _G.DataConfigManager:GetBattleGlobalConfig("pvp_team_name_set")
    self:SetTitle(name.str)
  elseif self.Mode == operatorMode.ModifySharedTeamName then
    self.PopUp3:SetBtnLeftText(LuaText.umg_rename_3)
    self.PopUp3:SetBtnRightText(LuaText.pet_nickname_btn_right)
    self.UsernameDisplay:SetText(self.Param.teamName)
    local name = _G.DataConfigManager:GetBattleGlobalConfig("pvp_team_name_set")
    self:SetTitle(name.str)
  end
end

function UMG_Rename_C:SetTitle(title)
  if string.IsNilOrEmpty(title) then
    self.PopUp3:SetTitleTextInfo()
  else
    self.PopUp3:SetTitleTextInfo(title)
  end
end

function UMG_Rename_C:OnBtnCancelClick()
  if self.Mode == operatorMode.ModifyPet then
    if self.Action then
      self.Action.action:Finish()
      self:DoClose()
      return
    end
    local petData = self.petData
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
    self.UsernameDisplay:SetText(petBaseConf.name)
    self.TexThint:SetText("")
  elseif self.Mode == operatorMode.ModifyTeamName then
    self.UsernameDisplay:SetText(self.Param.teamName)
  elseif self.Mode == operatorMode.ModifySharedTeamName then
    self.UsernameDisplay:SetText(self.Param.teamName)
  end
end

function UMG_Rename_C:OnBtnOkClick()
  local textArray = string.GetPrintTable(self.UsernameDisplay:GetText())
  if textArray and #textArray > 0 then
    for i, v in ipairs(textArray) do
      local fontSize = UE4.UNRCStatics.GetStringHeightSize(v, self.UsernameDisplay.WidgetStyle.Font.FontObject)
      if fontSize <= 0 and v and "" ~= v and " " ~= v then
        Log.Trace(fontSize, v, "\229\173\151\228\189\147\229\140\133\231\169\186\229\173\151\229\189\162\231\154\132\229\173\151\228\189\147")
        _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_rename_2)
        return
      end
    end
  end
  if self.Mode == operatorMode.ModifyPet then
    local PetGid = self.petData.gid
    local PetRename = self:GetPetName()
    local str = string.StringGetTotalNum(PetRename)
    if str > 0 then
      if self:GetNameIsValid(PetRename) then
        _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_rename_2)
      else
        _G.NRCModuleManager:DoCmd(PetUIModuleCmd.repetname, PetGid, PetRename)
        self:LoadAnimation(2)
        if self.Action then
          self.Action.action:Finish()
        end
      end
    else
      _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_rename_5)
    end
  elseif self.Mode == operatorMode.ModifyTeamName then
    local targetName = self.UsernameDisplay:GetText()
    local str = string.StringGetTotalNum(targetName)
    if not UIUtils.CheckNameIsLegal(targetName) then
      _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_rename_2)
      Log.Debug("Modify Team Name has special chars targetName:", targetName)
    elseif str > 0 then
      local teamType = self.Param.teamType
      local teamInfo = _G.NRCModuleManager:GetModule("PetUIModule"):GetPetTeamUITeamInfo(teamType)
      local curTeamIdx = self.Param.TeamIdx
      local newTeam = teamInfo.teams[curTeamIdx + 1].pet_infos or {}
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetTeamName, curTeamIdx, teamType, targetName)
      self:OnbtnCloseRenamePanelClick()
    else
      _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_rename_5)
    end
  elseif self.Mode == operatorMode.ModifySharedTeamName then
    local targetName = self.UsernameDisplay:GetText()
    local str = string.StringGetTotalNum(targetName)
    if not UIUtils.CheckNameIsLegal(targetName) then
      _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_rename_2)
      Log.Debug("Modify Shared Team Name has special chars targetName:", targetName)
    elseif str > 0 then
      self.targetShareTeamName = targetName
      local req = _G.ProtoMessage:newZoneCheckNameReq()
      req.name = targetName
      _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_CHECK_NAME_REQ, req, self, self.CheckName, true, true)
    else
      _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_rename_5)
    end
  end
end

function UMG_Rename_C:CheckName(rsp)
  if rsp.ret_info.ret_code == ProtoEnum.MOBA_RET.ErrorCode.SUCCESS then
    self:DispatchEvent(PetUIModuleEvent.SetShareTeamName, self.targetShareTeamName)
    self:OnbtnCloseRenamePanelClick()
  elseif rsp.ret_info.ret_code == ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_NAME_DUPLICATE then
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_characterpick_2, 0)
  elseif rsp.ret_info.ret_code == ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_INVALID_NAME_LEN then
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_characterpick_1, 0)
  elseif rsp.ret_info.ret_code == ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_ILLEGAL_CHAR then
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_characterpick_3, 0)
  elseif rsp.ret_info.ret_code == ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_NAME_EMPTY then
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_characterpick_4, 0)
  end
end

function UMG_Rename_C:OnTextCommitted()
  UE4.UNRCAudioManager.GEt():PlaySound2dAuto(1092, "UMG_Rename_C:OnTextCommitted")
  self._isPinYin = false
  self:OnTextChanged(self.UsernameDisplay:GetText())
end

function UMG_Rename_C:OnTextChanged(Text)
  if self._isPinYin then
    return
  end
  local text = self.UsernameDisplay:GetSelectedText()
  if text and "" ~= text then
    self._isPinYin = true
    return
  end
  local len = self:GetNameLen(Text)
  if len > 12 then
    local text1 = string.GetSubStr(Text, 12)
    self.UsernameDisplay:SetText(text1)
  end
  UIUtils.RemoveInvalidCharsHandle(self.UsernameDisplay)
  local bIsLegal = UIUtils.CheckNameIsLegal(self.UsernameDisplay:GetText())
  self.NameHint:SetVisibility(bIsLegal and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.Visible)
  UIUtils.SetBtnGary(self.PopUp3.Btn_Right, not bIsLegal, bIsLegal)
end

function UMG_Rename_C:GetNameLen(Name)
  local str = string.StringGetTotalNum(Name)
  if str > 12 then
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_rename_1)
  end
  return str
end

function UMG_Rename_C:GetNameIsValid(Text)
  return UIUtils.CheckEmoji(Text) or not UIUtils.CheckNameIsLegal(Text)
end

function UMG_Rename_C:SetPetName(PetText)
  self.UsernameDisplay:SetText(PetText)
end

function UMG_Rename_C:GetPetName()
  return self.UsernameDisplay:GetText()
end

function UMG_Rename_C:OnbtnCloseRenamePanelClick()
  self.PopUp3.FullScreen_Close:SetIsEnabled(false)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1076, "UMG_Handbook_C:OnPressRewardsBtn")
  if self.Action then
    self.Action.action:Finish()
  end
  self:LoadAnimation(2)
end

function UMG_Rename_C:SetBtnInfo()
  self.PopUp3:SetBtnLeftText(LuaText.umg_rename_3)
  self.PopUp3:SetBtnRightText(LuaText.umg_rename_4)
end

function UMG_Rename_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(2) then
    self:DoClose()
    self.PopUp3.FullScreen_Close:SetIsEnabled(true)
  end
end

return UMG_Rename_C
