local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local UMG_Pet_GroupWarfare_Item_C = NRCUmgClass:Extend("")

function UMG_Pet_GroupWarfare_Item_C:Construct()
  self.battlePet = nil
  self.Pos = nil
  self._pressed = false
  self._longPressThreshold = BattleConst.ItemLongPressThreshold
  self._timer = self._longPressThreshold
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:OnAddEventListener()
end

function UMG_Pet_GroupWarfare_Item_C:Destruct()
  self:OnRemoveEventListener()
end

function UMG_Pet_GroupWarfare_Item_C:OnActive()
end

function UMG_Pet_GroupWarfare_Item_C:OnAddEventListener()
  if self.TouchButton.OnClicked then
    self.TouchButton.OnClicked:Add(self, self.OnPetInfoShow)
  else
    Log.Error("TouchButton.OnPressed\228\184\186\231\169\186")
  end
  self.TouchButton.OnReleased:Add(self, self._OnItemRelease)
  self.ClickBtn.OnClicked:Add(self, self.OpenPetTips)
  _G.BattleEventCenter:Bind(self, BattleEvent.BATTLE_PET_DIE, BattleEvent.Replay_RefreshRoundIdx, BattleEvent.ROUND_START)
end

function UMG_Pet_GroupWarfare_Item_C:OnRemoveEventListener()
  self.ClickBtn.OnClicked:Remove(self, self.OpenPetTips)
  _G.BattleEventCenter:UnBind(self)
end

function UMG_Pet_GroupWarfare_Item_C:OnDeactive()
end

function UMG_Pet_GroupWarfare_Item_C:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.BATTLE_PET_DIE then
    self:PetDleUpdatePanel(...)
  elseif eventName == BattleEvent.Replay_RefreshRoundIdx then
    self:UpdateRound(...)
  elseif eventName == BattleEvent.ROUND_START and BattleUtils.IsTeam() then
    self:SetPetDeadInfo()
  end
end

function UMG_Pet_GroupWarfare_Item_C:_OnItemPressed()
  self._pressed = true
  self._timer = self._longPressThreshold
end

function UMG_Pet_GroupWarfare_Item_C:_OnItemRelease()
  if self._pressed then
  else
  end
  self._pressed = false
end

function UMG_Pet_GroupWarfare_Item_C:PetDleUpdatePanel(battlePet)
  if self.battlePet and self.battlePet.guid == battlePet.guid then
    self:SetPetDeadInfo()
  end
end

function UMG_Pet_GroupWarfare_Item_C:UpdateRound(Round)
  if self.battlePet and self.battlePet:IsDead() then
    local hasAlivePet = false
    local battlePlayer = self.battlePet.player
    if battlePlayer then
      hasAlivePet = battlePlayer:GetSummonNumber() > 0
    end
    if hasAlivePet then
      local ResidueRound = self.battlePet.card.petInfo.battle_inside_pet_info.revive_round - Round
      ResidueRound = math.max(0, ResidueRound + 1)
      self.Text_CountDown:SetText(ResidueRound)
      local Percent = ResidueRound / self.battlePet.card.petInfo.battle_inside_pet_info.revive_rounds
      self.Bar_CountDown:SetPercent(Percent)
    else
      self.Text_CountDown:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Bar_CountDown:SetPercent(1)
    end
  end
end

function UMG_Pet_GroupWarfare_Item_C:InitView(battlePet)
  self.ProgressBar:InitView(battlePet)
  self.battlePet = battlePet
  self.Pos = battlePet.player.TeamNumber
  self:SetPetInfo()
  self:SetTypes()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_Pet_GroupWarfare_Item_C:SetPetInfo()
  self:SetPetDeadInfo()
  self.HeadIcon:SetIconPathAndMaterial(self.battlePet.card.petBaseConf.id, self.battlePet.card.petInfo.battle_common_pet_info.mutation_type, self.battlePet.card.petInfo.battle_common_pet_info.glass_info)
  self.Bar_CountDown:SetFillImage(UE4.EChangeImageType.Fill, NRCUtils:FormatConfIconPath(self.battlePet.card.icon, _G.UIIconPath.HeadIconPath))
  self.ArrangeText:SetText(string.format("%dP", self.Pos))
  self.EnergyView:InitView(self.battlePet)
end

function UMG_Pet_GroupWarfare_Item_C:OpenPetTips()
  if self.battlePet and not BattleUtils.IsPartialShow(self.battlePet.card) then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1060, "UMG_Battle_HPBar_C:openTips")
    local data = {
      petData = {
        base_conf_id = self.battlePet.card.petBaseConf.id
      },
      is_not_set_bg = true
    }
    _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenBattleUIBackpackTips, data)
  end
end

function UMG_Pet_GroupWarfare_Item_C:SetPetDeadInfo()
  if self.battlePet and self.battlePet:IsDead() then
    self.Bar_CountDown:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Text_CountDown:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local CurRound = _G.BattleManager:GetCurRound()
    self:UpdateRound(CurRound)
    Log.Debug(CurRound, self.battlePet.card.petInfo.battle_inside_pet_info.revive_round - CurRound, "UMG_Pet_GroupWarfare_Item_C:SetPetDeadInfo")
  else
    self.Bar_CountDown:SetPercent(1)
    self.Bar_CountDown:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Text_CountDown:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Pet_GroupWarfare_Item_C:SetTypes()
  local card = self.battlePet.card
  if BattleUtils.IsPartialShow(card) then
    self.Attr1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Attr2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    local petTypes = card:GetPetType()
    if petTypes then
      for i = 1, 2 do
        local petType = petTypes[i]
        if petType and petType > 0 then
          local conf = _G.DataConfigManager:GetTypeDictionary(petType)
          if i <= #petTypes and petType > 1 and conf then
            self["Attr" .. i]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
            local iconPath = conf.type_icon
            self["Attr" .. i]:SetPath(iconPath)
          else
            self["Attr" .. i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
          end
        end
      end
    else
      if card.petBaseConf.unit_type[1] then
        self.Attr1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        local iconPath = _G.DataConfigManager:GetTypeDictionary(card.petBaseConf.unit_type[1]).type_icon
        self.Attr1:SetPath(iconPath)
      else
        self.Attr1:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      if card.petBaseConf.unit_type[2] then
        self.Attr2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        local iconPath = _G.DataConfigManager:GetTypeDictionary(card.petBaseConf.unit_type[2]).type_icon
        self.Attr2:SetPath(iconPath)
      else
        self.Attr2:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
end

function UMG_Pet_GroupWarfare_Item_C:Tick(geometry, InDeltaTime)
end

function UMG_Pet_GroupWarfare_Item_C:DoLongClick()
  self._pressed = false
  self._timer = 0
  self:OnPetInfoShow()
end

function UMG_Pet_GroupWarfare_Item_C:OnPetInfoShow()
  NRCModuleManager:DoCmd(BattleUIModuleCmd.ShowChangePetConfirm, self.battlePet.card, true)
end

function UMG_Pet_GroupWarfare_Item_C:OnPetInfoClose()
  NRCModuleManager:DoCmd(BattleUIModuleCmd.HideChangePetConfirm, true, true)
end

return UMG_Pet_GroupWarfare_Item_C
