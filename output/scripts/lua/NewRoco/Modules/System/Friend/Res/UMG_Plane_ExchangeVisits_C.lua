local UMG_Plane_ExchangeVisits_C = _G.NRCPanelBase:Extend("UMG_Plane_ExchangeVisits_C")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")

function UMG_Plane_ExchangeVisits_C:OnConstruct()
  self:SetChildViews(self.PopUp, self.PopUp1, self.PopUp2, self.PopUp3, self.PopUp4)
end

function UMG_Plane_ExchangeVisits_C:OnDestruct()
end

function UMG_Plane_ExchangeVisits_C:OnActive(Data, Type)
  _G.NRCAudioManager:PlaySound2DAuto(1224, "UMG_Plane_ExchangeVisits_C:OnActive")
  self:SetCommonPopUpInfo(self.PopUp)
  self:SetCommonPopUpInfo(self.PopUp1)
  self:SetCommonPopUpInfo(self.PopUp2)
  self:SetCommonPopUpInfo(self.PopUp3)
  self:SetCommonPopUpInfo(self.PopUp4)
  self:SetPanelInfo(Data, Type)
  self:PlayInAnim()
  self:OnAddEventListener()
  UE4Helper.SetDesiredShowCursor(true, "UMG_Plane_ExchangeVisits_C")
  _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(MainUIModuleEvent.UnLockOpenSubUiEvent)
end

function UMG_Plane_ExchangeVisits_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.OnCloseBtn
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_Plane_ExchangeVisits_C:OnDeactive()
  UE4Helper.ReleaseDesiredShowCursor("UMG_Plane_ExchangeVisits_C")
end

function UMG_Plane_ExchangeVisits_C:PlayInAnim()
  local switcherIndex = self.Switcher_73:GetActiveWidgetIndex()
  if 0 == switcherIndex then
    self:LoadAnimation(0)
  elseif 1 == switcherIndex then
    self:LoadAnimation(3)
  elseif 2 == switcherIndex then
    self:LoadAnimation(6)
  elseif 3 == switcherIndex then
    self:LoadAnimation(9)
  elseif 4 == switcherIndex then
    self:LoadAnimation(12)
  end
end

function UMG_Plane_ExchangeVisits_C:PlayLoopAnim()
  local switcherIndex = self.Switcher_73:GetActiveWidgetIndex()
  if 0 == switcherIndex then
    self:LoadAnimation(1)
  elseif 1 == switcherIndex then
    self:LoadAnimation(4)
  elseif 2 == switcherIndex then
    self:LoadAnimation(7)
  elseif 3 == switcherIndex then
    self:LoadAnimation(10)
  elseif 4 == switcherIndex then
    self:LoadAnimation(13)
  end
end

function UMG_Plane_ExchangeVisits_C:PlayOutAnim()
  local switcherIndex = self.Switcher_73:GetActiveWidgetIndex()
  if 0 == switcherIndex then
    self:LoadAnimation(2)
  elseif 1 == switcherIndex then
    self:LoadAnimation(5)
  elseif 2 == switcherIndex then
    self:LoadAnimation(8)
  elseif 3 == switcherIndex then
    self:LoadAnimation(11)
  elseif 4 == switcherIndex then
    self:LoadAnimation(14)
  end
end

function UMG_Plane_ExchangeVisits_C:PanelClose()
  if self.NeedOpenHitPanel and #self.UIData > 0 then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenApplyVisitInfoHit, self.Type, self.UIData[1])
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.ResumeTip, TipEnum.TipsPauseReason.ExchangeVisitsHint)
  end
  self:DoClose()
end

function UMG_Plane_ExchangeVisits_C:SetPanelInfo(Data, Type)
  self.Type = Type
  self.UIData = Data
  for i = 1, #self.UIData do
    self.UIData[i].Parent = self
    self.UIData[i].Type = Type
  end
  local OnlineConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.ONLINE_GLOBAL_CONFIG):GetAllDatas()
  for i = 1, #OnlineConf do
    if OnlineConf[i].key == "online_apply_message_handle_time" then
      self.Quantity:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("online_visitor_apply_list_title_reject_text").msg, OnlineConf[i].num))
      break
    end
  end
  if Type == FriendEnum.ExchangeVisitsType.ApplyVisit then
    if #Data > 0 then
      self.Switcher_73:SetActiveWidgetIndex(3)
      self.PopUp3:SetTitleTextInfo(_G.DataConfigManager:GetLocalizationConf("online_visitor_apply_list_title_text").msg)
      self.ItemList_Friend:InitList(Data)
      self.ItemList = self.ItemList_Friend
    else
      self.Switcher_73:SetActiveWidgetIndex(4)
      self.PopUp4:SetTitleTextInfo(_G.DataConfigManager:GetLocalizationConf("online_visitor_apply_list_title_text").msg)
      self.NRCTitle_5:SetText(_G.DataConfigManager:GetLocalizationConf("online_visitor_apply_list_title_none_text").msg)
    end
  elseif Type == FriendEnum.ExchangeVisitsType.InviteVisit then
    self.Switcher_73:SetActiveWidgetIndex(0)
    self.PopUp:SetTitleTextInfo(_G.DataConfigManager:GetLocalizationConf("online_invit_dialogue_title").msg)
    self.ItemList_Friend_1:InitList(Data)
    self.ItemList = self.ItemList_Friend_1
  elseif Type == FriendEnum.ExchangeVisitsType.ResponseCompetition then
    self.Switcher_73:SetActiveWidgetIndex(1)
    self.PopUp1:SetTitleTextInfo(_G.DataConfigManager:GetLocalizationConf("spar_invite_dialogue_title").msg)
    self.ItemList_Friend_2:InitList(Data)
    self.ItemList = self.ItemList_Friend_2
  elseif Type == FriendEnum.ExchangeVisitsType.ResponseSwapEggs then
    self.Switcher_73:SetActiveWidgetIndex(2)
    self.PopUp2:SetTitleTextInfo(_G.DataConfigManager:GetLocalizationConf("petegg_trade_invite_dialogue_title").msg)
    self.ItemList_Friend_3:InitList(Data)
    self.ItemList = self.ItemList_Friend_3
  elseif Type == FriendEnum.ExchangeVisitsType.DoubleRide then
    self.Switcher_73:SetActiveWidgetIndex(2)
    self.PopUp2:SetTitleTextInfo(_G.DataConfigManager:GetLocalizationConf("ride_invitation_option_title").msg)
    self.ItemList_Friend_3:InitList(Data)
    self.ItemList = self.ItemList_Friend_3
  elseif Type == FriendEnum.ExchangeVisitsType.EnterHome then
    self.Switcher_73:SetActiveWidgetIndex(0)
    self.PopUp:SetTitleIconInfo("PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_Iconyaoqing_png.img_Iconyaoqing_png'")
    self.PopUp:SetTitleTextInfo(LuaText.invite_visit_home_title)
    self.PopUp:SetDescInfo(string.format(LuaText.invite_visit_home_bottom_text, (self.UIData[1] or {}).name))
    self.ItemList_Friend_1:InitList(Data)
    self.ItemList = self.ItemList_Friend_1
    self.Desc:SetText(string.format(LuaText.invite_visit_home_bottom_text, (self.UIData[1] or {}).name))
    self.PromptText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif Type == FriendEnum.ExchangeVisitsType.ReturnBigWorld then
    self.Switcher_73:SetActiveWidgetIndex(0)
    self.PopUp:SetTitleIconInfo("PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Images/Frames/img_Iconyaoqing_png.img_Iconyaoqing_png'")
    self.PopUp:SetTitleTextInfo(LuaText.invite_leave_home_title)
    self.PopUp:SetDescInfo(string.format(LuaText.invite_leave_home_bottom_text, (self.UIData[1] or {}).name))
    self.ItemList_Friend_1:InitList(Data)
    self.ItemList = self.ItemList_Friend_1
    self.Desc:SetText(string.format(LuaText.invite_leave_home_bottom_text, (self.UIData[1] or {}).name))
    self.PromptText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Plane_ExchangeVisits_C:OnAddEventListener()
end

function UMG_Plane_ExchangeVisits_C:IsHasItem()
  if not self.ItemList then
    return
  end
  local ItemCount = self.ItemList:GetItemCount()
  for i = 1, ItemCount do
    local item = self.ItemList:GetItemByIndex(i - 1)
    if item:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
      return true
    end
  end
  self.NeedOpenHitPanel = false
  self:PlayOutAnim()
  return false
end

function UMG_Plane_ExchangeVisits_C:OnCloseBtn()
  self.NeedOpenHitPanel = true
  _G.NRCAudioManager:PlaySound2DAuto(1008, "UMG_Plane_ExchangeVisits_C:OnActive")
  self:PlayOutAnim()
end

function UMG_Plane_ExchangeVisits_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) or anim == self:GetAnimByIndex(5) or anim == self:GetAnimByIndex(8) or anim == self:GetAnimByIndex(11) or anim == self:GetAnimByIndex(14) then
    self:PanelClose()
  elseif anim == self:GetAnimByIndex(0) or anim == self:GetAnimByIndex(3) or anim == self:GetAnimByIndex(6) or anim == self:GetAnimByIndex(9) or anim == self:GetAnimByIndex(12) then
    self:PlayLoopAnim()
  end
end

return UMG_Plane_ExchangeVisits_C
