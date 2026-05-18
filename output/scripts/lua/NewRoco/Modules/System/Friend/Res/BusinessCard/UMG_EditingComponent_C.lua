local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local UMG_EditingComponent_C = _G.NRCPanelBase:Extend("UMG_EditingComponent_C")
local EditComponentItemData = require("NewRoco.Modules.System.Friend.EditComponentItemData")

function UMG_EditingComponent_C:OnConstruct()
  self.data = self.module:GetData("FriendModuleData")
  self.isWaitingSaveAndClose = false
  self:OnRegister()
end

function UMG_EditingComponent_C:OnDestruct()
  self:OnUnRegister()
end

function UMG_EditingComponent_C:OnActive(arg)
  self.ComponentType = self.data:GetCurCardComponentType()
  Log.Debug("UMG_EditingComponent_C:OnActive() ComponentType = " .. tostring(self.ComponentType))
  self:InitComponent()
  self:InitShowHidePanel()
end

function UMG_EditingComponent_C:InitComponent()
  self.data:SetPetTypeFilterList(nil)
  self.data:SetIsEditingComponent(true)
  self.data:InitCurEditCardInfo()
  if self.ComponentType == _G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET then
    self:InitPetComponent()
  elseif self.ComponentType == _G.ProtoEnum.RoleCardModuleType.RCMT_BADGE then
    self:InitBadgeComponent()
  else
    Log.Error("UMG_EditingComponent_C:Init() ComponentType is not supported: " .. tostring(self.ComponentType))
    return
  end
end

function UMG_EditingComponent_C:InitPetComponent()
  self:UpdatePetList()
  self.module:DispatchEvent(FriendModuleEvent.UpdateCardComponentEdit)
end

function UMG_EditingComponent_C:InitBadgeComponent()
  self:UpdateFashionList()
  self.module:DispatchEvent(FriendModuleEvent.UpdateCardComponentEdit)
end

function UMG_EditingComponent_C:OnDeactive()
  if self.data then
    self.data:SetIsEditingComponent(false)
  end
  if self.module then
    self.module:DispatchEvent(FriendModuleEvent.UpdateCardComponentEdit)
  end
end

function UMG_EditingComponent_C:OnRegister()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseBtnClicked)
  self:AddButtonListener(self.Confirm_1.btnLevelUp, self.OnSaveBtnClicked)
  self:AddButtonListener(self.Rotation_1.btnLevelUp, self.OnResetBtnClicked)
  self:AddButtonListener(self.Rotation.btnLevelUp, self.OnFilterBtnClicked)
  self:RegisterEvent(self, FriendModuleEvent.OnComponentEditPetTypeSelected, self.OnComponentEditPetTypeSelected)
  self:RegisterEvent(self, FriendModuleEvent.UpdateCardComponentEdit, self.UpdateCardComponentEdit)
  self:RegisterEvent(self, FriendModuleEvent.OnSetPlayerCardCollectPetSuccess, self.OnSetPlayerCardCollectPetSuccess)
end

function UMG_EditingComponent_C:OnUnRegister()
  self:UnRegisterEvent(self, FriendModuleEvent.OnComponentEditPetTypeSelected)
  self:UnRegisterEvent(self, FriendModuleEvent.UpdateCardComponentEdit)
  self:UnRegisterEvent(self, FriendModuleEvent.OnSetPlayerCardCollectPetSuccess)
end

function UMG_EditingComponent_C:UpdatePetList()
  self.Rotation:SetVisibility(UE4.ESlateVisibility.Visible)
  local petTypeFilterList = self.data:GetPetTypeFilterList()
  if petTypeFilterList and #petTypeFilterList > 0 then
    local filterIconPath = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/BusinessCard/Frames/img_Filter2_png.img_Filter2_png'"
    self.Rotation:SetPath(filterIconPath, filterIconPath, filterIconPath)
  else
    local normalIconPath = "PaperSprite'/Game/NewRoco/Modules/System/Friend/Raw/BusinessCard/Frames/img_Filter_png.img_Filter_png'"
    self.Rotation:SetPath(normalIconPath, normalIconPath, normalIconPath)
  end
  local PetHandbookList = self:GetValidPetDataListToEdit(petTypeFilterList, true)
  if not PetHandbookList or #PetHandbookList <= 0 then
    self.Item:Clear()
    self.Empty:SetVisibility(UE4.ESlateVisibility.Visible)
    return
  end
  self.Empty:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local itemDataList = {}
  for _, petData in ipairs(PetHandbookList) do
    local itemData = EditComponentItemData:Create(_G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET)
    if not itemData then
    else
      itemData:InitFromPetInfo({
        skill_dam_type = petData.skill_dam_type,
        pet_base_id = petData.pet_base_id,
        mutation_diff_type = petData.mutation_type
      }, FriendEnum.CardComponentShowType.EditComponent)
      table.insert(itemDataList, itemData)
    end
  end
  self.Item:InitList(itemDataList)
end

function UMG_EditingComponent_C:GetValidFashionListToEdit()
  local BondInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerBondInfo()
  if not (BondInfo and BondInfo.fashion_bond_item) or #BondInfo.fashion_bond_item <= 0 then
    return {}
  end
  local OwnFashionList = BondInfo.fashion_bond_item
  local FilterList = {}
  for _, fashionData in ipairs(OwnFashionList) do
    if not fashionData then
    else
      local bondConf = _G.DataConfigManager:GetFashionBondConf(fashionData.id)
      if not bondConf then
        Log.Error("UMG_EditingComponent_C:GetValidFashionListToEdit() bondConf is nil for id: " .. tostring(fashionData.id))
      elseif not self.data:IsCurEditCardFashionContainsFashionId(fashionData.id) then
        table.insert(FilterList, fashionData)
      end
    end
  end
  table.sort(FilterList, function(a, b)
    if not a.get_time or not b.get_time then
      return false
    end
    return a.get_time > b.get_time
  end)
  return FilterList
end

function UMG_EditingComponent_C:UpdateFashionList()
  self.Rotation:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local validFashionList = self:GetValidFashionListToEdit()
  if not validFashionList or #validFashionList <= 0 then
    self.Item:Clear()
    self.Empty:SetVisibility(UE4.ESlateVisibility.Visible)
    return
  end
  self.Empty:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local itemDataList = {}
  for i, item in ipairs(validFashionList) do
    local itemData = EditComponentItemData:Create(_G.ProtoEnum.RoleCardModuleType.RCMT_BADGE)
    if not itemData then
    else
      itemData:InitFromBadgeInfo({
        fashion_bond_id = item.id
      }, FriendEnum.CardComponentShowType.EditComponent)
      table.insert(itemDataList, itemData)
    end
  end
  self.Item:InitList(itemDataList)
end

function UMG_EditingComponent_C:GetValidPetDataListToEdit(petTypeFilterList, isSortByHandbookId)
  local OwnPetList = _G.DataModelMgr.PlayerDataModel:GetPetHandbookDataWithTypeFilter(petTypeFilterList)
  local FilterList = {}
  for _, petData in ipairs(OwnPetList) do
    if petData and not self.data:IsCurEditCardPetContainsPetHandbook(petData) then
      table.insert(FilterList, petData)
    end
  end
  if isSortByHandbookId then
    table.sort(FilterList, function(a, b)
      return a.handbook_id < b.handbook_id
    end)
  end
  return FilterList
end

function UMG_EditingComponent_C:OnComponentEditPetTypeSelected()
  self:UpdatePetList()
end

function UMG_EditingComponent_C:UpdateCardComponentEdit()
  self.ComponentType = self.data:GetCurCardComponentType()
  if self.ComponentType == _G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET then
    self:UpdatePetList()
  elseif self.ComponentType == _G.ProtoEnum.RoleCardModuleType.RCMT_BADGE then
    self:UpdateFashionList()
  else
    Log.Error("UMG_EditingComponent_C:UpdateCardComponentEdit() ComponentType is not supported: " .. tostring(self.ComponentType))
  end
end

function UMG_EditingComponent_C:OnFilterBtnClicked()
  Log.Debug("UMG_EditingComponent_C:OnFilterBtnClicked()")
  _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OpenPetCardTypeSelect)
end

function UMG_EditingComponent_C:OnResetBtnClicked()
  Log.Debug("UMG_EditingComponent_C:OnResetBtnClicked()")
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local Context = DialogContext()
  local curComponentName = self:GetCurComponentName()
  Context:SetTitle(LuaText.TIPS):SetContent(string.format(LuaText.rolecard_module_revert_tips, curComponentName)):SetMode(DialogContext.Mode.OK_CANCEL):SetButtonText(LuaText.tips_dialog_butten_accept, LuaText.tips_dialog_butten_cancel):SetCloseOnCancel(true):SetCallback(self, self.OnResetDialogCallBack):SetClickAnywhereClose(false)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Context)
end

function UMG_EditingComponent_C:GetCurComponentName()
  return self.data:GetComponentNameByType(self.ComponentType)
end

function UMG_EditingComponent_C:OnResetDialogCallBack(isOk)
  Log.Debug("UMG_EditingComponent_C:OnResetDialogCallBack() isOk = " .. tostring(isOk))
  if isOk then
    self.data:ResetCurEditCardInfoList(self.ComponentType)
    self.module:DispatchEvent(FriendModuleEvent.UpdateCardComponentEdit)
  end
end

function UMG_EditingComponent_C:OnSaveBtnClicked()
  Log.Debug("UMG_EditingComponent_C:OnSaveBtnClicked()")
  self.isWaitingSaveAndClose = false
  self:RequestSaveComponentHelper(false)
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_EditingComponent_C:OnSaveBtnClicked")
end

function UMG_EditingComponent_C:OnCloseBtnClicked()
  _G.NRCAudioManager:PlaySound2DAuto(41401010, "UMG_EditingComponent_C:OnCloseBtnClicked")
  if not self.data:IsCurEditCardInfoListChanged(_G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET) and not self.data:IsCurEditCardInfoListChanged(_G.ProtoEnum.RoleCardModuleType.RCMT_BADGE) then
    self:OnClose()
    return
  end
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local Context = DialogContext()
  Context:SetTitle(LuaText.TIPS):SetContent(LuaText.rolecard_module_edit_close_save):SetMode(DialogContext.Mode.OK_CANCEL):SetButtonText(LuaText.tips_dialog_butten_accept, LuaText.tips_dialog_butten_cancel):SetCloseOnCancel(true):SetCallback(self, self.OnCloseDialogCallBack):SetClickAnywhereClose(false)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Context)
end

function UMG_EditingComponent_C:OnCloseDialogCallBack(isOk)
  self.isWaitingSaveAndClose = false
  if isOk then
    self.isWaitingSaveAndClose = self:RequestSaveComponentHelper(true)
  end
  Log.Debug("UMG_EditingComponent_C:OnCloseDialogCallBack() isOk = " .. tostring(isOk) .. ", waitingClose = " .. tostring(waitingClose))
  if not self.isWaitingSaveAndClose then
    self:OnClose()
  end
end

function UMG_EditingComponent_C:RequestSaveComponentHelper(checkChanged)
  local doRequest = false
  if not self.data then
    Log.Error("UMG_EditingComponent_C:RequestSaveComponentHelper() self.data is nil")
    return false
  end
  local isPetTabFirst = self.data:GetCurCardComponentType() == _G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET
  
  local function requestPet()
    if self.data:IsCurEditCardInfoListChanged(_G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET) or not checkChanged then
      self.doRequest = true
      local componentId = self.data:GetCardComponentIdByType(_G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET)
      local curEditPetInfoList = self.data:GetCurEditCardInfoList(_G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET)
      local collectPetInfoList = self:GetCollectPetInfoListFromEditList(curEditPetInfoList)
      _G.NRCModuleManager:DoCmd(FriendModuleCmd.OnSetPlayerCardCollectPetInfoReq, componentId, collectPetInfoList)
    end
  end
  
  local function requestBadge()
    if self.data:IsCurEditCardInfoListChanged(_G.ProtoEnum.RoleCardModuleType.RCMT_BADGE) or not checkChanged then
      self.doRequest = true
      local componentId = self.data:GetCardComponentIdByType(_G.ProtoEnum.RoleCardModuleType.RCMT_BADGE)
      local curEditBadgeInfoList = self.data:GetCurEditCardInfoList(_G.ProtoEnum.RoleCardModuleType.RCMT_BADGE)
      local collectBadgeInfoList = self:GetCollectBadgeInfoListFromEditList(curEditBadgeInfoList)
      _G.NRCModuleManager:DoCmd(FriendModuleCmd.OnSetPlayerCardCollectBadgeInfoReq, componentId, collectBadgeInfoList)
    end
  end
  
  if isPetTabFirst then
    requestPet()
    requestBadge()
  else
    requestBadge()
    requestPet()
  end
  return doRequest
end

function UMG_EditingComponent_C:GetCollectPetInfoListFromEditList(curEditPetInfoList)
  local collectPetInfoList = {}
  for _, item in ipairs(curEditPetInfoList) do
    if item and item.petInfo then
      table.insert(collectPetInfoList, item.petInfo)
    end
  end
  return collectPetInfoList
end

function UMG_EditingComponent_C:GetCollectBadgeInfoListFromEditList(curEditBadgeInfoList)
  local collectBadgeInfoList = {}
  for _, item in ipairs(curEditBadgeInfoList) do
    if item and item.fashionInfo then
      table.insert(collectBadgeInfoList, item.fashionInfo)
    end
  end
  return collectBadgeInfoList
end

function UMG_EditingComponent_C:OnSetPlayerCardCollectPetSuccess(cardBriefInfo)
  if self.isWaitingSaveAndClose then
    self.isWaitingSaveAndClose = false
    self:OnClose()
    return
  end
  self.data:InitCurEditCardInfo()
  self.module:DispatchEvent(FriendModuleEvent.UpdateCardComponentEdit)
end

function UMG_EditingComponent_C:InitShowHidePanel()
  self.CanvasDown:SetVisibility(UE4.ESlateVisibility.Visible)
end

return UMG_EditingComponent_C
