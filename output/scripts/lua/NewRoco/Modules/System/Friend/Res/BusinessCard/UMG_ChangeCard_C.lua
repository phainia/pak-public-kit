local FriendModuleEvent = reload("NewRoco.Modules.System.Friend.FriendModuleEvent")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local UMG_ChangeCard_C = _G.NRCPanelBase:Extend("UMG_ChangeCard_C")

function UMG_ChangeCard_C:OnConstruct()
  self.IsFirstSelect = true
  self:SetChildViews(self.UMG_CardImage)
  self.data = self.module:GetData("FriendModuleData")
  self.player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.TabList = {
    {
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/BusinessCard/Frames/img_iconbg1_png.img_iconbg1_png'",
      Icon_1 = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/BusinessCard/Frames/img_iconbg2_png.img_iconbg2_png'",
      Type = FriendEnum.ImageEditorType.Theme,
      CardEntranceType = FriendEnum.CardEntrance.ImageEditorPanel
    },
    {
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/BusinessCard/Frames/img_Jacket1_png.img_Jacket1_png'",
      Icon_1 = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/BusinessCard/Frames/img_Jacket2_png.img_Jacket2_png'",
      Type = FriendEnum.ImageEditorType.Clothing,
      CardEntranceType = FriendEnum.CardEntrance.ImageEditorPanel
    },
    {
      Icon = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/BusinessCard/Frames/img_icondongzuo1_png.img_icondongzuo1_png'",
      Icon_1 = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/BusinessCard/Frames/img_icondongzuo2_png.img_icondongzuo2_png'",
      Type = FriendEnum.ImageEditorType.PlayerAction,
      CardEntranceType = FriendEnum.CardEntrance.ImageEditorPanel
    }
  }
  self:SetCommonTitle()
  self.CardBriefInfo = _G.DataModelMgr.PlayerDataModel:GetCardBriefInfo()
  local fashionIds = self.player:GetFashionIds()
  local DefaultSkinId = self.CardBriefInfo.card_appearance_info and self.CardBriefInfo.card_appearance_info.card_skin_selected and self.data:GetDefaultSkinId()
  local DeFaultFashionWearId = fashionIds
  self.SelectTabItem = {}
  self.SelectIndex = {}
  self.CardAppearance = {
    [FriendEnum.ImageEditorType.Theme] = DefaultSkinId,
    [FriendEnum.ImageEditorType.Clothing] = DeFaultFashionWearId,
    [FriendEnum.ImageEditorType.PlayerAction] = {
      Id = self.data:GetDefaultPoseId(),
      frame = 1
    }
  }
  self.SkinId = DefaultSkinId
  self.FashionWearId = DeFaultFashionWearId
  self.PoseId = 14
  self.PoseFrame = 1
  self.UMG_CardImage:SetCardEntranceType(FriendEnum.CardEntrance.ImageEditorPanel)
  self.player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.SelectTab = FriendEnum.ImageEditorType.Theme
  self.CurrentSelectItem = nil
  self.Lock = false
  self.data:SetSelectImageEditorIndex(self.SelectTab)
  self.data:SetOldSelectTab(nil)
  self:OnAddEventListener()
end

function UMG_ChangeCard_C:OnDestruct()
end

function UMG_ChangeCard_C:OnActive()
  self:BindInputAction()
  if _G.GlobalConfig.DebugOpenUI then
    UE4Helper.SetEnableWorldRendering(false)
    NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  end
  self.UMG_CardImage.panelName = "ChangeCardBG"
  self.UMG_CardImage:SetPlayerPath()
  self:SetPanelList()
  self.UMG_CardImage:SetGender(self.player.gender)
  self.UMG_CardImage:SetPlayerAppearanceInfo(FriendEnum.CardEntrance.ImageEditorPanel)
  self.UMG_CardImage:SetScaleAndLocation(UE4.FVector(1, 1, 1), UE4.FVector(0, -85, -28))
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_ChangeCard_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_ChangeCard_C:BindInputAction()
  local imc = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_CommonCloseUI")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperAddInputMappingContext, imc, self.depth)
  local ia = UE.UNRCEnhancedInputHelper.GetInputAction("IA_CloseUI")
  UE.UNRCEnhancedInputHelper.BindAction(ia, UE.ETriggerEvent.Triggered, self, "OnPcClose")
end

function UMG_ChangeCard_C:UnBindInputAction()
  local ia = UE.UNRCEnhancedInputHelper.GetInputAction("IA_CloseUI")
  UE.UNRCEnhancedInputHelper.UnBindAction(ia)
  local imc = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_CommonCloseUI")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperRemoveInputMappingContext, imc)
end

function UMG_ChangeCard_C:OnPcClose()
  if self:GetVisibility() ~= UE4.ESlateVisibility.Visible and self:GetVisibility() ~= UE4.ESlateVisibility.SelfHitTestInvisible then
    return
  end
  self:OnCloseBtn()
end

function UMG_ChangeCard_C:SetPanelList()
  self.List_tab:InitGridView(self.TabList)
  self.List_tab:SelectItemByIndex(0)
end

function UMG_ChangeCard_C:AgainPhotograph()
  local PoseId = self.PoseId
  PoseId = PoseId or 14
  local RolepLayBehaviorConf = _G.DataConfigManager:GetRoleplayBehaviorConf(PoseId)
  self.UMG_CardImage:PlayAnimInfo(RolepLayBehaviorConf.card_pose_resource_path)
  self.UMG_CardImage:SetScaleAndLocation(UE4.FVector(1, 1, 1), UE4.FVector(0, -85, -28))
  self.UMG_CardImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:SetLock(false)
end

function UMG_ChangeCard_C:OnDeactive()
  self:UnBindInputAction()
end

function UMG_ChangeCard_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseBtn)
  self:AddButtonListener(self.PhotographBtn, self.OnPhotographBtn)
  self:RegisterEvent(self, FriendModuleEvent.SelectInformationEditorIndex, self.OnSelectInformationEditorEvent)
  self:RegisterEvent(self, FriendModuleEvent.UpdateInformationEditorPanel, self.OnUpdateInformationEditorPanel)
  self:RegisterEvent(self, FriendModuleEvent.ShowOnlyActorsSucceed, self.OnShowOnlyActorsSucceed)
end

function UMG_ChangeCard_C:OnShowOnlyActorsSucceed(CardEntrance)
  Log.Debug(CardEntrance, "UMG_ChangeCard_C:OnShowOnlyActorsSucceed")
  if CardEntrance == FriendEnum.CardEntrance.ImageEditorPanel then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.open)
  elseif CardEntrance == FriendEnum.CardEntrance.Photograph then
    self.UMG_CardImage:SetScaleAndLocation(UE4.FVector(0.77, 0.77, 0.77), UE4.FVector(0, -20, 23))
    self.UMG_CardImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ChangeCard_C:SetPanelBg(ItemData)
  if not ItemData then
    Log.Error("\233\128\137\228\184\173\231\154\132\232\131\140\230\153\175\230\149\176\230\141\174\228\184\186\231\169\186")
    return
  end
  local CardSkinConf = ItemData.ConfigurationInfo
  self.SkinId = ItemData.card_item_id
  if ItemData then
    self.BusinessCardBg1:SetPath(string.format(UEPath.CARD_COMMON_PATH, CardSkinConf.skin_resource_path, "1", CardSkinConf.skin_resource_path, "1"))
  else
    Log.Error("\230\178\161\230\156\137\228\184\170\228\186\186\229\144\141\231\137\135\231\154\174\232\130\164\233\133\141\231\189\174,\232\175\183\230\159\165\231\156\139\228\184\170\228\186\186\229\144\141\231\137\135\231\154\174\232\130\164\233\133\141\231\189\174")
  end
end

function UMG_ChangeCard_C:OnSelectInformationEditorEvent(Type)
  if self.IsFirstSelect then
    self.IsFirstSelect = false
  else
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_ThisTag_C:OnActive")
  end
  self.SelectTab = Type
  self.firstSelectItem = true
  local ListInfo
  local SelectItemBy = self.SelectTabItem[Type]
  local CurrentSelectId = 0
  local Index
  if self.SelectTab == FriendEnum.ImageEditorType.Theme then
    if self.titleConf and self.titleConf.subtitle then
      self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
    end
    self.NRCTitle_3:SetText(LuaText.edit_personal_trope_skin)
    ListInfo = self.data:GetSkinList()
    local CurrentSelectIdInfo = SelectItemBy and SelectItemBy.ConfigurationInfo.id or self.CardBriefInfo.card_appearance_info.card_skin_selected
    CurrentSelectId = SelectItemBy and SelectItemBy.ConfigurationInfo.id or self.CardBriefInfo.card_appearance_info.card_skin_selected
  elseif self.SelectTab == FriendEnum.ImageEditorType.Clothing then
    if self.titleConf and self.titleConf.subtitle then
      self.Title1:SetSubtitle(self.titleConf.subtitle[2].subtitle)
    end
    self.NRCTitle_3:SetText(LuaText.edit_personal_trope_dress)
    ListInfo = self.data:GetSuitList()
    local fashionIds = self.player:GetFashionIds()
    CurrentSelectId = SelectItemBy and SelectItemBy.fashionIds[1] or fashionIds and fashionIds[1]
    if not self.SelectIndex[Type] then
      local fashionInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerFashionInfo()
      Index = fashionInfo.current_wardrobe_index + 1
    else
      Index = self.SelectIndex[Type]
    end
  elseif self.SelectTab == FriendEnum.ImageEditorType.PlayerAction then
    if self.titleConf and self.titleConf.subtitle then
      self.Title1:SetSubtitle(self.titleConf.subtitle[3].subtitle)
    end
    self.NRCTitle_3:SetText(LuaText.edit_personal_trope_pose)
    ListInfo = self.data:GetPoseList()
    CurrentSelectId = SelectItemBy and SelectItemBy.ConfigurationInfo.id or self.PoseId
  end
  Log.Debug(CurrentSelectId, "UMG_ChangeCard_C:OnSelectInformationEditorEvent")
  self:SetList(ListInfo, CurrentSelectId, Index)
end

function UMG_ChangeCard_C:SetList(ListInfo, CurrentSelectId, Index)
  self.List_2:ClearSelection()
  self.List_2:InitGridView(ListInfo)
  if #ListInfo <= 0 then
    return
  end
  local index = 0
  for i, Icon in ipairs(ListInfo) do
    if Index then
      if 0 ~= Icon.suitID then
        if Icon.card_item_id == CurrentSelectId then
          index = i - 1
        end
      elseif Index == i and Icon.card_item_id == CurrentSelectId then
        index = i - 1
      end
    elseif Icon.card_item_id == CurrentSelectId then
      index = i - 1
    end
  end
  local Type = _G.NRCModeManager:DoCmd(FriendModuleCmd.GetOldSelectTab)
  if self.SelectTab and Type and self.SelectTab == Type then
    return
  end
  self.List_2:SelectItemByIndex(index)
end

function UMG_ChangeCard_C:UpdateTabListState()
  for i, Tab in ipairs(self.TabList) do
    if Tab.Type == self.SelectTab and self.SelectTabItem[Tab.Type] then
      local Item = self.List_tab:GetItemByIndex(i - 1)
      if Item then
        Item:UpdateLock(self.SelectTabItem[Tab.Type].is_initial_unlock)
      end
    end
  end
end

function UMG_ChangeCard_C:OnUpdateInformationEditorPanel(ItemData, Index)
  if self.firstSelectItem then
    self.firstSelectItem = false
  else
    _G.NRCAudioManager:PlaySound2DAuto(40006004, "UMG_ChangeCard_Item_C:OnClick")
  end
  self.CurrentSelectItem = ItemData
  self.SelectTabItem[self.SelectTab] = ItemData
  self.SelectIndex[self.SelectTab] = Index
  local Type = _G.NRCModeManager:DoCmd(FriendModuleCmd.GetImageEditorIndex)
  local Text
  if Type == FriendEnum.ImageEditorType.Theme then
    self:SetPanelBg(ItemData)
    if not ItemData.is_initial_unlock then
      Text = ItemData.ConfigurationInfo.skin_get_ways
    end
  elseif Type == FriendEnum.ImageEditorType.Clothing then
    self:SetSuitInfo(ItemData)
  elseif Type == FriendEnum.ImageEditorType.PlayerAction then
    self:SetPoseInfo(ItemData)
    if not ItemData.is_initial_unlock then
      Text = ItemData.ConfigurationInfo.pose_get_ways
    end
  end
  if Text then
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, Text, 1.5)
  end
  self:UpdateCardAppearance(ItemData)
  self:UpdatePhotographBtnState()
  self:UpdateTabListState()
end

function UMG_ChangeCard_C:UpdateCardAppearance(ItemData)
  local Type = _G.NRCModeManager:DoCmd(FriendModuleCmd.GetImageEditorIndex)
  if Type == FriendEnum.ImageEditorType.Theme then
    self.SkinId = ItemData.card_item_id
  elseif Type == FriendEnum.ImageEditorType.Clothing then
    self.FashionWearId = ItemData.fashionIds
  elseif Type == FriendEnum.ImageEditorType.Clothing then
    self.PoseId = ItemData.card_item_id
  end
end

function UMG_ChangeCard_C:UpdatePhotographBtnState()
  for i, SelectTab in pairs(self.SelectTabItem) do
    if not SelectTab.is_initial_unlock then
      self.PhotographBtn_Mask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      return
    end
  end
  self.PhotographBtn_Mask:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_ChangeCard_C:SetBGInfo(ItemData)
  if nil == ItemData then
    return
  end
  self.SkinId = ItemData.id
  local Path = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/Skin/Frames/"
  local CardItemInfo = ItemData
  local LinePath = string.format("%s_4_png", CardItemInfo.skin_resource_path)
  local LabelPath = string.format("%s_png", CardItemInfo.skin_resource_path)
  local SkinBGPath = string.format("%s_3_png", CardItemInfo.skin_resource_path)
  self.LinePath = string.format("%s%s.%s'", Path, LinePath, LinePath)
  self.LabelPath = string.format("%s%s.%s'", Path, LabelPath, LabelPath)
  self.SkinBGPath = string.format("%s%s.%s'", Path, SkinBGPath, SkinBGPath)
  if nil == CardItemInfo then
    return
  end
  self.BusinessCardBg1:SetPath(self.SkinBGPath)
end

function UMG_ChangeCard_C:SetSuitInfo(ItemData)
  self.UMG_CardImage:SelectSuit(ItemData.fashionIds, FriendEnum.CardEntrance.Null, self.player:GetSalonIds())
end

function UMG_ChangeCard_C:SetPoseInfo(ItemData)
  self.UMG_CardImage:PlayAnimInfo(ItemData.ConfigurationInfo.card_pose_resource_path)
end

function UMG_ChangeCard_C:OnClickConfirm()
  _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_ChangeCard_C:OnClickConfirm")
  if self.CardBriefInfo.card_appearance_info.card_skin_selected ~= self.SkinId then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.SetStudentCardBGPath, self.SkinId)
  end
  self:PlayAnimation(self.CloseAnim)
end

function UMG_ChangeCard_C:CloseAvatarBGPanel()
  _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_ChangeCard_C:CloseAvatarBGPanel")
  self:PlayAnimation(self.CloseAnim)
end

function UMG_ChangeCard_C:OnPhotographBtn()
  if self.PhotographBtn_Mask:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\228\189\191\231\148\168\228\186\134\229\176\154\230\156\170\232\167\163\233\148\129\229\134\133\229\174\185\239\188\140\230\151\160\230\179\149\231\148\159\230\136\144\229\189\162\232\177\161\231\133\167\227\128\130")
    return
  end
  if self.Lock then
    return
  end
  self:SetLock(true)
  _G.NRCAudioManager:PlaySound2DAuto(40006001, "UMG_ChangeCard_C:CloseAvatarBGPanel")
  self.PoseFrame = self.UMG_CardImage:GetAnimPosition()
  self.PoseId = self:GetPoseId()
  self.data:SetPlayerCardAppearanceInfo(self.SkinId, self.FashionWearId, self.PoseId, self.PoseFrame, self.player:GetSalonIds())
  _G.NRCModeManager:DoCmd(FriendModuleCmd.OnClickPhoto)
end

function UMG_ChangeCard_C:SetLock(_Lock)
  self.Lock = _Lock
end

function UMG_ChangeCard_C:GetPoseId()
  local Name = self.UMG_CardImage:GetAnimName()
  local PoseList = self.data:GetPoseList()
  for i, Pose in ipairs(PoseList) do
    if Pose.ConfigurationInfo.card_pose_resource_path == Name then
      return Pose.card_item_id
    end
  end
  Log.Error("\230\178\161\230\156\137\230\137\190\229\136\176\231\155\184\229\133\179\229\144\141\229\173\151\231\154\132\229\138\168\231\148\187\230\154\130\230\151\182\232\191\148\229\155\158\233\187\152\232\174\164\229\138\168\231\148\187")
  return 14
end

function UMG_ChangeCard_C:OnCloseBtn()
  if not _G.GlobalConfig.DebugOpenUI then
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenStudentCardPanel, self.data:GetCardFriendInfo(), self.data:GetCardAdminFriendType(), self.data:GetCardSource(), self.data:GetCardSelectTab())
  else
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(Enum.UILayerType.UI_LAYER_MAIN)
    UE4Helper.SetEnableWorldRendering(true)
  end
  self:PlayAnimation(self.CloseAnim)
end

function UMG_ChangeCard_C:OnAnimationFinished(Animation)
  if Animation == self.CloseAnim then
    self:DoClose()
  end
end

return UMG_ChangeCard_C
