local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local EnhancedInputModuleEvent = require("NewRoco.Modules.Core.EnhancedInput.EnhancedInputModuleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local UMG_Battle_ChangePanel_C = NRCPanelBase:Extend("UMG_Battle_ChangePanel_C")

function UMG_Battle_ChangePanel_C:Construct()
  self.battleManager = _G.BattleManager
  self:AddListener()
  self.items = {
    self.Item1,
    self.Item2,
    self.Item3,
    self.Item4,
    self.Item5
  }
  self.widgetType = BattleEnum.WidgetType.ENUM_CHANGE_PET_PANEL
  self.visibleCount = 0
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  _G.NRCEventCenter:RegisterEvent("UMG_Battle_ChangePanel_C", self, EnhancedInputModuleEvent.KeyMappingsChanged, self.PCKeySetting)
  self.BloodLimit = nil
  self:PCKeySetting()
end

function UMG_Battle_ChangePanel_C:Destruct()
  self:RemoveListener()
  table.clear(self.items)
  self.items = nil
  self.TweenInCallback = nil
  self.TweenOutCallback = nil
  self:CancelOnOpenAnimDelay()
  NRCUmgClass.Destruct(self)
end

function UMG_Battle_ChangePanel_C:OnEnable(...)
  self:OnActive(...)
end

function UMG_Battle_ChangePanel_C:OnActive(pet, playAnim, callback)
  self:PCModeScreenSetting()
  self:Show(playAnim, callback)
end

function UMG_Battle_ChangePanel_C:OnDisable()
  self:Hide(false)
end

function UMG_Battle_ChangePanel_C:OnDeactive()
  self:Hide(false)
end

function UMG_Battle_ChangePanel_C:WaitingRecycle()
  self:RemoveListener()
end

function UMG_Battle_ChangePanel_C:AddListener()
  _G.BattleEventCenter:Bind(self, BattleEvent.BATTLE_CLICKED_BAG_PET, BattleEvent.BATTLE_BEGING_USE_CHANGE_PET_SKILL, BattleEvent.BATTLE_CLICKED_UI_CANCELPLAYERSKILL, BattleEvent.UI_HIDE, BattleEvent.UI_USE_PLAYERSKILL_UPDATE, BattleEvent.BATTLE_CANCEL_USE_PLAYERSKILL, BattleEvent.UPDATE_DATA)
end

function UMG_Battle_ChangePanel_C:RemoveListener()
  _G.BattleEventCenter:UnBind(self)
end

function UMG_Battle_ChangePanel_C:SelectItem(index, isPressed)
  if self.items[index] then
    if isPressed then
      self.items[index]:OnItemPressed()
    else
      self.items[index]:OnItemRelease()
    end
  end
end

function UMG_Battle_ChangePanel_C:PCKeySetting()
  self:SetUpPCKey()
end

function UMG_Battle_ChangePanel_C:SetUpPCKey()
  if SystemSettingModuleCmd then
    if self.Item1 then
      self.Item1.Text_PCKey:SetKeyVisibility(true)
      local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, "IA_BattleSelectItemStart_1")
      if "" ~= image then
        self.Item1.Text_PCKey:SetImageMode(image)
      else
        self.Item1.Text_PCKey:SetText(text)
      end
    end
    if self.Item2 then
      self.Item2.Text_PCKey:SetKeyVisibility(true)
      local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, "IA_BattleSelectItemStart_2")
      if "" ~= image then
        self.Item2.Text_PCKey:SetImageMode(image)
      else
        self.Item2.Text_PCKey:SetText(text)
      end
    end
    if self.Item3 then
      self.Item3.Text_PCKey:SetKeyVisibility(true)
      local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, "IA_BattleSelectItemStart_3")
      if "" ~= image then
        self.Item3.Text_PCKey:SetImageMode(image)
      else
        self.Item3.Text_PCKey:SetText(text)
      end
    end
    if self.Item4 then
      self.Item4.Text_PCKey:SetKeyVisibility(true)
      local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, "IA_BattleSelectItemStart_4")
      if "" ~= image then
        self.Item4.Text_PCKey:SetImageMode(image)
      else
        self.Item4.Text_PCKey:SetText(text)
      end
    end
    if self.Item5 then
      self.Item5.Text_PCKey:SetKeyVisibility(true)
      local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, "IA_BattleSelectItemStart_5")
      if "" ~= image then
        self.Item5.Text_PCKey:SetImageMode(image)
      else
        self.Item5.Text_PCKey:SetText(text)
      end
    end
    if self.Item6 then
      self.Item6.Text_PCKey:SetKeyVisibility(true)
      local text, image = _G.NRCModuleManager:DoCmd(SystemSettingModuleCmd.GetMappingKeyUIName, "IA_BattleSelectItemStart_6")
      if "" ~= image then
        self.Item6.Text_PCKey:SetImageMode(image)
      else
        self.Item6.Text_PCKey:SetText(text)
      end
    end
  end
end

function UMG_Battle_ChangePanel_C:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.BATTLE_CLICKED_BAG_PET then
    self:OnPetIconClicked(...)
  elseif eventName == BattleEvent.BATTLE_BEGING_USE_CHANGE_PET_SKILL then
    self:UpdatePetInfo(...)
  elseif eventName == BattleEvent.BATTLE_CLICKED_UI_CANCELPLAYERSKILL then
    self:InitializedPlyaerSkill()
  elseif eventName == BattleEvent.UI_HIDE then
    self:InitializedPlyaerSkill()
  elseif eventName == BattleEvent.UI_USE_PLAYERSKILL_UPDATE then
    self:UsePlayerSkillSuccess(...)
  elseif eventName == BattleEvent.BATTLE_CANCEL_USE_PLAYERSKILL then
    self:InitializedPlyaerSkill()
  elseif eventName == BattleEvent.UPDATE_DATA then
    self:UpdatePlayerData(...)
  end
end

function UMG_Battle_ChangePanel_C:InitializedPlyaerSkill()
  self.IsUsePlayerSkill = false
  self.BloodLimit = nil
end

function UMG_Battle_ChangePanel_C:UpdatePetInfo(_BloodLimit)
  self.IsUsePlayerSkill = true
  self.BloodLimit = _BloodLimit
  self:UpdateData(self.battleManager.battlePawnManager.playerTeam.player)
end

function UMG_Battle_ChangePanel_C:UsePlayerSkillSuccess(PlayerSkillData)
  if PlayerSkillData.EffectConf.effect_order == Enum.EffectType.ET_ROLE_CHANGE_PET then
    self.IsUsePlayerSkill = false
    self.BloodLimit = nil
    self:UpdateData(self.battleManager.battlePawnManager.playerTeam.player)
  end
end

function UMG_Battle_ChangePanel_C:UpdatePlayerData(pet)
  self:UpdateData(pet.team.player)
end

function UMG_Battle_ChangePanel_C:UpdateData(player)
  if not player then
    Log.Error("zgx player Not Found")
    return
  end
  local typeOfVisible = self:GetVisibility()
  if typeOfVisible == UE4.ESlateVisibility.Collapsed or typeOfVisible == UE4.ESlateVisibility.Hidden then
    return
  end
  local cards = player.deck.cards
  local changeCount = 1
  local restPets = player.team.RestPets
  for _, v in ipairs(cards) do
    if changeCount <= #self.items then
      if restPets[v.pos] then
        if v ~= restPets[v.pos].card then
          if self.IsUsePlayerSkill then
            if self:IsBloodLimit(v) then
              self.items[changeCount]:SetData(v, self)
              changeCount = changeCount + 1
            end
          else
            self.items[changeCount]:SetData(v, self)
            changeCount = changeCount + 1
          end
        end
      elseif not v:IsInBattle() and not v:IsBeCatch() and not v:IsBeRidOf() and not v:GetIsRunAway() then
        local satisfy = not self.IsUsePlayerSkill or self:IsBloodLimit(v)
        if satisfy then
          self.items[changeCount]:SetData(v, self)
          changeCount = changeCount + 1
        end
      end
    end
  end
  for i = changeCount, #self.items do
    self.items[i]:SetData()
  end
  if self.RoleHPMini and self.RoleHPMini.Update then
    self.RoleHPMini:Update(player)
  else
    Log.Error("self.RoleHPMini or self.RoleHPMini.Update Not Found")
  end
end

function UMG_Battle_ChangePanel_C:IsBloodLimit(CardEntity)
  for i, BloodId in ipairs(self.BloodLimit or {}) do
    if BloodId == CardEntity.petInfo.battle_common_pet_info.blood_id then
      return true
    end
  end
  return false
end

function UMG_Battle_ChangePanel_C:SetColor(color)
  for k, v in ipairs(self.items) do
    v:SetColor(color)
  end
end

function UMG_Battle_ChangePanel_C:CheckShouldTip(item, isCover)
  if isCover then
    if self.curTipPetBtn and not self.curTipPetBtn:GetIsCover() and item ~= self.curTipPetBtn then
      self:SetCurTipSkill(item)
      item:OnPetInfoUpdate()
      return true
    end
  elseif not self.curTipPetBtn then
    self:SetFirstTipSkill(item)
    self:SetCurTipSkill(item)
    return true
  end
  return false
end

function UMG_Battle_ChangePanel_C:CheckHideTip(item)
  if self.firstTipPetBtn and self.firstTipPetBtn == item then
    self:HideCurTipSkill()
  end
end

function UMG_Battle_ChangePanel_C:SetFirstTipSkill(item)
  self.firstTipPetBtn = item
end

function UMG_Battle_ChangePanel_C:SetCurTipSkill(item)
  self.curTipPetBtn = item
end

function UMG_Battle_ChangePanel_C:HideCurTipSkill()
  if self.curTipPetBtn then
    self.curTipPetBtn:OnPetInfoClose()
    self.firstTipPetBtn = nil
    self.curTipPetBtn = nil
  end
end

function UMG_Battle_ChangePanel_C:StopShowHide()
  self:StopAllAnimations()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Battle_ChangePanel_C:Show(playAnim, callback)
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Item1:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Item2:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Item3:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Item4:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Item5:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Item6:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TweenInCallback = nil
  self.TweenOutCallback = nil
  self:StopAllAnimations()
  self:CancelOnOpenAnimDelay()
  self:CancelOpenAnim()
  if self.RoleHPMini and self.RoleHPMini.SetVisibility then
    self.RoleHPMini:SetVisibility(BattleUtils.IsTeam() and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if playAnim then
    if self.RoleHPMini and self.RoleHPMini.SetVisibility and self.RoleHPMini.Show then
      if not BattleUtils.IsTeam() then
        self.RoleHPMini:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.RoleHPMini:Show()
      end
    else
      Log.Error("self.RoleHPMini or self.RoleHPMini.SetVisibility Not Found")
    end
    if not BattleUtils.IsMainWindowChangingBetweenSubPanels() then
      self:PlayAnimation(self.TweenIn)
    else
      self:PlayOpenAnim(true)
      self.onOpenAnimFinishedDelayId = _G.DelayManager:DelaySeconds(#self.items * 0.04 + 0.5, self.OnOpenAnimFinished, self)
    end
  end
  self.TweenInCallback = callback
  self:UpdateData(self.battleManager.battlePawnManager:GetPlayerMyTeam())
end

function UMG_Battle_ChangePanel_C:Hide(playAnim, callback)
  self.TweenInCallback = nil
  self.TweenOutCallback = nil
  self:CancelOnOpenAnimDelay()
  self:CancelOpenAnim()
  self:StopAllAnimations()
  if playAnim then
    self:PlayAnimation(self.TweenOut)
    
    function self.TweenOutCallback()
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
      if callback then
        callback()
      end
    end
    
    if self.RoleHPMini and self.RoleHPMini.Hide then
      self.RoleHPMini:Hide()
    else
      Log.Error("self.RoleHPMini or self.RoleHPMini.Hide Not Found")
    end
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if callback then
      callback()
    end
  end
end

function UMG_Battle_ChangePanel_C:OnAnimationFinished(Animation)
  if Animation == self.TweenIn then
    local Callback = self.TweenInCallback
    self.TweenInCallback = nil
    if Callback then
      Callback()
    end
  elseif Animation == self.TweenOut then
    local Callback = self.TweenOutCallback
    self.TweenOutCallback = nil
    if Callback then
      Callback()
    end
  end
end

function UMG_Battle_ChangePanel_C:OnPetIconClicked(id)
  self.Item1._canClick = false
  self.Item2._canClick = false
  self.Item3._canClick = false
  self.Item4._canClick = false
  self.Item5._canClick = false
  self:DelaySeconds(0.2, function()
    self.Item1._canClick = true
    self.Item2._canClick = true
    self.Item3._canClick = true
    self.Item4._canClick = true
    self.Item5._canClick = true
  end)
end

function UMG_Battle_ChangePanel_C:PCModeScreenSetting()
  if UE.UGameplayStatics.GetGameInstance(self):IsPCMode() then
    local Padding = UE4.FMargin()
    self.CanvasPanel_58:SetRenderScale(UE4.FVector2D(0.88, 0.88))
    Padding.Left = -52
    Padding.Top = 0
    Padding.Right = 0
    Padding.Bottom = 0
    self.CanvasPanel_58.Slot:SetOffsets(Padding)
    self.RoleHPMini:SetRenderScale(UE4.FVector2D(1.12, 1.12))
    Padding.Left = 68
    Padding.Top = -132
    Padding.Right = 115.46
    Padding.Bottom = 30
    self.RoleHPMini.Slot:SetOffsets(Padding)
  end
end

function UMG_Battle_ChangePanel_C:CancelOnOpenAnimDelay()
  if self.onOpenAnimFinishedDelayId then
    _G.DelayManager:CancelDelayById(self.onOpenAnimFinishedDelayId)
    self.onOpenAnimFinishedDelayId = nil
  end
end

function UMG_Battle_ChangePanel_C:OnOpenAnimFinished()
  self:OnAnimationFinished(self.TweenIn)
end

function UMG_Battle_ChangePanel_C:PlayOpenAnim(_IsOpen)
  for i, item in ipairs(self.items) do
    if _IsOpen then
      item:SetRenderOpacity(1)
      item:SetRenderScale(UE4.FVector2D(1, 1))
      item.CanvasPanel_0:SetRenderOpacity(0)
      item:DelayPlayOpenAnimation(_IsOpen, #self.items - i + 1)
    else
      item:PlayOpenAnimation(_IsOpen)
    end
  end
end

function UMG_Battle_ChangePanel_C:CancelOpenAnim()
  for i, item in ipairs(self.items) do
    item:SetRenderOpacity(1)
    item.CanvasPanel_0:SetRenderOpacity(1)
    item:CancelOpenAnimation()
  end
end

return UMG_Battle_ChangePanel_C
