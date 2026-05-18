local FriendModuleEvent = reload("NewRoco.Modules.System.Friend.FriendModuleEvent")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local UMG_Friend_ApplyFor_Blacklist_C = _G.NRCPanelBase:Extend("UMG_Friend_ApplyFor_Blacklist_C")

function UMG_Friend_ApplyFor_Blacklist_C:OnActive()
  self.In = self:GetAnimByIndex(0)
  self.Loop = self:GetAnimByIndex(1)
  self.Out = self:GetAnimByIndex(2)
  self.data = self.module:GetData("FriendModuleData")
  self.bNeedAnimOnDisable = false
  self.ListInfo = {}
  self:SetCommonPopUpInfo()
  self:SetPanelInfo()
  self:SetListInfo()
  self:OnAddEventListener()
  self:PlayAnimation(self.In)
  _G.NRCAudioManager:PlaySound2DAuto(41400002, "UMG_Friend_ApplyFor_Blacklist_C:OnActive")
  self:BindInputAction()
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "Friend").BLACKLIST
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.UnlockIsSelectBtn, "FriendModule", "Friend", touchReasonType)
end

function UMG_Friend_ApplyFor_Blacklist_C:SetPanelInfo()
  self.Text_Hint_1:SetText(LuaText.umg_friend_applyfor_blacklist_4)
end

function UMG_Friend_ApplyFor_Blacklist_C:SetCommonPopUpInfo()
  local FriendBlackList = self.data:GetFriendBlackList()
  local BlackListNumMax = _G.DataConfigManager:GetFriendGlobalConfig("blacklist_num_max")
  local FriendNum = string.format("%d/%d", #FriendBlackList, BlackListNumMax.num)
  local Text = _G.DataConfigManager:GetLocalizationConf("umg_friend_applyfor_blacklist_3").msg
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.TitleText = string.format("%s%s", Text, FriendNum)
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.OnClickCloseBtn
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_Friend_ApplyFor_Blacklist_C:SetListInfo(_IsSucceed)
  self:UpdateChildBtnState(_IsSucceed)
  self.ListInfo = self.data:GetFriendBlackList()
  if #self.ListInfo > 0 then
    self.Switcher_73:SetActiveWidgetIndex(0)
    self.ItemList_Friend_1:InitList(self.ListInfo)
    for i, List in ipairs(self.ListInfo) do
      local Item = self.ItemList_Friend_1:GetItemByIndex(i - 1)
      Item:SetParentInfo(self, self.Switcher_73.Slot:GetOffsets())
      Item:SetSwitcherState(false)
    end
  else
    self.Switcher_73:SetActiveWidgetIndex(1)
  end
end

function UMG_Friend_ApplyFor_Blacklist_C:UpdateChildBtnState(_IsSucceed)
  if #self.ListInfo > 0 then
    for i, List in ipairs(self.ListInfo) do
      if not _IsSucceed then
        local Item = self.ItemList_Friend_1:GetItemByIndex(i - 1)
        if List.uin == Item.data.uin then
          Item:SetLock()
        end
      end
    end
  end
end

function UMG_Friend_ApplyFor_Blacklist_C:OnDeactive()
end

function UMG_Friend_ApplyFor_Blacklist_C:OnTouchEnded(MyGeometry, InTouchEvent)
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_Friend_ApplyFor_Blacklist_C:OnAddEventListener()
  self:RegisterEvent(self, FriendModuleEvent.FriendConfirmAddFriendUpdate, self.FriendConfirmAddFriendUpdate)
  self:RegisterEvent(self, FriendModuleEvent.AddOrRemoveBlackListUpdate, self.FriendConfirmAddFriendUpdate)
end

function UMG_Friend_ApplyFor_Blacklist_C:GetChangedOffsetInfo()
  return self.ItemList_Friend_1:GetScrollOffset(), self.data:GetApplyForOrBlackListType()
end

function UMG_Friend_ApplyFor_Blacklist_C:FriendConfirmAddFriendUpdate(_IsSucceed)
  self:SetCommonPopUpInfo()
  self:SetPanelInfo()
  self:SetListInfo(_IsSucceed)
end

function UMG_Friend_ApplyFor_Blacklist_C:OnConstruct()
  self:SetChildViews(self.PopUp)
end

function UMG_Friend_ApplyFor_Blacklist_C:OnDestruct()
end

function UMG_Friend_ApplyFor_Blacklist_C:OnAnimationFinished(Animation)
  if Animation == self.In then
    self:PlayAnimation(self.Loop)
  elseif Animation == self.Out then
    self.data:SetFriendSelectEntranceType(FriendEnum.SELECT_TAB.FriendList)
    if not self.bNeedAnimOnDisable then
      self:DoClose()
    end
  end
end

function UMG_Friend_ApplyFor_Blacklist_C:OnClickCloseBtn()
  _G.NRCAudioManager:PlaySound2DAuto(41400003, "UMG_Friend_Item_C:StartFriendVisit")
  self:PlayAnimation(self.Out)
end

function UMG_Friend_ApplyFor_Blacklist_C:OnClickbtnCloseRenamePanel()
  self:DoClose()
end

function UMG_Friend_ApplyFor_Blacklist_C:Enable()
  self:PlayAnimation(self.In)
end

function UMG_Friend_ApplyFor_Blacklist_C:Disable()
  self:PlayAnimation(self.Out)
end

function UMG_Friend_ApplyFor_Blacklist_C:SetNeedAnimOnDisable(bNeedAnimOnDisable)
  self.bNeedAnimOnDisable = bNeedAnimOnDisable
end

function UMG_Friend_ApplyFor_Blacklist_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_FriendApplyForBlacklist")
  if mappingContext then
    mappingContext:BindAction("IA_CloseFriendApplyForBlacklist", self, "OnPcClose2")
  end
end

function UMG_Friend_ApplyFor_Blacklist_C:OnPcClose2()
  self:OnClickCloseBtn()
end

return UMG_Friend_ApplyFor_Blacklist_C
