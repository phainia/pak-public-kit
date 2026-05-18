local PetUtils = require("NewRoco.Utils.PetUtils")
local BattleCard = require("NewRoco.Modules.Core.Battle.Entity.Card.BattleCard")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Battle_ReservesPets_Item_C = Base:Extend("UMG_Battle_ReservesPets_Item_C")

function UMG_Battle_ReservesPets_Item_C:OnConstruct()
  self.cache = {}
  self.TouchButton.OnClicked:Add(self, self._OnPetInfoShow)
  self.AttrButton.OnClicked:Add(self, self._OnPetInfoShow)
end

function UMG_Battle_ReservesPets_Item_C:OnDestruct()
  self.TouchButton.OnClicked:Remove(self, self._OnPetInfoShow)
  self.AttrButton.OnClicked:Remove(self, self._OnPetInfoShow)
end

function UMG_Battle_ReservesPets_Item_C:OnItemUpdate(data, datalist, index)
  self:_UpdateCacheData(data)
  local state = self:_UpdateState(data)
  if state == BattleEnum.ReservesPetState.Appeared then
    self:_UpdatePetBasicInfo(data)
    self:_UpdateHeadIcon(data)
    self:_UpdateHPBar(data)
    self:_UpdatePetType(data)
  end
end

function UMG_Battle_ReservesPets_Item_C:_UpdateState(data)
  local state = data.reservesState
  local switcherIndices = {
    0,
    1,
    2
  }
  local index = switcherIndices[state] or 0
  self.Switcher:SetActiveWidgetIndex(index)
  return state
end

function UMG_Battle_ReservesPets_Item_C:_UpdateHeadIcon(data)
  if data.card then
    self:_UpdateHeadIconAsCard(data.card)
  elseif data.info then
    self:_UpdateHeadIconAsInfo(data.info)
  end
end

function UMG_Battle_ReservesPets_Item_C:_UpdateHeadIconAsCard(card)
  local bAlive = card:IsAlive()
  self:_DoUpdateHeadIcon(bAlive, card.petInfo.battle_common_pet_info, card.petInfo.battle_inside_pet_info)
end

function UMG_Battle_ReservesPets_Item_C:_UpdateHeadIconAsInfo(info)
  local bAlive = info:IsAlive()
  self:_DoUpdateHeadIcon(bAlive, info.battle_common_pet_info, info.battle_inside_pet_info)
end

function UMG_Battle_ReservesPets_Item_C:_DoUpdateHeadIcon(bAlive, battle_common_pet_info, battle_inside_pet_info)
  if not battle_common_pet_info then
    Log.Error("UMG_Battle_ReservesPets_Item_C:_DoUpdateHeadIconAsCard battle_common_pet_info is nil")
    return
  end
  if not battle_inside_pet_info then
    Log.Error("UMG_Battle_ReservesPets_Item_C:_DoUpdateHeadIconAsCard battle_inside_pet_info is nil")
    return
  end
  self.TheElves_1:SetVisibility(bAlive and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  self.Exhaustion:SetVisibility(not bAlive and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  if bAlive then
    self.TheElves_1:SetIconPathAndMaterial(battle_inside_pet_info.base_conf_id, battle_common_pet_info.mutation_type, battle_common_pet_info.glass_info)
  else
    local iconPath = self.TheElves_1.GetIconPath(battle_inside_pet_info.base_conf_id, battle_common_pet_info.mutation_type)
    self.Exhaustion:SetPath(iconPath)
  end
end

function UMG_Battle_ReservesPets_Item_C:_UpdateHPBar(data)
  if data.card then
    self:_UpdateHPBarAsCard(data.card)
  elseif data.info then
    self:_UpdateHPBarAsInfo(data.info)
  end
end

function UMG_Battle_ReservesPets_Item_C:_UpdateHPBarAsCard(card)
  self:_DoUpdateHPBar(card:IsEnemy(), card:GetHpPercent(), card:GetHp(), card:GetMaxHp(), card:GetFrozenPercent())
end

function UMG_Battle_ReservesPets_Item_C:_UpdateHPBarAsInfo(info)
  local bIsEnemy = true
  local battlePlayer = _G.BattleManager.battlePawnManager:GetPlayerByGuid(info.role_uin)
  if battlePlayer then
    bIsEnemy = battlePlayer:IsEnemy()
  end
  local hpPercent = PetUtils.GetHPPercent(info.battle_inside_pet_info)
  local currentHp = PetUtils.GetHP(info.battle_inside_pet_info)
  local maxHp = PetUtils.GetMaxHP(info.battle_inside_pet_info)
  local frozenPercent = PetUtils.GetFrozenPercent(info.battle_inside_pet_info)
  self:_DoUpdateHPBar(bIsEnemy, hpPercent, currentHp, maxHp, frozenPercent)
end

function UMG_Battle_ReservesPets_Item_C:_DoUpdateHPBar(bIsEnemy, hpPercent, currentHp, maxHp, frozenPercent)
  if bIsEnemy then
    self.Battle_Hp:SetHP(hpPercent)
  else
    self.Battle_Hp:SetHP(hpPercent, currentHp, maxHp)
  end
  if 0 == hpPercent or 0 == currentHp then
    frozenPercent = 0
  end
  self.Battle_Hp:SetFrozenPercent(frozenPercent)
end

function UMG_Battle_ReservesPets_Item_C:_UpdatePetBasicInfo(data)
  if data.card then
    self:_UpdatePetBasicInfoAsCard(data.card)
  elseif data.info then
    self:_UpdatePetBasicInfoAsInfo(data.info)
  end
end

function UMG_Battle_ReservesPets_Item_C:_UpdatePetBasicInfoAsCard(card)
  self:_DoUpdatePetBasicInfo(card.petInfo.battle_common_pet_info, card.petInfo.battle_inside_pet_info)
end

function UMG_Battle_ReservesPets_Item_C:_UpdatePetBasicInfoAsInfo(info)
  self:_DoUpdatePetBasicInfo(info.battle_common_pet_info, info.battle_inside_pet_info)
end

function UMG_Battle_ReservesPets_Item_C:_DoUpdatePetBasicInfo(battle_common_pet_info, battle_inside_pet_info)
  if not battle_inside_pet_info then
    Log.Error("UMG_Battle_ReservesPets_Item_C:_DoUpdatePetBasicInfo battle_inside_pet_info is nil")
    return
  end
  if not battle_common_pet_info then
    Log.Error("UMG_Battle_ReservesPets_Item_C:_DoUpdatePetBasicInfo battle_common_pet_info is nil")
    return
  end
  self.TxtPetName:SetText(PetUtils.GetPetShowName({battle_common_pet_info = battle_common_pet_info, battle_inside_pet_info = battle_inside_pet_info}))
  self.TxtLevel:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("umg_pass_awarditem1_1").msg, battle_common_pet_info.level))
  local gender = battle_common_pet_info.gender
  self.ImagePetGender2:SetVisibility(gender == Enum.GenderType.GT_MALE and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self.ImagePetGender1:SetVisibility(gender == Enum.GenderType.GT_FEMALE and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
  self.Point:SetText(tostring(battle_common_pet_info.energy))
end

local function __SafeCall(obj, funcName, ...)
  if obj then
    local func = obj[funcName]
    if func then
      func(obj, ...)
    end
  end
end

function UMG_Battle_ReservesPets_Item_C:_UpdatePetType(data)
  if data.card then
    self:_UpdatePetTypeAsCard(data.card)
  elseif data.info then
    self:_UpdatePetTypeAsInfo(data.info)
  end
end

function UMG_Battle_ReservesPets_Item_C:_UpdatePetTypeAsCard(card)
  self:_DoUpdatePetType(card.petInfo.battle_common_pet_info, card.petInfo.battle_inside_pet_info)
end

function UMG_Battle_ReservesPets_Item_C:_UpdatePetTypeAsInfo(info)
  self:_DoUpdatePetType(info.battle_common_pet_info, info.battle_inside_pet_info)
end

function UMG_Battle_ReservesPets_Item_C:_DoUpdatePetType(battle_common_pet_info, battle_inside_pet_info)
  local petTypes = PetUtils.GetPetTypes(battle_inside_pet_info)
  local bErrorData = nil == petTypes or 0 == #petTypes
  if bErrorData then
    Log.Error("PetUtils.GetPetTypes return nil or empty, pet_id:", battle_inside_pet_info.pet_id)
  end
  local bPartialShow = PetUtils.IsPartialShow(battle_inside_pet_info) or bErrorData
  if bPartialShow then
    for i = 1, 6 do
      __SafeCall(self["Attr" .. i], "SetVisibility", UE4.ESlateVisibility.Collapsed)
      __SafeCall(self["PetTypeBg" .. i], "SetVisibility", UE4.ESlateVisibility.Collapsed)
    end
  else
    for i = 1, 6 do
      local petType = petTypes[i]
      if petType and petType > 0 then
        local conf = _G.DataConfigManager:GetTypeDictionary(petType)
        if i <= #petTypes and petType > 1 and conf then
          __SafeCall(self["Attr" .. i], "SetVisibility", UE4.ESlateVisibility.SelfHitTestInvisible)
          __SafeCall(self["PetTypeBg" .. i], "SetVisibility", UE4.ESlateVisibility.SelfHitTestInvisible)
          __SafeCall(self["Attr" .. i], "SetPath", conf.type_icon)
        else
          __SafeCall(self["Attr" .. i], "SetVisibility", UE4.ESlateVisibility.Collapsed)
          __SafeCall(self["PetTypeBg" .. i], "SetVisibility", UE4.ESlateVisibility.Collapsed)
        end
      end
    end
  end
end

function UMG_Battle_ReservesPets_Item_C:_UpdateCacheData(data)
  self.cache.card = data.card
  self.cache.info = data.info
end

function UMG_Battle_ReservesPets_Item_C:_OnPetInfoShow()
  local card = self.cache.card
  local info = self.cache.info
  if card then
    local data = {
      cardData = card,
      petData = {
        base_conf_id = card.petBaseConf.id,
        extra_sdt = card.petInfo.battle_inside_pet_info.extra_sdt
      }
    }
    _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.OpenBattleChangePetConfirmPanel, data)
  elseif info then
    local data = {battlePetInfo = info}
    _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.OpenBattleChangePetConfirmPanel, data)
  else
    Log.Warning("UMG_Battle_ReservesPets_Item_C:_OnPetInfoShow battlepet is invalid")
  end
end

return UMG_Battle_ReservesPets_Item_C
