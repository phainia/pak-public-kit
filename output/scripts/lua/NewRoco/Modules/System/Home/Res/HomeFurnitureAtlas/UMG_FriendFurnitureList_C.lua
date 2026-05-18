local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_FriendFurnitureList_C = Base:Extend("UMG_FriendFurnitureList_C")
local HomeModuleEvent = require("NewRoco.Modules.System.Home.HomeModuleEvent")

function UMG_FriendFurnitureList_C:OnConstruct()
  self:AddButtonListener(self.Visit.btnLevelUp, self.OnVisitBtnClicked)
end

function UMG_FriendFurnitureList_C:OnDestruct()
  self:RemoveButtonListener(self.Visit.btnLevelUp)
end

function UMG_FriendFurnitureList_C:OnItemUpdate(_data, datalist, index)
  _G.NRCEventCenter:DispatchEvent(HomeModuleEvent.OnFriendFurniturePanelScroll, index)
  if not _data.home_level then
    if _data.bCollapsed then
      self.SizeBox_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Title:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.HomeName:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.State:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.FriendHeadItem:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Visit:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Recommend:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    return
  end
  self.SizeBox_0:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.itemData = _data
  if _data.note ~= "" then
    self.Title:SetText(_data.note)
    self.Title:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#DC9827"))
  else
    self.Title:SetText(_data.name)
  end
  if _data.online_state ~= ProtoEnum.PlayerOnlineState.ENUM.Logouted then
    self.State:SetActiveWidgetIndex(0)
  else
    self.State:SetActiveWidgetIndex(1)
    local curTime = math.floor(_G.ZoneServer:GetServerTime() / 1000)
    local diffSecond = curTime - _data.logout_time
    local diffDay
    if diffSecond > 2592000 then
      diffDay = 30
    else
      diffDay = math.floor(diffSecond / 86400)
    end
    if 0 == diffDay then
      local diffHour = math.floor(diffSecond / 3600)
      if 0 == diffHour then
        local diffMin = math.ceil(diffSecond / 60)
        self.Offline:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("umg_friend_applyfor_item_6").msg, diffMin))
      else
        self.Offline:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("umg_friend_item_4").msg, diffHour))
      end
    else
      self.Offline:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("umg_friend_item_3").msg, diffDay))
    end
  end
  local maxHomeLevel = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.ROOM_CONF):GetDataCount()
  local roomConf = _G.DataConfigManager:GetRoomConf(_data.home_level)
  if roomConf then
    self.NRCText:SetText(roomConf.name)
  end
  if maxHomeLevel == _data.home_level then
    self.NRCText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("FFCC65FF"))
  else
    self.NRCText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("272727FF"))
  end
  self.HomeName:SetActiveWidgetIndex(_data.home_level - 1)
  if _data.is_recommended then
    self.Recommend:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Recommend:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local data = {
    {
      icon = _data.card_icon_selected
    }
  }
  self.FriendHeadItem:InitGridView(data)
  if _data.refreshIndex and index > _data.refreshIndex then
    _G.NRCEventCenter:DispatchEvent(HomeModuleEvent.GetMoreFriendDataByFurnitureId)
  end
  self.Title:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.HomeName:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.State:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.FriendHeadItem:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Visit:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_FriendFurnitureList_C:OnVisitBtnClicked()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401001, "UMG_FriendFurnitureList_C:OnVisitBtnClicked")
  _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.ReqEnterPlayerHomeIndoor, self.itemData.uin, _G.MakeWeakFunctor(self, self.OnVisitCallBack))
end

function UMG_FriendFurnitureList_C:OnVisitCallBack(bSuccess)
  if bSuccess then
    _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.CloseFurnitureAtlasPanel)
    _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.CloseFriendFurniture)
  end
end

return UMG_FriendFurnitureList_C
