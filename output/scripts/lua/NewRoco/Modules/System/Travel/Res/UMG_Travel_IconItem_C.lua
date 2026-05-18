local PetUtils = require("NewRoco.Utils.PetUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local TravelModuleEvent = reload("NewRoco.Modules.System.Travel.TravelModuleEvent")
local UMG_Travel_IconItem_C = Base:Extend("UMG_Travel_IconItem_C")

function UMG_Travel_IconItem_C:OnConstruct()
end

function UMG_Travel_IconItem_C:OnDestruct()
end

function UMG_Travel_IconItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.LongPressTime = _G.DataConfigManager:GetGlobalConfig("long_press_lobby_btn_show").num / 750
  self.AnimEndTime = self.Loading:GetEndTime()
  if self.data.reward_item_id then
    self.isPet = false
    self:ShowItem()
  elseif self.data.gid then
    self.isPet = true
    self:ShowPet()
  end
  self.Gender:SetVisibility(self.isPet and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  if self.data.bShowLevel and self.data.level and self.txtLV then
    self.txtLV:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.txtLV:SetText(tostring(self.data.level))
  end
end

function UMG_Travel_IconItem_C:ShowItem()
  self.State:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.BlackPicture:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.BlackPicture_Pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Blackjiaobiao:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Formation:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.HeadIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.icon:SetVisibility(UE4.ESlateVisibility.Visible)
  self.BGColor:SetVisibility(UE4.ESlateVisibility.Visible)
  self.NRCSwitcher_17:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.data.isOther or self.data.isEgg then
    self.Switcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher:SetActiveWidgetIndex(1)
  end
  self:SetNumSize(self.data.reward_item_num)
  if self.data.reward_item_type == _G.Enum.GoodsType.GT_VITEM then
    local vItemsConf = _G.DataConfigManager:GetVisualItemConf(self.data.reward_item_id)
    if nil == vItemsConf then
      self:LogError("visualItemConf  id \229\188\130\229\184\184\232\175\183\230\163\128\230\159\165\233\133\141\231\189\174", self.data.reward_item_id)
      return
    end
    self:getQuality(vItemsConf.item_quality)
    self:GetItemBgTagQuality(vItemsConf.item_quality)
    self.icon:SetPath(NRCUtils:FormatConfIconPath(vItemsConf.bigIcon, _G.UIIconPath.BagItemPath))
    self.txtLV:SetText(string.format("x%d", self.data.reward_item_num))
  elseif self.data.reward_item_type == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.data.reward_item_id)
    if bagItemConf then
      self:getQuality(bagItemConf.item_quality)
      self:GetItemBgTagQuality(bagItemConf.item_quality)
      self.icon:SetPath(NRCUtils:FormatConfIconPath(bagItemConf.icon, _G.UIIconPath.BagItemPath))
    end
    self.txtLV:SetText(string.format("x%d", self.data.reward_item_num))
  end
end

function UMG_Travel_IconItem_C:SetNumSize(Count)
  local number = Count
  local numberStr = tostring(number)
  local length = string.len(numberStr)
  local Font = self.txtLV.Font
  if length > 5 then
    Font.Size = 22
    self.txtLV:SetFont(Font)
  end
end

function UMG_Travel_IconItem_C:ShowItemTips()
  _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, self.data.reward_item_id, self.data.reward_item_type, false)
end

function UMG_Travel_IconItem_C:GetItemBgTagQuality(quality)
  if 1 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_Travel_IconItem_C:getQuality(quality)
  self.Background:SetVisibility(UE4.ESlateVisibility.Visible)
  if 0 == quality then
    self.Background:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif 1 == quality then
    self.Background:SetPath(UEPath.PROP_QUALITY_1)
  elseif 2 == quality then
    self.Background:SetPath(UEPath.PROP_QUALITY_2)
  elseif 3 == quality then
    self.Background:SetPath(UEPath.PROP_QUALITY_3)
  elseif 4 == quality then
    self.Background:SetPath(UEPath.PROP_QUALITY_4)
  elseif 5 == quality then
    self.Background:SetPath(UEPath.PROP_QUALITY_5)
  end
end

function UMG_Travel_IconItem_C:ShowPet()
  self.isMask = true
  self.IsPlaySelect = false
  self:StopAllAnimations()
  self.State:SetVisibility(UE4.ESlateVisibility.Visible)
  self.BlackPicture:SetVisibility(UE4.ESlateVisibility.Visible)
  if UE.UObject.IsValid(self.BlackPicture_Pet) then
    self.BlackPicture_Pet:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  self.Blackjiaobiao:SetVisibility(UE4.ESlateVisibility.Visible)
  self.HeadIcon:SetVisibility(UE4.ESlateVisibility.Visible)
  self.icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Formation:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:PlayAnimation(self.normal)
  self.IsFormation = type(self.data.selectIndex) == "number" and 0 ~= self.data.selectIndex
  if self.IsFormation then
    self.Formation:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCText_0:SetText(self.data.selectIndex)
  else
    self.Formation:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.NRCSwitcher_17:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.txtLV:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.data.gid)
  if self.CollectCanvas then
    if petData.partner_mark and petData.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
      self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Visible)
      self.Star:SetVisibility(UE4.ESlateVisibility.Visible)
      self.Star:SetPath(PetUtils.GetPetCollectTagIcon(petData.partner_mark))
      if self.Blackjiaobiao_1 then
        self.Blackjiaobiao_1:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    else
      self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  self.HeadIcon:SetIconPathAndMaterial(petData.base_conf_id, petData.mutation_type, petData.glass_info)
  self.Gender:SetActiveWidgetIndex(petData.gender - 1)
  local baseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
  if baseConf then
    local modelConf = _G.DataConfigManager:GetModelConf(baseConf.model_conf)
    if modelConf and UE.UObject.IsValid(self.BlackPicture_Pet) then
      self.BlackPicture_Pet:SetPath(modelConf.icon)
    end
  end
  if petData.speciality_id and self.Output then
    local PetTalentConf = _G.DataConfigManager:GetPetTalentConf(petData.speciality_id)
    if PetTalentConf and 2 == PetTalentConf.type then
      if self.Output then
        self.Output:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.Output:SetPath(PetTalentConf.icon)
      end
    elseif self.Output then
      self.Output:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  elseif self.Output then
    self.Output:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.BGColor:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if 1 == self.data.isBattleTeam or self.data.isInGuard or self.data.isInHome or self.data.isInTemporarilyStoreBackpack then
    self.InTheFormationText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.State:SetActiveWidgetIndex(2)
    local iconPath = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/PetUIStatic/Frames/img_bianduizhong_png.img_bianduizhong_png'"
    self.InTheFormationText:SetText(LuaText.umg_travel_iconitem_2)
    if self.data.isInGuard then
      iconPath = "PaperSprite'/Game/NewRoco/Modules/System/Home/Raw/HomeMain/Frames/img_Plant_protectionIcon2_png.img_Plant_protectionIcon2_png'"
      self.InTheFormationText:SetText(LuaText.home_pet_check_in_suntitle)
    elseif self.data.isInHome then
      iconPath = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/PetUIStatic/Frames/img_ruzhu_png.img_ruzhu_png'"
      self.InTheFormationText:SetText(LuaText.home_pet_check_in_suntitle)
    elseif self.data.isInTemporarilyStoreBackpack then
      iconPath = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/PetUIStatic/Frames/img_InBackpack_png.img_InBackpack_png'"
      self.InTheFormationText:SetText(LuaText.travel_pet_bag_tips)
    end
    self.InFormation_1:SetPath(iconPath)
  elseif 1 == self.data.isTeam then
    self.InTheFormationText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.State:SetActiveWidgetIndex(1)
    self.InTheFormationText:SetText(LuaText.umg_travel_iconitem_2)
  elseif 1 == self.data.isTravel then
    self.InTheFormationText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.State:SetActiveWidgetIndex(0)
    self.InTheFormationText:SetText(LuaText.umg_travel_iconitem_3)
  else
    self.isMask = false
    self.BlackPicture:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.BlackPicture_Pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Blackjiaobiao:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.Blackjiaobiao_1 then
      self.Blackjiaobiao_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.State:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.InTheFormationText then
      self.InTheFormationText:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if 1 == self.data.IsTravelFinish then
    self.InTheFormationText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.InTheFormationText:SetText(LuaText.umg_travel_iconitem_4)
  end
end

function UMG_Travel_IconItem_C:getPetQuality(quality)
  if quality == _G.Enum.PetQuality.PQ_BLUE then
    self.Background:SetPath(UEPath.PROP_QUALITY_3)
  elseif quality == _G.Enum.PetQuality.PQ_PURPLE then
    self.Background:SetPath(UEPath.PROP_QUALITY_4)
  elseif quality == _G.Enum.PetQuality.PQ_ORANGE then
    self.Background:SetPath(UEPath.PROP_QUALITY_5)
  else
    self.Background:SetPath(UEPath.PROP_QUALITY_NONE)
  end
end

function UMG_Travel_IconItem_C:OnItemSelected(_bSelected)
  if not self.isPet then
    self:ShowItemTips()
    return
  end
  if self.isMask then
    return
  end
  if self.data.selectIndex == nil then
    if _bSelected and self.isPet then
      local PetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.data.gid)
      _G.NRCModeManager:DoCmd(PetUIModuleCmd.ShowChangePetConfirm, PetData)
    end
    return
  end
  if _bSelected then
    if 0 == self.data.selectIndex then
      _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_Travel_C:OnDepartBtn")
      local selectIndex = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetSelectTravelPetIndex)
      self.data.selectIndex = selectIndex
      if selectIndex > 0 then
        self.IsFormation = true
        self.Formation:SetVisibility(UE4.ESlateVisibility.Visible)
        self.NRCText_0:SetText(self.data.selectIndex)
        _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.SelectTravelPet, selectIndex, self.data.gid, self.data.baseId, self.data.level)
      else
        _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.umg_travel_iconitem_5)
      end
    else
      _G.NRCAudioManager:PlaySound2DAuto(41401005, "UMG_Travel_C:OnDepartBtn")
      self.Formation:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.IsFormation = false
      _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.SelectTravelPet, self.data.selectIndex, -1, -1, 0)
      self.data.selectIndex = 0
    end
  end
  self.Select:SetVisibility(_bSelected and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self:StopAllAnimations()
  if _bSelected then
    self:PlaySelectAnimation()
  else
    self:PlayUnSelectAnimation()
    if self.IsFormation == false then
    end
  end
end

function UMG_Travel_IconItem_C:UnSelect()
  self.Formation:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.IsFormation = false
  _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.SelectTravelPet, self.data.selectIndex, -1, -1, 0)
  self.data.selectIndex = 0
end

function UMG_Travel_IconItem_C:OnTouchStarted(MyGeometry, InTouchEvent)
  self.IsClick = true
  if not self.isPet or self.isMask then
    return UE4.UWidgetBlueprintLibrary.Handled()
  end
  self.StartPressTime = 0
  self.StartTime = 0
  _G.NRCModuleManager:DoCmd(TravelModuleCmd.OnSetSelectPetSkillTipsItem, self)
  _G.UpdateManager:Register(self)
  Base.OnTouchStarted(self, MyGeometry, InTouchEvent)
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_Travel_IconItem_C:OnTouchEnded(MyGeometry, InTouchEvent)
  Base.OnTouchEnded(self, MyGeometry, InTouchEvent)
  if not self.isPet or self.isMask then
    return UE4.UWidgetBlueprintLibrary.Handled()
  end
  self.IsClick = false
  self:StopLoading()
  _G.NRCModuleManager:DoCmd(TravelModuleCmd.OnSetSelectPetSkillTipsItem, nil)
  _G.UpdateManager:UnRegister(self)
  return UE4.UWidgetBlueprintLibrary.Handled()
end

function UMG_Travel_IconItem_C:OnMouseLeave(MouseEvent)
  self:OnStopUpdate()
end

function UMG_Travel_IconItem_C:OnStopUpdate()
  self.IsClick = false
  self.StartPressTime = 0
  self.StartTime = 0
  self:StopLoading()
  _G.NRCModuleManager:DoCmd(TravelModuleCmd.OnSetSelectPetSkillTipsItem, nil)
  _G.UpdateManager:UnRegister(self)
end

function UMG_Travel_IconItem_C:OnTick(InDeltaTime)
  if self.IsClick then
    self.StartPressTime = self.StartPressTime + InDeltaTime
  end
  if self.StartPressTime >= self.LongPressTime then
    self.StartPressTime = 0
    self.IsLongPress = true
  end
  if self.IsLongPress then
    self.StartTime = self.StartTime + InDeltaTime
    if self.IsOnClick then
      _G.NRCAudioManager:PlaySound2DAuto(1377, "UMG_EquipItem_C:Tick")
      self.IsOnClick = false
    end
    if not self.IsPlayAnim then
      self.IsPlayAnim = true
    end
  end
  if self.IsPlayAnim then
    local isFinsh = self:PlayLoading(self.StartTime)
    if isFinsh then
      self:FinshLoading()
    end
  end
end

function UMG_Travel_IconItem_C:PlayLoading(startTime)
  local endTime = 0.3
  if UE4.UKismetSystemLibrary.IsValid(self.CanvasPanel_38) then
    self.CanvasPanel_38:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local FillAmount = startTime / endTime
  self.CircleFillImage_77:SetFillAmount(FillAmount)
  return FillAmount > 1
end

function UMG_Travel_IconItem_C:StopLoading()
  self.IsPlayAnim = false
  _G.UpdateManager:UnRegister(self)
end

function UMG_Travel_IconItem_C:FinshLoading()
  if self.isPet then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1225, "UMG_Travel_IconItem_C:OnItemSelected")
    local petData = self.data.data
    local selectIndex = self.index - 1
    _G.NRCModuleManager:GetModule("TravelModule"):DispatchEvent(TravelModuleEvent.OnOpenPetSkillPanel, petData, false, selectIndex)
  end
  self:StopLoading()
end

function UMG_Travel_IconItem_C:PlaySelectAnimation()
  if self.IsPlaySelect == false then
    self:StopAllAnimations()
    self.IsPlaySelect = true
    _G.NRCModuleManager:DoCmd(TravelModuleCmd.SetTravelItemClickAble, "TravelPanel", false)
    self:PlayAnimation(self.change1)
  end
end

function UMG_Travel_IconItem_C:PlayUnSelectAnimation()
  if self.IsPlaySelect then
    self.IsPlaySelect = false
    self:PlayAnimation(self.change2)
  end
end

function UMG_Travel_IconItem_C:OnAnimationFinished(anim)
  if anim == self.change1 then
    _G.NRCModuleManager:DoCmd(TravelModuleCmd.SetTravelItemClickAble, "TravelPanel", true)
  elseif anim == self.Loading then
  end
end

function UMG_Travel_IconItem_C:OnDeactive()
end

return UMG_Travel_IconItem_C
