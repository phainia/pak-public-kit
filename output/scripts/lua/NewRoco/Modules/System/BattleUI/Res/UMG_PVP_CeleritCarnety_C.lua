local UMG_PVP_CeleritCarnety_C = _G.NRCPanelBase:Extend("UMG_PVP_CeleritCarnety_C")

function UMG_PVP_CeleritCarnety_C:OnActive(FinishData, Caller, CallBack)
  local pve_add_info = FinishData.settle_info.pve_add_info
  local activityConf = _G.DataConfigManager:GetActivityConf(pve_add_info.activity_id)
  self.ActiveType = activityConf.activity_type
  self.pre_level_ids = pve_add_info.pre_level_ids
  self.challenge_level_id = pve_add_info.challenge_level_id
  self.Caller = Caller
  self.CallBack = CallBack
  self:OnAddEventListener()
  self:RefreshUI()
end

function UMG_PVP_CeleritCarnety_C:OnDeactive()
end

function UMG_PVP_CeleritCarnety_C:OnAddEventListener()
  self:AddButtonListener(self.BtnClose, self.OnClickBtnClose)
  self:AddButtonListener(self.Btn5.btnLevelUp, self.OnClickBtnClose)
end

function UMG_PVP_CeleritCarnety_C:OnRemoveEventListener()
  self:RemoveButtonListener(self.BtnClose, self.OnClickBtnClose)
  self:RemoveButtonListener(self.Btn5.btnLevelUp, self.OnClickBtnClose)
end

function UMG_PVP_CeleritCarnety_C:OnTick()
end

function UMG_PVP_CeleritCarnety_C:OnLogin()
end

function UMG_PVP_CeleritCarnety_C:OnConstruct()
end

function UMG_PVP_CeleritCarnety_C:OnDestruct()
end

function UMG_PVP_CeleritCarnety_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_PVP_CeleritCarnety_C:OnClickBtnClose()
  self:DoCallBack()
  self:LoadAnimation(2)
end

function UMG_PVP_CeleritCarnety_C:RefreshUI()
  local eventConf, tips
  if self.ActiveType == Enum.ActivityType.ATP_NPC_CHALLENGE_EVENT then
    eventConf = _G.DataConfigManager:GetNpcChallengeConf(self.challenge_level_id)
    tips = LuaText.challenge_text_32
  elseif self.ActiveType == Enum.ActivityType.ATP_BOSS_CHALLENGE_EVENT then
    eventConf = _G.DataConfigManager:GetBossChallengeConf(self.challenge_level_id)
    tips = LuaText.challenge_text_33
  end
  if not eventConf then
    return
  end
  self.TextDescribe:SetText(string.format(tips, eventConf.topic))
  local info = {}
  for _, levelId in pairs(self.pre_level_ids) do
    table.insert(info, {
      id = levelId,
      ActiveType = self.ActiveType
    })
  end
  self.List:InitGridView(info)
  self:LoadAnimation(0)
end

function UMG_PVP_CeleritCarnety_C:DoCallBack()
  if self.Caller and self.CallBack then
    self.CallBack(self.Caller)
  end
  self.Caller = nil
  self.CallBack = nil
end

return UMG_PVP_CeleritCarnety_C
