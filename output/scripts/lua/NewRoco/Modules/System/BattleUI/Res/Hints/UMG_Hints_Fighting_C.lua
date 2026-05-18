local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local SkillUtils = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.SkillUtils")
local UMG_Common_Skill_Tips_C = require("NewRoco.Modules.System.BattleUI.Res.UMG_Common_Skill_Tips_C")
local ProtoEnum = require("Data.PB.ProtoEnum")
local UMG_Hints_Fighting_C = NRCViewBase:Extend("UMG_Hints_Fighting_C")

function UMG_Hints_Fighting_C:Construct()
  self.Overridden.Construct(self)
  self:Log("UMG_Hints_Fighting_C Construct")
  self._timer = 0
  self._longPressThreshold = BattleConst.ItemLongPressThreshold
  self._pressed = false
  self.isShow = false
  self.isShowDisplay = false
  self.Btn.OnPressed:Add(self, self._OnItemPressed)
  self.Btn.OnReleased:Add(self, self._OnItemRelease)
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  if self.info and self.pet then
    local data = {}
    data.info = self.info
    data.pet = self.pet
    self:SetData(data)
  end
end

function UMG_Hints_Fighting_C:Destruct()
  self:Log("UMG_Hints_Fighting_C Destruct")
  self.Btn.OnPressed:Remove(self, self._OnItemPressed)
  self.Btn.OnReleased:Remove(self, self._OnItemRelease)
  NRCUmgClass.Destruct(self)
end

function UMG_Hints_Fighting_C:_OnItemPressed()
  Log.Debug("UMG_Hints_Fighting_C _OnItemPressed")
  self._pressed = true
  self._timer = self._longPressThreshold
end

function UMG_Hints_Fighting_C:_OnItemRelease()
  Log.Debug("UMG_Hints_Fighting_C _OnItemRelease")
  if self._pressed then
    self:DoClick()
  end
  if not self._pressed then
  end
  self._pressed = false
end

function UMG_Hints_Fighting_C:DoLongClick()
  Log.Debug("UMG_Hints_Fighting_C _OnItemPressed Long")
  self._pressed = false
  self._timer = 0
  if BattleUtils.IsTerritoryTrialBattle() then
  elseif self.info and BattleConst.EnableOpenSkillPredictionTips then
    _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.OpenSkillPredictionTips, {
      info = self.info,
      pet = self.pet
    })
  end
end

function UMG_Hints_Fighting_C:DoClick()
  Log.Debug("UMG_Hints_Fighting_C DoClick")
  if BattleUtils.IsTerritoryTrialBattle() then
    self:OpenSkillTips()
  end
end

function UMG_Hints_Fighting_C:Tick(geometry, deltaTime)
  if not self._pressed then
    return
  end
  self._timer = self._timer - deltaTime
  if self._timer <= 0 then
    self:DoLongClick()
  end
end

function UMG_Hints_Fighting_C:Setup()
end

function UMG_Hints_Fighting_C:GetRootPosition()
  local CanvasPanelRootSlot = self.CanvasPanel_0 and self.CanvasPanel_0.Slot
  local Position = CanvasPanelRootSlot:GetPosition()
  return Position
end

function UMG_Hints_Fighting_C:SetRootPosition(nextPosition)
  local CanvasPanelRootSlot = self.CanvasPanel_0 and self.CanvasPanel_0.Slot
  CanvasPanelRootSlot:SetPosition(nextPosition)
end

function UMG_Hints_Fighting_C:SetData(data)
  self.data = data
  self:Reset()
  local info = data and data.info
  local pet = data and data.pet
  local isSkillBubble = data.isSkillBubble
  self.info = info
  self.pet = pet
  if not info then
    return
  end
  self.Bubble:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if BattleUtils.IsPve() then
    self.State:SetActiveWidgetIndex(1)
    self:SetEnergyState(info)
    self:SetDamTypeState(info)
    self:SetSkillFeatureState(info)
    self:SetSkillState(info)
    self:SetSkillTargetsState(info)
  elseif isSkillBubble then
    self.Bubble:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Bubble_Skill:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Skill:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Pet_UIIcon_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.State:SetActiveWidgetIndex(1)
    local skillId = info and info.show_skill_id
    local skillConf = _G.SkillUtils.GetSkillConf(skillId, true)
    local skillIcon = skillConf and skillConf.icon
    if skillIcon then
      self.Pet_UIIcon_1:SetPath(skillIcon)
    end
    local skillComponent = pet and pet.skillComponent
    local skillEntity = skillComponent and skillComponent:GetSkillBySkillID(skillId)
    local skillRoundData = skillEntity and skillEntity.skillData
    local damageType = skillRoundData and skillRoundData.damage_type
    damageType = damageType or skillConf and skillConf.damage_type
    local skillType = skillConf and skillConf.Skill_Type
    local skillTypeText, skillTypeIconPath = BattleUtils.GetSkillTypePath(skillType, damageType)
    self.Icon:SetPath(skillTypeIconPath)
  elseif self:IsRest(info) then
    self.State:SetActiveWidgetIndex(0)
    local skillTag = _G.DataConfigManager:GetSkillTag(info.skill_feature)
    if skillTag then
      self.Rest_Icon:SetPath(skillTag.tag_icon)
      self.Rest_Icon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    self.State:SetActiveWidgetIndex(1)
    self:SetEnergyState(info)
    self:SetDamTypeState(info)
    self:SetSkillFeatureState(info)
    self:SetSkillState(info)
    self:SetSkillTargetsState(info)
  end
end

function UMG_Hints_Fighting_C:SetEnergyState(info)
  if info.show_cost_energy then
    if info.cost_energy then
      self.EnergyNum:SetText(info.cost_energy)
      self.EnergyNum:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    self.EnergyPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Hints_Fighting_C:SetDamTypeState(info)
  if info.show_dam_type then
    local typeDict = _G.DataConfigManager:GetTypeDictionary(info.dam_type)
    if typeDict then
      self.Species_Icon:SetPath(typeDict.hint_res)
      self.Species_Icon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end

function UMG_Hints_Fighting_C:SetSkillFeatureState(info)
  if info.show_skill_feature then
    local featureId = BattleUtils.GetMSB(info.skill_feature)
    local skill_tag = _G.DataConfigManager:GetSkillTag(featureId)
    if skill_tag then
      self.Effect_Icon:SetPath(skill_tag.tag_icon)
      self.Effect_Icon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end

function UMG_Hints_Fighting_C:SetSkillTargetsState(info)
  if info.skill_targets then
    for i = 1, #info.skill_targets do
      local target = _G.BattleManager.battlePawnManager:GetPetByGuid(info.skill_targets[i])
      local baseConf = _G.DataConfigManager:GetPetbaseConf(target.card.petInfo.battle_common_pet_info.base_conf_id)
      local modelConf = _G.DataConfigManager:GetModelConf(baseConf.model_conf)
      self["Pet_UIIcon_" .. i]:SetPath(modelConf.ui_icon)
      self["Pet_UIIcon_" .. i]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end

function UMG_Hints_Fighting_C:SetSkillState(info)
  if info.hint_level ~= ProtoEnum.SkillHintLevel.LEVEL_INVALID then
    if info.show_skill_id then
      Log.Debug(info.skill_id)
      local skillConf = _G.SkillUtils.GetSkillConf(info.skill_id)
      if skillConf then
        self.UIIcon_1:SetPath(skillConf.icon)
      end
      self.Skills:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif info.show_skill_id then
    if info.npc_hint_mode == ProtoEnum.ShowType.ST_NO_HINT then
      return
    elseif info.npc_hint_mode == ProtoEnum.ShowType.ST_HINT then
      return
    elseif info.npc_hint_mode == ProtoEnum.ShowType.ST_DIRECT then
      local skillConf = _G.SkillUtils.GetSkillConf(info.skill_id)
      if skillConf then
        self.UIIcon_1:SetPath(skillConf.icon)
      end
      self.NonRelease_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.SkillIconBox_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    elseif info.npc_hint_mode == ProtoEnum.ShowType.ST_RANGE then
      local skillConf = _G.SkillUtils.GetSkillConf(info.skill_id)
      if skillConf then
        self.UIIcon_1:SetPath(skillConf.icon)
      end
      self.NonRelease_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.SkillIconBox_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      local skillConf2 = _G.SkillUtils.GetSkillConf(info.skill_id_2)
      if skillConf2 then
        self.UIIcon_2:SetPath(skillConf2.icon)
      end
      self.NonRelease_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.SkillIconBox_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.SkillSlashBox:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    elseif info.npc_hint_mode == ProtoEnum.ShowType.ST_WRONG then
      local skillConf = _G.SkillUtils.GetSkillConf(info.skill_id)
      if skillConf then
        self.UIIcon_1:SetPath(skillConf.icon)
      end
      self.NonRelease_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.SkillIconBox_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    self.Skills:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Hints_Fighting_C:Reset()
  self.Rest_Icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.EnergyPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Species_Icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Effect_Icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Bubble_Skill:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Skills:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Skill:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.SkillIconBox_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.SkillSlashBox:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.SkillIconBox_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Pet_UIIcon_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Pet_UIIcon_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Hints_Fighting_C:IsRest(info)
  if info.show_skill_feature and 6 == info.skill_feature then
    return true
  end
  return false
end

function UMG_Hints_Fighting_C:OnAnimationFinished(Animation)
  if Animation == self:GetTweenInAnimation(self.data) then
    local loopAnimation = self:GetLoopAnimation(self.data)
    self:PlayAnimation(loopAnimation, 0, 99999, 0, 1, true)
  elseif Animation == self:GetLoopAnimation(self.data) then
    self:RefreshDisplayShow()
  elseif Animation == self:GetTweenOutAnimation(self.data) then
    self:RefreshDisplayShow()
  end
end

function UMG_Hints_Fighting_C:Show()
  self:SetIsShow(true)
end

function UMG_Hints_Fighting_C:Hide()
  self:SetIsShow(false)
end

function UMG_Hints_Fighting_C:SetIsShow(nextIsShow)
  local prevIsShow = self.isShow
  self.isShow = nextIsShow
  self:OnIsShowChange(prevIsShow, nextIsShow)
  self:RefreshDisplayShow()
end

function UMG_Hints_Fighting_C:OnIsShowChange(prevIsShow, nextIsShow)
  if self:IsTweenInOutAnimationPlaying() then
    return
  end
  if prevIsShow == nextIsShow then
    return
  end
  if nextIsShow then
    self:PlayAnimation(self:GetTweenInAnimation(self.data))
  else
    self:StopAnimation(self:GetLoopAnimation(self.data))
    self:PlayAnimation(self:GetTweenOutAnimation(self.data))
  end
end

function UMG_Hints_Fighting_C:RefreshDisplayShow()
  local isShow = self.isShow
  local prevIsShowDisplay = self.isShowDisplay
  local nextIsShowDisplay = isShow
  if self:IsTweenInOutAnimationPlaying() or self:IsAnimationPlaying(self:GetLoopAnimation(self.data)) then
    nextIsShowDisplay = true
  end
  if prevIsShowDisplay == nextIsShowDisplay then
    return
  end
  self.isShowDisplay = nextIsShowDisplay
  if nextIsShowDisplay then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:SetRenderOpacity(1)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:SetRenderOpacity(0)
  end
end

function UMG_Hints_Fighting_C:IsTweenInOutAnimationPlaying()
  if self:IsAnimationPlaying(self:GetTweenInAnimation(self.data)) or self:IsAnimationPlaying(self:GetTweenOutAnimation(self.data)) then
    return true
  end
  return false
end

function UMG_Hints_Fighting_C:IsHide()
  return self.Visibility == UE4.ESlateVisibility.Collapsed or self.Visibility == UE4.ESlateVisibility.Hidden or 0 == self:GetRenderOpacity()
end

function UMG_Hints_Fighting_C:IsNpcMode()
  if self.info.hint_level ~= ProtoEnum.SkillHintLevel.LEVEL_INVALID then
    return false
  else
    return true
  end
end

function UMG_Hints_Fighting_C:GetTweenInAnimation(data)
  local isSkillBubble = data and data.isSkillBubble
  local animation = self.Bubble_In
  if isSkillBubble then
    animation = self.Bubble_Skill_In
  end
  return animation
end

function UMG_Hints_Fighting_C:GetTweenOutAnimation(data)
  local isSkillBubble = data and data.isSkillBubble
  local animation = self.Bubble_Out
  if isSkillBubble then
    animation = self.Bubble_Skill_Out
  end
  return animation
end

function UMG_Hints_Fighting_C:GetLoopAnimation(data)
  local isSkillBubble = data and data.isSkillBubble
  local animation = self.Bubble_Loop
  if isSkillBubble then
    animation = self.Bubble_Skill_Loop
  end
  return animation
end

function UMG_Hints_Fighting_C:OpenSkillTips()
  local info = self.info
  local skillId = info and info.show_skill_id
  skillId = _G.SkillUtils.CheckSkillId(skillId)
  local pet = self.pet
  local petGid = pet and pet.guid
  local skillComponent = pet and pet.skillComponent
  local skillEntity = skillComponent and skillComponent:GetSkillBySkillID(skillId)
  local skillRoundData = skillEntity and skillEntity.skillData
  local battleCard = pet and pet.card
  local petInfo = battleCard and battleCard.petInfo
  local req = petInfo and petInfo.req
  local type = req and req.req_type
  local targetPetId = -1
  if type == _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL then
    local castSkill = req and req.cast_skill
    targetPetId = castSkill and castSkill.target_pet_id
  end
  local restraint = skillEntity and skillEntity:GetRestraintByPetId(targetPetId)
  if skillRoundData then
    _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenSkillTips, {
      skillData = skillRoundData,
      skillEntity = nil,
      HideClose = false,
      closeInputActionType = UMG_Common_Skill_Tips_C.CloseInputActionType.BattleSkillItem,
      restraintResult = restraint
    })
  end
end

return UMG_Hints_Fighting_C
