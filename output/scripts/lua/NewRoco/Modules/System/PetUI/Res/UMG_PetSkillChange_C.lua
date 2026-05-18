local enum = reload("Data.Config.Enum")
local UMG_PetSkillChange_C = _G.NRCViewBase:Extend("UMG_PetSkillChange_C")
local PetUtils = require("NewRoco.Utils.PetUtils")

function UMG_PetSkillChange_C:Initialize(Initializer)
  Log.Debug("UMG_PetSkillChange_C:Initialize")
end

function UMG_PetSkillChange_C:OnConstruct()
  Log.Debug("UMG_PetSkillChange_C:OnConstruct")
  local menu1 = {
    nor = self.nor,
    on = self.on,
    btn = self.btn
  }
  local menu2 = {
    nor = self.nor_1,
    on = self.on_1,
    btn = self.btn_1
  }
  self.btnMeun = {menu1, menu2}
  self.btnMeunIndex = 0
  self.teshuSkill = {}
  self:OnAddEventListener()
  self:BtnInit()
end

function UMG_PetSkillChange_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_PetSkillChange_C:OnEnable()
  Log.Debug("UMG_PetSkillChange_C:OnEnable")
end

function UMG_PetSkillChange_C:OnDisable()
end

function UMG_PetSkillChange_C:OnAddEventListener()
  self:AddButtonListener(self.backBtn, self.OnCloseButtonClicked)
  self:AddButtonListener(self.backBtn_1, self.BackBtn_1)
  self:AddButtonListener(self.changeBtn.btnLevelUp, self.ChangeBtnClick)
  self:AddButtonListener(self.btn, self.OnClick1)
  self:AddButtonListener(self.btn_1, self.OnClick2)
end

function UMG_PetSkillChange_C:OnRemoveEventListener()
end

function UMG_PetSkillChange_C:OnClick1()
  if 1 == self.btnMeunIndex then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(1005, "UMG_PetLeftPanel_C:OnBtnCloseSubPanelClick")
  self:OnSelect(1)
end

function UMG_PetSkillChange_C:OnClick2()
  if 2 == self.btnMeunIndex then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(1005, "UMG_PetLeftPanel_C:OnBtnCloseSubPanelClick")
  self:OnSelect(2)
end

function UMG_PetSkillChange_C:GetSortPoint(skill_data)
  local point = 0
  if not skill_data.is_learned then
    point = point + 10000
  end
  if skill_data.is_equipped then
    point = point + 1000
  end
  if skill_data.unlock_need_lv then
    point = point + skill_data.unlock_need_lv
  elseif skill_data.sortIndex then
    point = point + skill_data.sortIndex
  end
  return point
end

function UMG_PetSkillChange_C:OnSelect(index)
  Log.Debug("UMG_PetSkillChange_C:OnSelect  " .. index)
  self.btnMeunIndex = index
  for i = 1, #self.btnMeun do
    if i == index then
      self.btnMeun[i].nor:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.btnMeun[i].on:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.btnMeun[i].nor:SetVisibility(UE4.ESlateVisibility.Visible)
      self.btnMeun[i].on:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  end
  local skills
  if 1 == index then
    skills = self:GetAllSkill()
    for i, skill in ipairs(skills) do
      if not self.changeSkillData then
        break
      end
      if self.changeSkillData.id == skill.skill_data.id then
        table.remove(skills, i)
        break
      end
    end
    table.sort(skills, function(a, b)
      if self:GetSortPoint(a.skill_data) == self:GetSortPoint(b.skill_data) then
        return a.skill_data.id < b.skill_data.id
      else
        return self:GetSortPoint(a.skill_data) < self:GetSortPoint(b.skill_data)
      end
    end)
  else
    skills = self:GetTeshuSkillData()
    table.sort(skills, function(a, b)
      if self:GetSortPoint(a.skill_data) == self:GetSortPoint(b.skill_data) then
        return a.skill_data.id < b.skill_data.id
      else
        return self:GetSortPoint(a.skill_data) < self:GetSortPoint(b.skill_data)
      end
    end)
  end
  self.NRCScrollViewSkill:InitList(skills)
end

function UMG_PetSkillChange_C:ShowChangeSkill(skillChangeData)
  self:updateInfo(skillChangeData)
end

function UMG_PetSkillChange_C:updateInfo(_data)
  self._data = _data
  self:SetVisibility(UE4.ESlateVisibility.Visible)
  self.changeBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
  local changeSkillData = self:GetSkillWithPos(self._data.pos)
  self.changeSkillData = changeSkillData
  if changeSkillData then
    local skillConf = _G.DataConfigManager:GetSkillConf(changeSkillData.id)
    self.SkillNameTxt:SetText(skillConf.name)
    self.SkillIcon:SetPath(skillConf.icon)
    self.NRCTextDes:SetText(skillConf.desc)
    self.SkillNengNum:SetText(skillConf.energy_cost[1])
    if skillConf.damage_type == enum.DamageType.DT_NONE then
      self.skillShuNumTxt:SetText(nil)
    else
      self.skillShuNumTxt:SetText(skillConf.dam_para[1])
    end
    local typeDic = _G.DataConfigManager:GetTypeDictionary(skillConf.skill_dam_type)
    if typeDic then
      self.SkillShuIcon:SetPath(typeDic.type_icon)
    end
    self.skillNorPlane:SetVisibility(UE4.ESlateVisibility.Visible)
    self.SizeBox_Des:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCImage_Add:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.skillNorPlane:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SizeBox_Des:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCImage_Add:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  table.clear()
  local teshuskill = self:GetTeshuSkill()
  if teshuskill then
    self.teshuSkill = teshuskill
  else
    table.clear(self.teshuSkill)
  end
  if self._data.changeSuccess == true then
    self._data.changeSuccess = false
    self:PlayAnimation(self.inchange)
    self:OnSelect(self.btnMeunIndex)
  else
    self:OnSelect(1)
    self.NRCScrollViewSkill:scrolltostart()
  end
end

function UMG_PetSkillChange_C:GetSkillWithPos(pos)
  if self._data._petData then
    for i, skillData in ipairs(self._data._petData.skill.skill_data) do
      if 1 == skillData.type and skillData.pos == pos then
        return skillData
      end
    end
  end
  return nil
end

function UMG_PetSkillChange_C:GetAllSkill()
  local petAllSkills = {}
  if self._data._petData then
    for i, skillData in ipairs(self._data._petData.skill.skill_data) do
      if 1 == skillData.type and (self.teshuSkill[skillData.id] == nil or skillData.unlock_need_lv and skillData.unlock_need_lv > 0) then
        local data = {}
        data.umg_petskillChange_c = self
        data.skill_data = skillData
        data.changeSuccess = self._data.changeSuccess
        data.petgid = self._data._petData.gid
        if nil ~= self.changeSkillData and self.changeSkillData.id == skillData.id then
          data.curskillId = self.changeSkillData.id
        end
        table.insert(petAllSkills, data)
      end
    end
  end
  return petAllSkills
end

function UMG_PetSkillChange_C:GetTeshuSkillData()
  local skills = {}
  for i, hanbookSkilldata in pairs(self.teshuSkill) do
    if hanbookSkilldata then
      local data = {}
      data.umg_petskillChange_c = self
      data.skill_data = hanbookSkilldata
      data.changeSuccess = self._data.changeSuccess
      data.petgid = self._data._petData.gid
      data.isHanbookSkill = true
      local skillData = self:GetSkillDataWithID(hanbookSkilldata.id)
      if skillData then
        hanbookSkilldata.is_equipped = skillData.is_equipped
        hanbookSkilldata.pos = skillData.pos
        if self.changeSkillData ~= nil and self.changeSkillData.id == skillData.id then
          data.curskillId = self.changeSkillData.id
        end
      end
      table.insert(skills, data)
    end
  end
  return skills
end

function UMG_PetSkillChange_C:GetSkillDataWithID(id)
  if self._data._petData then
    for i, skillData in ipairs(self._data._petData.skill.skill_data) do
      if 1 == skillData.type and skillData.id == id then
        return skillData
      end
    end
  end
  return nil
end

function UMG_PetSkillChange_C:GetTeshuSkill()
  local baseid = self._data._petData.base_conf_id
  local evoids = PetUtils.GetEvoListIDs(baseid)
  local skillDatas = {}
  self:GetHavingSkill(skillDatas)
  for i = 1, #evoids do
    local id = evoids[i]
    if id then
      self:GetAwardInfo(id, skillDatas, i)
    end
  end
  return skillDatas
end

function UMG_PetSkillChange_C:GetHavingSkill(skillDatas)
  local skill = self._data._petData.skill
  for i, skillData in ipairs(skill.skill_data) do
    if skillData.carryon_info then
      local PetCarryonItem = _G.DataConfigManager:GetPetCarryonItem(skillData.carryon_info.carryon_id)
      if PetCarryonItem and PetCarryonItem.carryon_skill_type == Enum.CarryonSkillTYpe.COST_ACTIVE then
        skillDatas[skillData.id] = {
          id = skillData.id,
          pos = 0,
          is_equipped = skillData.is_equipped,
          is_learned = skillData.is_learned,
          petbase_conf_id = self._data._petData.base_conf_id
        }
      end
    end
  end
end

function UMG_PetSkillChange_C:GetAwardInfo(baseid, skillDatas, index)
  local PetHandbook = _G.DataConfigManager:GetPetHandbook(baseid)
  if PetHandbook then
    local study_lv = 0
    local petinfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
    for i = 1, #petinfo.handbook.record_collection do
      if not petinfo.handbook.record_collection[i].record or 0 == #petinfo.handbook.record_collection[i].record then
      else
        local record = petinfo.handbook.record_collection[i].record[1]
        if record.pet_base_id == baseid then
          study_lv = record.study_lv
          break
        end
      end
    end
    local pet_handbook = PetHandbook.pet_handbook
    for i, PetAwardList in ipairs(pet_handbook) do
      local award_data = PetAwardList.award_data
      if PetAwardList.award_type == _G.Enum.PetHandbookAward.AWARD_SKILL then
        local learned = false
        if i <= study_lv then
          learned = true
        end
        skillDatas[award_data[1]] = {
          id = award_data[1],
          unlock_need_lv = i,
          pos = 0,
          is_equipped = false,
          is_learned = learned,
          sortIndex = index * 100 + i,
          petbase_conf_id = baseid
        }
      end
    end
  end
  Log.Dump(skillDatas)
  return skillDatas
end

function UMG_PetSkillChange_C:OnSkillChange(changedata)
  self._data.waitWorkSkill = changedata.skillData
  if changedata.skillData.is_learned and (self.changeSkillData == nil or changedata.skillData.id ~= self.changeSkillData.id) then
    self.changeBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.changeBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_PetSkillChange_C:ChangeBtnClick()
  local pos = self._data.pos
  _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_PetSkillChange_C:BackBtn_1")
  NRCModuleManager:DoCmd(PetUIModuleCmd.EquipSkill2, self._data._petData.gid, self._data.waitWorkSkill, self.changeSkillData, pos)
end

function UMG_PetSkillChange_C:BackBtn_1()
  self:OnBack()
  _G.NRCAudioManager:PlaySound2DAuto(1216, "UMG_PetSkillChange_C:BackBtn_1")
end

function UMG_PetSkillChange_C:OnCloseButtonClicked()
  _G.NRCAudioManager:PlaySound2DAuto(1007, "UMG_PetSkillChange_C:BackBtn_1")
  self:OnBack()
end

function UMG_PetSkillChange_C:OnBack()
  if self._data.callbackCaller and self._data.callbackFunc then
    tcall(self._data.callbackCaller, self._data.callbackFunc, 1)
  end
end

function UMG_PetSkillChange_C:BtnInit()
  self.changeBtn:SetBtnText(LuaText.umg_petskillchange_1)
  self.changeBtn:SetPath("PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/ui_combtn_change_png.ui_combtn_change_png'")
end

return UMG_PetSkillChange_C
