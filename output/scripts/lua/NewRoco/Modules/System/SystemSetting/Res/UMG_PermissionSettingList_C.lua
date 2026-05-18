local SystemSettingModuleEvent = require("NewRoco.Modules.System.SystemSetting.SystemSettingModuleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local UMG_PermissionSettingList_C = _G.NRCViewBase:Extend("UMG_PermissionSettingList_C")
local EPermission = {
  WatchBattle = "WatchBattle",
  FriendSuggest = "FriendSuggest",
  FriendSearch = "FriendSearch",
  FriendAdd = "FriendAdd",
  FriendVisit = "FriendVisit"
}

function UMG_PermissionSettingList_C:OnConstruct()
  if not RocoEnv.PLATFORM_WINDOWS then
    self.ManagementBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.ManagementBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:AddButtonListener(self.ManagementBtn.btnLevelUp, self.OnManagementBtnClicked)
  local FriendModule = _G.NRCModuleManager:GetModule("FriendModule")
  if FriendModule then
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.QueryWhetherCanBeSearched, self, self.QueryCallback)
    self:InitGridView()
    _G.NRCEventCenter:RegisterEvent("UMG_PermissionSettingList_C", self, SystemSettingModuleEvent.PlayerSettingUpdate, self.HandlePlayerSettingUpdate)
    self.module:RegisterEvent(self, SystemSettingModuleEvent.CloseDetailTips, self.OnCloseDetailTips)
  else
    self.List:InitGridView({})
  end
end

function UMG_PermissionSettingList_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, SystemSettingModuleEvent.PlayerSettingUpdate, self.HandlePlayerSettingUpdate)
  if self.module then
    self.module:UnRegisterEvent(self, SystemSettingModuleEvent.CloseDetailTips)
  end
end

function UMG_PermissionSettingList_C:OnCloseDetailTips()
  Log.Info("UMG_PermissionSettingList_C:OnCloseDetailTips")
  if self.List then
    local itemCount = self.List:GetItemCount()
    for i = 1, itemCount do
      local itemData = self.List:GetItemByIndex(i - 1)
      if itemData then
        itemData:CloseDetailTips()
      end
    end
  end
end

function UMG_PermissionSettingList_C:InitGridView()
  local dataList = {}
  table.insert(dataList, {
    Name = LuaText.privacy_setting_39,
    IsToggled = _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.GetAllowFriendWatchBattle),
    OnItemClickCheckedOwner = self,
    OnItemClickChecked = self.OnWatchBattleCheckStateChanged,
    UniqueType = EPermission.WatchBattle,
    DetailTipsContent = LuaText.privacy_setting_35,
    OnBtnDetailClickedOwner = self,
    OnBtnDetailClicked = self.OnGridViewItemBtnDetailClicked
  })
  table.insert(dataList, {
    Name = LuaText.privacy_setting_10,
    IsToggled = true,
    OnItemClickCheckedOwner = self,
    OnItemClickChecked = self.OnFriendSearchStateChanged,
    UniqueType = EPermission.FriendSearch,
    DetailTipsContent = LuaText.privacy_setting_8,
    OnBtnDetailClickedOwner = self,
    OnBtnDetailClicked = self.OnGridViewItemBtnDetailClicked
  })
  table.insert(dataList, {
    Name = LuaText.privacy_setting_11,
    IsToggled = true,
    OnItemClickCheckedOwner = self,
    OnItemClickChecked = self.OnFriendSuggestCheckStateChanged,
    UniqueType = EPermission.FriendSuggest,
    DetailTipsContent = LuaText.privacy_setting_9,
    OnBtnDetailClickedOwner = self,
    OnBtnDetailClicked = self.OnGridViewItemBtnDetailClicked
  })
  table.insert(dataList, {
    Name = LuaText.privacy_setting_47,
    IsToggled = true,
    OnItemClickCheckedOwner = self,
    OnItemClickChecked = self.OnFriendAddCheckStateChanged,
    UniqueType = EPermission.FriendAdd,
    DetailTipsContent = "",
    OnBtnDetailClickedOwner = self,
    OnBtnDetailClicked = self.OnGridViewItemBtnDetailClicked
  })
  table.insert(dataList, {
    Name = LuaText.privacy_setting_48,
    IsToggled = true,
    OnItemClickCheckedOwner = self,
    OnItemClickChecked = self.OnFriendVisitCheckStateChanged,
    UniqueType = EPermission.FriendVisit,
    DetailTipsContent = "",
    OnBtnDetailClickedOwner = self,
    OnBtnDetailClicked = self.OnGridViewItemBtnDetailClicked
  })
  self.dataList = dataList
  self.List:InitGridView(dataList)
end

function UMG_PermissionSettingList_C:OnGridViewItemBtnDetailClicked()
  Log.Info("UMG_PermissionSettingList_C:OnGridViewItemBtnDetailClicked")
  self.module:DispatchEvent(SystemSettingModuleEvent.DetailTipsShowNotify)
end

function UMG_PermissionSettingList_C:RefreshGridViewToggleState(ePermission, bChecked)
  if self.dataList then
    for _, data in pairs(self.dataList) do
      if data.UniqueType == ePermission then
        data.IsToggled = bChecked
        break
      end
    end
    self.List:InitGridView(self.dataList)
  end
end

function UMG_PermissionSettingList_C:OnManagementBtnClicked()
  Log.Info("UMG_PermissionSettingList_C:OnManagementBtnClicked")
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_PermissionSettingList_C:OnManagementBtnClicked")
  _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.OpenPrivilegeAuthorizationPopUp)
end

function UMG_PermissionSettingList_C:OnWatchBattleCheckStateChanged(data, bChecked)
  Log.Info("UMG_PermissionSettingList_C:OnWatchBattleCheckStateChanged", data.Name, bChecked)
  if data.UniqueType == EPermission.WatchBattle then
    local nextAllowFriendWatchBattle = bChecked and true or false
    local prevPlayerSettings = _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.GetPlayerSettings)
    local nextPlayerSettings = BattleUtils.ModifyAllowObserveInPlayerSettings(prevPlayerSettings, nextAllowFriendWatchBattle)
    if prevPlayerSettings == nextPlayerSettings then
      return
    end
    _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.ReqModifyPlayerSettings, nextPlayerSettings)
  end
end

function UMG_PermissionSettingList_C:OnFriendVisitCheckStateChanged(data, bChecked)
  Log.Info("UMG_PermissionSettingList_C:OnFriendVisitCheckStateChanged ", data.Name, bChecked)
  if data.UniqueType == EPermission.FriendVisit then
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.SetWhetherCanStrangerVisit, bChecked, self, self.SetPlayerSettingsCallback)
  end
end

function UMG_PermissionSettingList_C:OnFriendAddCheckStateChanged(data, bChecked)
  Log.Info("UMG_PermissionSettingList_C:OnFriendAddCheckStateChanged ", data.Name, bChecked)
  if data.UniqueType == EPermission.FriendAdd then
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.SetWhetherCanStrangerAdd, bChecked, self, self.SetPlayerSettingsCallback)
  end
end

function UMG_PermissionSettingList_C:OnFriendSuggestCheckStateChanged(data, bChecked)
  Log.Info("UMG_PermissionSettingList_C:OnFriendSuggestCheckStateChanged ", data.Name, bChecked)
  if data.UniqueType == EPermission.FriendSuggest then
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.SetWhetherCanBeSuggested, bChecked, self, self.SetPlayerSettingsCallback)
  end
end

function UMG_PermissionSettingList_C:OnFriendSearchStateChanged(data, bChecked)
  Log.Info("UMG_PermissionSetting_C:OnFriendSuggestSuggestStateChanged ", data.Name, bChecked)
  if data.UniqueType == EPermission.FriendSearch then
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.SetWhetherCanBeSearched, bChecked, self, self.SetPlayerSettingsCallback)
  end
end

function UMG_PermissionSettingList_C:HandlePlayerSettingUpdate()
  Log.Info("UMG_PermissionSettingList_C:HandlePlayerSettingUpdate, allowFriendWatchBattle ", _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.GetAllowFriendWatchBattle))
  self:RefreshGridViewToggleState(EPermission.WatchBattle, _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.GetAllowFriendWatchBattle))
end

function UMG_PermissionSettingList_C:QueryCallback(friendShip)
  local can_be_searched = friendShip and friendShip.can_be_searched
  local can_be_suggested = friendShip and friendShip.can_be_sugguested
  local can_be_add_friend = friendShip and friendShip.can_be_add_friend
  local can_stranger_visit = friendShip and friendShip.can_stranger_visit
  Log.Info("UMG_PermissionSettingList_C:QueryCallback, can_be_searched  ", can_be_searched, "can_be_suggested ", can_be_suggested, " can_be_add_friend ", can_be_add_friend, " can_stranger_visit ", can_stranger_visit)
  self:RefreshGridViewToggleState(EPermission.FriendSuggest, can_be_suggested)
  self:RefreshGridViewToggleState(EPermission.FriendSearch, can_be_searched)
  self:RefreshGridViewToggleState(EPermission.FriendAdd, can_be_add_friend)
  self:RefreshGridViewToggleState(EPermission.FriendVisit, can_stranger_visit)
end

function UMG_PermissionSettingList_C:SetPlayerSettingsCallback(friendShip)
  local can_be_searched = friendShip and friendShip.can_be_searched
  local can_be_suggested = friendShip and friendShip.can_be_sugguested
  local can_be_add_friend = friendShip and friendShip.can_be_add_friend
  local can_stranger_visit = friendShip and friendShip.can_stranger_visit
  Log.Info("UMG_PermissionSettingList_C:SetFriendSuggestOrFriendSearchCallback, can_be_searched  ", can_be_searched, "can_be_suggested ", can_be_suggested, " can_be_add_friend ", can_be_add_friend, " can_stranger_visit ", can_stranger_visit)
  self:RefreshGridViewToggleState(EPermission.FriendSuggest, can_be_suggested)
  self:RefreshGridViewToggleState(EPermission.FriendSearch, can_be_searched)
  self:RefreshGridViewToggleState(EPermission.FriendAdd, can_be_add_friend)
  self:RefreshGridViewToggleState(EPermission.FriendVisit, can_stranger_visit)
end

return UMG_PermissionSettingList_C
