local PetUtils = require("NewRoco.Utils.PetUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SpeedComparison_Item_C = Base:Extend("UMG_SpeedComparison_Item_C")

function UMG_SpeedComparison_Item_C:OnConstruct()
end

function UMG_SpeedComparison_Item_C:OnDestruct()
end

function UMG_SpeedComparison_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  local card, speed_compare, max_num = self.data[1], self.data[2], self.data[3]
  local flag
  local is_mimic = false
  if card.petInfo then
    is_mimic = not card:IsMyself() and card.petState:GetMimic()
    if is_mimic then
      self.Unknown:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.HeadIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Unknown:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.HeadIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      local iconPath = PetUtils.GetPetIconPath({
        battle_common_pet_info = card.petInfo.battle_common_pet_info,
        battle_inside_pet_info = card.petInfo.battle_inside_pet_info
      })
      self.HeadIcon:SetPetIconPathAndMaterial(iconPath, card.petInfo.battle_common_pet_info.mutation_type, card.petInfo.battle_common_pet_info.glass_info)
    end
  else
    local iconPath = PetUtils.GetPetIconPath({
      battle_common_pet_info = card.battle_common_pet_info,
      battle_inside_pet_info = card.battle_inside_pet_info
    })
    self.HeadIcon:SetPetIconPathAndMaterial(iconPath, card.battle_common_pet_info.mutation_type, card.battle_common_pet_info.glass_info)
  end
  self.ArrowSwitcher:SetVisibility(UE4.ESlateVisibility.Hidden)
  if card.battle_inside_pet_info or not card:IsMyself() then
    local min_speed, max_speed
    local text_value = LuaText.A1_finalbattle_unknown_pet_name
    if is_mimic then
      min_speed, max_speed = 0, 0
    else
      if card.battle_inside_pet_info then
        min_speed, max_speed = card.battle_inside_pet_info.speed_min, card.battle_inside_pet_info.speed_max
      else
        min_speed, max_speed = card:GetSpeedMinMax()
      end
      text_value = string.format("%d~%d", min_speed, max_speed)
    end
    self.SkillNameTxt_3:SetText(text_value)
    min_speed = math.max(min_speed, 0)
    max_speed = math.max(max_speed, 0)
    self.Progress:SetPercent(min_speed / max_num)
    self.Progress:SetIncreasePercent(max_speed / max_num - min_speed / max_num)
  else
    local speed = card:GetSpeed()
    self.SkillNameTxt_3:SetText(tostring(speed))
    self.Progress:SetPercent(speed / max_num)
    self.Progress:SetIncreasePercent(0)
    if speed_compare == BattleEnum.SpeedCompare.ENUM_FASTER then
      self.ArrowSwitcher:SetActiveWidgetIndex(0)
      self.ArrowSwitcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    elseif speed_compare == BattleEnum.SpeedCompare.ENUM_SLOWER then
      self.ArrowSwitcher:SetActiveWidgetIndex(1)
      self.ArrowSwitcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end

return UMG_SpeedComparison_Item_C
