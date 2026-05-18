local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PetUIModuleCmd = require("NewRoco.Modules.System.PetUI.PetUIModuleCmd")
local PetUtils = reload("NewRoco.Utils.PetUtils")
local Enum = reload("Data.Config.Enum")
local UMG_PetSkillInfo_C = _G.NRCViewBase:Extend("UMG_PetSkillInfo_C")

function UMG_PetSkillInfo_C:Initialize(Initializer)
end

function UMG_PetSkillInfo_C:OnConstruct()
  Log.Debug("UMG_PetSkillInfo_C:OnConstruct  ccc")
  self.uiData = {
    isShow = false,
    skillList = {},
    petEquipSkills = {},
    waitWorkSkillPos = 0
  }
  if self.uiData == nil then
    Log.Debug("UMG_PetSkillInfo_C:OnConstruct  aaaa")
  end
  self:OnAddEventListener()
end

function UMG_PetSkillInfo_C:OnDestruct()
  Log.Debug("UMG_PetSkillInfo_C:OnDestruct")
  self.curWorkSkill:Destruct()
  self.skillList:ReleaseForce()
end

function UMG_PetSkillInfo_C:OnEnable()
end

function UMG_PetSkillInfo_C:OnDisable()
end

function UMG_PetSkillInfo_C:getCurSelectIndex()
  return self.curSkillListSelectIndex
end

function UMG_PetSkillInfo_C:getCurSelectSkill()
  if self.curSkillListSelectIndex and self.petSkillList then
    return self.petSkillList[self.curSkillListSelectIndex]
  end
end

function UMG_PetSkillInfo_C:updatePetSkillList(_petSkillList)
  if self.skillList._selectedItem then
    self.skillList._selectedItem:OnSelectionChange(false)
    self.skillList._selectedItem = nil
    self.skillList._selectedItemIndex = 0
  end
  self.btnChangeSkill:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.curSkillListSelectIndex = -1
  self.petSkillList = _petSkillList
  self.skillList:SetDatas(_petSkillList)
  self.skillList:SetCaller(self)
  self.skillList.OnItemSelected = self.OnScrollItemSelected
end

function UMG_PetSkillInfo_C:OnScrollItemSelected(item, index)
  self.curSkillListSelectIndex = index
  if index >= 0 then
    self.btnChangeSkill:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.btnChangeSkill:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_PetSkillInfo_C:checkCurSkillInfo(_skillPos)
  return _skillPos == self:getWaitWorkSkillPos()
end

function UMG_PetSkillInfo_C:OnAddEventListener()
  self:AddButtonListener(self.btnChangeSkill, self.OnBtnChangeSkillClick)
end

function UMG_PetSkillInfo_C:OnRemoveEventListener()
end

function UMG_PetSkillInfo_C:OnMainUIPetSkillSelectChange(_skillData, _skillPos)
  self.uiData.waitWorkSkillPos = _skillPos
  self:updatePetSkillInfo()
  self:DispatchEvent(PetUIModuleEvent.PET_UI_SELECT_SKILL_UPDATE, self.uiData.waitWorkSkillPos)
end

function UMG_PetSkillInfo_C:OnParentPanelStateChange(_isShow)
  self.uiData.isShow = _isShow
  if _isShow then
    self:updatePetSkillInfo()
  else
    self:DispatchEvent(PetUIModuleEvent.PET_UI_SELECT_SKILL_UPDATE, 0)
  end
end

function UMG_PetSkillInfo_C:updatePetInfo(_petData, _petBaseConf)
  local petNormalSkillList = {}
  local petUltimateSkillList = {}
  local petEquipSkills = {}
  if _petData then
    for i, skillData in ipairs(_petData.skill.skill_data) do
      if skillData.is_equipped and skillData.pos > 0 and skillData.pos <= 4 then
        petEquipSkills[skillData.pos] = skillData
      end
      local skillConfig = _G.DataConfigManager:GetSkillConf(skillData.id)
      if skillConfig then
        if Enum.SkillActiveType.SAT_NORMAL == skillConfig.type then
          table.insert(petNormalSkillList, skillData)
        end
        if Enum.SkillActiveType.SAT_ULTIMATE == skillConfig.type then
          table.insert(petUltimateSkillList, skillData)
        end
      end
    end
  end
  if self.uiData == nil then
    Log.Debug("UMG_PetSkillInfo_C:OnConstruct  cccc")
    self.uiData = {}
    Log.Dump(_petData, 6, "UMG_PetSkillInfo_C:_petData")
  end
  self.uiData.petData = _petData
  self.uiData.normalSkillList = petNormalSkillList
  self.uiData.ultimateSkillList = petUltimateSkillList
  self.uiData.petEquipSkills = petEquipSkills
  if self.uiData.isShow then
    self:updatePetSkillInfo()
  end
end

function UMG_PetSkillInfo_C:updatePetSkillInfo()
  local skillList
  local waitWorkSkillPos = self.uiData.waitWorkSkillPos
  if waitWorkSkillPos > 0 and waitWorkSkillPos <= 4 then
    skillList = self.uiData.normalSkillList
  else
    return
  end
  local waitWorkSkill = self:getWaitWorkSkill()
  self.curWorkSkill:SetData(waitWorkSkill)
  local waitWorkSkillId = waitWorkSkill and waitWorkSkill.id or 0
  local petSkillList = {}
  for _, skillData in pairs(skillList) do
    if waitWorkSkillId ~= skillData.id then
      local sortValue = 0
      if skillData.is_equipped then
        sortValue = sortValue + skillData.pos
      else
        sortValue = sortValue + 10
      end
      if not skillData.is_learned then
        sortValue = sortValue + 100
      end
      skillData._skillSortValue = sortValue
      table.insert(petSkillList, skillData)
    end
  end
  table.sort(petSkillList, function(a, b)
    if a._skillSortValue == b._skillSortValue then
      return a.unlock_need_lv < b.unlock_need_lv
    else
      return a._skillSortValue < b._skillSortValue
    end
  end)
  for _, v in ipairs(petSkillList) do
    v._skillSortValue = nil
  end
  self:updatePetSkillList(petSkillList)
end

function UMG_PetSkillInfo_C:OnBtnChangeSkillClick()
  _G.NRCAudioManager:PlaySound2DAuto(1071, "UMG_PetSkillInfo_C:OnBtnChangeSkillClick")
  local curSelectSkill = self:getCurSelectSkill()
  if not curSelectSkill then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_petskillinfo_1)
    return
  end
  if not curSelectSkill.is_learned then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_petskillinfo_2)
    return
  end
  local pos = self.uiData.waitWorkSkillPos
  local waitWorkSkill = self:getWaitWorkSkill()
  if not waitWorkSkill and pos <= 0 then
    return
  end
  NRCModuleManager:DoCmd(PetUIModuleCmd.EquipSkill2, self.uiData.petData.gid, curSelectSkill, waitWorkSkill, pos)
  self:DispatchEvent(PetUIModuleEvent.PET_UI_CHANGE_SKILL_INFO, curSelectSkill, pos)
  self:DispatchEvent(PetUIModuleEvent.PET_UI_MODEL_PLAY_ANIM, "Show")
end

function UMG_PetSkillInfo_C:getWaitWorkSkillPos()
  return self.uiData.waitWorkSkillPos or 0
end

function UMG_PetSkillInfo_C:getWaitWorkSkill()
  local waitWorkSkillPos = self.uiData.waitWorkSkillPos
  if waitWorkSkillPos > 0 and waitWorkSkillPos <= 4 and self.uiData.petEquipSkills then
    return self.uiData.petEquipSkills[waitWorkSkillPos]
  end
end

return UMG_PetSkillInfo_C
