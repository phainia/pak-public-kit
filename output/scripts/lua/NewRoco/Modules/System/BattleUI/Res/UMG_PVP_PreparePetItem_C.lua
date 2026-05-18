local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_PVP_PreparePetItem_C = Base:Extend("UMG_PVP_PreparePetItem_C")

function UMG_PVP_PreparePetItem_C:OnConstruct()
  if _G.GlobalConfig.DebugOpenUI then
    self:PlayAnimation(self.In)
  end
end

function UMG_PVP_PreparePetItem_C:OnAddEventListener()
end

function UMG_PVP_PreparePetItem_C:OnRemoveEventListener()
end

function UMG_PVP_PreparePetItem_C:OnDestruct()
  _G.UpdateManager:UnRegister(self)
  self:OnRemoveEventListener()
end

function UMG_PVP_PreparePetItem_C:OnItemUpdate(_data, datalist, index)
  if _data.pet_data == nil then
    return
  end
  self:OnAddEventListener()
  self.index = index
  self.isAdjust = _data.adjusted
  self.petData = _data.pet_data
  self.gid = self.petData.gid
  self.maxHp = PetUtils.GetPetAdditionalByType(self.petData, _G.ProtoEnum.AttributeType.AT_HPMAX)
  self.hp = self.maxHp
  self:UpdateUI()
end

function UMG_PVP_PreparePetItem_C:OnItemSelected(Selected)
  local readyState = NRCModuleManager:DoCmd(BattleUIModuleCmd.GetPVP_PreparePlayerReadyState)
  if Selected then
    if nil == readyState or false == readyState then
      self:PlayAnimation(self.Change_Select)
      self:SetSelectBg(UE4.ESlateVisibility.SelfHitTestInvisible)
      NRCModuleManager:DoCmd(BattleUIModuleCmd.SetPVP_PrepareSelectPet, self.index, true)
    else
      NRCModuleManager:DoCmd(BattleUIModuleCmd.SetPVP_PrepareSelectPet, self.index, false)
    end
  else
    self:SetSelectBg(UE4.ESlateVisibility.Collapsed)
    self:PlayAnimation(self.Change_UnSelect)
  end
end

function UMG_PVP_PreparePetItem_C:SetSelectBg(visibility)
  if self.SelectBg then
    self.SelectBg:SetVisibility(visibility)
  end
end

function UMG_PVP_PreparePetItem_C:OnDeactive()
end

function UMG_PVP_PreparePetItem_C:UpdateUI()
  self.Text_Name:SetText(self.petData.name)
  self.Text_Level:SetText(string.format(LuaText.umg_petskilltemple2_1, self.petData.level or -1))
  self.TxtHp:SetText(self.hp .. "/" .. self.maxHp)
  local Btn_particularsVisibility = UE4.ESlateVisibility.Collapsed
  local typeInfo = self.petData and self.petData.type
  local typeInfoType = typeInfo and typeInfo.type
  if 1 == self.petData.gender then
    self.ImagePetGender2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ImagePetGender1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif 2 == self.petData.gender then
    self.ImagePetGender2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ImagePetGender1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif self.uiData then
    Log.Trace("\230\128\167\229\136\171\228\184\141\230\152\142 ", self.uiData.petData.gender)
  end
  if typeInfoType == ProtoEnum.PetTypeInfo.ENUM.PET_TYPE_RANDOM then
    Btn_particularsVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
  end
  if self.isAdjust then
    self.Text_Name:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("D56C1FFF"))
  end
  self.Btn_particulars:SetVisibility(Btn_particularsVisibility)
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.petData.base_conf_id)
  if petBaseConf then
    local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
    self.ColorfulHeadIcon:SetIconPathAndMaterial(self.petData.base_conf_id, self.petData.mutation_type, self.petData.glass_info)
  end
end

function UMG_PVP_PreparePetItem_C:OpenDetailsPanel()
  NRCModuleManager:DoCmd(BattleUIModuleCmd.OpenPreparePanelPetInfo, self.index)
end

function UMG_PVP_PreparePetItem_C:OnTick(InDeltaTime)
  if not self._pressed or not self._timer then
    return
  end
  self._timer = self._timer - InDeltaTime
  if self._timer <= 0 then
    self:DoLongClick()
  end
end

function UMG_PVP_PreparePetItem_C:DoLongClick()
  self._pressed = false
  self._timer = 0
  _G.UpdateManager:UnRegister(self)
  self:OpenDetailsPanel()
end

function UMG_PVP_PreparePetItem_C:OnTouchStarted(MyGeometry, InTouchEvent)
  self._pressed = true
  self._timer = BattleConst.ItemLongPressThreshold
  _G.UpdateManager:Register(self)
  Base.OnTouchStarted(self, MyGeometry, InTouchEvent)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_PVP_PreparePetItem_C:OnTouchEnded(MyGeometry, InTouchEvent)
  local oldPress = self._pressed
  self._pressed = false
  _G.UpdateManager:UnRegister(self)
  if oldPress then
    return Base.OnTouchEnded(self, MyGeometry, InTouchEvent)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

return UMG_PVP_PreparePetItem_C
