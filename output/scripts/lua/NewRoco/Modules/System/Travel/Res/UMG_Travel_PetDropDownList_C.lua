local UMG_Travel_PetDropDownList_C = _G.NRCPanelBase:Extend("UMG_Travel_PetDropDownList_C")

function UMG_Travel_PetDropDownList_C:OnConstruct()
  self.uidata = nil
  self.selectedIndex = -1
  self.DefaultSort = {
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8
  }
  self.bListVisible = false
  self.bFilterListVisible = false
  self.IsReversedSort = false
  self:OnAddEventListener()
  self.TypeList = {}
  self.ConfirmBtn:SetBtnText(LuaText.umg_travel_petdropdownlist_1)
  local iconPath = "PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_shaixuan_png.img_shaixuan_png'"
  self.ConfirmBtn:SetPath(iconPath)
  self:IsCloseMask(true)
end

function UMG_Travel_PetDropDownList_C:OnDestruct()
end

function UMG_Travel_PetDropDownList_C:OnAddEventListener()
  self:AddButtonListener(self.FilterBtn, self.OnFilterBtnClicked)
  self:AddButtonListener(self.ConfirmBtn.btnLevelUp, self.OnConfirmBtnClicked)
  self:AddButtonListener(self.Btn_Global, self.OnBtn_Global)
end

function UMG_Travel_PetDropDownList_C:SetConfirmBtnEnable(bEnable)
  if bEnable then
    self.ConfirmBtn:SetIsEnabled(true)
  else
    self.ConfirmBtn:SetIsEnabled(false)
  end
end

function UMG_Travel_PetDropDownList_C:OnFilterBtnClicked()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1287, "UMG_PetDropDownList_C:OnConfirmBtnClicked")
  self:IsCloseMask(self.bFilterListVisible)
  self:SetFilterListVisible(not self.bFilterListVisible)
end

function UMG_Travel_PetDropDownList_C:OnConfirmBtnClicked()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_PetDropDownList_C:OnConfirmBtnClicked")
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OnTypeChooseBtnClicked, self.TypeList)
  self:OnBtn_Global()
end

function UMG_Travel_PetDropDownList_C:OnBtn_Global()
  self:IsCloseMask(true)
  self:SetFilterListVisible(false)
end

function UMG_Travel_PetDropDownList_C:IsCloseMask(_IsClose)
  if true == _IsClose then
    self.Btn_Global:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.Btn_Global:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_Travel_PetDropDownList_C:SetReversedSort()
  self.IsReversedSort = false
end

function UMG_Travel_PetDropDownList_C:OnNRCButton_0Click()
  self:OnBtn_Global()
  if self.IsReversedSort == false then
    self.IsReversedSort = true
    self.NRCButton_0:SetRenderScale(UE4.FVector2D(-1, 1))
  else
    self.IsReversedSort = false
    self.NRCButton_0:SetRenderScale(UE4.FVector2D(-1, -1))
  end
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OnClickReversedSort, self.IsReversedSort)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1218, "UMG_PetDropDownList_C:OnNRCButton_0Click")
end

function UMG_Travel_PetDropDownList_C:OnActive(_index)
  self.uidata = nil
  self.selectedIndex = _index
  self.bListVisible = false
  self:SetFilterListVisible(false)
end

function UMG_Travel_PetDropDownList_C:SetFilterListVisible(bVisible)
  if true == bVisible then
    self:SetDeptList()
    self.FilterListPanel:SetVisibility(UE4.ESlateVisibility.Visible)
    self.bFilterListVisible = true
  else
    self.FilterListPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.bFilterListVisible = false
  end
end

function UMG_Travel_PetDropDownList_C:SetDeptList()
  local chooseTypeList = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.GetTypeChooseNum)
  self:UpdateDeptList(chooseTypeList)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetChooseTypeListTemporary, chooseTypeList)
end

function UMG_Travel_PetDropDownList_C:UpdateDeptList(chooseTypeList)
  local TypeData = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.TYPE_DICTIONARY):GetAllDatas()
  local TypeList = {}
  for k, v in ipairs(TypeData) do
    if 1 ~= v.id and 7 ~= v.id and 21 ~= v.id then
      local IsChooseType = false
      for i, Type in ipairs(chooseTypeList) do
        if v.id == Type then
          IsChooseType = true
          break
        end
      end
      table.insert(TypeList, {
        typeId = v.id,
        typeName = v.short_name,
        typeIcon = v.tips_res,
        IsChooseType = IsChooseType,
        caller = self,
        handler = self.SelectTypeUpdate
      })
    end
  end
  self:SetFilterListInfo(TypeList)
end

function UMG_Travel_PetDropDownList_C:SelectTypeUpdate()
  local ChooseTypeListTemporary = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.GetChooseTypeListTemporary)
  self:UpdateDeptList(ChooseTypeListTemporary)
end

function UMG_Travel_PetDropDownList_C:SetFilterListInfo(data)
  self.FilterList:InitGridView(data)
end

function UMG_Travel_PetDropDownList_C:SelectItem(sortType)
  local selected = {}
  table.insert(selected, sortType)
  self.ShowSelectedItem:InitGridView(selected)
end

function UMG_Travel_PetDropDownList_C:GetbListVisible()
  return self.bListVisible
end

function UMG_Travel_PetDropDownList_C:OnDeactive()
end

return UMG_Travel_PetDropDownList_C
