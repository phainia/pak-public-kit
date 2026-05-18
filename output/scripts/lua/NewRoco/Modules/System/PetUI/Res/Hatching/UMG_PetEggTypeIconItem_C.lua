local UMG_PetEggTypeIconItem_C = _G.NRCPanelBase:Extend("UMG_PetEggTypeIconItem_C")
local PetUtils = require("NewRoco.Utils.PetUtils")

function UMG_PetEggTypeIconItem_C:OnActive()
end

function UMG_PetEggTypeIconItem_C:OnDeactive()
end

function UMG_PetEggTypeIconItem_C:OnAddEventListener()
end

function UMG_PetEggTypeIconItem_C:SetItemIcon(EggGID, IsSmallIcon)
  if nil == IsSmallIcon then
    IsSmallIcon = false
  end
  self.TypeIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
  if not EggGID then
    return
  end
  if 0 == EggGID then
    return
  end
  if self:CheckIsCustomGlassPiece(EggGID) then
    local PreciousEggType = _G.Enum.PreciousEggType.PET_CUSTOM_GLASS
    self:InnerSetItemIcon(PreciousEggType, IsSmallIcon)
  else
    local PetEggConfigType, PetEggConfig = PetUtils.GetPetEggConfigTypeByGID(EggGID)
    local BagEggItem = _G.NRCModeManager:DoCmd(_G.BagModuleCmd.GetBagItemByGid, EggGID)
    if PetEggConfigType then
      local PreciousEggType = PetEggConfig and PetEggConfig.precious_egg_type
      if BagEggItem and BagEggItem.egg_data and BagEggItem.egg_data.precious_egg_type then
        PreciousEggType = BagEggItem.egg_data.precious_egg_type
      end
      if PreciousEggType then
        self:InnerSetItemIcon(PreciousEggType, IsSmallIcon)
      end
    end
  end
end

function UMG_PetEggTypeIconItem_C:InnerSetItemIcon(PreciousEggType, IsSmallIcon)
  local PetEggTypeConf = _G.DataConfigManager:GetEggTypeConf(PreciousEggType + 1)
  local IconPath
  if not IsSmallIcon then
    if PetEggTypeConf and PetEggTypeConf.icon then
      IconPath = PetEggTypeConf.icon
    end
  elseif PetEggTypeConf and PetEggTypeConf.small_icon then
    IconPath = PetEggTypeConf.small_icon
  end
  if IconPath then
    self.TypeIcon:SetPath(IconPath)
    self.TypeIcon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_PetEggTypeIconItem_C:CheckIsCustomGlassPiece(gid)
  local isCustomGlassPiece = false
  local BagItem = _G.NRCModeManager:DoCmd(_G.BagModuleCmd.GetBagItemByGid, gid)
  if BagItem then
    local BagItemConf = _G.DataConfigManager:GetBagItemConf(BagItem.id)
    if BagItemConf then
      local type = BagItemConf.type
      if type and type == _G.Enum.BagItemType.BI_GLASS_EGG_PIECE then
        isCustomGlassPiece = true
      end
    end
  end
  return isCustomGlassPiece
end

return UMG_PetEggTypeIconItem_C
