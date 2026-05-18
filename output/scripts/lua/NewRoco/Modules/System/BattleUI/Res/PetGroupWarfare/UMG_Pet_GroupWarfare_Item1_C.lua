local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local UMG_Pet_GroupWarfare_Item1_C = NRCUmgClass:Extend("")

function UMG_Pet_GroupWarfare_Item1_C:Construct()
  self.battlePet = nil
  self.Pos = nil
  self.StarTime = 0
  self.EndTime = 2
  self._pressed = false
  self.IsShow = false
  self._longPressThreshold = BattleConst.ItemLongPressThreshold
  self._timer = self._longPressThreshold
  self:OnAddEventListener()
  self:RefreshUI()
end

function UMG_Pet_GroupWarfare_Item1_C:Destruct()
  self:OnRemoveEventListener()
end

function UMG_Pet_GroupWarfare_Item1_C:OnAddEventListener()
  if self.TouchButton.OnClicked then
    self.TouchButton.OnClicked:Add(self, self.OnPetInfoShow)
  else
    Log.Error("TouchButton.OnPressed\228\184\186\231\169\186")
  end
  self.TouchButton.OnReleased:Add(self, self._OnItemRelease)
  _G.BattleEventCenter:Bind(self, BattleEvent.PLAYER_PERFORM_SKILL, BattleEvent.BATTLE_PET_DIE, BattleEvent.Replay_RefreshRoundIdx, BattleEvent.ROUND_START)
end

function UMG_Pet_GroupWarfare_Item1_C:OnRemoveEventListener()
  _G.BattleEventCenter:UnBind(self)
end

function UMG_Pet_GroupWarfare_Item1_C:RefreshUI()
  if BattleUtils.IsB1FinalBattleP3() then
    self.NRCImage_114:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ArrangeText:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Pet_GroupWarfare_Item1_C:OnActive()
end

function UMG_Pet_GroupWarfare_Item1_C:OnDeactive()
end

function UMG_Pet_GroupWarfare_Item1_C:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.PLAYER_PERFORM_SKILL then
  elseif eventName == BattleEvent.BATTLE_PET_DIE then
    self:PetDleUpdatePanel(...)
  elseif eventName == BattleEvent.Replay_RefreshRoundIdx then
    self:UpdateRound(...)
  elseif eventName == BattleEvent.ROUND_START and BattleUtils.IsTeam() then
    self:SetPetDeadInfo()
  end
end

function UMG_Pet_GroupWarfare_Item1_C:_OnItemPressed()
  self._pressed = true
  self._timer = self._longPressThreshold
end

function UMG_Pet_GroupWarfare_Item1_C:_OnItemRelease()
  if self._pressed then
  else
  end
  self._pressed = false
end

function UMG_Pet_GroupWarfare_Item1_C:PetDleUpdatePanel(battlePet)
  if self.battlePet and self.battlePet.guid == battlePet.guid then
    self:SetPetDeadInfo()
  end
end

function UMG_Pet_GroupWarfare_Item1_C:UpdateRound(Round)
  if self.battlePet and self.battlePet:IsDead() then
    local hasAlivePet = false
    local battlePlayer = self.battlePet.player
    if battlePlayer then
      hasAlivePet = battlePlayer:GetSummonNumber() > 0
    end
    if hasAlivePet then
      local ResidueRound = self.battlePet.card.petInfo.battle_inside_pet_info.revive_round - Round
      ResidueRound = math.max(0, ResidueRound + 1)
      local revive_rounds = self.battlePet.card.petInfo.battle_inside_pet_info.revive_rounds or 1
      if ResidueRound <= 0 then
        self.Text_CountDown:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.Bar_CountDown:SetPercent(1)
      else
        self.Text_CountDown:SetText(ResidueRound)
        local Percent = ResidueRound / revive_rounds
        self.Bar_CountDown:SetPercent(Percent)
      end
    else
      self.Text_CountDown:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Bar_CountDown:SetPercent(1)
    end
  end
end

function UMG_Pet_GroupWarfare_Item1_C:InitView(battlePet)
  self.battlePet = battlePet
  self.Pos = battlePet.player.TeamNumber
  self.ProgressBar_Small:InitView(battlePet)
  self:SetPetInfo()
end

function UMG_Pet_GroupWarfare_Item1_C:SetPetInfo()
  self:SetPetDeadInfo()
  self.HeadIcon:SetIconPathAndMaterial(self.battlePet.card.petBaseConf.id, self.battlePet.card.petInfo.battle_common_pet_info.mutation_type, self.battlePet.card.petInfo.battle_common_pet_info.glass_info)
  self.Bar_CountDown:SetFillImage(UE4.EChangeImageType.Fill, NRCUtils:FormatConfIconPath(self.battlePet.card.icon, _G.UIIconPath.HeadIconPath))
  self.ArrangeText:SetText(string.format("%dP", self.Pos))
  self.CanvasPanel_138:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Pet_GroupWarfare_Item1_C:SetPetDeadInfo()
  if self.battlePet and self.battlePet:IsDead() then
    self.Bar_CountDown:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Text_CountDown:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local CurRound = _G.BattleManager:GetCurRound()
    self:UpdateRound(CurRound)
    Log.Debug(CurRound, self.battlePet.card.petInfo.battle_inside_pet_info.revive_round - CurRound, "UMG_Pet_GroupWarfare_Item1_C:SetPetDeadInfo")
  else
    self.Bar_CountDown:SetPercent(1)
    self.Bar_CountDown:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Text_CountDown:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Pet_GroupWarfare_Item1_C:SkillBalance(BattleSkillCast)
  if self.battlePet then
    local isShow = false
    if BattleSkillCast.caster_id then
      isShow = BattleSkillCast.caster_id == self.battlePet.guid
    else
      isShow = BattleSkillCast.caster_uin == self.battlePet.player.guid
    end
    local skillId = BattleSkillCast.skill_id
    if isShow then
      self.CanvasPanel_138:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self:SkillStar()
      self:PlayAnimation(self.In)
      local SkillConf = _G.SkillUtils.GetSkillConf(skillId)
      if SkillConf then
        self.UIIcon_2:SetPath(NRCUtils:FormatConfIconPath(SkillConf.icon, _G.UIIconPath.SkillIconPath))
        self.Skill_Name_1:SetText(SkillConf.name)
      end
    end
  end
end

function UMG_Pet_GroupWarfare_Item1_C:SkillStar()
  self:StopAllAnimations()
  self.StarTime = 0
  self.IsShow = true
end

function UMG_Pet_GroupWarfare_Item1_C:SkillEnd()
  self.StarTime = 0
  self.IsShow = false
end

function UMG_Pet_GroupWarfare_Item1_C:Tick(geometry, InDeltaTime)
  if self.IsShow then
    self.StarTime = self.StarTime + InDeltaTime
    if self.StarTime >= self.EndTime then
      self:PlayAnimation(self.Out)
      self:SkillEnd()
    end
  end
end

function UMG_Pet_GroupWarfare_Item1_C:DoLongClick()
  self._pressed = false
  self._timer = 0
  self:OnPetInfoShow()
end

function UMG_Pet_GroupWarfare_Item1_C:OnPetInfoShow()
  if self.battlePet then
    NRCModuleManager:DoCmd(BattleUIModuleCmd.ShowChangePetConfirm, self.battlePet.card, true)
  end
end

function UMG_Pet_GroupWarfare_Item1_C:OnPetInfoClose()
  NRCModuleManager:DoCmd(BattleUIModuleCmd.HideChangePetConfirm, true, true)
end

function UMG_Pet_GroupWarfare_Item1_C:OnAnimationFinished(Animation)
  if Animation == self.Out then
    self.CanvasPanel_138:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_Pet_GroupWarfare_Item1_C
