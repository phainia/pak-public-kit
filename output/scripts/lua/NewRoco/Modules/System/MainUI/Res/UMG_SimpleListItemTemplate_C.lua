local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local UMG_SimpleListItemTemplate_C = Base:Extend("UMG_SimpleListItemTemplate_C")

function UMG_SimpleListItemTemplate_C:OnConstruct()
end

function UMG_SimpleListItemTemplate_C:OnDestruct()
end

function UMG_SimpleListItemTemplate_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data.itemInfo
  self.index = index
  self:UpdateItemInfo()
end

function UMG_SimpleListItemTemplate_C:UpdateItemInfo()
  self:SetSelectedVisible(false)
  self:StopAllAnimations()
  self.NRCSwitcher_44:SetActiveWidgetIndex(0)
  local getEquipItem = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetCurEquipItemInfo)
  local getEquipMagic = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetEquipMagicInfo)
  local bShowQuantity = true
  if self.uiData then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.uiData.id)
    if bagItemConf then
      local itemNum = self.uiData.num
      bShowQuantity = 0 ~= bagItemConf.show_quantity
      if not bShowQuantity then
        self:SetNumVisible(false)
      else
        self:SetNumVisible(true)
      end
      if bagItemConf.type == _G.Enum.BagItemType.BI_PET_BALL then
        self:SetQuality(0)
        self:SetTagIcon(false, "")
        if getEquipItem and getEquipItem.gid == self.uiData.gid then
          self:SetSelectedVisible(true)
          self:PlayAnimation(self.change2, 0)
          self:PauseAnimation(self.change2)
        else
          self:SetSelectedVisible(false)
          self:PlayAnimation(self.normal)
        end
        self.ItemIcon:SetPath(NRCUtils:FormatConfIconPath(bagItemConf.icon, _G.UIIconPath.BagItemPath))
        self.ItemIcon_Mask:SetPath(NRCUtils:FormatConfIconPath(bagItemConf.icon, _G.UIIconPath.BagItemPath))
        self.ItemIcon_Mask:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.CornerMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
        if 0 == itemNum then
          self.NumText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#c7494aff"))
        else
          self.NumText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#f4eee1ff"))
        end
      elseif bagItemConf.type == _G.Enum.BagItemType.BI_MAGIC then
        bShowQuantity = false
        self:SetQuality(0)
        self:SetSelectedVisible(false)
        if getEquipMagic and getEquipMagic.gid == self.uiData.gid then
          self:PlayAnimation(self.select)
          self:SetTagIcon(true, "")
        else
          self:PlayAnimation(self.normal)
          self:SetTagIcon(false, "")
        end
        self.ItemIcon:SetPath(bagItemConf.TUIbutton_icon)
        local magicBaseConf = _G.DataConfigManager:GetMagicBaseConf(bagItemConf.magic_id)
        local abilityHelper
        if magicBaseConf then
          abilityHelper = AbilityHelperManager.GetHelper(magicBaseConf.sceneability)
        end
        if abilityHelper then
          if abilityHelper.InitFromConf then
            abilityHelper:InitFromConf(bagItemConf.id, bagItemConf.magic_id, magicBaseConf.sceneability)
          end
          local localPlayer = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
          self.bIsBlock, self.MyAbilityErrorCode = abilityHelper:IsBlock(localPlayer)
          self.ItemIcon_Mask:SetPath(bagItemConf.TUIbutton_icon)
          local costItemId = magicBaseConf.cost_bag_item[1]
          local costNum = magicBaseConf.cost_bag_item[2]
          local OwnedNum = 0
          if nil == costItemId then
            costNum = -1
          else
            local ownedItemData = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemByID, costItemId)
            if ownedItemData and ownedItemData.num then
              OwnedNum = ownedItemData.num
            end
          end
          local isBan = _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.ExceptMyAbilityErrorCode, self.MyAbilityErrorCode)
          if not self.bIsBlock or self.bIsBlock and not isBan then
            local usableTimes = OwnedNum / costNum
            itemNum = math.floor(usableTimes)
            if costItemId then
              local costBagItemConf = _G.DataConfigManager:GetBagItemConf(costItemId, true)
              if costBagItemConf then
                bShowQuantity = costNum > 0 and 0 ~= costBagItemConf.show_quantity
              end
            end
            self.ItemIcon_Mask:SetVisibility(UE4.ESlateVisibility.Collapsed)
            self.CornerMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
            if itemNum > 0 then
              self.NumText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#f4eee1ff"))
            else
              self.NumText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#c7494aff"))
            end
          else
            self.ItemIcon_Mask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
            self.CornerMark:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
            self.CornerMark:SetPath("PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUI/Frames/img_Forbidden_png.img_Forbidden_png'")
          end
          self:SetNumVisible(bShowQuantity)
          if self.bIsBlock and isBan then
            itemNum = nil
            self.ItemIcon_Mask:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
            self.CornerMark:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
            self.NumText:SetVisibility(UE4.ESlateVisibility.Hidden)
          end
        end
      end
      local showNumStr = _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.GetBallOrMagicShowCountText, itemNum, bagItemConf.type)
      self.NumText:SetText(showNumStr)
    end
  else
    self.NRCSwitcher_44:SetActiveWidgetIndex(1)
  end
end

function UMG_SimpleListItemTemplate_C:SetQuality(quality)
  if 0 == quality then
    self.BGColor:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.BGColor:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if 0 == quality then
  elseif 1 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_1)
  elseif 2 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_2)
  elseif 3 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_3)
  elseif 4 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_4)
  elseif 5 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_5)
  end
end

function UMG_SimpleListItemTemplate_C:SetTagIcon(visible, path)
  if visible then
    self.TagIcon:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.TagIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_SimpleListItemTemplate_C:OnItemSelected(_bSelected)
  self:StopAllAnimations()
  if self.uiData then
    local itemConf = _G.DataConfigManager:GetBagItemConf(self.uiData.id)
    if _bSelected then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1305, "UMG_SimpleListItemTemplate_C:OnItemSelected")
      self:PlayAnimation(self.change1)
      if itemConf.type == _G.Enum.BagItemType.BI_MAGIC then
        _G.NRCModuleManager:DoCmd(BagModuleCmd.SetEquipMagicInfo, self.uiData, true)
      elseif itemConf.type == _G.Enum.BagItemType.BI_PET_BALL then
        _G.NRCModuleManager:DoCmd(BagModuleCmd.SetCurEquipItemInfo, self.uiData)
      end
      _G.NRCModuleManager:DoCmd(MainUIModuleCmd.UI_SetSimpleUseListVisible, false)
    else
      self:PlayAnimation(self.change2)
    end
  end
end

function UMG_SimpleListItemTemplate_C:SetSelectedVisible(visible)
  if visible then
    self.Selected:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Selected:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_SimpleListItemTemplate_C:SetNumVisible(visible)
  if visible then
    self.NumText:SetVisibility(UE4.ESlateVisibility.Visible)
    self.TextBG:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.NumText:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.TextBG:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_SimpleListItemTemplate_C:OnAnimationFinished(Animation)
  if Animation == self.change1 then
    self:PlayAnimation(self.select, 0, 99999)
  end
  if Animation == self.change2 then
  end
end

function UMG_SimpleListItemTemplate_C:OnDeactive()
end

function UMG_SimpleListItemTemplate_C:GetGuidanceCustomListIndex()
  if self.uiData then
    return self.uiData.id
  end
  return self._index
end

return UMG_SimpleListItemTemplate_C
