local BattleComponent = require("NewRoco.Modules.Core.Battle.Entity.BattleComponent")
local Skill = require("NewRoco.Modules.Core.Battle.Entity.Components.Skill.Skill")
local Base = BattleComponent
local SkillComponent = BattleComponent:Extend("SkillComponent")
local tInsert = table.insert

local function DisplaySkillSorter(a, b)
  if a.type == b.type then
    if a.skillData.pos == b.skillData.pos then
      if a.skillData.state == b.skillData.state then
        return false
      else
        return a.skillData.state == _G.ProtoEnum.SkillState.SKILL_READY and true or false
      end
    else
      return a.skillData.pos < b.skillData.pos
    end
  else
    return a.type < b.type
  end
end

function SkillComponent:Ctor(owner)
  Base.Ctor(self)
  self.owner = owner
  self.skills = {}
  self.CardEntity = nil
end

function SkillComponent:GetDisplaySkills()
  return self:GetDisplaySkillsInternal(self.skills)
end

function SkillComponent:GetDisplaySkillsInternal(skillList)
  skillList = skillList or {}
  local showSkills = {}
  for _, skill in ipairs(skillList) do
    if skill.config.type == Enum.SkillActiveType.SAT_NORMAL then
      tInsert(showSkills, skill)
    elseif skill.config.type == Enum.SkillActiveType.SAT_ULTIMATE then
      tInsert(showSkills, skill)
    elseif skill.config.type == Enum.SkillActiveType.SAT_LEGENDARY then
      tInsert(showSkills, skill)
    end
  end
  table.sort(showSkills, DisplaySkillSorter)
  return showSkills
end

function SkillComponent:GetExSkillID(sat)
  for _, skill in ipairs(self.skills) do
    if skill.config.type == sat then
      return skill.id
    end
  end
  return nil
end

function SkillComponent:GetExSkillByType(sat)
  for _, skill in ipairs(self.skills) do
    if skill.config.type == sat then
      return skill
    end
  end
  return nil
end

function SkillComponent:GetSkillWithType(SkillType)
  local Skills = {}
  for _, skill in ipairs(self.skills) do
    if skill.type == SkillType then
      tInsert(Skills, skill)
    end
  end
  return Skills
end

function SkillComponent:GetHeadOfChangeSrcSkillChain(skill)
  local headSkill = skill
  local change_src_skill = headSkill and headSkill.skillData.change_src_skill
  local count = 0
  while change_src_skill and change_src_skill > 0 and count < 500 do
    for _, skillItem in ipairs(self.skills) do
      if change_src_skill == skillItem.id then
        headSkill = skillItem
        change_src_skill = headSkill and headSkill.skillData.change_src_skill
        break
      end
    end
    count = count + 1
  end
  return headSkill
end

function SkillComponent:InitByCard(Card)
  self.CardEntity = Card
  Base.InitByCard(self)
  local curRound = _G.BattleManager.battleRuntimeData.roundIndex or 1
  self.skills = self.skills or {}
  local prevSkillList = {}
  table.copy(self.skills, prevSkillList)
  local SkillDataArray = Card.skillRoundData or {}
  for i = 1, #self.skills do
    self.skills[i].IsRefreshData = false
  end
  for i = 1, #SkillDataArray do
    local skillRoundData = Card.skillRoundData[i]
    local IsHasSkill, oldSkill = self:FindSkillBySkillId(skillRoundData)
    if not IsHasSkill then
      local skill = self:CreateSkill(skillRoundData.id, skillRoundData)
      if skill then
        skill:RefreshByServer(skillRoundData, curRound)
        tInsert(self.skills, skill)
      end
    else
      oldSkill:RefreshByServer(skillRoundData, curRound)
    end
  end
  for i = #self.skills, 1, -1 do
    if not self.skills[i].IsRefreshData then
      table.remove(self.skills, i)
    end
  end
  Card.petState:SetFever(self:IsFever())
  self:OnSkillListChange(prevSkillList, self.skills)
end

function SkillComponent:UpdateByCard(Card)
  self:InitByCard(Card)
end

function SkillComponent:OnSkillListChange(prevSkillList, nextSkillList)
  local nextSkillDisplayInfo = self:CalculateSkillDisplayInfoBySkillList(nextSkillList)
  self:SetSkillDisplayInfo(nextSkillDisplayInfo)
end

function SkillComponent:GetSkillByID(skillID)
  for i = 1, #self.skills do
    if self.skills[i].id == skillID then
      return self.skills[i]
    end
  end
  return nil
end

function SkillComponent:GetSkillBySkillID(skillID)
  for i = 1, #self.skills do
    if self.skills[i].skill_id == skillID then
      return self.skills[i]
    end
  end
  return nil
end

function SkillComponent:UpdateSkillDataByID(skillDataList)
  local prevSkillList = {}
  table.copy(self.skills, prevSkillList)
  for i = 1, #self.skills do
    self.skills[i].IsRefreshData = false
  end
  local curRound = _G.BattleManager.battleRuntimeData.roundIndex or 1
  for i = 1, #skillDataList do
    local skillRoundData = skillDataList[i]
    local IsHasSkill, oldSkill = self:FindSkillBySkillId(skillRoundData)
    if not IsHasSkill then
      local skill = self:CreateSkill(skillRoundData.id, skillRoundData)
      if skill then
        skill:RefreshByServer(skillRoundData, curRound)
        tInsert(self.skills, skill)
      end
    else
      oldSkill:RefreshByServer(skillRoundData, curRound)
    end
  end
  for i = #self.skills, 1, -1 do
    if not self.skills[i].IsRefreshData then
      table.remove(self.skills, i)
    end
  end
  self:OnSkillListChange(prevSkillList, self.skills)
end

function SkillComponent:FindSkillBySkillId(skillData)
  for j = 1, #self.skills do
    if self.skills[j].id == skillData.id then
      return true, self.skills[j]
    end
  end
  return false, nil
end

function SkillComponent:CreateSkill(id, skillRoundData)
  if 0 == id then
    Log.Error("\229\188\130\229\184\184\230\138\128\232\131\189ID\239\188\154", id)
    return
  end
  local skillConfig = _G.SkillUtils.GetSkillConf(id)
  if skillConfig then
    local skillEntity = Skill(self.owner)
    skillEntity:Init(skillConfig, skillRoundData)
    return skillEntity
  else
    Log.Error("skillID not exist:", id)
  end
end

function SkillComponent:IsFever()
  for _, skill in ipairs(self.skills) do
    if skill:IsFeverSkill() then
      return true
    end
  end
  return false
end

function SkillComponent:CalculateSkillDisplayInfoBySkillList(skillList)
  local skills = self:GetDisplaySkillsInternal(skillList)
  skills = self:RemoveDisabledSkill(skills)
  local skillMap = {}
  for _, skill in pairs(skills) do
    if not skillMap[skill.skillData.pos] then
      skillMap[skill.skillData.pos] = skill
    end
  end
  local globalSkillList = self:GetSkillWithType(Enum.SkillActiveType.SAT_GLOBAL)
  self:RemoveDisabledRestSkill(globalSkillList)
  local skillDisplayInfo = {}
  skillDisplayInfo.slotIndexToSkill = skillMap
  skillDisplayInfo.globalSkillList = globalSkillList
  return skillDisplayInfo
end

function SkillComponent:RemoveDisabledSkill(skills)
  for i = #skills, 1, -1 do
    if skills[i].skillData.state == ProtoEnum.SkillState.SKILL_DISABLED or 0 == skills[i].skillData.pos then
      table.remove(skills, i)
    end
  end
  return skills
end

function SkillComponent:RemoveDisabledRestSkill(skills)
  for i = #skills, 1, -1 do
    if skills[i].skillData.state == ProtoEnum.SkillState.SKILL_DISABLED then
      table.remove(skills, i)
    end
  end
  return skills
end

function SkillComponent:SetSkillDisplayInfo(nextSkillDisplayInfo)
  local prevSkillDisplayInfo = self.skillDisplayInfo
  self.skillDisplayInfo = nextSkillDisplayInfo
end

function SkillComponent:GetSkillDisplayInfo()
  return self.skillDisplayInfo
end

function SkillComponent:Destroy()
  self.skills = {}
  self.CardEntity = nil
  self.owner = nil
end

return SkillComponent
