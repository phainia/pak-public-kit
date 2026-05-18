local FriendModuleEvent = reload("NewRoco.Modules.System.Friend.FriendModuleEvent")
local UMG_FriendRequest_C = _G.NRCPanelBase:Extend("UMG_FriendRequest_C")

function UMG_FriendRequest_C:OnConstruct()
  self.data = self.module:GetData("FriendModuleData")
  self:RegisterEvent(self, FriendModuleEvent.OnFriendApplyListUpdate, self.UpdateUI)
  self:SetChildViews(self.PopUp4)
end

function UMG_FriendRequest_C:OnDestruct()
  self:UnRegisterEvent(self, FriendModuleEvent.OnFriendApplyListUpdate)
end

function UMG_FriendRequest_C:OnActive()
  self:SetCommonPopUpInfo(self.PopUp4)
  self:UpdateUI()
  self:PlayOpenAnim()
end

function UMG_FriendRequest_C:UpdateUI()
  self.FriendApplyForList = self.data:GetFriendApplyForList()
  if #self.FriendApplyForList > 0 then
    self.Switcher_73:SetActiveWidgetIndex(0)
    self.ItemList_Friend_4:InitList(self.FriendApplyForList)
  else
    self.Switcher_73:SetActiveWidgetIndex(1)
  end
end

function UMG_FriendRequest_C:SetCommonPopUpInfo(PopUp)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.TitleText = LuaText.friend_apply_list_title
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.OnCloseBtn
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_FriendRequest_C:OnCloseBtn()
  _G.NRCAudioManager:PlaySound2DAuto(1008, "UMG_Plane_ExchangeVisits_C:OnActive")
  self:PlayCloseAnim()
end

function UMG_FriendRequest_C:PlayOpenAnim()
  self:LoadAnimation(0)
end

function UMG_FriendRequest_C:PlayCloseAnim()
  self:LoadAnimation(2)
end

function UMG_FriendRequest_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  elseif anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  end
end

return UMG_FriendRequest_C
