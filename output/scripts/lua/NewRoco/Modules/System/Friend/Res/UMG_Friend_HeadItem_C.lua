local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local UIUtils = require("NewRoco.Utils.UIUtils")
local UMG_Friend_HeadItem_C = _G.NRCViewBase:Extend("UMG_Friend_HeadItme_C")

function UMG_Friend_HeadItem_C:OnActive()
end

function UMG_Friend_HeadItem_C:OnDeactive()
end

function UMG_Friend_HeadItem_C:SetInfo(_data, _index, _studentCardForbidAddFriend, _hideLevel, _forbidStudentCardForStranger)
  self.data = _data
  self.index = _index
  self.studentCardForbidAddFriend = _studentCardForbidAddFriend
  self.forbidStudentCardForStranger = _forbidStudentCardForStranger
  self:SetPanelInfo()
  self:HideLevel(_hideLevel and true or false, _hideLevel and true or false)
end

function UMG_Friend_HeadItem_C:UpdateHead(_data, worldLevel, bUseBigHeadIcon)
  self.data = _data
  self:SetHeadInfo(self.data.CardInfo.card_icon_selected, bUseBigHeadIcon)
  self.Grade:SetText(self.data.level)
  self:HideLevel(false)
  if self.Name_content_2 then
    local worldLevelConf
    if worldLevel then
      worldLevelConf = _G.DataConfigManager:GetWorldLevelConf(worldLevel)
    else
      worldLevelConf = _G.DataConfigManager:GetWorldLevelConf(self.data.WorldLevel + 1)
    end
    if worldLevelConf then
      self.Name_content_2:SetText(worldLevelConf.title)
    else
      self.Name_content_2:SetText("")
    end
  end
  self:SetBlackListInfo()
end

function UMG_Friend_HeadItem_C:SetPanelInfo()
  local data = self.data
  if data.head_img then
    self.HeadPortrait:SetPath(data.head_img)
  end
  if data.icon then
    local CardIconConf = _G.DataConfigManager:GetCardIconConf(data.icon)
    local AvatarPath = CardIconConf.icon_resource_path
    AvatarPath = string.format("%s%s.%s'", "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/HeadIcon/", AvatarPath, AvatarPath)
    self.HeadPortrait:SetPath(AvatarPath)
  end
  self:SetHeadInfo()
  if data.card_icon_selected then
    self:SetHeadInfo(data.card_icon_selected, true)
  elseif data.card_info and data.card_info.card_icon_selected then
    self:SetHeadInfo(data.card_info.card_icon_selected, true)
  end
  self.Grade:SetText(data.level)
  self:SetBlackListInfo()
end

function UMG_Friend_HeadItem_C:SetBlackListInfo()
  local isBlack = _G.DataModelMgr.PlayerDataModel:CheckHasBlackByPlayerUin(self.data.uin)
  if isBlack then
    UIUtils.SafeSetVisibility(self.BlacklistIcon, UE4.ESlateVisibility.SelfHitTestInvisible, true)
    UIUtils.SafeSetVisibility(self.BlacklistIcon_1, UE4.ESlateVisibility.SelfHitTestInvisible, true)
  else
    UIUtils.SafeSetVisibility(self.BlacklistIcon, UE4.ESlateVisibility.Collapsed, true)
    UIUtils.SafeSetVisibility(self.BlacklistIcon_1, UE4.ESlateVisibility.Collapsed, true)
  end
end

function UMG_Friend_HeadItem_C:SetParentInfo(_Parent, _ParentSwitcherOffset)
  self.Parent = _Parent
  self.PatentSwitcherOffset = _ParentSwitcherOffset
end

function UMG_Friend_HeadItem_C:SetItemSize(_ItemSize)
  self.ItemSize = _ItemSize
end

function UMG_Friend_HeadItem_C:HideLevel(isHideLevel, isHideLevelBg)
  if isHideLevel then
    self.Grade:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Grade:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if isHideLevelBg then
    if self.NRCImage then
      self.NRCImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  elseif self.NRCImage then
    self.NRCImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Friend_HeadItem_C:SetHeadInfo(card_icon_selected, bUseBigHeadIcon)
  local path = "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/HeadIcon/"
  if bUseBigHeadIcon then
    path = "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BigHeadIcon256/"
  end
  if card_icon_selected and 0 ~= card_icon_selected then
    local CardIconConf = _G.DataConfigManager:GetCardIconConf(card_icon_selected)
    if CardIconConf then
      local AvatarPath = CardIconConf.icon_resource_path
      AvatarPath = string.format("%s%s.%s'", path, AvatarPath, AvatarPath)
      Log.Debug(AvatarPath, "UMG_Friend_HeadItem_C:SetHeadInfo")
      self.HeadPortrait:SetPath(AvatarPath)
    end
  else
  end
end

function UMG_Friend_HeadItem_C:OnTouchEnded(_MyGeometry, _InTouchEvent)
  if self.index then
    if self.forbidStudentCardForStranger then
      Log.DebugFormat("UMG_Friend_HeadItem_C:OnTouchEnded \231\166\129\230\173\162\230\159\165\231\156\139\233\153\140\231\148\159\228\186\186\229\144\141\231\137\135, player uin=%s", tostring(self.data.uin))
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.role_not_open_stranger_card)
      return UE.UWidgetBlueprintLibrary.Unhandled()
    end
    local CurSelectTabIndex = _G.NRCModuleManager:DoCmd(FriendModuleCmd.GetFriendSelectEntranceType)
    local Friend = _G.NRCModeManager:DoCmd(FriendModuleCmd.GetFriendByUin, self.data.uin)
    local Source
    if Friend then
      Source = FriendEnum.Source.Friend
    else
      Source = FriendEnum.Source.Scene
    end
    local FriendModule = NRCModuleManager:GetModule("FriendModule")
    if FriendModule then
      FriendModule:ReportTLog(3, 6, self.data)
    end
    _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_Friend_HeadItem_C:OnTouchEnded")
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenStudentCardPanel, self.data, FriendEnum.AdminFriendType.Others, Source, CurSelectTabIndex, nil, nil, self.studentCardForbidAddFriend)
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_Friend_HeadItem_C:PlayAni(_IsSelect)
  if _IsSelect then
    self:PlayAnimation(self.Select_in)
  else
    self:PlayAnimation(self.Select_out)
  end
end

function UMG_Friend_HeadItem_C:OnAddEventListener()
end

return UMG_Friend_HeadItem_C
