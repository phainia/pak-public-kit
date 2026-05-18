local FriendModuleEvent = reload("NewRoco.Modules.System.Friend.FriendModuleEvent")
local UMG_AccessAuthority_C = _G.NRCPanelBase:Extend("UMG_AccessAuthority_C")

function UMG_AccessAuthority_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
end

function UMG_AccessAuthority_C:OnDestruct()
end

function UMG_AccessAuthority_C:OnActive(permission_type)
  self.CurType = permission_type
  self.CurSelectType = nil
  self:SetCommonPopUpInfo(self.PopUp3)
  self:OnAddEventListener()
  local PermissionSettingTypeList = {}
  local SelectIndex
  local Str = _G.DataConfigManager:GetOnlineGlobalConfig(24).str
  local online_limit_order = string.Split(Str, ";")
  if online_limit_order then
    for i, v in pairs(online_limit_order) do
      local Type = ProtoEnum.VisitPermissionSettingType.VPST_JOIN_AFTER_AGREE
      if "online_limit_refuse" == v then
        Type = ProtoEnum.VisitPermissionSettingType.VPST_JOIN_REFUSE
      end
      if "online_limit_agree" == v then
        Type = ProtoEnum.VisitPermissionSettingType.VPST_JOIN_DIRECT
      end
      if Type == permission_type then
        SelectIndex = i
      end
      table.insert(PermissionSettingTypeList, {
        data = Type,
        initSelect = permission_type == v,
        text = _G.DataConfigManager:GetLocalizationConf(v).msg
      })
    end
  end
  self.SortList:InitGridView(PermissionSettingTypeList)
  if SelectIndex then
    self.SortList:SelectItemByIndex(SelectIndex - 1)
  end
  self.PopUp3:SetTitleTextInfo(LuaText.online_limit_title)
  self:PlayAnimation(self.Open)
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "Friend").VISITSET
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "FriendModule", "Friend", touchReasonType)
end

function UMG_AccessAuthority_C:OnDeactive()
end

function UMG_AccessAuthority_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.CancelBtnClick
  CommonPopUpData.Btn_RightHandler = self.OkBtnClick
  CommonPopUpData.ClosePanelHandler = self.CancelBtnClick
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_AccessAuthority_C:OnPermissionItemSelect(permission_type)
  self.CurSelectType = permission_type
end

function UMG_AccessAuthority_C:OnAddEventListener()
  self:RegisterEvent(self, FriendModuleEvent.OnAccessAuthorityClick, self.OnPermissionItemSelect)
end

function UMG_AccessAuthority_C:CancelBtnClick()
  if self:IsAnimationPlaying(self.Close) then
    return
  end
  self:PlayAnimation(self.Close)
end

function UMG_AccessAuthority_C:OnPcClose()
  self:CancelBtnClick()
end

function UMG_AccessAuthority_C:OnAnimationFinished(anim)
  if anim == self.Close then
    self:DoClose()
  end
end

function UMG_AccessAuthority_C:OkBtnClick()
  if self:IsAnimationPlaying(self.Close) then
    return
  end
  self:PlayAnimation(self.Close)
  if self.CurType ~= self.CurSelectType then
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.SendZoneSetVisitPermissionSettingReq, self.CurSelectType)
  end
end

return UMG_AccessAuthority_C
