local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local SleepingOwlModuleEvent = require("NewRoco.Modules.System.SleepingOwl.SleepingOwlModuleEvent")
local UMG_SleepingOwl_FruitItem_C = Base:Extend("UMG_SleepingOwl_FruitItem_C")

function UMG_SleepingOwl_FruitItem_C:OnConstruct()
end

function UMG_SleepingOwl_FruitItem_C:OnDestruct()
end

function UMG_SleepingOwl_FruitItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self:UpdateItemIcon()
end

function UMG_SleepingOwl_FruitItem_C:UpdateItemIcon()
  self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Advantage:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.InferiorPosition:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.data.BagItem.id)
  self:SetQuality(bagItemConf.item_quality)
  self.Icon:SetPath(NRCUtils:FormatConfIconPath(bagItemConf.icon, _G.UIIconPath.BagItemPath))
  local isHaveBook, itemName = _G.NRCModeManager:DoCmd(_G.HandbookModuleCmd.OnCmdCheckItemInHandbook, self.data.BagItem.id)
  if isHaveBook then
    self.Name:SetText(itemName)
  else
    self.Name:SetText(bagItemConf.name)
  end
  local notCdFruit = _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.OnGetFruitCd, self.data.BagItem.fruit_active_timestamp)
  local text = self:TruncateChineseCharacters(string.format(_G.DataConfigManager:GetLocalizationConf("pet_fruit_use_tips").msg))
  self.Describe:SetText(text)
  self.txtLV:SetText(self.data.BagItem.num)
  self.Countdown:SetVisibility(notCdFruit and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  if false == notCdFruit then
    self.Describe:SetText(LuaText.pet_fruit_use_tips_cd)
  end
  if 1 == self.data.type then
    self.InferiorPosition:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Advantage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Ash:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif 3 == self.data.type then
    self.Advantage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.InferiorPosition:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Ash:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local text = self:TruncateChineseCharacters(_G.DataConfigManager:GetLocalizationConf("pet_fruit_advantage_tips").msg)
    self.Describe:SetText(text)
  else
    self.Advantage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.InferiorPosition:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Ash:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  for i = 1, #self.data.pet_form_factor_tag do
    if self.data.pet_form_factor_tag[i] ~= Enum.PetFormFacto.PFF_NORMAL then
      if 1 == self.data.type then
        self.NRCImage_124:SetVisibility(UE4.ESlateVisibility.Collapsed)
        break
      end
      self.NRCImage_124:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Describe:SetText(LuaText.pet_fruit_use_tips_change)
      break
    end
    if i == #self.data.pet_form_factor_tag then
      self.NRCImage_124:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self.data.isDisabled then
    self.InferiorPosition:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Countdown:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Advantage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Ash:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCImage_124:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    if self:IsLandWaterDisable() then
      self.Describe:SetText(LuaText.pet_fruit_use_tips_ban_landwater)
    elseif self:IsDisableDesc(30004) then
      self.Describe:SetText(LuaText.pet_fruit_use_tips_ban_land)
    elseif self:IsDisableDesc(30001) then
      self.Describe:SetText(LuaText.pet_fruit_use_tips_ban_water)
    else
      self.Describe:SetText(LuaText.pet_fruit_disable)
    end
    self.Name:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("BD3D3CFF"))
    self.Describe:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("BD3D3CFF"))
  else
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.InferiorPosition:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Ash:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Name:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("908F85FF"))
    self.Describe:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("62605EFF"))
    if not notCdFruit then
      self.Describe:SetText(LuaText.pet_fruit_cd_tips)
    end
  end
end

function UMG_SleepingOwl_FruitItem_C:OnUpdateTime()
  local notCdFruit = _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.OnGetFruitCd, self.data.BagItem.fruit_active_timestamp)
  if notCdFruit and self.data then
    self.Countdown:SetVisibility(UE4.ESlateVisibility.Collapsed)
    local text = self:TruncateChineseCharacters(string.format(_G.DataConfigManager:GetLocalizationConf("pet_fruit_use_tips").msg))
    self.Describe:SetText(text)
    self.txtLV:SetText(self.data.BagItem.num)
    self.Countdown:SetVisibility(notCdFruit and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
    if 1 == self.data.type then
      self.InferiorPosition:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Advantage:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Ash:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    elseif 3 == self.data.type then
      self.Advantage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.InferiorPosition:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Ash:SetVisibility(UE4.ESlateVisibility.Collapsed)
      local str = self:TruncateChineseCharacters(_G.DataConfigManager:GetLocalizationConf("pet_fruit_advantage_tips").msg)
      self.Describe:SetText(str)
    else
      self.Advantage:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.InferiorPosition:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Ash:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    for i = 1, #self.data.pet_form_factor_tag do
      if self.data.pet_form_factor_tag[i] ~= Enum.PetFormFacto.PFF_NORMAL then
        if 1 == self.data.type then
          self.NRCImage_124:SetVisibility(UE4.ESlateVisibility.Collapsed)
          break
        end
        self.NRCImage_124:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.Describe:SetText(LuaText.pet_fruit_use_tips_change)
        break
      end
      if i == #self.data.pet_form_factor_tag then
        self.NRCImage_124:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    if self.data.isDisabled then
      self.InferiorPosition:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Countdown:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Advantage:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Ash:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.NRCImage_124:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      if self:IsLandWaterDisable() then
        self.Describe:SetText(LuaText.pet_fruit_use_tips_ban_landwater)
      elseif self:IsDisableDesc(30004) then
        self.Describe:SetText(LuaText.pet_fruit_use_tips_ban_land)
      elseif self:IsDisableDesc(30001) then
        self.Describe:SetText(LuaText.pet_fruit_use_tips_ban_water)
      else
        self.Describe:SetText(LuaText.pet_fruit_disable)
      end
      if not self.isSelect then
        self.Name:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("BD3D3CFF"))
        self.Describe:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("BD3D3CFF"))
      end
    else
      self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.InferiorPosition:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Ash:SetVisibility(UE4.ESlateVisibility.Collapsed)
      if not self.isSelect then
        self.Name:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("908F85FF"))
        self.Describe:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("62605EFF"))
      end
    end
  end
end

function UMG_SleepingOwl_FruitItem_C:IsDisableDesc(id)
  local bagId = self.data.BagItem.id
  local contentId = _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.OnCmdGetOwlSanctuaryContentId)
  local sanctuaryConf = _G.DataConfigManager:GetOwlSanctuaryConf(contentId)
  local fruitConf = _G.DataConfigManager:GetOwlPetFruitConf(bagId)
  if sanctuaryConf and sanctuaryConf.owl_area_group and fruitConf and fruitConf.pet_refresh then
    if 30004 == id then
      for _, refresh in pairs(fruitConf.pet_refresh) do
        local npcIds = refresh.npc_id
        for _, npcId in pairs(npcIds) do
          local cfg = _G.DataConfigManager:GetOwlContentNpcConf(npcId)
          if not (cfg and cfg.is_land_pet) or cfg.is_water_pet or next(sanctuaryConf.visit_owl_refresh_polygon) then
          else
            return true
          end
        end
      end
    elseif 30001 == id then
      for _, refresh in pairs(fruitConf.pet_refresh) do
        local npcIds = refresh.npc_id
        for _, npcId in pairs(npcIds) do
          local cfg = _G.DataConfigManager:GetOwlContentNpcConf(npcId)
          if not (cfg and cfg.is_water_pet) or cfg.is_land_pet or next(sanctuaryConf.visit_water_owl_refresh_polygon) then
          else
            return true
          end
        end
      end
    end
  end
  return false
end

function UMG_SleepingOwl_FruitItem_C:IsLandWaterDisable()
  local bagId = self.data.BagItem.id
  local contentId = _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.OnCmdGetOwlSanctuaryContentId)
  local sanctuaryConf = _G.DataConfigManager:GetOwlSanctuaryConf(contentId)
  local fruitConf = _G.DataConfigManager:GetOwlPetFruitConf(bagId)
  if sanctuaryConf and sanctuaryConf.owl_area_group and fruitConf and fruitConf.pet_refresh then
    for _, refresh in pairs(fruitConf.pet_refresh) do
      local npcIds = refresh.npc_id
      for _, npcId in pairs(npcIds) do
        local cfg = _G.DataConfigManager:GetOwlContentNpcConf(npcId)
        if not (cfg and cfg.is_land_pet and cfg.is_water_pet) or next(sanctuaryConf.visit_owl_refresh_polygon) and next(sanctuaryConf.visit_water_owl_refresh_polygon) then
        else
          return true
        end
      end
    end
  end
  return false
end

function UMG_SleepingOwl_FruitItem_C:CountChineseCharacters(str)
  local count = 0
  for _, char in utf8.codes(str) do
    if char >= 19968 and char <= 40869 then
      count = count + 1
    end
  end
  return count
end

function UMG_SleepingOwl_FruitItem_C:TruncateChineseCharacters(str)
  local chineseCount = self:CountChineseCharacters(str)
  if chineseCount > 12 then
    local truncatedStr = str
    local removedCount = 0
    for _, char in utf8.codes(str) do
      if char >= 19968 and char <= 40869 then
        removedCount = removedCount + 1
        if removedCount > chineseCount - 2 then
          truncatedStr = string.gsub(truncatedStr, utf8.char(char), "", 1)
        end
      end
    end
    return truncatedStr
  else
    return str
  end
end

function UMG_SleepingOwl_FruitItem_C:OnItemSelected(_bSelected)
  self:StopAllAnimations()
  if _bSelected then
    self:PlayAnimation(self.Select1)
    self.Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    _G.NRCModeManager:DoCmd(_G.SleepingOwlModuleCmd.SetSelectedFruitItem, self.index, self.data)
    if self.CanOpenTips then
      self.CanOpenTips = false
      _G.NRCModeManager:DoCmd(_G.SleepingOwlModuleCmd.OpenOwlFruitTipsPanel, self.data)
    else
      _G.NRCAudioManager:PlaySound2DAuto(1003, "CampingModule:OpenNourishRightFruit")
    end
    self.CanOpenTips = true
  else
    self.CanOpenTips = false
    self:PlayAnimation(self.Unselect)
    self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.isSelect = _bSelected
end

function UMG_SleepingOwl_FruitItem_C:OnDeactive()
end

function UMG_SleepingOwl_FruitItem_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.Quality:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

return UMG_SleepingOwl_FruitItem_C
