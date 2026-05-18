local UMG_InvitationRecord_C = _G.NRCPanelBase:Extend("UMG_InvitationRecord_C")

function UMG_InvitationRecord_C:OnConstruct()
  self:SetChildViews(self.PopUp)
end

function UMG_InvitationRecord_C:OnActive(invited_users)
  local usersData = {}
  if invited_users then
    usersData = invited_users
  end
  local initData = {}
  for _, v in ipairs(usersData) do
    local data = {}
    local date = os.date("*t", v.register_time)
    data.registerTime = string.format(_G.DataConfigManager:GetLocalizationConf("Activity_Invite_friend_time").msg, date.year, date.month, date.day, date.hour, date.min, date.sec)
    data.headIconId = v.icon
    data.gameName = v.name
    data.platformName = v.plat_nick_name
    data.role_level = v.role_level
    data.uin = v.uin
    table.insert(initData, data)
  end
  self.List:InitList(initData)
  self:LoadAnimation(0)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.CloseRecord
  self.PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_InvitationRecord_C:CloseRecord()
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_InvitationRecord_C:CloseRecord")
  self:LoadAnimation(2)
end

function UMG_InvitationRecord_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  elseif anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_InvitationRecord_C:OnDeactive()
end

function UMG_InvitationRecord_C:OnAddEventListener()
end

return UMG_InvitationRecord_C
