local AppearanceUtils = {}

function AppearanceUtils:GetSuitGradeColor(suitGrade)
  local color = "ffffffff"
  local qualityGrade = 0
  if suitGrade == Enum.SuitGrade.SG_DAILY then
    color = "5fb5d5ff"
    qualityGrade = 3
  elseif suitGrade == Enum.SuitGrade.SG_UNIFORM or suitGrade == Enum.SuitGrade.SG_UNIBOND then
    color = "9b73f8ff"
    qualityGrade = 4
  elseif suitGrade == Enum.SuitGrade.SG_BOND then
    color = "f8a955ff"
    qualityGrade = 5
  end
  return color, qualityGrade
end

function AppearanceUtils.GetPIKAQualityPath(quality)
  if 0 == quality then
  elseif 1 == quality then
    return UEPath.PIKA_QUALITY_1
  elseif 2 == quality then
    return UEPath.PIKA_QUALITY_2
  elseif 3 == quality then
    return UEPath.PIKA_QUALITY_3
  elseif 4 == quality then
    return UEPath.PIKA_QUALITY_4
  elseif 5 == quality then
    return UEPath.PIKA_QUALITY_5
  elseif 6 == quality then
    return UEPath.PIKA_QUALITY_Gorgeous_Selected
  end
  return UEPath.PIKA_QUALITY_1
end

function AppearanceUtils:GetPIKABackgroundPath(bHasGorgeous)
  if bHasGorgeous then
    return UEPath.PIKA_QUALITY_Gorgeous
  else
    return UEPath.PIKA_Unselected_Background
  end
end

function AppearanceUtils.GetSuitQuality(suitQuality)
  if suitQuality == Enum.SuitGrade.SG_DAILY then
    return 3
  elseif suitQuality == Enum.SuitGrade.SG_UNIFORM or suitQuality == Enum.SuitGrade.SG_UNIBOND then
    return 4
  elseif suitQuality == Enum.SuitGrade.SG_BOND then
    return 5
  end
  return 3
end

function AppearanceUtils:GetPetIconById(id)
  return string.format("/Game/NewRoco/Modules/System/Common/Icon/HeadIcon/%s.%s", id, id)
end

function AppearanceUtils.GetFashionLabelSortPriority(targetLabelType, DataStoreTable)
  if not targetLabelType then
    return math.maxinteger
  end
  DataStoreTable = DataStoreTable or {}
  if table.isEmpty(DataStoreTable) then
    local config = _G.DataConfigManager:GetRoleGlobalConfig("fashion_label_sort")
    if config and config.numList then
      for priority, labelType in ipairs(config.numList) do
        DataStoreTable[labelType] = priority
      end
    end
  end
  return DataStoreTable and DataStoreTable[targetLabelType] or math.maxinteger
end

function AppearanceUtils.GetWardrobeIconPath(fashionItems)
  local dressIconPath
  if fashionItems and #fashionItems > 0 then
    for k, v in ipairs(fashionItems) do
      if v and 0 ~= v.wearing_item_id then
        local fashionItem = _G.DataConfigManager:GetFashionItemConf(v.wearing_item_id)
        if fashionItem and (fashionItem.type == _G.Enum.FashionLabelType.FLT_DRESSES or fashionItem.type == _G.Enum.FashionLabelType.FLT_TOPS) then
          dressIconPath = fashionItem.icon
          break
        end
      end
    end
    if not dressIconPath then
      local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
      if 1 == player.gender then
        dressIconPath = "Texture2D'/Game/NewRoco/Modules/System/Appearance/Raw/Icon/10700001.10700001'"
      else
        dressIconPath = "Texture2D'/Game/NewRoco/Modules/System/Appearance/Raw/Icon/20700001.20700001'"
      end
    end
  end
  return dressIconPath
end

function AppearanceUtils.GetWardrobeGlassInfo(fashionItems)
  local dressGlassInfo
  local isGlassItem = false
  if fashionItems and #fashionItems > 0 then
    for k, v in ipairs(fashionItems) do
      if v and 0 ~= v.wearing_item_id then
        local fashionItem = _G.DataConfigManager:GetFashionItemConf(v.wearing_item_id)
        if fashionItem and (fashionItem.type == _G.Enum.FashionLabelType.FLT_DRESSES or fashionItem.type == _G.Enum.FashionLabelType.FLT_TOPS) then
          dressGlassInfo = v.wearing_glass
          if dressGlassInfo then
            isGlassItem = true
          end
        elseif fashionItem and fashionItem.type == _G.Enum.FashionLabelType.FLT_HATS and not dressGlassInfo then
          dressGlassInfo = v.wearing_glass
          if dressGlassInfo then
            isGlassItem = true
          end
        end
      end
    end
  end
  return isGlassItem, dressGlassInfo
end

function AppearanceUtils.CheckIsGlassItem(item_id)
  local fashionInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerFashionInfo()
  if fashionInfo then
    local ownedItemInfo = fashionInfo.owned_item_info
    for _, item in pairs(ownedItemInfo or {}) do
      if item and item.item_id == item_id then
        if item.unlocked_glass and #item.unlocked_glass > 0 then
          return true
        end
        if item.claimable_glass and #item.claimable_glass > 0 then
          return true
        end
        break
      end
    end
  end
  return false
end

return AppearanceUtils
