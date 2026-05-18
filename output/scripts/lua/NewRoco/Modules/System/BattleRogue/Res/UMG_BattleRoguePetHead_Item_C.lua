local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BattleRoguePetHead_Item_C = Base:Extend("UMG_BattleRoguePetHead_Item_C")

function UMG_BattleRoguePetHead_Item_C:OnConstruct()
end

function UMG_BattleRoguePetHead_Item_C:OnDestruct()
end

function UMG_BattleRoguePetHead_Item_C:OnItemUpdate(_data, datalist, index)
  self.Data = _data
  self.index = index
  self:SetInfo()
end

function UMG_BattleRoguePetHead_Item_C:SetInfo()
  local Data = self.Data
  local PetConf = _G.DataConfigManager:GetPetbaseConf(Data.conf_id)
  if PetConf then
    self.HeadIcon:SetIconPathAndMaterial(Data.conf_id, Data.mutation_type, Data.glass_info)
  end
  self.UnSelectedGrade:SetText(Data.level)
  local currentEnergy = Data.remain_energy
  self.UnSelectedTxtNeng:SetText(string.format("%02d", currentEnergy))
  local petHpPercent
  local maxHp, hp = Data.max_hp, Data.remain_hp
  if maxHp > 0 and hp >= 0 then
    petHpPercent = hp / maxHp
    if petHpPercent > 1 then
      petHpPercent = 1
    end
  end
  self.HpBarGreen:SetPercent(petHpPercent)
end

function UMG_BattleRoguePetHead_Item_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.Bg_5:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local PetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.Data.pet_gid)
    if PetData then
      _G.NRCModuleManager:DoCmd(MainUIModuleCmd.UI_SetThrowItem, _G.MainUIModuleEnum.MainUIChooseType.PET, PetData)
      _G.NRCModuleManager:DoCmd(MainUIModuleCmd.UI_RefreshMainPetSelectedState, self.Data.pet_gid)
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetPetSelectIndex, self.index)
    end
  else
    self.Bg_5:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_BattleRoguePetHead_Item_C:OnDeactive()
end

return UMG_BattleRoguePetHead_Item_C
