local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local UMG_Backpack_ChangePet_Attr_C = Base:Extend("UMG_Backpack_ChangePet_Attr_C")

function UMG_Backpack_ChangePet_Attr_C:OnConstruct()
end

function UMG_Backpack_ChangePet_Attr_C:OnDestruct()
end

function UMG_Backpack_ChangePet_Attr_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  self:UpdateInfo(self.uiData)
end

function UMG_Backpack_ChangePet_Attr_C:UpdateInfo(skillData)
  if not skillData then
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
    return
  else
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  local skillConf = _G.SkillUtils.GetSkillConf(skillData.id)
  local commonAttrData = {}
  if skillConf then
    self.SkillIcon:SetPath(skillConf.icon)
    self.TxtSkillName:SetText(skillConf.name)
    local skillDesc = skillConf.desc
    self.Desc:SetText(skillDesc)
    local typeDic = _G.DataConfigManager:GetTypeDictionary(skillConf.skill_dam_type)
    if typeDic then
      table.insert(commonAttrData, {
        Path = typeDic.tips_res
      })
    end
    if skillConf.damage_type == Enum.DamageType.DT_NONE then
      if commonAttrData[1] then
        commonAttrData[1].Name = "-"
      else
        table.insert(commonAttrData, {Name = "-"})
      end
    elseif commonAttrData[1] then
      commonAttrData[1].Name = string.format("%d", skillConf.dam_para[1] or 0)
    else
      table.insert(commonAttrData, {
        Name = string.format("%d", skillConf.dam_para[1] or 0)
      })
    end
    if skillData.NoShowline then
      self.Divider:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Divider:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if _G.BattleManager.isInBattle and 1 ~= skillConf.damage_type and not BattleUtils:IsFirstMeetAllEnemyPet(_G.BattleManager.battlePawnManager.playerTeam.player) then
      self.GainCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      local restraintResult = BattleUtils:GetSkillRestraint(skillData)
      if restraintResult == BattleEnum.TypeRestraint.ENUM_NORMAL then
        self.EffectSwitcher:SetActiveWidgetIndex(1)
      elseif restraintResult == BattleEnum.TypeRestraint.ENUM_RESTRAINT then
        self.EffectSwitcher:SetActiveWidgetIndex(0)
      elseif restraintResult == BattleEnum.TypeRestraint.ENUM_WEAK then
        self.EffectSwitcher:SetActiveWidgetIndex(2)
      else
        self.GainCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    else
      self.GainCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if skillConf.energy_rule == Enum.EnergyRule.ER_ROLEHP then
      self.Canvasnenliang:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.StarImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.RoleHPImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.SkillNengNum:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.SkillNengNum:SetText(skillConf.energy_cost[1])
    else
      self.RoleHPImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
      if 0 == skillData.cost_energy and 0 == skillConf.energy_cost[1] then
        self.Canvasnenliang:SetVisibility(UE4.ESlateVisibility.Hidden)
      else
        self.Canvasnenliang:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.StarImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.SkillNengNum:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.SkillNengNum:SetText(skillConf.energy_cost[1])
      end
    end
    if self.Attr then
      self.Attr:InitGridView(commonAttrData)
    end
  else
    Log.Debug("\230\138\128\232\131\189id\230\178\146\230\156\137\230\137\190\229\136\176", skillData.skill_id)
  end
  self:PlayAnimation(self.TweenIn, 0, 1)
end

function UMG_Backpack_ChangePet_Attr_C:ShowDescPanel(id)
  id = string.format("%s%s%s", id, "A", self.index)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ShowDescRightPanel, id)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ShowDescCampPanel, id)
  _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.ShowDescPanel, id)
end

function UMG_Backpack_ChangePet_Attr_C:OnDeactive()
end

return UMG_Backpack_ChangePet_Attr_C
