local UMG_VideoSharing_C = _G.NRCViewBase:Extend("UMG_VideoSharing_C")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local PetUtils = require("NewRoco.Utils.PetUtils")

function UMG_VideoSharing_C:OnConstruct()
  self.uiItem = {}
  self.uiItem.genderIcons = {
    self.NRCImage_18,
    self.NRCImage_17
  }
  self._refActorIsolateWorld = nil
  self:OnAddEventListener()
end

function UMG_VideoSharing_C:Destruct()
  self:RemoveButtonListener(self.PlayBtn, self.OnPlayVideoClick)
end

function UMG_VideoSharing_C:OnAddEventListener()
  self:AddButtonListener(self.PlayBtn, self.OnPlayVideoClick)
end

function UMG_VideoSharing_C:Show(petData)
  self.petData = petData
  self:ShowPetInfo()
  self:ShowPlayerInfo()
  self:PlayAnimation(self.Stamp_in, 0)
  self:PauseAnimation(self.Stamp_in)
end

function UMG_VideoSharing_C:ShowPetInfo()
  self.PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.petData.base_conf_id)
  local handbookInfo = _G.DataModelMgr.PlayerDataModel:GetHandbookInfoByPetBaseId(self.petData.base_conf_id)
  if handbookInfo then
    local handbookCfg = _G.DataConfigManager:GetPetHandbook(handbookInfo.handbook_id)
    local petName = _G.DataConfigManager:GetPetHandbook(handbookInfo.handbook_id).name
    self.Name_1:SetText(petName)
    self.DepartmentName:SetText(handbookCfg.type_desc)
    self.Describe:SetText(self.PetBaseConf.description)
  else
    Log.Error("UMG_VideoSharing_C:ShowPetInfo \229\155\190\233\137\180\230\178\161\230\156\137\233\133\141\231\189\174\232\175\165\231\178\190\231\129\181\239\188\129\239\188\129\239\188\129")
  end
  if self.PetBaseConf.form == nil or self.PetBaseConf.form == "" then
    self.Name_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Name_2:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  self.Name_2:SetText(self.PetBaseConf.form)
  self:updatePetGender(self.petData.gender)
  self:ShowPetType()
  self:ShowWeightAndStature()
  self:ShowPetImage()
  self:ShowPetFindInfo()
end

function UMG_VideoSharing_C:ShowPlayerInfo()
  local playerInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo().brief_info
  self.Grade:SetText(playerInfo.name)
  self.Grade_1:SetText("UID:" .. playerInfo.uin)
  local cardInfo = playerInfo.additional_data.card_brief_info
  if cardInfo then
    local cardIconConf = _G.DataConfigManager:GetCardIconConf(cardInfo.card_icon_selected)
    if cardIconConf then
      local avatarPath = cardIconConf.icon_resource_path
      avatarPath = string.format("%s%s.%s'", "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/HeadIcon/", avatarPath, avatarPath)
      self.HeadPortrait:SetPath(avatarPath)
    end
  end
  self.Name:SetText(playerInfo.name)
  self.Amount:SetText(tostring(self.petData.gid))
  self:ShowCardInfo()
end

function UMG_VideoSharing_C:updatePetGender(_gender)
  for gender, genderIcon in ipairs(self.uiItem.genderIcons) do
    if _gender == gender then
      genderIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      genderIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_VideoSharing_C:ShowPetType()
  local unit_type = _G.DataConfigManager:GetPetbaseConf(self.petData.base_conf_id).unit_type
  self.Attr:InitGridView(unit_type)
end

function UMG_VideoSharing_C:ShowWeightAndStature()
  self.QuestionMark_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.QuestionMark_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.petData.weight then
    self.Weight_1:SetText(string.format(LuaText.umg_handbookcontent_2, self.petData.weight * 0.001))
  end
  if self.petData.height then
    self.Stature_1:SetText(string.format(LuaText.umg_handbookcontent_3, self.petData.height * 0.01))
  end
end

function UMG_VideoSharing_C:ShowCardInfo()
  local playerInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerInfo().brief_info
  local cardInfo = playerInfo.additional_data.card_brief_info
  if cardInfo and cardInfo.card_label_first_selected and cardInfo.card_label_last_selected then
    local cardLabelFirstConf = _G.DataConfigManager:GetCardLabelConf(cardInfo.card_label_first_selected)
    local cardLabelLastConf = _G.DataConfigManager:GetCardLabelConf(cardInfo.card_label_last_selected)
    if cardLabelFirstConf and cardLabelLastConf then
      self.BusinessCard_Label:SetLabelText(string.format("%s%s", cardLabelFirstConf.label_text, cardLabelLastConf.label_text))
    end
  end
end

function UMG_VideoSharing_C:ShowPetImage()
  local _scale = self.PetBaseConf.res_ui_percentage and self.PetBaseConf.res_ui_percentage > 0 and self.PetBaseConf.res_ui_percentage or 1
  local NewUILocation = UE4.FVector2D(0, 0)
  local _offsetConf
  if self.PetBaseConf.res_offset and next(self.PetBaseConf.res_offset) then
    _offsetConf = self.PetBaseConf.res_offset
    _offsetConf = UE4.FVector2D(_offsetConf[1] or 0, _offsetConf[2] or 0)
  else
    _offsetConf = UE4.FVector2D(0, 0)
  end
  NewUILocation.X = NewUILocation.X + _offsetConf.X
  NewUILocation.Y = NewUILocation.Y + _offsetConf.Y
  self.Icon_2.Slot:SetPosition(NewUILocation)
  if 1 == self.PetBaseConf.res_horizontal_flip_data then
    self.Icon_2:SetRenderScale(UE4.FVector2D(_scale, _scale))
  else
    self.Icon_2:SetRenderScale(UE4.FVector2D(-_scale, _scale))
  end
  local path = self.PetBaseConf.JL_res
  if PetMutationUtils.GetMutationValue(self.petData.mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) or PetUtils.CheckIsShiningGlass(self.petData.mutation_type) then
    path = self.PetBaseConf.JL_shiny_res
  end
  self.IconBg_3:SetPath(self.PetBaseConf.share_bg)
  self.Icon_2:SetPath(path)
end

function UMG_VideoSharing_C:ShowPetFindInfo()
  if self.petData.add_time then
    local addTime = os.date("%Y/%m/%d", self.petData.add_time)
    self.Time:SetText(addTime)
    self.Time:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Time:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local isShowFindPos = false
  if self.petData.caught_camp then
    local campConf = _G.DataConfigManager:GetCampConf(self.petData.caught_camp)
    if campConf then
      isShowFindPos = true
      self.Name_3:SetText(campConf.camp_name)
    end
  end
  if isShowFindPos then
    self.Name_3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Name_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_VideoSharing_C:OnPlayVideoClick()
  if not self.Parent.IsAnimAllFinish then
    return
  end
  
  local function OpenCb()
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.PlayShareVideoG6)
  end
  
  local function CloseCb()
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenSharePanel, 2, self.petData)
  end
  
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenShareCameraPanel, self.petData, OpenCb, CloseCb)
  self.Parent:OnClickCloseBtn()
end

function UMG_VideoSharing_C:SetParent(parent)
  self.Parent = parent
end

function UMG_VideoSharing_C:PlayStampInAnim()
  self:PlayAnimation(self.Stamp_in)
end

function UMG_VideoSharing_C:OnAnimationFinished(Animation)
  if Animation == self.Stamp_in then
    _G.NRCModuleManager:DoCmd(ShareModuleCmd.EndRecordVideo, self.petData.gid)
  end
end

return UMG_VideoSharing_C
