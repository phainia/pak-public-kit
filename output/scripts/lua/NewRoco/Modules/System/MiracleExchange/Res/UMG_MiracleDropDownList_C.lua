local UMG_MiracleDropDownList_C = _G.NRCPanelBase:Extend("UMG_MiracleDropDownList_C")

function UMG_MiracleDropDownList_C:OnConstruct()
  self.uidata = nil
  self.module = NRCModuleManager:GetModule("MiracleExchangeModule")
  self.data = self.module:SetData("MiracleExchangeModuleData")
  self.selectedIndex = -1
  local cfgTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.PET_BAG_SEQUENCE)
  local cfgDatas = cfgTable:GetAllDatas()
  self.DefaultSort = {}
  for i = 1, #cfgDatas do
    table.insert(self.DefaultSort, i)
  end
  self.bListVisible = false
  self.bFilterListVisible = false
  self.IsReversedSort = false
  self:SetScrollVisible(self.bListVisible)
  self.NRCButton_0:SetRenderScale(UE4.FVector2D(-1, -1))
  self:OnAddEventListener()
  self.TypeList = {}
  self.ConfirmBtn:SetBtnText(LuaText.umg_miracledropdownlist_1)
  local iconPath = "PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_shaixuan_png.img_shaixuan_png'"
  self.ConfirmBtn:SetPath(iconPath)
  self:IsCloseMask(true)
end

function UMG_MiracleDropDownList_C:OnDestruct()
end

function UMG_MiracleDropDownList_C:OnAddEventListener()
  self:AddButtonListener(self.SelectButton, self.OnSelectedBtnClick)
  self:AddButtonListener(self.NRCButton_0, self.OnNRCButton_0Click)
  self:AddButtonListener(self.FilterBtn, self.OnFilterBtnClicked)
  self:AddButtonListener(self.ConfirmBtn.btnLevelUp, self.OnConfirmBtnClicked)
  self:AddButtonListener(self.Btn_Global, self.OnBtn_Global)
end

function UMG_MiracleDropDownList_C:OnSelectedBtnClick()
  self:IsCloseMask(self.bListVisible)
  self:SetFilterListVisible(false)
  if self.bListVisible == true then
    self:SetScrollVisible(false)
  else
    self:SetScrollVisible(true)
  end
end

function UMG_MiracleDropDownList_C:SetConfirmBtnEnable(bEnable)
  if bEnable then
    self.ConfirmBtn:SetIsEnabled(true)
  else
    self.ConfirmBtn:SetIsEnabled(false)
  end
end

function UMG_MiracleDropDownList_C:OnFilterBtnClicked()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1287, "UMG_PetDropDownList_C:OnConfirmBtnClicked")
  self:SetScrollVisible(false)
  self:IsCloseMask(self.bFilterListVisible)
  self:SetFilterListVisible(not self.bFilterListVisible)
end

function UMG_MiracleDropDownList_C:OnConfirmBtnClicked()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_PetDropDownList_C:OnConfirmBtnClicked")
  _G.NRCModuleManager:DoCmd(MiracleExchangeModuleCmd.OnTypeChooseBtnClicked, self.TypeList)
  self:OnBtn_Global()
end

function UMG_MiracleDropDownList_C:OnBtn_Global()
  self:IsCloseMask(true)
  self:SetScrollVisible(false)
  self:SetFilterListVisible(false)
end

function UMG_MiracleDropDownList_C:IsCloseMask(_IsClose)
  if true == _IsClose then
    self.Btn_Global:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.Btn_Global:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_MiracleDropDownList_C:SetReversedSort()
  self.IsReversedSort = false
end

function UMG_MiracleDropDownList_C:OnNRCButton_0Click()
  self:OnBtn_Global()
  if self.IsReversedSort == false then
    self.IsReversedSort = true
    self.NRCButton_0:SetRenderScale(UE4.FVector2D(-1, 1))
  else
    self.IsReversedSort = false
    self.NRCButton_0:SetRenderScale(UE4.FVector2D(-1, -1))
  end
  _G.NRCModuleManager:DoCmd(MiracleExchangeModuleCmd.OnMiracleMainReversedSort, self.IsReversedSort)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1218, "UMG_PetDropDownList_C:OnNRCButton_0Click")
end

function UMG_MiracleDropDownList_C:OnActive(_index)
  self.uidata = nil
  self.selectedIndex = _index
  self.bListVisible = false
  self:SetScrollVisible(self.bListVisible)
  self:SetFilterListVisible(false)
  self:SetDropDownListInfo(self.DefaultSort)
end

function UMG_MiracleDropDownList_C:SetScrollVisible(visible)
  if true == visible then
    self.CandidateListScroll:SetVisibility(UE4.ESlateVisibility.Visible)
    self.FrameBG:SetVisibility(UE4.ESlateVisibility.Visible)
    self.DownArrow:SetRenderTransformAngle(180)
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1086, "UMG_PetSkillChange_C:BackBtn_1")
    self.bListVisible = true
  else
    self.Btn_Global:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.CandidateListScroll:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.FrameBG:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.DownArrow:SetRenderTransformAngle(0)
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1089, "UMG_PetSkillChange_C:BackBtn_1")
    self.bListVisible = false
  end
end

function UMG_MiracleDropDownList_C:SetFilterListVisible(bVisible)
  if true == bVisible then
    self:SetDeptList()
    self.FilterListPanel:SetVisibility(UE4.ESlateVisibility.Visible)
    self.bFilterListVisible = true
  else
    self.FilterListPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.bFilterListVisible = false
  end
end

function UMG_MiracleDropDownList_C:SetDeptList()
  local chooseTypeList = self.data.chooseTypeList
  self:UpdateDeptList(chooseTypeList)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetChooseTypeListTemporary, chooseTypeList)
end

function UMG_MiracleDropDownList_C:UpdateDeptList(chooseTypeList)
  local TypeData = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.TYPE_DICTIONARY):GetAllDatas()
  local TypeList = {}
  for k, v in ipairs(TypeData) do
    if 1 ~= v.id and 7 ~= v.id then
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

function UMG_MiracleDropDownList_C:SelectTypeUpdate()
  local ChooseTypeListTemporary = self.data.chooseTypeListTemporary
  self:UpdateDeptList(ChooseTypeListTemporary)
end

function UMG_MiracleDropDownList_C:SetDropDownListInfo(data)
  Log.Dump(data, 4, "UMG_PetDropDownList_C:SetDropDownListInfo")
  self.CandidateListScroll:InitList(data)
  if self.selectedIndex >= 0 then
    self.CandidateListScroll:SelectItemByIndex(self.selectedIndex)
  end
end

function UMG_MiracleDropDownList_C:SetFilterListInfo(data)
  self.FilterList:InitGridView(data)
end

function UMG_MiracleDropDownList_C:SelectItem(sortType)
  self:SetScrollVisible(false)
  local selected = {}
  table.insert(selected, sortType)
  self.ShowSelectedItem:InitGridView(selected)
end

function UMG_MiracleDropDownList_C:GetbListVisible()
  return self.bListVisible
end

function UMG_MiracleDropDownList_C:OnDeactive()
end

return UMG_MiracleDropDownList_C
