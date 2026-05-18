local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_GollumBallItem_C = Base:Extend("UMG_GollumBallItem_C")

function UMG_GollumBallItem_C:OnConstruct()
end

function UMG_GollumBallItem_C:OnDestruct()
end

function UMG_GollumBallItem_C:OnItemUpdate(_data, datalist, index)
  self.isItemSelected = false
  self.data = _data
  self.index = index
  local isRefreshSelectIndex = false
  local exchangeId, _, _ = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetAlchemyItem)
  if 0 ~= exchangeId then
    for _, v in ipairs(_data.DataList) do
      if v.exchangeId == exchangeId then
        isRefreshSelectIndex = true
        break
      end
    end
  end
  if isRefreshSelectIndex then
    self:UpdateExchangeIndex()
  else
    self.exchangeIndex = 1
  end
  self:SelectExchangeIndex(self.exchangeIndex)
end

function UMG_GollumBallItem_C:SelectExchangeIndex(Index)
  if not self.data then
    return
  end
  local data = self.data.DataList[Index]
  if not data then
    return
  end
  local get_item = data.get_item
  self:SetGetItemIcon(get_item)
end

function UMG_GollumBallItem_C:GetBallNumInBattle(BallId)
  local player = _G.BattleManager.battlePawnManager.TeamatePlayer
  if not player then
    Log.Error("UMG_GollumBallItem_C:CreateBalls player is nil")
    return 0
  end
  local itemData = player.itemInfo or {}
  for _, v in ipairs(itemData) do
    if v.num > 0 and v.item_type == ProtoEnum.BagItemType.BI_PET_BALL and v.item_conf_id == BallId then
      return v.num
    end
  end
  return 0
end

function UMG_GollumBallItem_C:SetGetItemIcon(get_item)
  local get_goods_type = get_item and get_item.get_goods_type
  if get_goods_type == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(get_item.get_goods_id)
    if bagItemConf then
      local bagItem, id = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemByID, bagItemConf.id)
      local bagItemNum = self:GetBallNumInBattle(get_item.get_goods_id)
      self.getBagItemConf = bagItemConf
      self:SetQuality(bagItemConf.item_quality)
      if bagItemConf.type == _G.Enum.BagItemType.BI_SKILL_MACHINE then
        local skillMachineId = bagItemConf.item_behavior[1].ratio[1]
        local skillConf = _G.DataConfigManager:GetSkillConf(skillMachineId)
        self:SetNumSize(bagItemNum)
        self.IconText:SetText(string.format("\195\151%d", bagItemNum))
        self.IconText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        self.ICON_2:SetPath(bagItemConf.icon)
        self:SetNumSize(bagItemNum)
        self.IconText:SetText(string.format("\195\151%d", bagItemNum))
        self.IconText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  elseif get_goods_type == _G.Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(get_item.get_goods_id)
    if vItemConf then
      local vItemNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(vItemConf.id) or 0
      self:SetQuality(vItemConf.item_quality)
      self.ICON_2:SetPath(vItemConf.iconPath)
      self:SetNumSize(vItemNum)
      self.IconText:SetText(string.format("\195\151%d", vItemNum))
      self.IconText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end

function UMG_GollumBallItem_C:SetNumSize(Count)
  local number = Count
  local numberStr = tostring(number)
  local length = string.len(numberStr)
  local Font = self.IconText.Font
  if length > 5 then
    Font.Size = 22
    self.IconText:SetFont(Font)
  end
end

function UMG_GollumBallItem_C:GetItemNum(goods_id)
  local bagItemData, index = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByID, goods_id)
  if nil == bagItemData then
    return 0
  end
  return bagItemData.num
end

function UMG_GollumBallItem_C:OnItemSelected(_bSelected, _bScrollSelect)
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  if _bSelected then
    if _bScrollSelect then
      self:StopAllAnimations()
      self:PlayAnimation(self.select)
    elseif self.isItemSelected then
    else
      self.isItemSelected = true
      self:StopAllAnimations()
      self:PlayAnimation(self.change1)
      if self.data then
        _G.NRCEventCenter:DispatchEvent(_G.AlchemyModuleEvent.AlchemyItemChanged, self.data.DataList[self.exchangeIndex].exchangeId, self.index, self.exchangeIndex)
      end
    end
  else
    self.exchangeIndex = 1
    if self.isItemSelected then
      self.isItemSelected = false
      self:StopAllAnimations()
      self:PlayAnimation(self.change2)
    else
      self:StopAllAnimations()
      self:PlayAnimation(self.normal)
    end
  end
end

function UMG_GollumBallItem_C:OnDespawn()
  self:StopAllAnimations()
  self:PlayAnimation(self.normal)
end

function UMG_GollumBallItem_C:OnAnimationFinished(Animation)
  if self.isItemSelected then
  end
end

function UMG_GollumBallItem_C:OnDeactive()
end

function UMG_GollumBallItem_C:SetIconText(SlateColor)
  self.Quality:SetColorAndOpacity(SlateColor)
end

function UMG_GollumBallItem_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self:SetIconText(UE4.UNRCStatics.HexToLinearColor("#afac9fff"))
    self.SelectBGColor_1:SetPath(UEPath.PROP_QUALITY_1)
  elseif 2 == quality then
    self:SetIconText(UE4.UNRCStatics.HexToLinearColor("#5ca011ff"))
    self.SelectBGColor_1:SetPath(UEPath.PROP_QUALITY_2)
  elseif 3 == quality then
    self:SetIconText(UE4.UNRCStatics.HexToLinearColor("#42a7ccff"))
    self.SelectBGColor_1:SetPath(UEPath.PROP_QUALITY_3)
  elseif 4 == quality then
    self:SetIconText(UE4.UNRCStatics.HexToLinearColor("#7f4dffff"))
    self.SelectBGColor_1:SetPath(UEPath.PROP_QUALITY_4)
  elseif 5 == quality then
    self:SetIconText(UE4.UNRCStatics.HexToLinearColor("#efa012ff"))
    self.SelectBGColor_1:SetPath(UEPath.PROP_QUALITY_5)
  end
end

function UMG_GollumBallItem_C:UpdateExchangeIndex()
  local _, _, selectedIndex = _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.GetAlchemyItem)
  if self.data and self.data.DataList[selectedIndex] and self.data.DataList[selectedIndex].canExchangeNum > 0 then
    self.exchangeIndex = selectedIndex
    return
  end
  
  local function _SortFunc(a, b)
    local canExchangeA = a.canExchangeNum > 0 and 1 or 0
    local canExchangeB = b.canExchangeNum > 0 and 1 or 0
    if canExchangeA ~= canExchangeB then
      return canExchangeA > canExchangeB
    else
      return a.exchangeId < b.exchangeId
    end
  end
  
  table.sort(self.data.DataList, _SortFunc)
  self.exchangeIndex = 1
end

function UMG_GollumBallItem_C:RefreshCount()
  self:SelectExchangeIndex(self.exchangeIndex)
end

function UMG_GollumBallItem_C:UpdateInfoIcon(get_item)
  self:SetGetItemIcon(get_item)
  self.Obturation:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_GollumBallItem_C:SetSelectIndex(exchangeId)
  self.exchangeIndex = exchangeId
end

return UMG_GollumBallItem_C
