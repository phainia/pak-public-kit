local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UIUtils = require("NewRoco.Utils.UIUtils")
local UMG_FriendRequest_Item_C = Base:Extend("UMG_FriendRequest_Item_C")

function UMG_FriendRequest_Item_C:OnConstruct()
  self.BtnAgree.OnClicked:Add(self, self.OnAgreeClicked)
  self.BtnRefuse.OnClicked:Add(self, self.OnRefuseClicked)
end

function UMG_FriendRequest_Item_C:OnDestruct()
end

function UMG_FriendRequest_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self:UpdateUI()
end

function UMG_FriendRequest_Item_C:OnItemSelected(_bSelected)
end

function UMG_FriendRequest_Item_C:OnAgreeClicked()
  if self:CheckIsSelectBtn() then
    return
  end
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "Friend").ACCEPT
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.LockIsSelectBtn, "FriendModule", "Friend", touchReasonType)
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_FriendRequest_Item_C:OnClickConsent")
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.FriendConfirmAddFriend, self.data.uin, _G.ProtoEnum.ZoneFriendConfirmAddFriendReq.TYPE.AGREE_REQ, self.index)
end

function UMG_FriendRequest_Item_C:OnRefuseClicked()
  if self:CheckIsSelectBtn() then
    return
  end
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "Friend").DELETE
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.LockIsSelectBtn, "FriendModule", "Friend", touchReasonType)
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_FriendRequest_Item_C:OnClickDeleteBtn")
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.FriendConfirmAddFriend, self.data.uin, _G.ProtoEnum.ZoneFriendConfirmAddFriendReq.TYPE.REFUSE_REQ, self.index)
end

function UMG_FriendRequest_Item_C:UpdateUI()
  if self.HeadItem then
    local data = self.data
    self.HeadItem:SetInfo(data, self.index)
  end
  self.RemarkName:SetText(self.data.name)
  self:SetOnlineInfo()
  local signatureText
  if self.data.card_info == nil or nil == self.data.card_info.card_signature or self.data.card_info.card_signature == "" then
    signatureText = _G.DataConfigManager:GetLocalizationConf("card_signature_input_empty_text").msg
  else
    signatureText = self.data.card_info.card_signature
  end
  self.Signature:SetText(signatureText)
end

function UMG_FriendRequest_Item_C:SetOnlineInfo()
  self.State:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if self.data.online then
    self.State:SetActiveWidgetIndex(0)
  else
    self.State:SetActiveWidgetIndex(1)
    local LastLogoutTime = self.data.req_time
    local nowTime = math.floor(_G.ZoneServer:GetServerTime() / 1000)
    local TimeDiff = nowTime - LastLogoutTime
    local min = math.floor(TimeDiff / 60)
    local hour = math.floor(min / 60)
    local day = math.floor(hour / 24)
    if day >= 7 then
      self.Offline:SetText(LuaText.umg_friend_item_2)
    else
      local Text
      if day < 7 and hour >= 24 then
        Text = string.format(LuaText.umg_friend_item_3, day)
      elseif hour < 24 and hour > 0 then
        Text = string.format(LuaText.umg_friend_item_4, hour)
      elseif min < 60 and min >= 1 then
        Text = string.format(LuaText.umg_friend_applyfor_item_6, min)
      elseif min < 1 and min >= 0 then
        Text = LuaText.umg_friend_applyfor_item_5
      end
      self.Offline:SetText(Text)
    end
  end
end

function UMG_FriendRequest_Item_C:CheckIsSelectBtn()
  return _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetIsSelectBtn, "FriendModule", "Friend")
end

function UMG_FriendRequest_Item_C:OnDeactive()
end

return UMG_FriendRequest_Item_C
