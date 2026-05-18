local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_TalentRestore_Popup_C = _G.NRCPanelBase:Extend("UMG_TalentRestore_Popup_C")

function UMG_TalentRestore_Popup_C:OnConstruct()
  self:SetChildViews(self.PopUp1)
end

function UMG_TalentRestore_Popup_C:OnDestruct()
end

function UMG_TalentRestore_Popup_C:OnActive(PetInfo)
  self.PetItemData = PetInfo
  self:SetPetIcon()
  self:SetCommonPopUpInfo(self.PopUp1, LuaText.key_used_record_title)
  local attribute_info = self.PetItemData.attribute_info
  local talentInfo = {}
  if 0 ~= attribute_info.hp.talent then
    table.insert(talentInfo, {
      talent = attribute_info.hp.talent,
      type = Enum.AttributeType.AT_HPMAX
    })
  end
  if 0 ~= attribute_info.attack.talent then
    table.insert(talentInfo, {
      talent = attribute_info.attack.talent,
      type = Enum.AttributeType.AT_PHYATK
    })
  end
  if 0 ~= attribute_info.special_attack.talent then
    table.insert(talentInfo, {
      talent = attribute_info.special_attack.talent,
      type = Enum.AttributeType.AT_SPEATK
    })
  end
  if 0 ~= attribute_info.defense.talent then
    table.insert(talentInfo, {
      talent = attribute_info.defense.talent,
      type = Enum.AttributeType.AT_PHYDEF
    })
  end
  if 0 ~= attribute_info.special_defense.talent then
    table.insert(talentInfo, {
      talent = attribute_info.special_defense.talent,
      type = Enum.AttributeType.AT_SPEDEF
    })
  end
  if 0 ~= attribute_info.speed.talent then
    table.insert(talentInfo, {
      talent = attribute_info.speed.talent,
      type = Enum.AttributeType.AT_SPEED
    })
  end
  if PetInfo.attribute_info.talent_change_info and PetInfo.attribute_info.talent_change_info.talent_change_cnt and PetInfo.attribute_info.talent_change_info.talent_change_cnt > 0 then
    if PetInfo.attribute_info.talent_change_info.after_talent_type then
      local iconPath, iconText, talentValue = self:GetIconPath(PetInfo.attribute_info.talent_change_info.after_talent_type)
      self.after_talent_type = iconText
      self.OwnedText_1:SetText(iconText)
      self.attributeIcon_1:SetPath(iconPath)
      self.OwnedText_6:SetText("+" .. talentValue)
      self.OwnedText:SetText("+" .. talentValue)
      for i, v in pairs(talentInfo) do
        if v.type == PetInfo.attribute_info.talent_change_info.after_talent_type then
          talentInfo[i].talent = talentValue
          talentInfo[i].type = PetInfo.attribute_info.talent_change_info.prev_talent_type
          break
        end
      end
    end
    if PetInfo.attribute_info.talent_change_info.prev_talent_type and PetInfo.attribute_info.talent_change_info.prev_talent_type ~= Enum.AttributeType.AT_NONE then
      local iconPath
      do
        local iconPath, iconText = self:GetIconPath(PetInfo.attribute_info.talent_change_info.prev_talent_type)
        self.OwnedText_3:SetText(iconText)
        self.attributeIcon:SetPath(iconPath)
      end
    else
      local vP = UE4.FVector2D(41, -1)
      self.OwnedText.Slot:SetPosition(vP)
      self.attributeIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.OwnedText_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.OwnedText:SetText("-")
    end
    local num = 0
    self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasPanel_4:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasPanel_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    for i, v in pairs(talentInfo) do
      if 1 == i and v.type and v.type ~= Enum.AttributeType.AT_NONE then
        self.CanvasPanel_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        local iconPath, iconText, talentValue = self:GetIconPath(v.type)
        self.OwnedText_4:SetText(iconText)
        self.attributeIcon_2:SetPath(iconPath)
        self.OwnedText_5:SetText("+" .. v.talent)
        num = num + 1
      end
      if 2 == i and v.type and v.type ~= Enum.AttributeType.AT_NONE then
        self.CanvasPanel_3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        local iconPath, iconText, talentValue = self:GetIconPath(v.type)
        self.OwnedText_8:SetText(iconText)
        self.attributeIcon_3:SetPath(iconPath)
        self.OwnedText_9:SetText("+" .. v.talent)
        num = num + 1
      end
      if 3 == i and v.type and v.type ~= Enum.AttributeType.AT_NONE then
        self.CanvasPanel_4:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        local iconPath, iconText, talentValue = self:GetIconPath(v.type)
        self.OwnedText_10:SetText(iconText)
        self.attributeIcon_4:SetPath(iconPath)
        self.OwnedText_11:SetText("+" .. v.talent)
        num = num + 1
      end
    end
  end
  self.PopUp1:SetDescInfo(string.format(LuaText.key_used_record, self.PetItemData.name, self.after_talent_type))
  self:LoadAnimation(0)
  self:OnAddEventListener()
end

function UMG_TalentRestore_Popup_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.ClosePanel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_TalentRestore_Popup_C:OnPcClose()
  self:ClosePanel()
end

function UMG_TalentRestore_Popup_C:GetIconPath(Type)
  local iconPath = "PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Hp_png.img_Hp_png'"
  local iconText = "\231\148\159\229\145\189"
  local talentValue = self.PetItemData.attribute_info.hp.talent
  if Type == Enum.AttributeType.AT_HPMAX then
    iconPath = "PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Hp_png.img_Hp_png'"
  elseif Type == Enum.AttributeType.AT_PHYATK then
    iconPath = "PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Atk_png.img_Atk_png'"
    iconText = "\231\137\169\230\148\187"
    talentValue = self.PetItemData.attribute_info.attack.talent
  elseif Type == Enum.AttributeType.AT_SPEATK then
    iconPath = "PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpAtk_png.img_SpAtk_png'"
    iconText = "\233\173\148\230\148\187"
    talentValue = self.PetItemData.attribute_info.special_attack.talent
  elseif Type == Enum.AttributeType.AT_PHYDEF then
    iconPath = "PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Def_png.img_Def_png'"
    iconText = "\231\137\169\233\152\178"
    talentValue = self.PetItemData.attribute_info.defense.talent
  elseif Type == Enum.AttributeType.AT_SPEDEF then
    iconPath = "PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_SpDef_png.img_SpDef_png'"
    iconText = "\233\173\148\233\152\178"
    talentValue = self.PetItemData.attribute_info.special_defense.talent
  elseif Type == Enum.AttributeType.AT_SPEED then
    iconPath = "PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Speed_png.img_Speed_png'"
    iconText = "\233\128\159\229\186\166"
    talentValue = self.PetItemData.attribute_info.speed.talent
  end
  return iconPath, iconText, talentValue
end

function UMG_TalentRestore_Popup_C:SetPetIcon()
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
  self.StarList:InitGridView(petlevel)
end

function UMG_TalentRestore_Popup_C:OnDeactive()
end

function UMG_TalentRestore_Popup_C:OpenTips()
  _G.NRCModeManager:DoCmd(PetUIModuleCmd.ShowChangePetConfirm, self.PetItemData)
end

function UMG_TalentRestore_Popup_C:TryTalentReset()
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local Context = LuaText.key_withdraw_tips
  local Ctx = DialogContext()
  Ctx:SetTitle(LuaText.TIPS)
  Ctx:SetContent(Context)
  Ctx:SetMode(DialogContext.Mode.OK_CANCEL)
  Ctx:SetCallback(self, self.IsTalentReset)
  Ctx:SetClickAnywhereClose(true)
  Ctx:SetCloseOnCancel(true)
  Ctx:SetCloseOnOK(true)
  Ctx:SetToppingIconType(0)
  Ctx:SetButtonText(LuaText.umg_dialog_2, LuaText.umg_dialog_1)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx, nil, Enum.UILayerType.UI_LAYER_POPUP)
end

function UMG_TalentRestore_Popup_C:SendZoneRecallTalentChangeReq()
  local req = _G.ProtoMessage:newZoneRecallTalentChangeReq()
  req.pet_gid = self.PetItemData.gid
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_RECALL_TALENT_CHANGE_REQ, req, self, self.ZoneRecallTalentChangeRsp, false, true)
end

function UMG_TalentRestore_Popup_C:ZoneRecallTalentChangeRsp(rsp)
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if 0 == rsp.ret_info.ret_code then
    self.PopUp1:SetDescInfo(string.format(LuaText.key_withdraw_sucess_tips, self.PetItemData.name))
    self.PopUp1:SetTitleTextInfo(LuaText.key_withdraw_sucess_title)
    self.Btn3:SetVisibility(UE4.ESlateVisibility.Visible)
    self.TalentCanvas2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.Use)
  else
    local key = string.format("Error_Code_%d", rsp.ret_info.ret_code)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText[key])
  end
end

function UMG_TalentRestore_Popup_C:IsTalentReset(NeedRe)
  if NeedRe then
    self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self:DelaySeconds(0.15, function()
      self:SendZoneRecallTalentChangeReq()
    end)
  else
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_TalentRestore_Popup_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  elseif anim == self.Use then
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.AttributePanelRefresh)
    self.TalentCanvas1:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_TalentRestore_Popup_C:ClosePanel()
  self:LoadAnimation(2)
end

function UMG_TalentRestore_Popup_C:OnAddEventListener()
  self:AddButtonListener(self.Tipsbtn, self.OpenTips)
  self:AddButtonListener(self.ChangeBtn_5, self.TryTalentReset)
  self:AddButtonListener(self.Btn3.btnLevelUp, self.ClosePanel)
end

return UMG_TalentRestore_Popup_C
