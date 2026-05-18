local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local UMG_DialogueText_Intimacy_C = _G.NRCPanelBase:Extend("UMG_DialogueText_Intimacy_C")

function UMG_DialogueText_Intimacy_C:OnConstruct()
  _G.NRCEventCenter:RegisterEvent("UMG_DialogueText_Intimacy_C", self, DialogueModuleEvent.DialogueEnded, self.OnDialogueEnded)
end

function UMG_DialogueText_Intimacy_C:OnActive(action)
  self.NextFlag = true
  self.FinishFlag = false
  local TitleStr = _G.DataConfigManager:GetLocalizationConf("pet_gift_dialogue_title").msg
  local DialogStr = _G.DataConfigManager:GetLocalizationConf("pet_gift_dialogue_text").msg
  self.action = nil
  self.PetName = nil
  if action then
    self.action = action
    self.PetName = action.Owner.owner.serverData.base.name
  end
  if TitleStr then
    self.NPC_Name:SetText(TitleStr)
  end
  if DialogStr and self.PetName then
    self.Dialogue:SetText(string.format(DialogStr, self.PetName))
  end
  self:PlayAnimation(self.In)
  self.BtnClose.OnClicked:Add(self, self.OnCloseClicked)
  self.BtnGift.OnClicked:Add(self, self.OnGiftClicked)
  self.BtnItem.OnClicked:Add(self, self.OnGiftIconClicked)
end

function UMG_DialogueText_Intimacy_C:OnDestruct()
  self.BtnClose.OnClicked:Remove(self, self.OnCloseClicked)
  self.BtnGift.OnClicked:Remove(self, self.OnGiftClicked)
  _G.NRCEventCenter:UnRegisterEvent(self, DialogueModuleEvent.DialogueEnded, self.OnDialogueEnded)
  _G.NRCPanelBase.OnDestruct(self)
end

function UMG_DialogueText_Intimacy_C:OnCloseClicked()
  if self.NextFlag then
    _G.NRCAudioManager:PlaySound2DAuto(40008004, "UMG_DialogueText_Intimacy_C:OnCloseClicked")
    local DialogStr = _G.DataConfigManager:GetLocalizationConf("pet_gift_name_amounts").msg
    local Have = self.action.Have
    local Need = self.action.Need
    local GiftNameConf = _G.DataConfigManager:GetBagItemConf(self.action.GiftId)
    local GiftName, GiftTexture, quality
    if GiftNameConf then
      GiftTexture = GiftNameConf.icon
      GiftName = GiftNameConf.name
      quality = GiftNameConf.item_quality
    end
    if DialogStr and Have and Need and GiftName then
      self.Dialogue:SetText(string.format(DialogStr, GiftName, Have, Need))
    end
    if 1 == quality then
      self.QualityColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
    elseif 2 == quality then
      self.QualityColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
    elseif 3 == quality then
      self.QualityColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
    elseif 4 == quality then
      self.QualityColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
    elseif 5 == quality then
      self.QualityColor:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
    end
    self:PlayAnimation(self.Press)
    self.CanvasPanel_62:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCImage:SetPath("Texture2D'/Game/NewRoco/Modules/System/Dialogue/Raw/Frames/img_Dialogue_BtnClose_png.img_Dialogue_BtnClose_png'")
    self.Icon:SetPath(GiftTexture)
    self.NextFlag = false
  else
    _G.NRCAudioManager:PlaySound2DAuto(40008006, "UMG_DialogueText_Intimacy_C:OnCloseClicked")
    if self.action and self.action.Finish then
      self.action:Finish(false, nil)
      self.action = nil
    end
    if self.Press then
      self:PlayAnimation(self.Press)
    end
    self.FinishFlag = true
    _G.NRCModuleManager:DoCmd(DialogueModuleCmd.ClosePetGiftPanel)
  end
end

function UMG_DialogueText_Intimacy_C:OnGiftClicked()
  self.BtnClose.OnClicked:Remove(self, self.OnCloseClicked)
  self.BtnGift.OnClicked:Remove(self, self.OnGiftClicked)
  self.BtnItem.OnClicked:Remove(self, self.OnGiftIconClicked)
  _G.NRCAudioManager:PlaySound2DAuto(40008005, "UMG_DialogueText_Intimacy_C:OnGiftClicked")
  if self.action then
    local GiftIDStr = tostring(self.action.GiftId)
    self.action:Finish(true, nil, GiftIDStr)
    self.action = nil
  end
  if self.Press_Gift then
    self.CanvasPanel_101:SetVisibility(UE4.ESlateVisibility.Visible)
    self:PlayAnimation(self.Press_Gift)
  end
end

function UMG_DialogueText_Intimacy_C:OnAnimationFinished(anim)
  if anim == self.Press_Gift then
    self:PlayAnimation(self.Out)
    _G.NRCModuleManager:DoCmd(DialogueModuleCmd.ClosePetGiftPanel)
  end
  if anim == self.Press and self.FinishFlag then
    self:PlayAnimation(self.Out)
  end
end

function UMG_DialogueText_Intimacy_C:OnGiftIconClicked()
  _G.NRCAudioManager:PlaySound2DAuto(40008003, "UMG_DialogueText_Intimacy_C:OnGiftClicked")
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, self.action.GiftId, Enum.GoodsType.GT_BAGITEM)
end

function UMG_DialogueText_Intimacy_C:OnDialogueEnded()
  if self.action then
    self.action:Finish(false, nil)
    self.action = nil
    self:DoClose()
  end
end

return UMG_DialogueText_Intimacy_C
