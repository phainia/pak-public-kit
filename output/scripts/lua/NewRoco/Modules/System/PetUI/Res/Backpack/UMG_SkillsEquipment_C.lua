local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_SkillsEquipment_C = Base:Extend("UMG_SkillsEquipment_C")

function UMG_SkillsEquipment_C:OnConstruct()
end

function UMG_SkillsEquipment_C:OnDestruct()
end

function UMG_SkillsEquipment_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  self:UpdateInfo(self.uiData)
end

function UMG_SkillsEquipment_C:UpdateInfo(skillData)
  if not skillData then
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
    return
  else
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  local skillConf = _G.SkillUtils.GetSkillConf(skillData.id)
  local commonAttrData = {}
  if skillConf then
    self.skillConf = skillConf
    self.SkillIcon:SetPath(skillConf.icon)
    self.SkillNameTxt:SetText(skillConf.name)
    self.Number:SetText(self.index)
    if self.Select_NM_3 then
      if self.uiData.bFantastic then
        self.Select_NM_3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        self.Select_NM_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  else
    Log.Debug("\230\138\128\232\131\189id\230\178\146\230\156\137\230\137\190\229\136\176", skillData.skill_id)
  end
end

function UMG_SkillsEquipment_C:OnItemSelected(_bSelected)
  if _bSelected and self.skillConf then
    _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.OpenSkillTips, {
      skillData = self.skillConf,
      HideClose = false,
      isAddImc = true
    }, true)
  end
end

function UMG_SkillsEquipment_C:OnDeactive()
end

return UMG_SkillsEquipment_C
