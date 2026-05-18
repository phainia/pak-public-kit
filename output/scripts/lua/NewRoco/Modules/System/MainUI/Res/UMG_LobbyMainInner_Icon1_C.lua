local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local UMG_LobbyMainInner_Icon1_C = Base:Extend("UMG_LobbyMainInner_Icon1_C")
UMG_LobbyMainInner_Icon1_C.RedPointKeyMap = {
  friend = 71,
  role_card = 40,
  mail = 60,
  shop = 377,
  battle_pass = 149,
  teaching = 220,
  role_card = 40,
  activity = 217,
  music_collection = 291,
  fasion_mall = 308,
  season = 395
}

function UMG_LobbyMainInner_Icon1_C:OnConstruct()
  self.data = nil
end

function UMG_LobbyMainInner_Icon1_C:OnDestruct()
  if self.DelayId then
    _G.DelayManager:CancelDelayById(self.DelayId)
  end
  self.Button.OnClicked:Remove(self, self.OnButtonClicked)
end

function UMG_LobbyMainInner_Icon1_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:UpdateIcon()
  self.Button.OnClicked:Remove(self, self.OnButtonClicked)
  self.Button.OnClicked:Add(self, self.OnButtonClicked)
  self.Button.OnPressed:Add(self, self.OnBtnPressed)
  self.Button.OnReleased:Add(self, self.OnBtnReleased)
end

function UMG_LobbyMainInner_Icon1_C:OnBtnPressed()
  self:PlayAnimation(self.Press)
end

function UMG_LobbyMainInner_Icon1_C:OnBtnReleased()
  self:PlayAnimation(self.Up)
end

function UMG_LobbyMainInner_Icon1_C:OnItemSelected(_bSelected)
end

function UMG_LobbyMainInner_Icon1_C:OnDeactive()
end

function UMG_LobbyMainInner_Icon1_C:OnButtonClicked()
  if self.data and self.data.icon_initialize then
    local UIType = MainUIModuleEnum.FunctionID.NoneUI
    if self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_ACTIVITY then
      UIType = MainUIModuleEnum.FunctionID.ActivityUI
      _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_LobbyMainInner_Icon1_C:OnButtonClicked")
      local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_ACTIVITY, true)
      if isBan then
        return
      end
    elseif self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_FRIEND then
      UIType = MainUIModuleEnum.FunctionID.FriendUI
      local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_FRIEND, true)
      if isBan then
        return
      end
    elseif self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_MAIL then
      UIType = MainUIModuleEnum.FunctionID.MailUI
      local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_MAIL, true)
      if isBan then
        return
      end
    elseif self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_SHOP then
      UIType = MainUIModuleEnum.FunctionID.ShopUI
      local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_CHARGE, true)
      if isBan then
        return
      end
    elseif self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_BATTLEPASS then
      UIType = MainUIModuleEnum.FunctionID.BattlePassUI
      local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_BP, true)
      local isOpen = _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.IsActivitePass)
      if isBan or not isOpen then
        return
      end
    elseif self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_PLATPRIVIL then
      _G.NRCAudioManager:PlaySound2DAuto(1011, "UMG_LobbyMainInner_Icon1_C:OnCreateCustomerService")
      self.DelayId = _G.DelayManager:DelaySeconds(0.1, function()
        _G.NRCSDKManager:CustomerService(5)
      end)
      return
    elseif self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_MUSICCOLLECTION then
      local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_MUSIC, true)
      if isBan then
        return
      end
    elseif self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_TEACHING then
      UIType = MainUIModuleEnum.FunctionID.TeachingUI
      local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_GUIDE, true)
      if isBan then
        return
      end
    elseif self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_ROLECARD then
      UIType = MainUIModuleEnum.FunctionID.RoleCardUI
    elseif self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_FASHIONMALL then
      UIType = MainUIModuleEnum.FunctionID.FashionMallUI
    elseif self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_SEASON then
      UIType = MainUIModuleEnum.FunctionID.SeasonIntegration
      local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionHide, Enum.FunctionEntrance.FE_SEASON)
      local isOpen = _G.NRCModuleManager:DoCmd(_G.SeasonIntegrationModuleCmd.GetSeasonInfo) and true or false
      if isBan or not isOpen then
        return
      end
    end
    _G.NRCEventCenter:DispatchEvent(_G.MainUIModuleEvent.OnMainUIFuncPanelOpen, self.data.icon_initialize)
    if UIType ~= MainUIModuleEnum.FunctionID.NoneUI then
      _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.SendTLog, UIType)
    end
  end
end

function UMG_LobbyMainInner_Icon1_C:UpdateIcon()
  local isBan = false
  local isOpen = true
  local redPointKey
  if self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_FRIEND then
    isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_FRIEND, false)
    redPointKey = self.RedPointKeyMap.friend
  elseif self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_ROLECARD then
    redPointKey = self.RedPointKeyMap.role_card
  elseif self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_MAIL then
    isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_MAIL, false)
    redPointKey = self.RedPointKeyMap.mail
  elseif self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_SHOP then
    self:PlayAnimation(self.shangchang_loop)
    local IsHiddenRed = _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OnGetIsHiddenShopItemRed)
    if not IsHiddenRed then
      redPointKey = self.RedPointKeyMap.shop
    end
  elseif self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_BATTLEPASS then
    isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_BP, false)
    isOpen = _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.IsActivitePass)
    redPointKey = self.RedPointKeyMap.battle_pass
  elseif self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_TEACHING then
    redPointKey = self.RedPointKeyMap.teaching
  elseif self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_ACTIVITY then
    isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionHide, _G.Enum.FunctionEntrance.FE_ACTIVITY, false)
    redPointKey = self.RedPointKeyMap.activity
  elseif self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_MUSICCOLLECTION then
    isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionHide, _G.Enum.FunctionEntrance.FE_MUSIC, false)
    redPointKey = self.RedPointKeyMap.music_collection
  elseif self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_FASHIONMALL then
    self:PlayAnimation(self.pikamonthly_loop)
    redPointKey = self.RedPointKeyMap.fasion_mall
  elseif self.data.icon_initialize == _G.ProtoEnum.LobbyMainInnerUIType.LMIUT_SEASON then
    isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionHide, Enum.FunctionEntrance.FE_SEASON)
    isOpen = _G.NRCModuleManager:DoCmd(_G.SeasonIntegrationModuleCmd.GetSeasonInfo) and true or false
    redPointKey = self.RedPointKeyMap.season
  end
  if isBan or not isOpen then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCText_35:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Icon:SetPath(self.data.icon_path)
    self.NRCText_35:SetText(self.data.icon_name)
    if redPointKey then
      self.NrcRedPoint:SetupKey(redPointKey)
    end
  end
end

return UMG_LobbyMainInner_Icon1_C
