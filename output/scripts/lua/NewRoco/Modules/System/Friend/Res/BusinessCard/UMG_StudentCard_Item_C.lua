local Base = require("NewRoco.Modules.System.Friend.Res.BusinessCard.UMG_StudentCard_DragableItem_C")
local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local UIUtils = require("NewRoco.Utils.UIUtils")
local UMG_StudentCard_Item_C = Base:Extend("UMG_StudentCard_Item_C")

function UMG_StudentCard_Item_C:IsValidItem()
  return self.data
end

function UMG_StudentCard_Item_C:OnConstruct()
  self.IsPlayIn = true
  self.BtnBlacklist.OnClicked:Add(self, self.OnDeleteItem)
  self.BtnBlacklist_1.OnClicked:Add(self, self.OnDeleteItem)
end

function UMG_StudentCard_Item_C:OnDestruct()
end

function UMG_StudentCard_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.module = _G.NRCModuleManager:GetModule("FriendModule")
  self.moduleData = self.module:GetData("FriendModuleData")
  if not self:IsValidItem() then
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
    return
  end
  if self.data.ComponentType == _G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET then
    self.NRCSwitcher_0:SetActiveWidgetIndex(0)
    self:InitPetInfo()
  else
    self.NRCSwitcher_0:SetActiveWidgetIndex(1)
    self:InitBadgeInfo()
  end
  if self.IsPlayIn then
    self:PlayAnimation(self.In)
    self.IsPlayIn = false
  end
end

function UMG_StudentCard_Item_C:SetReplaceElfHead(_data)
  self.Icon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.IconBg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Add:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Mask:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Name:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.IconBg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(_data.SystemType.rolecard_favorite_pets_colour))
  self.Icon:SetPath(_data.SystemType.rolecard_favorite_pets_icon)
end

function UMG_StudentCard_Item_C:SetPanelInfo()
  self.Text_21:SetText(self.data.name)
  if self.data.battle_count or self.data.collect_count or self.data.follow_duration then
    self.CanvasPanel_10:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local count
    if 1 == self.index then
      count = self.data.battle_count
      if self:IsMaxCount(count) then
        count = 999
      end
      self.Number:SetText(string.format("%s%s", count, LuaText.umg_studentcard_item_1))
    elseif 2 == self.index then
      count = self.data.collect_count
      if self:IsMaxCount(count) then
        count = 999
      end
      self.Number:SetText(string.format("%s%s", count, LuaText.umg_studentcard_item_1))
    else
      local min = math.floor(self.data.follow_duration / 60)
      local hour = math.floor(min / 60)
      local day = math.floor(hour / 24)
      count = day
      local Text
      if day > 0 then
        if self:IsMaxCount(day) then
          day = 999
        end
        Text = string.format("%s%s", day, LuaText.umg_studentcard_item_2)
      elseif hour < 1 then
        Text = string.format("<%s%s", 1, LuaText.umg_studentcard_item_3)
      else
        Text = string.format("%s%s", hour, LuaText.umg_studentcard_item_3)
      end
      self.Number:SetText(Text)
    end
    Log.Debug(count, "1111")
    if count >= 999 then
      self.NRCText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.data.pet_base_id then
      local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.data.pet_base_id)
      local modelConf = _G.DataConfigManager:GetModelConf(PetBaseConf.model_conf)
      self.Pet:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Name:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.NRCImage_44:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Pet:SetPath(modelConf.icon)
      self.Name:SetText(PetBaseConf.name)
    end
  end
end

function UMG_StudentCard_Item_C:IsMaxCount(count)
  if count > 999 then
    return true
  end
  return false
end

function UMG_StudentCard_Item_C:InitializedShow()
end

function UMG_StudentCard_Item_C:InitPetInfo()
  if self.Icon then
    self.Icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Add then
    self.Add:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Name then
    self.Name:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:SetMoveShow(false)
  self:SetSelectedState(false)
  if self.data.petInfo and 0 ~= self.data.petInfo.pet_base_id and _G.DataConfigManager:GetPetbaseConf(self.data.petInfo.pet_base_id) then
    self.Pet:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Add:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Empty:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.IconBg:SetVisibility(UE4.ESlateVisibility.Visible)
    self.BigIconBg:SetVisibility(UE4.ESlateVisibility.Visible)
    if self:IsEditMode() then
      self.BtnBlacklist:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.BtnBlacklist:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.data.petInfo.pet_base_id)
    local typeDic = _G.DataConfigManager:GetTypeDictionary(self.data.petInfo.skill_dam_type)
    if typeDic then
      self.IconBg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(typeDic.rolecard_favorite_pets_colour))
    end
    if PetBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(PetBaseConf.model_conf)
      if modelConf then
        local mutation_type = self.data.petInfo.mutation_diff_type
        if PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
          self.Pet:SetPath(modelConf.shiny_icon)
        else
          self.Pet:SetPath(NRCUtils:FormatConfIconPath(modelConf.icon, _G.UIIconPath.HeadIconPath))
        end
      end
    end
  else
    self.Pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Add:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Empty:SetVisibility(UE4.ESlateVisibility.Visible)
    self.BtnBlacklist:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.IconBg:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.BigIconBg:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_StudentCard_Item_C:InitBadgeInfo()
  UIUtils.SafeSetVisibility(self.move_1, UE4.ESlateVisibility.Collapsed)
  self:SetSelectedState(false)
  local fashionData = self.data
  if not fashionData or fashionData:IsCardInfoEmpty() then
    UIUtils.SafeSetVisibility(self.Icon_1, UE4.ESlateVisibility.Collapsed)
    UIUtils.SafeSetVisibility(self.BtnBlacklist_1, UE4.ESlateVisibility.Collapsed)
    UIUtils.SafeSetVisibility(self.Empty_1, UE4.ESlateVisibility.Visible)
    return
  end
  local bondConf = _G.DataConfigManager:GetFashionBondConf(fashionData.fashionInfo.fashion_bond_id)
  if not bondConf then
    Log.Warning("UMG_StudentCard_Item_C:InitBadgeInfo", "Fashion bond config not found for id: " .. tostring(fashionData.fashionInfo.fashion_bond_id))
    UIUtils.SafeSetVisibility(self.Icon_1, UE4.ESlateVisibility.Collapsed)
    UIUtils.SafeSetVisibility(self.BtnBlacklist_1, UE4.ESlateVisibility.Collapsed)
    UIUtils.SafeSetVisibility(self.Empty_1, UE4.ESlateVisibility.Visible)
    return
  end
  self.Icon_1:SetPath(bondConf.fashion_bond_big_icon)
  UIUtils.SafeSetVisibility(self.Icon_1, UE4.ESlateVisibility.Visible)
  UIUtils.SafeSetVisibility(self.Empty_1, UE4.ESlateVisibility.Collapsed)
  if self:IsEditMode() then
    UIUtils.SafeSetVisibility(self.BtnBlacklist_1, UE4.ESlateVisibility.Visible)
  else
    UIUtils.SafeSetVisibility(self.BtnBlacklist_1, UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_StudentCard_Item_C:SetAngle(Angle)
  if self.data:IsCardInfoEmpty() then
    Angle = 0
  end
  self.Pet:SetRenderTransformAngle(Angle)
end

function UMG_StudentCard_Item_C:OnItemSelected(_bSelected, bScrolled)
end

function UMG_StudentCard_Item_C:OnDeleteItem()
  if not self:IsEditMode() then
    return
  end
  if self.data:IsCardInfoEmpty() then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401005, "UMG_StudentCard_Item_C:OnDeleteItem")
  self.moduleData:RemoveCurEditCard(self.data.ComponentType, self.index - 1)
  self.module:DispatchEvent(FriendModuleEvent.UpdateCardComponentEdit)
end

function UMG_StudentCard_Item_C:IsEditMode()
  return self.data.cardShowType == FriendEnum.CardComponentShowType.CardModified
end

function UMG_StudentCard_Item_C:IsEmptyItem()
  if self.data.ComponentType == _G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET then
    if self.data.petInfo and self.data.petInfo.pet_base_id and 0 ~= self.data.petInfo.pet_base_id then
      return false
    end
  elseif self.data.ComponentType == _G.ProtoEnum.RoleCardModuleType.RCMT_BADGE then
  end
  return true
end

function UMG_StudentCard_Item_C:HideBySetAlpha()
  self:SetColorAndOpacity(UE4.FLinearColor(0, 0, 0, 0))
end

function UMG_StudentCard_Item_C:ShowBySetAlpha()
  self:SetColorAndOpacity(UE4.FLinearColor(1, 1, 1, 1))
end

function UMG_StudentCard_Item_C:IsShowDragDropWidget()
  return self:IsEditMode() and not self.data:IsCardInfoEmpty()
end

function UMG_StudentCard_Item_C:IsEnableListScroll()
  return false
end

function UMG_StudentCard_Item_C:IsValidDrag()
  if self.data.cardShowType ~= FriendEnum.CardComponentShowType.CardModified then
    return false
  end
  return not self.data:IsCardInfoEmpty()
end

function UMG_StudentCard_Item_C:GetDragWidgetInitParam()
  return self.data
end

function UMG_StudentCard_Item_C:HandleDragStart(MyGeometry, PointerEvent, BP_CardDragDropOperation_C)
  local widgetRefName = ""
  if BP_CardDragDropOperation_C and BP_CardDragDropOperation_C.WidgetRef then
    widgetRefName = BP_CardDragDropOperation_C.WidgetRef.className or "Unknown"
  end
  Log.Debug("UMG_StudentCard_Item_C:HandleDragStart", widgetRefName)
  if not self.data:IsCardInfoEmpty() then
    self:SetSelectedState(true)
    _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_StudentCard_Item_C:HandleDragStart")
  end
end

function UMG_StudentCard_Item_C:SetSelectedState(isSelected)
  if isSelected then
    UIUtils.SafeSetVisibility(self.Selected, UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.Select)
  else
    UIUtils.SafeSetVisibility(self.Selected, UE4.ESlateVisibility.Collapsed)
    self:PlayAnimation(self.Normal)
  end
end

function UMG_StudentCard_Item_C:SetMoveShow(isShow)
  if isShow then
    UIUtils.SafeSetVisibility(self.move, UE4.ESlateVisibility.SelfHitTestInvisible)
    UIUtils.SafeSetVisibility(self.move_1, UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    UIUtils.SafeSetVisibility(self.move, UE4.ESlateVisibility.Collapsed)
    UIUtils.SafeSetVisibility(self.move_1, UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_StudentCard_Item_C:OnCustomDragFinished()
  self:SetSelectedState(false)
end

function UMG_StudentCard_Item_C:HandleDragEnter(MyGeometry, PointerEvent, Operation)
  if not self:IsEditMode() then
    Log.Debug("UMG_StudentCard_Item_C:HandleDragEnter", "Invalid drag operation, not in edit mode")
    return
  end
  if not Operation or not Operation.WidgetRef then
    Log.Debug("UMG_StudentCard_Item_C:HandleDragEnter", "Operation or Operation.WidgetRef is nil")
    return
  end
  Log.Debug("UMG_StudentCard_Item_C:HandleDragEnter")
  self:SetMoveShow(false)
  if Operation.WidgetRef.className == "UMG_StudentCard_Comp_Item_C" then
    local compItem = Operation.WidgetRef
    if self.data:IsCardInfoEmpty() then
      self:PlayAnimation(self.MovingRange)
    else
      self:SetMoveShow(true)
    end
  elseif Operation.WidgetRef.className == "UMG_StudentCard_Item_C" then
    local dragItem = Operation.WidgetRef
    if dragItem.data and not dragItem.data:IsCardInfoEmpty() and dragItem ~= self then
      if self.data:IsCardInfoEmpty() then
        self:PlayAnimation(self.MovingRange)
      else
        self:SetMoveShow(true)
      end
    end
  else
    Log.Error("UMG_StudentCard_Item_C:HandleDragEnter", "Unknown WidgetRef className: " .. tostring(Operation.WidgetRef.className))
  end
end

function UMG_StudentCard_Item_C:HandleDragLeave(PointerEvent, Operation)
  if not self:IsEditMode() then
    Log.Debug("UMG_StudentCard_Item_C:HandleDragLeave", "Invalid drag operation, not in edit mode")
    return
  end
  if not Operation or not Operation.WidgetRef then
    Log.Debug("UMG_StudentCard_Item_C:HandleDragLeave", "Operation or Operation.WidgetRef is nil")
    return
  end
  Log.Debug("UMG_StudentCard_Item_C:HandleDragLeave")
  if self.data:IsCardInfoEmpty() then
    self:PlayAnimationReverse(self.MovingRange)
  else
    self:SetMoveShow(false)
  end
end

function UMG_StudentCard_Item_C:HandleDrop(MyGeometry, PointerEvent, Operation)
  if not self:IsEditMode() then
    Log.Debug("UMG_StudentCard_Item_C:HandleDrop", "Invalid drag operation, not in edit mode")
    return
  end
  if not Operation or not Operation.WidgetRef then
    Log.Debug("UMG_StudentCard_Item_C:HandleDrop", "Operation or Operation.WidgetRef is nil")
    return
  end
  Log.Debug("UMG_StudentCard_Item_C:HandleDrop")
  if self.data:IsCardInfoEmpty() then
    self:PlayAnimationReverse(self.MovingRange)
  end
  self:SetMoveShow(false)
  if Operation.WidgetRef.className == "UMG_StudentCard_Item_C" then
    local dragItem = Operation.WidgetRef
    local dragCardInfo
    if dragItem.data and not dragItem.data:IsCardInfoEmpty() then
      dragCardInfo = dragItem.data
    else
      Log.Error("UMG_StudentCard_Item_C:HandleDrop", "dragItem.data is not valid")
      goto lbl_160
    end
    local dropPosIndex = self.index - 1
    local dragPosIndex = dragCardInfo:GetIndex()
    if dropPosIndex == dragPosIndex then
      Log.Debug("UMG_StudentCard_Item_C:HandleDrop", "dragPosIndex = dropPosIndex =" .. dragPosIndex .. ", ignore")
      goto lbl_160
    elseif not self.data:IsCardInfoEmpty() then
      self.moduleData:SwapCurEditCardInfo(self.data.ComponentType, dropPosIndex, dragPosIndex)
      _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_StudentCard_Item_C:HandleDrop")
    else
      self.moduleData:RemoveCurEditCard(self.data.ComponentType, dragPosIndex)
      self.moduleData:AddOrReplaceCurEditCardInfo(dropPosIndex, dragCardInfo)
      _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_StudentCard_Item_C:HandleDrop")
    end
  elseif Operation.WidgetRef.className == "UMG_StudentCard_Comp_Item_C" then
    local dragItem = Operation.WidgetRef
    local dragCardInfo
    if dragItem.data and not dragItem.data:IsCardInfoEmpty() then
      dragCardInfo = dragItem.data
    else
      Log.Error("UMG_StudentCard_Item_C:HandleDrop", "dragItem.data.petInfo is nil")
      goto lbl_160
    end
    local posIndex = self.index - 1
    self.moduleData:AddOrReplaceCurEditCardInfo(posIndex, dragCardInfo)
    _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_StudentCard_Item_C:HandleDrop")
  else
    Log.Error("UMG_StudentCard_Item_C:HandleDrop", "Unknown WidgetRef className: " .. tostring(Operation.WidgetRef.className))
  end
  ::lbl_160::
  self.module:DispatchEvent(FriendModuleEvent.UpdateCardComponentEdit)
end

function UMG_StudentCard_Item_C:HandleDragCancelled(PointerEvent, Operation)
  if not self:IsEditMode() then
    Log.Debug("UMG_StudentCard_Item_C:HandleDragCancelled", "Invalid drag operation, not in edit mode")
    return
  end
  Log.Debug("UMG_StudentCard_Item_C:HandleDragCancelled")
  if not Operation or not Operation.WidgetRef then
    Log.Debug("UMG_StudentCard_Item_C:HandleDragCancelled", "Operation or Operation.WidgetRef is nil")
    return
  end
  self.module:DispatchEvent(FriendModuleEvent.UpdateCardComponentEdit)
end

function UMG_StudentCard_Item_C:OnDeactive()
end

return UMG_StudentCard_Item_C
