local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattlePerformEvent = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePerformEvent")
local BuffUtils = require("NewRoco.Modules.Core.Battle.Entity.Components.Buff.BuffUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Enum = require("Data.Config.Enum")
local UMG_Battle_RunAway_C = _G.NRCPanelBase:Extend("UMG_Battle_RunAway_C")

function UMG_Battle_RunAway_C:OnConstruct()
  self.NRCModeManager = _G.NRCModeManager
  self.IsHasPopup = false
  self.ForceHide = false
  self.runAwayCountIconPath = ""
  self.runAwayCount = 0
  self.runAwayInfoText = ""
  self.isOpen = false
  self.isOpenDisplay = false
  self.isOpenAfterPopupEnd = false
end

function UMG_Battle_RunAway_C:OnDestruct()
  if self.battlePet then
    self.battlePet = nil
    self:RemoveListeners()
  end
end

function UMG_Battle_RunAway_C:AddListeners()
  _G.BattleEventCenter:Bind(self, BattleEvent.MULTI_PLAYER_TIP_CHANGE, BattleEvent.Popup_CommandInfo, BattleEvent.Popup_CommandInfo_End, BattlePerformEvent.BuffTriggerOnHit)
end

function UMG_Battle_RunAway_C:RemoveListeners()
  _G.BattleEventCenter:UnBind(self)
end

function UMG_Battle_RunAway_C:OnActive(pet)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:PCModeScreenSetting()
  self:SetPetInfo(pet, pet.card)
  self:UpdateRunAwayData()
  self:RefreshIcons()
  self:Show()
end

function UMG_Battle_RunAway_C:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.MULTI_PLAYER_TIP_CHANGE then
    local context = (...)
    context = context or {}
    if context.isRoundStart then
      self:UpdateSpecialMoveData()
    end
    self:UpdateRunAwayData()
    self:RefreshIcons()
    return true
  elseif eventName == BattleEvent.Popup_CommandInfo then
    self.IsHasPopup = true
    self:Hide()
    return true
  elseif eventName == BattleEvent.Popup_CommandInfo_End then
    self.IsHasPopup = false
    if self:CanShow() then
      self.isOpenAfterPopupEnd = true
    end
    self:Show()
    return true
  elseif eventName == BattlePerformEvent.BuffTriggerOnHit then
    local target_id, buff_type, buff_id = ...
    if self.battlePet and self.battlePet.guid == target_id and BuffUtils.IsRidOfBuff(buff_id) then
      self:Show()
    end
    return true
  end
end

function UMG_Battle_RunAway_C:SetRunAwayCount(count)
  count = count or 0
  if count >= 0 then
    self.RunAwayCountUI:SetText(count)
  else
    self.RunAwayCountUI:SetText("")
  end
end

function UMG_Battle_RunAway_C:SetRunAwayCountIcon(path)
  if path then
    self.RunAwayCountIconUI:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.RunAwayCountIconUI:SetPath(path)
  else
    self.RunAwayCountIconUI:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Battle_RunAway_C:UpdateRunAwayData(specialMoveInfo)
  self.runAwayCount = 0
  if self.escape_info_conf then
    self.runAwayCountIconPath = self.escape_info_conf.icon
    if self.escape_info_conf.skill_trigger_type == Enum.SkillTriggerType.STGT_SPE_ROUND_GAP then
      local curRound = _G.BattleManager.curRound
      local triggerRound = self.escape_info_conf.type_param[1] and self.escape_info_conf.type_param[1].params and self.escape_info_conf.type_param[1].params[1]
      local repeatRound = self.escape_info_conf.type_param[2] and self.escape_info_conf.type_param[2].params and self.escape_info_conf.type_param[2].params[1]
      if curRound <= triggerRound then
        self.runAwayCount = triggerRound - curRound
      elseif repeatRound >= 999 then
        self.runAwayCount = -1
      else
        self.runAwayCount = repeatRound - (curRound - triggerRound) % repeatRound
        if self.runAwayCount == repeatRound then
          self.runAwayCount = 0
        end
      end
      if self.runAwayCount >= 0 then
        self.PopupHintText:SetText(string.format(self.escape_info_conf.description, self.runAwayCount))
      else
        self.PopupHintText:SetText(self.escape_info_conf.trigger_description or "")
      end
    elseif self.escape_info_conf.skill_trigger_type == Enum.SkillTriggerType.STGT_SPE_ESCAPE then
      if self.specialMoveInfo then
        local currentRoundNumber = _G.BattleManager.curRound or 0
        local roundNumberToEscape = self.specialMoveInfo.round or 0
        local restRoundToEscape = roundNumberToEscape - currentRoundNumber
        local restRoundToEscapeText = tostring(restRoundToEscape)
        local popupHintTextValue = ""
        if restRoundToEscape <= 0 then
          local localizationConf = _G.DataConfigManager:GetLocalizationConf("battle_wildmonster_escape_text_2")
          local textFormat = localizationConf and localizationConf.msg
          popupHintTextValue = textFormat and string.format(textFormat, tostring(self.petName)) or ""
        else
          local localizationConf = _G.DataConfigManager:GetLocalizationConf("battle_wildmonster_escape_text_1")
          local textFormat = localizationConf and localizationConf.msg
          popupHintTextValue = textFormat and string.format(textFormat, tostring(self.petName), restRoundToEscapeText) or ""
        end
        self.PopupHintText:SetText(popupHintTextValue)
        self.runAwayCount = restRoundToEscape
      else
        self.runAwayCount = -1
        self:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    else
      self.runAwayCount = -1
      self.PopupHintText:SetText(self.escape_info_conf.description or "")
    end
  elseif BattleUtils.IsWorldLeaderFight() then
    if BattleUtils.GetWorldLeaderRewardCount() > 1 then
      self.runAwayCountIconPath = "PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/Combat/Frames/img_star_bg_png.img_star_bg_png'"
      self.runAwayCount = -1
      self.PopupHintText:SetText(LuaText.worldcombat_execution_tips)
    else
      self.runAwayCountIconPath = nil
      self.runAwayCount = -1
      self.PopupHintText:SetText("")
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_Battle_RunAway_C:RefreshIcons()
  self:SetRunAwayCountIcon(self.runAwayCountIconPath)
  self:SetRunAwayCount(self.runAwayCount)
end

function UMG_Battle_RunAway_C:DisableButton()
  self.RunAwayButton:SetIsEnabled(false)
end

function UMG_Battle_RunAway_C:EnableButton()
  self.RunAwayButton:SetIsEnabled(true)
end

function UMG_Battle_RunAway_C:SetPetInfo(battlePet, card)
  if self.battlePet then
    self:RemoveListeners()
  end
  self.battlePet = battlePet
  self:UpdateSpecialMoveData()
  self.petName = card.name
  self.monsterId = card.petInfo.battle_common_pet_info.conf_id
  local allSpecialMoveConfList = _G.DataConfigManager:GetAllByTableID(_G.DataConfigManager.ConfigTableId.SPECIAL_MOVE_CONF) or {}
  for id, conf in pairs(allSpecialMoveConfList) do
    local confMonsterId = conf.monsterID or -1
    if confMonsterId == self.monsterId then
      self.escape_info_conf = conf
      break
    end
  end
  if self.escape_info_conf or BattleUtils.IsWorldLeaderFight() then
    self:AddListeners()
    self:UpdateRunAwayData()
    self:RefreshIcons()
  else
    self:Hide()
  end
end

function UMG_Battle_RunAway_C:Hide()
  self.isOpen = false
  self:ShowHint()
end

function UMG_Battle_RunAway_C:Show()
  if self:CanShow() then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.isOpen = true
  else
    self.isOpen = false
  end
  self:ShowHint()
end

function UMG_Battle_RunAway_C:ShowHint()
  if self.isOpen == self.isOpenDisplay then
    return
  end
  if self:IsAnimationPlaying(self.NewOpen) then
    return
  end
  if self.isOpen then
    local playSpeedRate = 1
    if self.isOpenAfterPopupEnd then
      playSpeedRate = 2
    end
    self:PlayAnimationTimeRange(self.NewOpen, 0, 1, 1, 0, playSpeedRate)
  else
    self:PlayAnimationTimeRange(self.NewOpen, 0.75, 0, 1, 1, 5)
  end
  self.isOpenDisplay = self.isOpen
  self.isOpenAfterPopupEnd = false
end

function UMG_Battle_RunAway_C:CanShow()
  if self.IsHasPopup then
    return false
  end
  if self.ForceHide then
    return false
  end
  do
    local battleCard = self.battlePet and self.battlePet.card
    local petState = battleCard and battleCard.petState
    local isRidOf = petState and petState:GetBeRidOf()
    if isRidOf then
      return false
    end
  end
  if self.escape_info_conf then
    if self.escape_info_conf.skill_trigger_type == Enum.SkillTriggerType.STGT_SPE_ROUND_GAP then
      return true
    elseif self.escape_info_conf.skill_trigger_type == Enum.SkillTriggerType.STGT_SPE_ESCAPE then
      return self.specialMoveInfo ~= nil
    end
  elseif BattleUtils.IsWorldLeaderFight() then
    return BattleUtils.GetWorldLeaderRewardCount() > 1
  end
end

function UMG_Battle_RunAway_C:PCModeScreenSetting()
  if UE.UGameplayStatics.GetGameInstance(self):IsPCMode() then
    local Padding = UE4.FMargin()
    Padding.Left = -100
    Padding.Top = 182
    Padding.Right = 30
    Padding.Bottom = 30
    self.CanvasPanel_154.Slot:SetOffsets(Padding)
  end
end

function UMG_Battle_RunAway_C:UpdateSpecialMoveData()
  local battleRuntimeData = _G.BattleManager.battleRuntimeData
  local battlePet = self.battlePet
  if battleRuntimeData then
    local specialMoveInfoList = battleRuntimeData.specialMoveInfoList or {}
    for i, specialMoveInfo in ipairs(specialMoveInfoList) do
      local petId = battlePet and battlePet.guid
      if petId == specialMoveInfo.pet_id then
        self.specialMoveInfo = specialMoveInfo
        break
      end
    end
  end
end

function UMG_Battle_RunAway_C:OnAnimationFinished(Anim)
  if self.NewOpen == Anim then
    self:ShowHint()
  end
end

return UMG_Battle_RunAway_C
