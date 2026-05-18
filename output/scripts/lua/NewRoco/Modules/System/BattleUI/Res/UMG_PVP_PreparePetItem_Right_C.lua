local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PVP_PreparePetItem_Right_C = Base:Extend("UMG_PVP_PreparePetItem_Right_C")

function UMG_PVP_PreparePetItem_Right_C:OnConstruct()
  if _G.GlobalConfig.DebugOpenUI then
    self:PlayAnimation(self.In)
  end
end

function UMG_PVP_PreparePetItem_Right_C:OnDestruct()
  _G.UpdateManager:UnRegister(self)
end

function UMG_PVP_PreparePetItem_Right_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.petData = _data
  self:UpdateUI()
end

function UMG_PVP_PreparePetItem_Right_C:UpdateUI()
  local Btn_particularsVisibility = UE4.ESlateVisibility.Collapsed
  local typeInfo = self.petData and self.petData.type
  local typeInfoType = typeInfo and typeInfo.type
  if typeInfoType == ProtoEnum.PetTypeInfo.ENUM.PET_TYPE_RANDOM then
    Btn_particularsVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
  end
  self.Text_Name:SetText(self.petData.name or "")
  self.Text_Level:SetText(string.format(LuaText.umg_petskilltemple2_1, self.petData.level or -1))
  self.ImagePetGender2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ImagePetGender1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ColorfulHeadIcon:SetIconPathAndMaterial(self.petData.petbase_id, self.petData.mutation_type, self.petData.glass_info)
  self.Btn_particulars:SetVisibility(Btn_particularsVisibility)
end

function UMG_PVP_PreparePetItem_Right_C:OpenDetailsPanel()
  NRCModuleManager:DoCmd(BattleUIModuleCmd.OpenPreparePanelPetInfo, self.index, true)
end

function UMG_PVP_PreparePetItem_Right_C:OnTick(InDeltaTime)
  if not self._pressed or not self._timer then
    return
  end
  self._timer = self._timer - InDeltaTime
  if self._timer <= 0 then
    self:DoLongClick()
  end
end

function UMG_PVP_PreparePetItem_Right_C:DoLongClick()
  self._pressed = false
  self._timer = 0
  _G.UpdateManager:UnRegister(self)
  self:OpenDetailsPanel()
end

function UMG_PVP_PreparePetItem_Right_C:OnTouchStarted(MyGeometry, InTouchEvent)
  self._pressed = true
  self._timer = BattleConst.ItemLongPressThreshold
  _G.UpdateManager:Register(self)
  Base.OnTouchStarted(self, MyGeometry, InTouchEvent)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_PVP_PreparePetItem_Right_C:OnTouchEnded(MyGeometry, InTouchEvent)
  local oldPress = self._pressed
  self._pressed = false
  _G.UpdateManager:UnRegister(self)
  if oldPress then
    return Base.OnTouchEnded(self, MyGeometry, InTouchEvent)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_PVP_PreparePetItem_Right_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:DoLongClick()
  end
end

function UMG_PVP_PreparePetItem_Right_C:OnDeactive()
end

return UMG_PVP_PreparePetItem_Right_C
