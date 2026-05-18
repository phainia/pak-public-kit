local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_LineupSkills_C = Base:Extend("UMG_LineupSkills_C")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")

function UMG_LineupSkills_C:OnConstruct()
end

function UMG_LineupSkills_C:OnDestruct()
end

function UMG_LineupSkills_C:OnItemUpdate(_data, datalist, index)
  self.skillIndex = index
  self.uiData = _data
  if self.uiData then
    self.petIndex = self.uiData.petIndex
    self.petGid = self.uiData.petGid
    if self.uiData.sharedPetSkillData then
      self:CheckHasSkillDataAndUpdateUI()
      if self.lostSkill then
        self:UpdateInfo(self.uiData.sharedPetSkillData)
      else
        self:UpdateInfo(self.uiData.petSkillData)
      end
    else
      self:UpdateInfo(self.uiData)
    end
  else
    Log.Error("UMG_LineupSkills_C:OnItemUpdate", "uiData is nil")
  end
end

function UMG_LineupSkills_C:UpdateInfo(skillData)
  if not skillData then
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
    return
  else
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  if 0 == skillData.id then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  local skillConf = _G.DataConfigManager:GetSkillConf(skillData.id)
  if skillConf then
    self.skillConf = skillConf
    self.SkillIcon:SetPath(skillConf.icon)
    self.SkillNameTxt:SetText(skillConf.name)
    self.skillIsValid = true
    if self.uiData.bFantastic then
      self.Select_NM_3:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Select_NM_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    Log.Debug("\230\138\128\232\131\189id\230\178\146\230\156\137\230\137\190\229\136\176", skillData.skill_id)
    self.skillIsValid = false
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_LineupSkills_C:CheckHasSkillDataAndUpdateUI()
  if 0 == self.uiData.petSkillData.id then
    self.lostSkill = true
    local petDataInfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.petGid)
    for _, skill in pairs(petDataInfo.skill.skill_data) do
      if skill.id == self.uiData.sharedPetSkillData.id and skill.is_learned then
        self.lostSkill = false
        NRCEventCenter:DispatchEvent(PetUIModuleEvent.ChangePetSkill, self.petIndex, self.skillIndex, self.uiData.sharedPetSkillData.id)
        break
      end
    end
  else
    self.lostSkill = false
  end
  if self.lostSkill then
    if self.HighlightOutline then
      self.HighlightOutline:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    self.ExclamationMark:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    if self.HighlightOutline then
      self.HighlightOutline:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.ExclamationMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_LineupSkills_C:OnItemSelected(_bSelected)
  if _bSelected and self.lostSkill then
    local skillsList = {}
    if not self.skillIsValid then
      skillsList = self.uiData.petSkillData.alternative_skills
    else
      table.insert(skillsList, self.uiData.sharedPetSkillData.id)
    end
    if self.uiData.petSkillData.alternative_skills then
      for _, id in ipairs(self.uiData.petSkillData.alternative_skills) do
        local hasRepeatedSkill = false
        for j, skill in ipairs(self.uiData.fullPetSkillData) do
          if skill.id == id then
            hasRepeatedSkill = true
            break
          end
        end
        if false == hasRepeatedSkill then
          table.insert(skillsList, id)
        end
      end
    end
    _G.NRCAudioManager:PlaySound2DAuto(40002004, "UMG_LineupSkills_C:OnItemSelected")
    NRCModuleManager:DoCmd(PetUIModuleCmd.OpenSkillAlternative, 1, skillsList, self.petIndex, self.skillIndex, self.skillIsValid, self.petGid)
  end
end

function UMG_LineupSkills_C:OnDeactive()
end

return UMG_LineupSkills_C
