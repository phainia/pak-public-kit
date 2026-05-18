local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")
local UIUtils = require("NewRoco.Utils.UIUtils")
local EditComponentItemData = reload("NewRoco.Modules.System.Friend.EditComponentItemData")
local UMG_ShiningMedal_C = _G.NRCPanelBase:Extend("UMG_ShiningMedal_C")

function UMG_ShiningMedal_C:OnActive(context)
  self:LoadAnimation(0)
  self:OnAddEventListener()
  self.LeftBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.RightBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.HandHoldingPrivilege:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.context = context
  if context.title then
    self.PopUp.TitleText:SetText(context.title)
  end
  if context.image then
    self.Picture:SetPath(context.image)
  end
  if context.leftImage then
    self.Image_Icon:SetPath(context.leftImage)
    self.Image_Icon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Image_Icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if context.desc then
    self.Text1:SetText(context.desc)
  end
  if context.bIsShiningMedal then
    self.Switcher_0:SetActiveWidgetIndex(0)
    self.titleText = _G.LuaText.popup_magic_award
    self:InitShiningMedalDetail(context)
  elseif context.bIsMagicWand then
    self.Switcher_0:SetActiveWidgetIndex(0)
    self.titleText = _G.LuaText.popup_magic_wand
  elseif context.bIsNameCard then
    self.Switcher_0:SetActiveWidgetIndex(1)
    self.titleText = _G.LuaText.popup_name_card
    self:InitNameCardDetail(context)
  end
  self:SetCommonPopUpInfo()
end

function UMG_ShiningMedal_C:InitNameCardDetail(context)
  local baseData = {}
  self.PlayerInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo().brief_info
  self.CardInfo = _G.DataModelMgr.PlayerDataModel:GetCardBriefInfo()
  baseData.name = self.PlayerInfo.name
  baseData.uin = self.PlayerInfo.uin
  baseData.level = _G.DataModelMgr.PlayerDataModel:GetPlayerLevel()
  baseData.note = "\230\181\139\232\175\149note"
  baseData.CardInfo = self.CardInfo
  baseData.isBlack = false
  baseData.isFriend = false
  baseData.isOnline = true
  baseData.isTop = false
  baseData.WorldLevel = _G.DataModelMgr.PlayerDataModel:GetPlayerWorldLevel()
  self.Name_content_3:SetText(self.PlayerInfo.name)
  self.MoreBtn2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local Text = ""
  if self.CardInfo.card_signature == nil or "" == self.CardInfo.card_signature then
    Text = _G.LuaText.card_signature_input_empty_text
  else
    Text = self.CardInfo.card_signature
  end
  self.Personalized_Signature:SetText(Text)
  self.Time:SetText(os.date("%Y.%m.%d", self.PlayerInfo.register_time))
  if self.CardInfo.card_fashion_bond_collect_num then
    UIUtils.SafeSetText(self.Time_1, self.CardInfo.card_fashion_bond_collect_num)
  else
    UIUtils.SafeSetText(self.Time_1, "0")
  end
  if self.CardInfo.card_handbook_collect_num then
    self.Time_2:SetText(self.CardInfo.card_handbook_collect_num)
  else
    self.Time_2:SetText("0")
  end
  self.NRCText_1:SetText(self.PlayerInfo.uin)
  self.List:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.BusinessCard_HeadItem:UpdateHead(baseData, self.PlayerInfo.world_level)
  self.PanelBg_3:SetPathWithCallBack(context.nameCardPanelBackground, {
    self,
    self.SetShinePetIcon
  })
  local CardComponentTabDataList = {}
  table.insert(CardComponentTabDataList, {
    ComponentType = _G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET
  })
  table.insert(CardComponentTabDataList, {
    ComponentType = _G.ProtoEnum.RoleCardModuleType.RCMT_BADGE
  })
  self.TabList:InitGridView(CardComponentTabDataList)
  UIUtils.SafeSetVisibility(self.TabList, UE4.ESlateVisibility.HitTestInvisible)
  UIUtils.SafeSetVisibility(self.TravelButton, UE4.ESlateVisibility.HitTestInvisible)
  self:UpdateMyFavorite()
  self.ChangeNumber_1:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.MenuBtn:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
end

function UMG_ShiningMedal_C:OnDeactive()
  self:OnRemoveEventListener()
end

function UMG_ShiningMedal_C:OnAddEventListener()
  self:BindInputAction()
  self:AddButtonListener(self.LeftBtn.btnLevelUp, self.OnLeftBtnClicked)
  self:AddButtonListener(self.RightBtn.btnLevelUp, self.OnRightBtnClicked)
  self.Video:AddOnEndReached(self, self.MovieDone)
  self.Video:AddOnSeekCompleted(self, self.MovieSeekComplete)
  self:AddButtonListener(self.Play.btnLevelUp, self.OnPlayButtonClicked)
  self:AddButtonListener(self.Pause.btnLevelUp, self.OnPauseButtonClicked)
end

function UMG_ShiningMedal_C:MovieSeekComplete()
  self.Video:Pause()
  self:SetBtnVisibility(false)
end

function UMG_ShiningMedal_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.TitleText = self.titleText
  CommonPopUpData.Call = self
  CommonPopUpData.PopUpType = 2
  CommonPopUpData.ClosePanelHandler = self.OnClickCloseBtn
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_ShiningMedal_C:OnPcClose()
  self:OnClickCloseBtn()
end

function UMG_ShiningMedal_C:OnSwitchAvatarSuitComplete()
  if not self.context.bIsNameCard then
    return
  end
  self.UMG_CardImage:AddHeadWear()
  self.UMG_CardImage:SetAnimInstance()
  local AnimComponent = self.UMG_CardImage.PlayerActor:GetComponentByClass(UE4.URocoAnimComponent)
  AnimComponent:PlayAnimByName("Idle", 0, 0.1, 0, 0, -1, 0)
  self.UMG_CardImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_ShiningMedal_C:OnConstruct()
  self:SetChildViews(self.UMG_CardImage, self.PopUp, self.Video)
  self.Video:OnConstruct(self)
  self.Video.bAutoPlay = true
  self.curPage = 1
  self.totalPages = 2
end

function UMG_ShiningMedal_C:OnDestruct()
  self:OnRemoveEventListener()
  self.Video:OnDestruct()
end

function UMG_ShiningMedal_C:OnRemoveEventListener()
  self:UnBindInputAction()
  self.Video:RemoveOnEndReached(self, self.MovieDone)
end

function UMG_ShiningMedal_C:OnClickCloseBtn()
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_ShiningMedal_C:OnClickCloseBtn")
  if self.context.deselectContainer and self.context.deselectItemIndex and self.context.deselectContainer.DeselectItemByIndex then
    self.context.deselectContainer:DeselectItemByIndex(self.context.deselectItemIndex)
  end
  self:LoadAnimation(2)
end

function UMG_ShiningMedal_C:OnTick()
end

function UMG_ShiningMedal_C:SetShinePetIcon()
  local CurrentBrush = self.PanelBg_3.Brush
  CurrentBrush.DrawAs = UE4.ESlateBrushDrawType.Box
  self.PanelBg_3:SetBrush(CurrentBrush)
end

function UMG_ShiningMedal_C:UpdateMyFavorite()
  self.LovePartner_3:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  local cardComponentDataList = self:GetCardFavoritePetList()
  self.LovePartner_3:InitList(cardComponentDataList)
  for i = 0, self.LovePartner_3:GetItemCount() - 1 do
    local item = self.LovePartner_3:GetItemByIndex(i)
    if item then
      item:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    end
  end
  self.NRCButton_68:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if #cardComponentDataList > 6 then
    self.NRCButton:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    local pageNum = math.min(3, math.ceil(#cardComponentDataList / 6))
    local pageData = {}
    for i = 1, pageNum do
      table.insert(pageData, i)
    end
    self.Dot_List:InitGridView(pageData)
    self.Dot_List:SelectItemByIndex(0)
    self.Dot_List:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  else
    self.NRCButton:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Dot_List:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ShiningMedal_C:GetCardFavoritePetList()
  local cardInfoList = {}
  if not self.CardInfo or not self.CardInfo.card_collect_info then
    local temp = {}
    for i = 1, 6 do
      local cardItemData
      cardItemData = EditComponentItemData:Create(_G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET)
      cardItemData:InitEmptyInfo(_G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET, FriendEnum.CardComponentShowType.CardNormal)
      table.insert(temp, cardItemData)
    end
    return temp
  end
  local collectCardInfo = self.CardInfo.card_collect_info
  if collectCardInfo.card_module_pet_infos then
    for i, petInfo in ipairs(collectCardInfo.card_module_pet_infos) do
      local newPetInfo = table.deepCopy(petInfo)
      local itemData = EditComponentItemData:Create(_G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET)
      itemData:InitFromPetInfo(newPetInfo)
      table.insert(cardInfoList, itemData)
    end
  end
  local maxLength = 6
  local cardModuleConf = _G.DataConfigManager:GetCardModuleConf(1)
  if cardModuleConf then
    maxLength = cardModuleConf.module_num
  end
  local minIndex = 9999
  for _, v in ipairs(cardInfoList) do
    minIndex = math.min(minIndex, v:GetIndex())
  end
  local cardInfoListResult = {}
  local size = #cardInfoList
  local finalLength = math.ceil(size / 6) * 6
  if 0 == finalLength then
    finalLength = 6
  end
  for i = 1, finalLength do
    local validCardInfo
    for _, v in ipairs(cardInfoList) do
      if v:GetIndex() - minIndex == i - 1 then
        validCardInfo = v
        break
      end
    end
    local cardItemData
    if validCardInfo then
      cardItemData = validCardInfo
      cardItemData:SetCardShowType(FriendEnum.CardComponentShowType.CardNormal)
    else
      cardItemData = EditComponentItemData:Create(_G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET)
      cardItemData:InitEmptyInfo(_G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET, FriendEnum.CardComponentShowType.CardNormal)
    end
    table.insert(cardInfoListResult, cardItemData)
  end
  return cardInfoListResult
end

function UMG_ShiningMedal_C:InitShiningMedalDetail(context)
  if not context.bondId then
    return
  end
  local bondConf = _G.DataConfigManager:GetFashionBondConf(context.bondId)
  if not bondConf then
    return
  end
  if bondConf.fashion_bond_quality == _G.Enum.FashionBondQuality.FBQ_S then
    self.HandHoldingPrivilege:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self:InitVideo(bondConf)
    self.textArr = {}
    table.insert(self.textArr, bondConf.exhibit_text)
    table.insert(self.textArr, bondConf.popup_text)
    self:SwitchToPage(1)
  else
    self.Switcher_0:SetActiveWidgetIndex(0)
    self.totalPages = 1
    self.LeftBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.RightBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Pause:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Play:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ShiningMedal_C:InitVideo(bondConf)
  self.Video:OnActive()
  self:SetBtnVisibility(true)
  self.Video:Close()
  self.videoPath = bondConf.popup_image_male
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player and 2 == player.gender then
    self.videoPath = bondConf.popup_image_female
  end
  local paramTable = {
    source = self.videoPath,
    needAutoPlay = true,
    isLoop = false
  }
  self.Video:OpenMediaPanelByParamTable(paramTable)
end

function UMG_ShiningMedal_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_ShiningMedal_C:SwitchToPage(pageIndex)
  self.curPage = pageIndex
  self.LeftBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.RightBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.HandHoldingPrivilege:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if 1 == self.curPage then
    self.LeftBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HandHoldingPrivilege:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  end
  if self.curPage == self.totalPages then
    self.RightBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.Text1:SetText(self.textArr[self.curPage])
  self.Switcher_0:SetActiveWidgetIndex(self:GetPageIndexToSwitcherIndex(pageIndex))
end

function UMG_ShiningMedal_C:GetPageIndexToSwitcherIndex(pageIndex)
  if 2 == pageIndex then
    return 0
  end
  if 1 == pageIndex then
    return 2
  end
  return 0
end

function UMG_ShiningMedal_C:OnLeftBtnClicked()
  local newPage = math.clamp(self.curPage - 1, 1, self.totalPages)
  self:SwitchToPage(newPage)
  if 1 == newPage then
    self.Video:Close()
    local paramTable = {
      source = self.videoPath,
      needAutoPlay = true,
      isLoop = false
    }
    self.Video:OpenMediaPanelByParamTable(paramTable)
    self:SetBtnVisibility(true)
  end
end

function UMG_ShiningMedal_C:OnRightBtnClicked()
  local newPage = math.clamp(self.curPage + 1, 1, self.totalPages)
  self:SwitchToPage(newPage)
end

function UMG_ShiningMedal_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_MagnificentMagic")
  if mappingContext then
    mappingContext:BindAction("IA_PlayMagicVideo", self, "OnVideoPlayOrPause", UE.ETriggerEvent.Triggered)
  end
end

function UMG_ShiningMedal_C:UnBindInputAction()
  local mappingContext = self:GetInputMappingContext("IMC_MagnificentMagic")
  if mappingContext then
    mappingContext:UnBindAction("IA_PlayMagicVideo")
  end
end

function UMG_ShiningMedal_C:OnVideoPlayOrPause()
  if self.Video.MediaPlayer:IsPlaying() then
    self:OnPauseButtonClicked()
  else
    self:OnPlayButtonClicked()
  end
end

function UMG_ShiningMedal_C:MovieDone()
  self.Video:Seek(UE.UKismetMathLibrary.FromSeconds(0))
end

function UMG_ShiningMedal_C:OnPauseButtonClicked()
  self:SetBtnVisibility(false)
  self.Video:Pause()
end

function UMG_ShiningMedal_C:OnPlayButtonClicked()
  self:SetBtnVisibility(true)
  self.Video:Play()
end

function UMG_ShiningMedal_C:SetBtnVisibility(bPlay)
  if bPlay then
    self.Pause:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Play:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Pause:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Play:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

return UMG_ShiningMedal_C
