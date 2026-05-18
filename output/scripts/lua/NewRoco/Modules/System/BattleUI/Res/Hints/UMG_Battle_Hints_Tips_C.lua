local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local ProtoEnum = require("Data.PB.ProtoEnum")
local UMG_Battle_Hints_Tips_C = _G.NRCPanelBase:Extend("UMG_Battle_Hints_Tips_C")
UMG_Battle_Hints_Tips_C.DamageTypeMap = {
  [1] = nil,
  [2] = 1,
  [3] = 2
}
UMG_Battle_Hints_Tips_C.ContextData = nil

function UMG_Battle_Hints_Tips_C:OnConstruct()
  self.spEnergyUI = {
    self.SpEnergySkillInfo1,
    self.SpEnergySkillInfo2,
    self.SpEnergySkillInfo3,
    self.SpEnergySkillInfo4
  }
  self.HotArea:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.GainCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:AddButtonListener(self.HotArea, self.OnHotAreaClick)
end

function UMG_Battle_Hints_Tips_C:OnDestruct()
  self:RemoveButtonListener(self.HotArea)
end

function UMG_Battle_Hints_Tips_C:OnActive(contextData)
  self:PlayAnimation(self.open)
  self.HotArea:SetVisibility(UE4.ESlateVisibility.Visible)
  self:Reset()
  if contextData.info and contextData.pet then
    Log.Debug("Will Update Skill Prediction Data")
    self.info = contextData.info
    self.pet = contextData.pet
    self:UpdateInfo(contextData.info, contextData.pet)
  end
end

function UMG_Battle_Hints_Tips_C:OnDeactive()
  self.info = nil
  self.pet = nil
end

function UMG_Battle_Hints_Tips_C:UpdateInfo(info, pet)
  if not info or not pet then
    return
  end
  self:SetCasterTitle()
  self:SetSkillBox()
  self:SetNormalBox()
  self:SetSpeciesPanel()
  self:SetEnergyPanel()
  self:SetEffectsPanel()
  self:SetSkillPanel()
  self:SetTargetBox()
  self:SetNormalDescTxt()
end

function UMG_Battle_Hints_Tips_C:IsRest(info)
  if info.show_skill_feature and 6 == info.skill_feature then
    return true
  end
  return false
end

function UMG_Battle_Hints_Tips_C:Reset()
  self.EnergyPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.SpeciesPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.EffectsPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.SkillPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.NormalBox:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.SkillBox:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TargetBox:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:ResetTargetUI()
  self.mainDesc = ""
end

function UMG_Battle_Hints_Tips_C:SetCasterTitle()
  local txt = ""
  if self.info.npc_hint_mode == ProtoEnum.ShowType.ST_WRONG then
    txt = _G.DataConfigManager:GetBattleGlobalConfig("battle_npc_skill_prediction_sihubu").str
    local player = self.pet.player
    if player then
      txt = string.format(txt, player.roleInfo.base.name)
    else
      txt = string.format(txt, self.pet.petInfo.battle_common_pet_info.name)
    end
  elseif self.info.npc_hint_mode == ProtoEnum.ShowType.ST_NO_HINT then
    txt = _G.DataConfigManager:GetBattleGlobalConfig("battle_skill_prediction_sihu").str
    txt = string.format(txt, self.pet.card.petInfo.battle_common_pet_info.name)
  else
    txt = _G.DataConfigManager:GetBattleGlobalConfig("battle_npc_skill_prediction_sihu").str
    local player = self.pet.player
    if player then
      txt = string.format(txt, player.roleInfo.base.name)
    else
      txt = string.format(txt, self.pet.petInfo.battle_common_pet_info.name)
    end
  end
  self.Title:SetText(txt)
end

function UMG_Battle_Hints_Tips_C:SetSkillBox()
  if (self.info.npc_hint_mode == ProtoEnum.ShowType.ST_DIRECT or self.info.npc_hint_mode == ProtoEnum.ShowType.ST_NO_HINT) and self.info.show_skill_id then
    self.SkillBox:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local specialId = _G.DataConfigManager:GetGlobalConfigNumByKeyType("change_pet_icon", _G.DataConfigManager.ConfigTableId.BATTLE_GLOBAL_CONFIG, 0)
    if SkillUtils.InstSkillIdToCfgId(self.info.skill_id) == specialId then
      self:UpdateSkillInfoById(self.info.skill_id)
    else
      for _, skill in ipairs(self.pet.skillComponent.skills) do
        if skill.id == self.info.skill_id then
          self:UpdateSkillInfo(skill.skillData, skill)
          break
        end
      end
    end
  end
end

function UMG_Battle_Hints_Tips_C:SetNormalBox()
  if self.info.npc_hint_mode == ProtoEnum.ShowType.ST_DIRECT or self.info.npc_hint_mode == ProtoEnum.ShowType.ST_NO_HINT and self.info.show_skill_id or not self.info.show_cost_energy and not self.info.show_dam_type and not self.info.show_skill_feature and (self.info.npc_hint_mode ~= ProtoEnum.ShowType.ST_WRONG or not self.info.show_skill_id) and self.info.npc_hint_mode ~= ProtoEnum.ShowType.ST_RANGE then
    self.NormalBox:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  self.NormalBox:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_Battle_Hints_Tips_C:SetTargetBox()
  local info = self.info
  if not (self.info.npc_hint_mode ~= ProtoEnum.ShowType.ST_NO_HINT or self.info.show_skill_id) or self.info.npc_hint_mode == ProtoEnum.ShowType.ST_HINT then
    self.TargetBox:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    return
  end
  if info.skill_targets then
    self.TargetDescription:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local txt = _G.DataConfigManager:GetBattleGlobalConfig("battle_skill_prediction_xiang").str
    if self.info.npc_hint_mode ~= ProtoEnum.ShowType.ST_NO_HINT then
      txt = _G.DataConfigManager:GetBattleGlobalConfig("battle_npc_skill_prediction_xiang").str
    end
    self.TargetDescriptionPreTxt:SetText(txt)
    for i = 1, #info.skill_targets do
      local target = _G.BattleManager.battlePawnManager:GetPetByGuid(info.skill_targets[i])
      local baseConf = _G.DataConfigManager:GetPetbaseConf(target.card.petInfo.battle_common_pet_info.base_conf_id)
      local modelConf = _G.DataConfigManager:GetModelConf(baseConf.model_conf)
      self["Target_Icon_" .. i]:SetPath(NRCUtils:FormatConfIconPath(modelConf.ui_icon, _G.UIIconPath.UIHeadIconPath))
      self["Target_Icon_" .. i]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    self.TargetDescription:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Battle_Hints_Tips_C:SetNormalDescTxt()
  if (self.info.npc_hint_mode == ProtoEnum.ShowType.ST_DIRECT or self.info.npc_hint_mode == ProtoEnum.ShowType.ST_NO_HINT) and self.info.show_skill_id then
    return
  end
  local finalDesc = _G.DataConfigManager:GetBattleGlobalConfig("battle_skill_prediction_shifang").str
  if self.info.npc_hint_mode ~= ProtoEnum.ShowType.ST_NO_HINT then
    finalDesc = _G.DataConfigManager:GetBattleGlobalConfig("battle_npc_skill_prediction_shifang").str
  end
  finalDesc = string.format(finalDesc, self.mainDesc)
  self.NormalDescriptionTxt:SetText(finalDesc)
end

function UMG_Battle_Hints_Tips_C:SetSpeciesPanel()
  if self.info.show_dam_type then
    local typeDict = _G.DataConfigManager:GetTypeDictionary(self.info.dam_type)
    if typeDict then
      self.Species_Icon:SetPath(typeDict.hint_res)
      self.Species_Icon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.mainDesc = self.mainDesc .. typeDict.type_name
      self.SpeciesPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end

function UMG_Battle_Hints_Tips_C:SetEffectsPanel()
  if self.info.show_skill_feature then
    local featureId = BattleUtils.GetMSB(self.info.skill_feature)
    local skill_tag = _G.DataConfigManager:GetSkillTag(featureId)
    if skill_tag then
      self.Effect_Icon:SetPath(skill_tag.tag_icon)
      self.Effect_Icon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.mainDesc = self.mainDesc .. skill_tag.tag
      self.EffectsPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end

function UMG_Battle_Hints_Tips_C:SetEnergyPanel()
  if self.info.show_cost_energy and self.info.cost_energy then
    self.EnergyNum:SetText(self.info.cost_energy)
    self.EnergyNum:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local txt = _G.DataConfigManager:GetBattleGlobalConfig("battle_skill_prediction_energy").str
    self.mainDesc = self.mainDesc .. string.format(txt, self.info.cost_energy)
    self.EnergyPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Battle_Hints_Tips_C:SetSkillPanel()
  if self.info.npc_hint_mode == ProtoEnum.ShowType.ST_NO_HINT then
    return
  elseif self.info.npc_hint_mode == ProtoEnum.ShowType.ST_DIRECT then
    return
  elseif self.info.npc_hint_mode == ProtoEnum.ShowType.ST_WRONG then
    self.OrText:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SkillIconBox_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SkillIconBox_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NonRelease_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.info.show_skill_id and self.info.skill_id then
      local skillConf = _G.SkillUtils.GetSkillConf(self.info.skill_id)
      if skillConf then
        self.UIIcon_1:SetPath(NRCUtils:FormatConfIconPath(skillConf.icon, _G.UIIconPath.SkillIconPath))
        self.Skill_Name_1:SetText(skillConf.name)
      end
    end
    self.SkillPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif self.info.npc_hint_mode == ProtoEnum.ShowType.ST_RANGE then
    self.OrText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.SkillIconBox_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.SkillIconBox_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NonRelease_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NonRelease_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.info.show_skill_id then
      if self.info.skill_id then
        local skillConf = _G.SkillUtils.GetSkillConf(self.info.skill_id)
        if skillConf then
          self.UIIcon_1:SetPath(NRCUtils:FormatConfIconPath(skillConf.icon, _G.UIIconPath.SkillIconPath))
          self.Skill_Name_1:SetText(skillConf.name)
        end
      end
      if self.info.skill_id_2 then
        local skillConf = _G.SkillUtils.GetSkillConf(self.info.skill_id_2)
        if skillConf then
          self.UIIcon_2:SetPath(NRCUtils:FormatConfIconPath(skillConf.icon, _G.UIIconPath.SkillIconPath))
          self.Skill_Name_2:SetText(skillConf.name)
        end
      end
    end
    self.SkillPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif self.info.npc_hint_mode == ProtoEnum.ShowType.ST_HINT then
    return
  end
end

function UMG_Battle_Hints_Tips_C:ResetTargetUI()
  self.Target_Icon_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Target_Icon_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Battle_Hints_Tips_C:Show()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_Battle_Hints_Tips_C:Hide()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Battle_Hints_Tips_C:OnHotAreaClick()
  Log.Debug("UMG_Common_Skill_Tips_C:OnHotAreaClick")
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1076, "UMG_Common_Skill_Tips_C:OnHotAreaClick")
  self.HotArea:SetVisibility(UE4.ESlateVisibility.Hidden)
  self:PlayAnimation(self.close)
end

function UMG_Battle_Hints_Tips_C:OnAnimationFinished(Animation)
  if self.open == Animation then
    self:PlayAnimation(self.loop)
  elseif self.close == Animation then
    self:DoClose()
  end
end

function UMG_Battle_Hints_Tips_C:UpdateSkillInfoById(skillID)
  local skillConf = _G.SkillUtils.GetSkillConf(skillID)
  self.SkillIcon:SetPath(NRCUtils:FormatConfIconPath(skillConf.icon, _G.UIIconPath.SkillIconPath))
  self.TxtSkillName:SetText(skillConf.name)
  local typeDic = _G.DataConfigManager:GetTypeDictionary(skillConf.skill_dam_type)
  if typeDic then
    self.PetTypeIcon1:SetPath(typeDic.type_icon)
  end
  if skillConf.type == ProtoEnum.SkillActiveType.SAT_LACKENERGY then
    self.StarImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TxtPnumCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if skillConf.energy_cost[1] then
      self.TxtPnum:SetText(tostring(skillConf.energy_cost[1]))
    end
  elseif skillConf.type == ProtoEnum.SkillActiveType.SAT_IDLE then
    self.StarImage:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.TxtPnumCanvas:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif skillConf.type == ProtoEnum.SkillActiveType.SAT_FEATURE then
    self.StarImage:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.TxtPnumCanvas:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif skillConf.type == ProtoEnum.SkillActiveType.SAT_NORMAL then
    self.StarImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TxtPnumCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TxtPnum:SetText(tostring(skillConf.energy_cost[1]))
  else
    self.StarImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TxtPnumCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local damageTypeImg = UMG_Battle_Hints_Tips_C.DamageTypeMap[skillConf.damage_type]
  if 1 ~= skillConf.damage_type then
    self.TxtPower:SetText(tostring(skillConf.dam_para[1]))
    self.ImgPower:ChangeImage(damageTypeImg)
    self.ImgPower:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.ImgPower:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TxtPower:SetText("-")
  end
  if skillConf.cd_round[1] <= 1 then
    self.CDText:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.CDText:SetVisibility(UE4.ESlateVisibility.Visible)
    local DisplayCD = skillConf.cd_round[1] - 1
    self.CDText:SetText(string.format(LuaText.SKILL_TIPS_CD, DisplayCD))
  end
  self.Desc:SetText(skillConf.desc)
  self.AmplifyInfoGroup_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.AmplifyDesc_1:SetText("")
  self.AmplifyIcon_1:SetPath("")
  self.AmplifyInfo:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if skillConf.target_field and #skillConf.target_field > 0 and #skillConf.field_skill > 0 then
    self.Content_SpEnergy:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    for i = 1, #self.spEnergyUI do
      if i <= #skillConf.target_field and skillConf.field_skill[i] > 0 then
        self.spEnergyUI[i]:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
        self.spEnergyUI[i]:InitUI(skillConf.field_belong, skillConf.target_field[i], skillConf.field_skill[i])
      else
        self.spEnergyUI[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  else
    self.Content_SpEnergy:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Battle_Hints_Tips_C:UpdateSkillInfo(skillData, skillEntity)
  local skillConf = _G.DataConfigManager:GetSkillConf(skillData.skill_id)
  local newSkillConfig = skillConf
  if skillEntity then
    newSkillConfig = _G.BattleManager.battleRuntimeData:GetNewSkillBySpEnergy(skillEntity)
  end
  self.SkillIcon:SetPath(NRCUtils:FormatConfIconPath(newSkillConfig.icon, _G.UIIconPath.SkillIconPath))
  self.TxtSkillName:SetText(newSkillConfig.name)
  local typeDic = _G.DataConfigManager:GetTypeDictionary(newSkillConfig.skill_dam_type)
  if typeDic then
    self.PetTypeIcon1:SetPath(typeDic.type_icon)
  end
  if skillData.type == ProtoEnum.SkillActiveType.SAT_LACKENERGY then
    self.StarImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TxtPnumCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if skillEntity then
      self.TxtPnum:SetText(tostring(skillEntity.energy))
    end
  elseif skillData.type == ProtoEnum.SkillActiveType.SAT_IDLE then
    self.StarImage:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.TxtPnumCanvas:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif skillData.type == ProtoEnum.SkillActiveType.SAT_FEATURE then
    self.StarImage:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.TxtPnumCanvas:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif skillEntity and skillEntity:IsCostEnergy() then
    self.StarImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TxtPnumCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TxtPnum:SetText(tostring(skillEntity.energy))
  else
    self.StarImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TxtPnumCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local damageTypeImg = UMG_Battle_Hints_Tips_C.DamageTypeMap[skillConf.damage_type]
  if 1 ~= skillConf.damage_type then
    self.TxtPower:SetText(tostring(newSkillConfig.dam_para[1]))
    self.ImgPower:ChangeImage(damageTypeImg)
    self.ImgPower:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.ImgPower:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TxtPower:SetText("-")
  end
  if skillConf.cd_round[1] <= 1 then
    self.CDText:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.CDText:SetVisibility(UE4.ESlateVisibility.Visible)
    local DisplayCD = skillConf.cd_round[1] - 1
    self.CDText:SetText(string.format(LuaText.SKILL_TIPS_CD, DisplayCD))
  end
  self.Desc:SetText(skillConf.desc)
  if skillEntity then
    self.AmplifyInfoGroup_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.AmplifyInfoGroup_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.AmplifyInfoGroup_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.AmplifyDesc_1:SetText("")
    self.AmplifyIcon_1:SetPath("")
    self.AmplifyInfo:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if skillConf.target_field and #skillConf.target_field > 0 and #skillConf.field_skill > 0 then
    self.Content_SpEnergy:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    for i = 1, #self.spEnergyUI do
      if i <= #skillConf.target_field and skillConf.field_skill[i] > 0 then
        self.spEnergyUI[i]:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
        self.spEnergyUI[i]:InitUI(skillConf.field_belong, skillConf.target_field[i], skillConf.field_skill[i])
      else
        self.spEnergyUI[i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  else
    self.Content_SpEnergy:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_Battle_Hints_Tips_C
