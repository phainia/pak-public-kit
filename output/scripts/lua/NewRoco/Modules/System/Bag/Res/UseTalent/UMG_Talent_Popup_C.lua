local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_Talent_Popup_C = _G.NRCPanelBase:Extend("UMG_Talent_Popup_C")
UMG_Talent_Popup_C.CloseEnum = {
  Cancel = 0,
  OK = 1,
  Change = 2,
  SuccessClose = 3
}
UMG_Talent_Popup_C.BtnEnum = {
  None = 0,
  TipsBtn = 1,
  Btn2 = 2,
  ChangeBtn = 3,
  Btn3 = 4
}

function UMG_Talent_Popup_C:OnConstruct()
  self:SetChildViews(self.PopUp4)
end

function UMG_Talent_Popup_C:OnDestruct()
end

function UMG_Talent_Popup_C:OnActive(Success, BagItemId, Param)
  self.unlock_attribute_quantity = _G.DataConfigManager:GetPetGlobalConfig("unlock_attribute_quantity").num
  if Param then
    self:SetRenderOpacity(0)
    self.param = Param
    self.BagItemId = Param.BagItem.id
    self.PetItemData = Param.PetData
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(self.BagItemId)
    if BagItemConf and BagItemConf.item_behavior[1] and BagItemConf.item_behavior[1].use_action then
      self.UseAction = BagItemConf.item_behavior[1].use_action
    end
    self.ChangeTalentType = Param.ChangeTalentType
    self.ResultTalentType = Param.ResultTalentType
    self:SetCommonPopUpInfo(self.PopUp4, BagItemConf.name, BagItemConf.icon, true)
    self:SetPetIcon()
    self.Success = Success
    if self.ChangeTalentType then
      local ChangeTalentName = _G.DataConfigManager:GetAttributeConf(self.ChangeTalentType).attribute_name
      if self.ResultTalentType then
        local ResultTalentName = _G.DataConfigManager:GetAttributeConf(self.ResultTalentType).attribute_name
        self.PopUp4:SetDescInfo(string.format(LuaText.talent_change_changing_talent_chose, self.PetItemData.name, ChangeTalentName, ResultTalentName))
        self.PopUp4:SetBtnRightEnableStateNew(true)
      elseif self.UseAction == Enum.ItemBehavior.IB_IMPROVE_TALENT then
        self.PopUp4:SetDescInfo(LuaText.talent_improve_talent_choose)
        self.PopUp4:SetBtnRightEnableStateNew(false)
      else
        self.PopUp4:SetDescInfo(LuaText.change_attribute_select_tip)
        self.PopUp4:SetBtnRightEnableStateNew(false)
      end
    elseif self.ResultTalentType then
      local ResultTalentName = _G.DataConfigManager:GetAttributeConf(self.ResultTalentType).attribute_name
      self.PopUp4:SetDescInfo(string.format(LuaText.talent_change_add_talent_chose, self.PetItemData.name, ResultTalentName))
      self.PopUp4:SetBtnRightEnableStateNew(true)
    elseif self.UseAction == Enum.ItemBehavior.IB_IMPROVE_TALENT then
      self.PopUp4:SetDescInfo(LuaText.talent_improve_talent_choose)
      self.PopUp4:SetBtnRightEnableStateNew(false)
    else
      self.PopUp4:SetDescInfo(LuaText.change_attribute_select_tip)
      self.PopUp4:SetBtnRightEnableStateNew(false)
    end
    self:SetSuccessPanel()
    self:OnAddEventListener()
    return
  end
  self.data = self.module:GetData("BagModuleData")
  if self.module.PetOpenUseAction then
    self.PopUp4:SetBtnLeftText("\229\143\150\230\182\136")
  else
    self.PopUp4:SetBtnLeftText("\230\155\180\230\141\162\231\178\190\231\129\181")
  end
  if BagItemId then
    self.BagItemId = BagItemId
  else
    self.BagItemId = self.data:GetCurSelectedItemData().id
  end
  self.PetItemData = self.data.PetTalentItem
  if not self.PetItemData then
    Log.Error("self.PetItemData\230\149\176\230\141\174\230\178\161\228\186\134\239\188\140\232\175\183\229\176\134\230\151\165\229\191\151\229\143\145\231\187\153byzyzhao")
    return
  end
  local BagItemConf = _G.DataConfigManager:GetBagItemConf(self.BagItemId)
  if BagItemConf and BagItemConf.item_behavior[1] and BagItemConf.item_behavior[1].use_action then
    self.UseAction = BagItemConf.item_behavior[1].use_action
  end
  self:SetCommonPopUpInfo(self.PopUp4, BagItemConf.name, BagItemConf.icon)
  self.CloseState = self.CloseEnum.Cancel
  self.BtnState = self.BtnEnum.None
  self:SetPetIcon()
  self:SetTalentIcons()
  self:OnAddEventListener()
  if self.data.ChangeTalentType then
    local ChangeTalentName = _G.DataConfigManager:GetAttributeConf(self.data.ChangeTalentType).attribute_name
    if self.data.ResultTalentType then
      local ResultTalentName = _G.DataConfigManager:GetAttributeConf(self.data.ResultTalentType).attribute_name
      self.PopUp4:SetDescInfo(string.format(LuaText.talent_change_changing_talent_chose, self.PetItemData.name, ChangeTalentName, ResultTalentName))
      self.PopUp4:SetBtnRightEnableStateNew(true)
    elseif self.UseAction == Enum.ItemBehavior.IB_IMPROVE_TALENT then
      self.PopUp4:SetDescInfo(LuaText.talent_improve_talent_choose)
      self.PopUp4:SetBtnRightEnableStateNew(false)
    else
      self.PopUp4:SetDescInfo(LuaText.change_attribute_select_tip)
      self.PopUp4:SetBtnRightEnableStateNew(false)
    end
  elseif self.data.ResultTalentType then
    local ResultTalentName = _G.DataConfigManager:GetAttributeConf(self.data.ResultTalentType).attribute_name
    self.PopUp4:SetDescInfo(string.format(LuaText.talent_change_add_talent_chose, self.PetItemData.name, ResultTalentName))
    self.PopUp4:SetBtnRightEnableStateNew(true)
  elseif self.UseAction == Enum.ItemBehavior.IB_IMPROVE_TALENT then
    self.PopUp4:SetDescInfo(LuaText.talent_improve_talent_choose)
    self.PopUp4:SetBtnRightEnableStateNew(false)
  else
    self.PopUp4:SetDescInfo(LuaText.change_attribute_select_tip)
    self.PopUp4:SetBtnRightEnableStateNew(false)
  end
  self.Success = Success
  self:LoadAnimation(0)
end

function UMG_Talent_Popup_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon, HideBtn)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  if HideBtn then
    CommonPopUpData.HideBtn = true
  else
    CommonPopUpData.Btn_LeftHandler = self.OnCancelOrClose
    CommonPopUpData.Btn_RightHandler = self.OnOK
  end
  CommonPopUpData.ClosePanelHandler = self.CloseBtnClick
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_Talent_Popup_C:SetSuccessPanel()
  self.ChangeBtn_5:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ChangeBtn_4:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ChangeBtn_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CanvasPanel_8:SetVisibility(UE4.ESlateVisibility.Hidden)
  local TalentCount = 0
  local ChangeTalentIndex = 0
  local attribute_info = self.PetItemData.attribute_info
  local ResultTalentName = _G.DataConfigManager:GetAttributeConf(self.ResultTalentType).attribute_name
  if self.UseAction == Enum.ItemBehavior.IB_IMPROVE_TALENT then
    self.PopUp4:SetDescInfo(string.format(LuaText.talent_improve_talent_improved, self.PetItemData.name, ResultTalentName))
  else
    self.PopUp4:SetDescInfo(string.format(LuaText.talent_change_done, self.PetItemData.name, ResultTalentName))
  end
  if 0 ~= attribute_info.hp.talent then
    TalentCount = TalentCount + 1
    self:SetTalentIconResult(TalentCount, Enum.AttributeType.AT_HPMAX, attribute_info.hp.talent)
    if self.ResultTalentType == Enum.AttributeType.AT_HPMAX then
      ChangeTalentIndex = TalentCount
    end
  end
  if 0 ~= attribute_info.attack.talent then
    TalentCount = TalentCount + 1
    self:SetTalentIconResult(TalentCount, Enum.AttributeType.AT_PHYATK, attribute_info.attack.talent)
    if self.ResultTalentType == Enum.AttributeType.AT_PHYATK then
      ChangeTalentIndex = TalentCount
    end
  end
  if 0 ~= attribute_info.special_attack.talent then
    TalentCount = TalentCount + 1
    self:SetTalentIconResult(TalentCount, Enum.AttributeType.AT_SPEATK, attribute_info.special_attack.talent)
    if self.ResultTalentType == Enum.AttributeType.AT_SPEATK then
      ChangeTalentIndex = TalentCount
    end
  end
  if 0 ~= attribute_info.defense.talent then
    TalentCount = TalentCount + 1
    self:SetTalentIconResult(TalentCount, Enum.AttributeType.AT_PHYDEF, attribute_info.defense.talent)
    if self.ResultTalentType == Enum.AttributeType.AT_PHYDEF then
      ChangeTalentIndex = TalentCount
    end
  end
  if 0 ~= attribute_info.special_defense.talent then
    TalentCount = TalentCount + 1
    self:SetTalentIconResult(TalentCount, Enum.AttributeType.AT_SPEDEF, attribute_info.special_defense.talent)
    if self.ResultTalentType == Enum.AttributeType.AT_SPEDEF then
      ChangeTalentIndex = TalentCount
    end
  end
  if 0 ~= attribute_info.speed.talent then
    TalentCount = TalentCount + 1
    self:SetTalentIconResult(TalentCount, Enum.AttributeType.AT_SPEED, attribute_info.speed.talent)
    if self.ResultTalentType == Enum.AttributeType.AT_SPEED then
      ChangeTalentIndex = TalentCount
    end
  end
  if 1 == TalentCount then
    self.CanvasPanel_5:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.CanvasPanel_9:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  if 2 == TalentCount then
    self.CanvasPanel_9:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  if 1 == ChangeTalentIndex then
    self.OwnedText_4:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("EFA012FF"))
    self.attributeIcon_4:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("EFA012FF"))
    if self.UseAction == Enum.ItemBehavior.IB_CHANGE_TALENT then
      self.Dot_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif 2 == ChangeTalentIndex then
    self.OwnedText_5:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("EFA012FF"))
    self.attributeIcon_5:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("EFA012FF"))
    if self.UseAction == Enum.ItemBehavior.IB_CHANGE_TALENT then
      self.Dot_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif 3 == ChangeTalentIndex then
    self.OwnedText_8:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("EFA012FF"))
    self.attributeIcon_8:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("EFA012FF"))
    if self.UseAction == Enum.ItemBehavior.IB_CHANGE_TALENT then
      self.Dot_3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  self:PlayAnimation(self.Use, self.Use:GetEndTime())
end

function UMG_Talent_Popup_C:SetUseSuccess()
  self.Success = true
  self.PopUp4:SetBtnLeftText("\230\159\165\231\156\139\231\178\190\231\129\181")
  self.PopUp4:SetTitleTextInfo("\228\189\191\231\148\168\230\136\144\229\138\159")
  self.ChangeBtn_5:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ChangeBtn_4:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ChangeBtn_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.PetItemData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.PetItemData.gid)
  if self.UseAction == Enum.ItemBehavior.IB_IMPROVE_TALENT then
    local AttributeConf = _G.DataConfigManager:GetAttributeConf(self.data.ChangeTalentType)
    local ResultTalentName = AttributeConf and AttributeConf.attribute_name
    if ResultTalentName then
      self.PopUp4:SetDescInfo(string.format(LuaText.talent_improve_talent_improved, self.PetItemData.name, ResultTalentName))
    end
    if self.data.ChangeTalentType then
      local PetInfoList = {}
      if self.module.PetOpenUseAction then
        PetInfoList = {
          self.PetItemData
        }
      else
        PetInfoList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
      end
      local text = string.format("+%d", (self.petlevel + 1) * self.unlock_attribute_quantity)
      for i = 1, #PetInfoList do
        if PetInfoList[i].gid == self.PetItemData.gid then
          if self.TalentAddMax1 then
            self.MaxText:SetVisibility(UE4.ESlateVisibility.Collapsed)
          end
          if self.TalentAddMax2 then
            self.MaxText_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
          end
          if self.TalentAddMax3 then
            self.MaxText_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
          end
          local TalentCount = 0
          local attribute_info = PetInfoList[i].attribute_info
          if 0 ~= attribute_info.hp.talent then
            TalentCount = TalentCount + 1
            self:SetTalentIconResult(TalentCount, Enum.AttributeType.AT_HPMAX, attribute_info.hp.talent)
          end
          if 0 ~= attribute_info.attack.talent then
            TalentCount = TalentCount + 1
            self:SetTalentIconResult(TalentCount, Enum.AttributeType.AT_PHYATK, attribute_info.attack.talent)
          end
          if 0 ~= attribute_info.special_attack.talent then
            TalentCount = TalentCount + 1
            self:SetTalentIconResult(TalentCount, Enum.AttributeType.AT_SPEATK, attribute_info.special_attack.talent)
          end
          if 0 ~= attribute_info.defense.talent then
            TalentCount = TalentCount + 1
            self:SetTalentIconResult(TalentCount, Enum.AttributeType.AT_PHYDEF, attribute_info.defense.talent)
          end
          if 0 ~= attribute_info.special_defense.talent then
            TalentCount = TalentCount + 1
            self:SetTalentIconResult(TalentCount, Enum.AttributeType.AT_SPEDEF, attribute_info.special_defense.talent)
          end
          if 0 ~= attribute_info.speed.talent then
            TalentCount = TalentCount + 1
            self:SetTalentIconResult(TalentCount, Enum.AttributeType.AT_SPEED, attribute_info.speed.talent)
          end
          break
        end
      end
    end
  elseif not self.data.ChangeTalentType then
    local PetInfoList = {}
    if self.module.PetOpenUseAction then
      PetInfoList = {
        self.PetItemData
      }
    else
      PetInfoList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
    end
    local text = string.format("+%d", (self.petlevel + 1) * self.unlock_attribute_quantity)
    for i = 1, #PetInfoList do
      if PetInfoList[i].gid == self.PetItemData.gid then
        if self.data.ResultTalentType == Enum.AttributeType.AT_HPMAX then
          text = "+" .. PetInfoList[i].attribute_info.hp.talent
        end
        if self.data.ResultTalentType == Enum.AttributeType.AT_PHYATK then
          text = "+" .. PetInfoList[i].attribute_info.attack.talent
        end
        if self.data.ResultTalentType == Enum.AttributeType.AT_SPEATK then
          text = "+" .. PetInfoList[i].attribute_info.special_attack.talent
        end
        if self.data.ResultTalentType == Enum.AttributeType.AT_PHYDEF then
          text = "+" .. PetInfoList[i].attribute_info.defense.talent
        end
        if self.data.ResultTalentType == Enum.AttributeType.AT_SPEDEF then
          text = "+" .. PetInfoList[i].attribute_info.special_defense.talent
        end
        if self.data.ResultTalentType == Enum.AttributeType.AT_SPEED then
          text = "+" .. PetInfoList[i].attribute_info.speed.talent
        end
      end
    end
    if 2 == self.data.ChangeTalentIndex then
      self.CanvasPanel_9:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.OwnedText_5:SetText(text)
    end
    if 3 == self.data.ChangeTalentIndex then
      self.OwnedText_8:SetText(text)
    end
    local attrConf = _G.DataConfigManager:GetAttributeConf(self.data.ResultTalentType)
    if attrConf then
      local ResultTalentName = attrConf.attribute_name
      self.PopUp4:SetDescInfo(string.format(LuaText.talent_change_done, self.PetItemData.name, ResultTalentName))
    end
  else
    local attrConf = _G.DataConfigManager:GetAttributeConf(self.data.ResultTalentType)
    if attrConf then
      local ResultTalentName = attrConf.attribute_name
      self.PopUp4:SetDescInfo(string.format(LuaText.talent_change_done, self.PetItemData.name, ResultTalentName))
    end
    if 1 == self.TalentCount then
      self.CanvasPanel_5:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.CanvasPanel_9:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if 2 == self.TalentCount then
      self.CanvasPanel_9:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if 1 == self.data.ChangeTalentIndex then
    if self.UseAction == Enum.ItemBehavior.IB_IMPROVE_TALENT then
      self.OwnedText_4:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("EFA012FF"))
    else
      self.Dot_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.attributeIcon_4:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("EFA012FF"))
    end
  elseif 2 == self.data.ChangeTalentIndex then
    if self.UseAction == Enum.ItemBehavior.IB_IMPROVE_TALENT then
      self.OwnedText_5:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("EFA012FF"))
    else
      self.Dot_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.attributeIcon_5:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("EFA012FF"))
    end
  elseif 3 == self.data.ChangeTalentIndex then
    if self.UseAction == Enum.ItemBehavior.IB_IMPROVE_TALENT then
      self.OwnedText_8:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("EFA012FF"))
    else
      self.Dot_3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.attributeIcon_8:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("EFA012FF"))
    end
  end
  self:PlayAnimation(self.Use)
end

function UMG_Talent_Popup_C:SetTalentIcons()
  if self.UseAction == Enum.ItemBehavior.IB_IMPROVE_TALENT then
    self.ChangeBtnIcon_2:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_promote_png.img_promote_png'")
    self.ChangeBtnIcon_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_promote_png.img_promote_png'")
    self.ChangeBtnIcon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_promote_png.img_promote_png'")
    self.ChangeBtnIcon_4:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_promote_png.img_promote_png'")
    self.ChangeBtnIcon_5:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_promote_png.img_promote_png'")
    self.ChangeBtnIcon_3:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_promote_png.img_promote_png'")
    local TalentCount = 0
    local attribute_info = self.PetItemData.attribute_info
    if 0 ~= attribute_info.hp.talent then
      TalentCount = TalentCount + 1
      self:SetTalentIcon1(TalentCount, Enum.AttributeType.AT_HPMAX, attribute_info.hp.talent, attribute_info.hp.talent_add_value)
    end
    if 0 ~= attribute_info.attack.talent then
      TalentCount = TalentCount + 1
      self:SetTalentIcon1(TalentCount, Enum.AttributeType.AT_PHYATK, attribute_info.attack.talent, attribute_info.attack.talent_add_value)
    end
    if 0 ~= attribute_info.special_attack.talent then
      TalentCount = TalentCount + 1
      self:SetTalentIcon1(TalentCount, Enum.AttributeType.AT_SPEATK, attribute_info.special_attack.talent, attribute_info.special_attack.talent_add_value)
    end
    if 0 ~= attribute_info.defense.talent then
      TalentCount = TalentCount + 1
      self:SetTalentIcon1(TalentCount, Enum.AttributeType.AT_PHYDEF, attribute_info.defense.talent, attribute_info.defense.talent_add_value)
    end
    if 0 ~= attribute_info.special_defense.talent then
      TalentCount = TalentCount + 1
      self:SetTalentIcon1(TalentCount, Enum.AttributeType.AT_SPEDEF, attribute_info.special_defense.talent, attribute_info.special_defense.talent_add_value)
    end
    if 0 ~= attribute_info.speed.talent then
      TalentCount = TalentCount + 1
      self:SetTalentIcon1(TalentCount, Enum.AttributeType.AT_SPEED, attribute_info.speed.talent, attribute_info.speed.talent_add_value)
    end
    if 2 == TalentCount then
      self.TalentCanvas3:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.CanvasPanel_9:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if 1 == TalentCount then
      self.TalentCanvas3:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.TalentCanvas2:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.CanvasPanel_5:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.CanvasPanel_9:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.attributeIcon_7:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("EFA012FF"))
    self.attributeIcon_3:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("EFA012FF"))
    self.attributeIcon_1:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("EFA012FF"))
    self.OwnedText_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("62605EFF"))
    self.OwnedText_3:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("62605EFF"))
    self.OwnedText_7:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("62605EFF"))
    local TalentCount = 0
    local attribute_info = self.PetItemData.attribute_info
    local talentInfo = {}
    if 0 ~= attribute_info.hp.talent then
      table.insert(talentInfo, {
        attrInfo = attribute_info.hp,
        type = Enum.AttributeType.AT_HPMAX
      })
    end
    if 0 ~= attribute_info.attack.talent then
      table.insert(talentInfo, {
        attrInfo = attribute_info.attack,
        type = Enum.AttributeType.AT_PHYATK
      })
    end
    if 0 ~= attribute_info.special_attack.talent then
      table.insert(talentInfo, {
        attrInfo = attribute_info.special_attack,
        type = Enum.AttributeType.AT_SPEATK
      })
    end
    if 0 ~= attribute_info.defense.talent then
      table.insert(talentInfo, {
        attrInfo = attribute_info.defense,
        type = Enum.AttributeType.AT_PHYDEF
      })
    end
    if 0 ~= attribute_info.special_defense.talent then
      table.insert(talentInfo, {
        attrInfo = attribute_info.special_defense,
        type = Enum.AttributeType.AT_SPEDEF
      })
    end
    if 0 ~= attribute_info.speed.talent then
      table.insert(talentInfo, {
        attrInfo = attribute_info.speed,
        type = Enum.AttributeType.AT_SPEED
      })
    end
    local resultTalentInfo
    for i = 1, #talentInfo do
      if talentInfo[i].type == self.data.ResultTalentType then
        resultTalentInfo = talentInfo[i]
        table.remove(talentInfo, i)
        break
      end
    end
    if resultTalentInfo then
      table.insert(talentInfo, self.data.ChangeTalentIndex, resultTalentInfo)
    end
    for i = 1, #talentInfo do
      TalentCount = TalentCount + 1
      self:SetTalentIcon(TalentCount, talentInfo[i].type, talentInfo[i].attrInfo.talent)
    end
    self.CanvasPanel_6:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ChangeBtn_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ChangeBtnIcon_2:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Reset_png.img_Reset_png'")
    self.ChangeBtnIcon_3:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Reset_png.img_Reset_png'")
    self.ChangeBtnIcon_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Reset_png.img_Reset_png'")
    self.ChangeBtnIcon_4:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Reset_png.img_Reset_png'")
    if 1 == TalentCount then
      self.CanvasPanel_6:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.ChangeBtn_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.attributeIcon_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
      local vP = UE4.FVector2D(65, 8)
      self.OwnedText_2.Slot:SetPosition(vP)
      self.OwnedText_2:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("7e807fff"))
      self.OwnedText_2:SetText("-")
      self.ChangeBtnIcon_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_suo_png.img_suo_png'")
      self.ChangeBtnIcon_4:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_suo_png.img_suo_png'")
    elseif 2 == TalentCount then
      self.attributeIcon_6:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.OwnedText_6:SetText("-")
      local vP = UE4.FVector2D(65, 8)
      self.OwnedText_6.Slot:SetPosition(vP)
      self.OwnedText_6:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("7e807fff"))
      self.ChangeBtnIcon_2:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_suo_png.img_suo_png'")
      self.ChangeBtnIcon_3:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_suo_png.img_suo_png'")
    end
    self.TalentCount = TalentCount
    if self.data.ChangeTalentIndex and self.data.ResultTalentType then
      local iconPath = self:GetIconPath(self.data.ResultTalentType)
      if 1 == self.data.ChangeTalentIndex then
        self.ChangeBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.ChangeBtn_5:SetVisibility(UE4.ESlateVisibility.Visible)
        self.attributeIcon_1:SetPath(iconPath)
        self.attributeIcon_4:SetPath(iconPath)
        local text = string.format("+%d", (self.petlevel + 1) * self.unlock_attribute_quantity)
        if self.data.ChangeTalent and self.data.ChangeTalent > 0 then
          text = "+" .. self.data.ChangeTalent
        end
        self.OwnedText_1:SetText(text)
        self.OwnedText_4:SetText(text)
        self.Transitional:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.TransitionalImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      if 2 == self.data.ChangeTalentIndex then
        self.ChangeBtn_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.ChangeBtn_4:SetVisibility(UE4.ESlateVisibility.Visible)
        self.attributeIcon_3:SetPath(iconPath)
        self.attributeIcon_5:SetPath(iconPath)
        local text = string.format("+%d", (self.petlevel + 1) * self.unlock_attribute_quantity)
        if self.data.ChangeTalent and self.data.ChangeTalent > 0 then
          text = "+" .. self.data.ChangeTalent
        else
          self.ChangeBtnIcon_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Reset_png.img_Reset_png'")
          self.ChangeBtnIcon_4:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Reset_png.img_Reset_png'")
        end
        self.OwnedText_3:SetText(text)
        self.OwnedText_5:SetText(text)
        self.CanvasPanel_4:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.TransitionalImage_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      if 3 == self.data.ChangeTalentIndex then
        self.ChangeBtn_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.ChangeBtn_3:SetVisibility(UE4.ESlateVisibility.Visible)
        self.attributeIcon_7:SetPath(iconPath)
        self.attributeIcon_8:SetPath(iconPath)
        local text = string.format("+%d", (self.petlevel + 1) * self.unlock_attribute_quantity)
        if self.data.ChangeTalent and self.data.ChangeTalent > 0 then
          text = "+" .. self.data.ChangeTalent
        else
          self.ChangeBtnIcon_2:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Reset_png.img_Reset_png'")
          self.ChangeBtnIcon_3:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Reset_png.img_Reset_png'")
        end
        self.OwnedText_7:SetText(text)
        self.OwnedText_8:SetText(text)
        self.CanvasPanel_8:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.TransitionalImage_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  end
end

function UMG_Talent_Popup_C:SetTalentIcon(TalentCount, attributeCfg, num)
  local icon = self.attributeIcon
  local icon1 = self.attributeIcon_4
  local text = self.OwnedText
  local text1 = self.OwnedText_4
  if 1 == TalentCount then
    icon = self.attributeIcon
    icon1 = self.attributeIcon_4
    text = self.OwnedText
    text1 = self.OwnedText_4
    self.Talent1 = num
    self.TalentType1 = attributeCfg
  elseif 2 == TalentCount then
    icon = self.attributeIcon_2
    icon1 = self.attributeIcon_5
    text = self.OwnedText_2
    text1 = self.OwnedText_5
    self.Talent2 = num
    self.TalentType2 = attributeCfg
  elseif 3 == TalentCount then
    icon = self.attributeIcon_6
    icon1 = self.attributeIcon_8
    text = self.OwnedText_6
    text1 = self.OwnedText_8
    self.Talent3 = num
    self.TalentType3 = attributeCfg
  else
    return
  end
  text:SetText("+" .. num)
  text1:SetText("+" .. num)
  text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("62605EFF"))
  icon:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("1E1F21FF"))
  if attributeCfg == Enum.AttributeType.AT_HPMAX then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Hp_png.img_Hp_png'")
    icon1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Hp_png.img_Hp_png'")
  elseif attributeCfg == Enum.AttributeType.AT_PHYATK then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Atk_png.img_Atk_png'")
    icon1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Atk_png.img_Atk_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEATK then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpAtk_png.img_SpAtk_png'")
    icon1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpAtk_png.img_SpAtk_png'")
  elseif attributeCfg == Enum.AttributeType.AT_PHYDEF then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Def_png.img_Def_png'")
    icon1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Def_png.img_Def_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEDEF then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpDef_png.img_SpDef_png'")
    icon1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpDef_png.img_SpDef_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEED then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Speed_png.img_Speed_png'")
    icon1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Speed_png.img_Speed_png'")
  end
end

function UMG_Talent_Popup_C:SetTalentIcon1(TalentCount, attributeCfg, num, addNum)
  local icon = self.attributeIcon
  local text = self.OwnedText
  local icon1 = self.attributeIcon_4
  local IsMax = false
  local Btn = self.ChangeBtn
  local MaxText = self.MaxText
  local BagItemConf = _G.DataConfigManager:GetBagItemConf(self.BagItemId)
  local AddRatio = BagItemConf.item_behavior[1].ratio[1]
  local deltaValue = addNum + AddRatio
  if addNum >= 10 then
    IsMax = true
  end
  if 1 == TalentCount then
    icon = self.attributeIcon
    text = self.OwnedText
    self.Talent1 = num
    self.TalentType1 = attributeCfg
    self.TalentAdd1 = (self.petlevel + 1) * deltaValue
    self.TalentAddMax1 = IsMax
  elseif 2 == TalentCount then
    icon = self.attributeIcon_2
    text = self.OwnedText_2
    Btn = self.ChangeBtn_1
    MaxText = self.MaxText_1
    icon1 = self.attributeIcon_5
    self.Talent2 = num
    self.TalentType2 = attributeCfg
    self.TalentAdd2 = (self.petlevel + 1) * deltaValue
    self.TalentAddMax2 = IsMax
  elseif 3 == TalentCount then
    icon = self.attributeIcon_6
    text = self.OwnedText_6
    Btn = self.ChangeBtn_2
    MaxText = self.MaxText_2
    icon1 = self.attributeIcon_8
    self.Talent3 = num
    self.TalentType3 = attributeCfg
    self.TalentAdd3 = (self.petlevel + 1) * deltaValue
    self.TalentAddMax3 = IsMax
  else
    return
  end
  if IsMax then
    Btn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    MaxText:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    Btn:SetVisibility(UE4.ESlateVisibility.Visible)
    MaxText:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("1E1F21FF"))
  icon:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("62605EFF"))
  text:SetText("+" .. num)
  if attributeCfg == Enum.AttributeType.AT_HPMAX then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Hp_png.img_Hp_png'")
    icon1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Hp_png.img_Hp_png'")
  elseif attributeCfg == Enum.AttributeType.AT_PHYATK then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Atk_png.img_Atk_png'")
    icon1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Atk_png.img_Atk_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEATK then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpAtk_png.img_SpAtk_png'")
    icon1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpAtk_png.img_SpAtk_png'")
  elseif attributeCfg == Enum.AttributeType.AT_PHYDEF then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Def_png.img_Def_png'")
    icon1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Def_png.img_Def_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEDEF then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpDef_png.img_SpDef_png'")
    icon1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpDef_png.img_SpDef_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEED then
    icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Speed_png.img_Speed_png'")
    icon1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Speed_png.img_Speed_png'")
  end
end

function UMG_Talent_Popup_C:SetTalentIconResult(TalentCount, attributeCfg, num)
  local icon1 = self.attributeIcon_4
  local text1 = self.OwnedText_4
  if 1 == TalentCount then
    icon1 = self.attributeIcon_4
    text1 = self.OwnedText_4
  elseif 2 == TalentCount then
    icon1 = self.attributeIcon_5
    text1 = self.OwnedText_5
  elseif 3 == TalentCount then
    icon1 = self.attributeIcon_8
    text1 = self.OwnedText_8
  else
    return
  end
  text1:SetText("+" .. num)
  if attributeCfg == Enum.AttributeType.AT_HPMAX then
    icon1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Hp_png.img_Hp_png'")
  elseif attributeCfg == Enum.AttributeType.AT_PHYATK then
    icon1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Atk_png.img_Atk_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEATK then
    icon1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpAtk_png.img_SpAtk_png'")
  elseif attributeCfg == Enum.AttributeType.AT_PHYDEF then
    icon1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Def_png.img_Def_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEDEF then
    icon1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpDef_png.img_SpDef_png'")
  elseif attributeCfg == Enum.AttributeType.AT_SPEED then
    icon1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Speed_png.img_Speed_png'")
  end
end

function UMG_Talent_Popup_C:SetPetIcon()
  self.NumText:SetText(self.PetItemData.level)
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.PetItemData.base_conf_id)
  if petBaseConf then
    local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    if modelConf then
      self.PetHeadIcon:SetIconPathAndMaterial(self.PetItemData.base_conf_id, self.PetItemData.mutation_type, self.PetItemData.glass_info)
    end
  end
  local petlevel = PetUtils.GetBreakThroughStarsList(self.PetItemData)
  self.petlevel = 0
  for i = 1, #petlevel do
    if 1 == petlevel[i].IsShow then
      self.petlevel = self.petlevel + 1
    end
  end
  local petlevelStar = PetUtils.GetPetStarsListByPetGID(self.PetItemData.gid)
  self.StarList:InitGridView(petlevelStar)
end

function UMG_Talent_Popup_C:OnDeactive()
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnPlayerDataUpdate)
end

function UMG_Talent_Popup_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(2) then
    if self.param then
      self:DoClose()
      return
    end
    if self.CloseState == self.CloseEnum.Cancel then
      self.data.ChangeTalentIndex = nil
      self.data.ChangeTalent = nil
      self.data.ChangeTalentType = nil
      self.data.ResultTalentType = nil
      _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenOrCloseCharacterPanelToList, self.data.CharacterPanelEnum.TalentPopup, false)
    elseif self.CloseState == self.CloseEnum.Change then
      _G.NRCModeManager:DoCmd(_G.BagModuleCmd.OpenOrCloseCharacterPanelToList, self.data.CharacterPanelEnum.TalentChange, true)
    elseif self.CloseState == self.CloseEnum.SuccessClose then
      self.data.PetTalentItem = nil
      self.data.ChangeTalentIndex = nil
      self.data.ChangeTalent = nil
      self.data.ChangeTalentType = nil
      self.data.ResultTalentType = nil
      self:DoClose()
    end
  elseif Animation == self:GetAnimByIndex(0) then
    if self.Success then
      self:SetUseSuccess()
    end
  elseif Animation == self.Use and self.Success then
    self:SetRenderOpacity(1)
  end
end

function UMG_Talent_Popup_C:OnAddEventListener()
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnPlayerDataUpdate)
  self:AddButtonListener(self.Tipsbtn, self.OpenTips)
  self:AddButtonListener(self.ChangeBtn, self.ChangeBtnClick)
  self:AddButtonListener(self.ChangeBtn_1, self.ChangeBtnClick1)
  self:AddButtonListener(self.ChangeBtn_2, self.ChangeBtnClick2)
  self:AddButtonListener(self.ChangeBtn_5, self.ChangeBtnClick)
  self:AddButtonListener(self.ChangeBtn_4, self.ChangeBtnClick1)
  self:AddButtonListener(self.ChangeBtn_3, self.ChangeBtnClick2)
end

function UMG_Talent_Popup_C:OnPlayerDataUpdate()
  if self.PetItemData then
    self.PetItemData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.PetItemData.gid)
  end
end

function UMG_Talent_Popup_C:OnCancelOrClose()
  if self.BtnState ~= self.BtnEnum.None then
    return
  end
  self.BtnState = self.BtnEnum.Btn2
  self:BtnClick()
end

function UMG_Talent_Popup_C:OnOK()
  if self.BtnState ~= self.BtnEnum.None then
    return
  end
  self.BtnState = self.BtnEnum.Btn3
  self:BtnClick()
end

function UMG_Talent_Popup_C:ChangeBtnClick()
  self:SetChangeIndex(1)
  self.data.ChangeTalent = self.Talent1
  self.data.ChangeTalentType = self.TalentType1
  if self.BtnState ~= self.BtnEnum.None then
    return
  end
  self.BtnState = self.BtnEnum.ChangeBtn
  self:BtnClick()
end

function UMG_Talent_Popup_C:ChangeBtnClick1()
  self:SetChangeIndex(2)
  self.data.ChangeTalent = self.Talent2
  self.data.ChangeTalentType = self.TalentType2
  if self.BtnState ~= self.BtnEnum.None then
    return
  end
  self.BtnState = self.BtnEnum.ChangeBtn
  self:BtnClick()
end

function UMG_Talent_Popup_C:ChangeBtnClick2()
  self:SetChangeIndex(3)
  self.data.ChangeTalent = self.Talent3
  self.data.ChangeTalentType = self.TalentType3
  if self.BtnState ~= self.BtnEnum.None then
    return
  end
  self.BtnState = self.BtnEnum.ChangeBtn
  self:BtnClick()
end

function UMG_Talent_Popup_C:SetChangeIndex(index)
  self.data.ChangeTalentIndex = index
end

function UMG_Talent_Popup_C:OpenTips()
  if self.BtnState ~= self.BtnEnum.None then
    return
  end
  self.BtnState = self.BtnEnum.TipsBtn
  self:BtnClick()
end

function UMG_Talent_Popup_C:ShowAddNum()
  self:ResetBtnState()
  self.Transitional:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CanvasPanel_4:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CanvasPanel_8:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TransitionalImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TransitionalImage_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TransitionalImage_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local ResultTalentName = _G.DataConfigManager:GetAttributeConf(self.TalentType1).attribute_name
  if 1 == self.data.ChangeTalentIndex then
    self.Transitional:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TransitionalImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ChangeBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local iconPath = self:GetIconPath(self.TalentType1)
    self.attributeIcon_1:SetPath(iconPath)
    self.OwnedText_1:SetText("+" .. self.TalentAdd1)
  elseif 2 == self.data.ChangeTalentIndex then
    self.CanvasPanel_4:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TransitionalImage_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ChangeBtn_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local iconPath = self:GetIconPath(self.TalentType2)
    self.attributeIcon_3:SetPath(iconPath)
    self.OwnedText_3:SetText("+" .. self.TalentAdd2)
    ResultTalentName = _G.DataConfigManager:GetAttributeConf(self.TalentType2).attribute_name
  elseif 3 == self.data.ChangeTalentIndex then
    self.CanvasPanel_8:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TransitionalImage_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ChangeBtn_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local iconPath = self:GetIconPath(self.TalentType3)
    self.attributeIcon_7:SetPath(iconPath)
    self.OwnedText_7:SetText("+" .. self.TalentAdd3)
    ResultTalentName = _G.DataConfigManager:GetAttributeConf(self.TalentType3).attribute_name
  end
  self.PopUp4:SetDescInfo(string.format(LuaText.talent_improve_talent_chose, ResultTalentName))
  self.PopUp4:SetBtnRightEnableStateNew(true)
end

function UMG_Talent_Popup_C:ResetBtnState()
  if self.TalentAddMax1 then
    self.ChangeBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.MaxText:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.ChangeBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    self.MaxText:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.TalentAddMax2 then
    self.ChangeBtn_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.MaxText_1:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.ChangeBtn_1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.MaxText_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.TalentAddMax3 then
    self.ChangeBtn_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.MaxText_2:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.ChangeBtn_2:SetVisibility(UE4.ESlateVisibility.Visible)
    self.MaxText_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Talent_Popup_C:GetIconPath(Type)
  local iconPath = "PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Hp_png.img_Hp_png'"
  if Type == Enum.AttributeType.AT_HPMAX then
    iconPath = "PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Hp_png.img_Hp_png'"
  elseif Type == Enum.AttributeType.AT_PHYATK then
    iconPath = "PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Atk_png.img_Atk_png'"
  elseif Type == Enum.AttributeType.AT_SPEATK then
    iconPath = "PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpAtk_png.img_SpAtk_png'"
  elseif Type == Enum.AttributeType.AT_PHYDEF then
    iconPath = "PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Def_png.img_Def_png'"
  elseif Type == Enum.AttributeType.AT_SPEDEF then
    iconPath = "PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpDef_png.img_SpDef_png'"
  elseif Type == Enum.AttributeType.AT_SPEED then
    iconPath = "PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Speed_png.img_Speed_png'"
  end
  return iconPath
end

function UMG_Talent_Popup_C:CloseBtnClick()
  if self.param then
    self:LoadAnimation(2)
    return
  end
  if self.BtnState ~= self.BtnEnum.None then
    self.PopUp4:SetLock(false)
    return
  end
  if self.Success then
    self.BtnState = self.BtnEnum.Btn3
  else
    self.BtnState = self.BtnEnum.Btn2
  end
  self:BtnClick()
end

function UMG_Talent_Popup_C:BtnClick()
  if self.BtnState == self.BtnEnum.TipsBtn then
    _G.NRCModeManager:DoCmd(PetUIModuleCmd.ShowChangePetConfirm, self.PetItemData)
  elseif self.BtnState == self.BtnEnum.Btn2 then
    if self.Success then
      self.data.PetTalentItem = nil
      self.data.ChangeTalentIndex = nil
      self.data.ChangeTalent = nil
      self.data.ChangeTalentType = nil
      self.data.ResultTalentType = nil
      if self.module.IsPetInfoMainToPanel then
        local openPetData, index, bIsRevertMainPanel = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.GetOpenPanelPetData)
        if not openPetData then
          bIsRevertMainPanel = true
        end
        _G.NRCModuleManager:DoCmd(PetUIModuleCmd.EnablePanelPetMain)
        local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.PetItemData.gid)
        _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetOpenPanelPetData, petData, 1, bIsRevertMainPanel)
        _G.NRCModuleManager:DoCmd(PetUIModuleCmd.RefreshPetRightPanel, true)
        _G.NRCModuleManager:DoCmd(BagModuleCmd.CloseBagMainPanel)
      else
        local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.PetItemData.gid)
        _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetIsBagToOpenPanel)
        _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetOpenPanelPetData, petData, 1, false)
        NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPanelPetMain, {
          subPanelIndex = 4,
          callback = self.OnUMGLoadFinished
        })
        self:DoClose()
      end
    else
      _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_Bag_BXTips_C:OnClose")
      self.CloseState = self.CloseEnum.Cancel
      self:LoadAnimation(2)
    end
  elseif self.BtnState == self.BtnEnum.ChangeBtn then
    if self.UseAction == Enum.ItemBehavior.IB_IMPROVE_TALENT then
      self:ShowAddNum()
    else
      self.CloseState = self.CloseEnum.Change
      self:LoadAnimation(2)
    end
  elseif self.BtnState == self.BtnEnum.Btn3 then
    if self.Success then
      self:OnClose()
    else
      _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Bag_BXTips_C:OnClose")
      if self.UseAction == Enum.ItemBehavior.IB_IMPROVE_TALENT then
        if not self.data.ChangeTalentIndex then
          local tipsStr = LuaText.enhance_attribute_select_tip
          _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tipsStr)
        else
          self.module:ADDPetTalentSuccess()
        end
      elseif not self.data.ChangeTalentIndex or not self.data.ResultTalentType then
        local tipsStr = LuaText.change_attribute_select_tip
        _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tipsStr)
      else
        self.module:SetChangePetGid(self.PetItemData.gid)
        self.module:ChangePetTalentSuccess()
      end
    end
  end
  self:DelaySeconds(0.4, function()
    self.BtnState = self.BtnEnum.None
  end)
end

function UMG_Talent_Popup_C:SecondaryConfirmation()
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local dialogContext = DialogContext()
  local Text = _G.DataConfigManager:GetLocalizationConf("key_using_tips").msg
  dialogContext:SetContent(Text):SetMode(DialogContext.Mode.OK_CANCEL):SetButtonText(LuaText.umg_dialog_2, LuaText.umg_dialog_1):SetCloseOnCancel(true):SetCallback(self, self.OpenSecondaryConfirmation)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, dialogContext)
end

function UMG_Talent_Popup_C:OpenSecondaryConfirmation(_ok)
  if _ok then
    self.module:SetChangePetGid(self.PetItemData.gid)
    self.module:ChangePetTalentSuccess()
  end
end

function UMG_Talent_Popup_C:OnClose()
  if self.Success then
    self.CloseState = self.CloseEnum.SuccessClose
    self:LoadAnimation(2)
  end
end

return UMG_Talent_Popup_C
