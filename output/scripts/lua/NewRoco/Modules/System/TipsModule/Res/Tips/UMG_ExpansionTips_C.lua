local UMG_ExpansionTips_C = _G.NRCPanelBase:Extend("UMG_ExpansionTips_C")

function UMG_ExpansionTips_C:OnActive(OnEnter, bCloseSelf)
  self.OnEnter = OnEnter
  self.bCloseSelf = bCloseSelf
  if OnEnter then
    OnEnter(self)
  end
end

function UMG_ExpansionTips_C:OnDeactive()
end

function UMG_ExpansionTips_C:OnAddEventListener()
end

function UMG_ExpansionTips_C:SetParent(parent)
  self.ParentPanel = parent
end

function UMG_ExpansionTips_C:Show(bFinish)
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if bFinish then
    self:PlayAnimation(self.Finish)
    self.Title:SetText(LuaText.room_expend_succeed)
    local RoomConf = DataConfigManager:GetRoomConf(HomeIndoorSandbox.Server.WorldData.RoomLevel)
    self.Title_Describe:SetText(RoomConf.name)
  else
    _G.NRCAudioManager:PlaySound2DAuto(1220002125, "UMG_ExpansionTips_C:Show")
    self:PlayAnimation(self.Event)
    self.Title:SetText(LuaText.home_new_event)
    self.Title_Describe:SetText(LuaText.room_expend_start)
  end
end

function UMG_ExpansionTips_C:OnAnimationFinished(Anim)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.ParentPanel then
    self.ParentPanel:ConsumeNext()
  end
  if self.bCloseSelf then
    self:OnClose()
  end
end

return UMG_ExpansionTips_C
