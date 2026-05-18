local UMG_PetFiltering_C = _G.NRCPanelBase:Extend("UMG_PetFiltering_C")

function UMG_PetFiltering_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
end

function UMG_PetFiltering_C:OnActive(filterRule, skillCountTab, skillPool, petBaseId)
  self.oldFilterRule = {}
  self.filterRule = {}
  self.skillCountTab = skillCountTab
  self.skillPool = skillPool
  self.petBaseId = petBaseId
  if filterRule then
    for i, v in pairs(filterRule) do
      self.oldFilterRule[i] = {}
      self.filterRule[i] = {}
      for j, v2 in pairs(v) do
        self.oldFilterRule[i][j] = v2
        self.filterRule[i][j] = v2
      end
    end
  end
  self.isChange = false
  self:SetCommonPopUpInfo(self.PopUp3, LuaText.skill_filter_tips_4)
  self:InitFilterLists()
  self:RefreshLeftBtnShowText()
  self:RefreshViewDesc()
  self:LoadAnimation(0)
end

function UMG_PetFiltering_C:OnDeactive()
end

function UMG_PetFiltering_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnLeftBtnClick
  CommonPopUpData.Btn_RightHandler = self.OnRightBtnClick
  CommonPopUpData.ClosePanelHandler = self.OnClosePanel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  if PopUp then
    PopUp:SetPanelInfo(CommonPopUpData)
    PopUp:SetBtnRightText(LuaText.UMG_Bag_PopUp6)
  end
end

function UMG_PetFiltering_C:RefreshLeftBtnShowText()
  if self.isChange then
    self.PopUp3:SetBtnLeftText(LuaText.umg_rename_3)
  else
    self.PopUp3:SetBtnLeftText(LuaText.CANCEL)
  end
end

function UMG_PetFiltering_C:OnRightBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_PetFiltering_C:OnLeftBtnClick")
  local t1 = self.filterRule
  local t2 = self.oldFilterRule
  local change = false
  for i, v in pairs(t1) do
    if not t2[i] then
      change = true
      break
    end
    for j, v2 in pairs(v) do
      if not t2[i][j] then
        change = true
        break
      end
    end
  end
  for i, v in pairs(t2) do
    if not t1[i] then
      change = true
      break
    end
    for j, v2 in pairs(v) do
      if not t1[i][j] then
        change = true
        break
      end
    end
  end
  if change then
    local filterRule
    for i, v in pairs(self.filterRule) do
      if self:GetTableCount(v) > 0 then
        if nil == filterRule then
          filterRule = {}
        end
        filterRule[i] = {}
        for j, v2 in pairs(v) do
          filterRule[i][j] = v2
        end
      end
    end
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OnPetSkillFilterRuleChange, filterRule)
    _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.OnPetSkillFilterRuleChange, filterRule)
  end
  self:LoadAnimation(2)
  self.PopUp3:LoadAnimation(2)
end

function UMG_PetFiltering_C:OnLeftBtnClick()
  if self.isChange then
    _G.NRCAudioManager:PlaySound2DAuto(41401016, "UMG_PetFiltering_C:OnLeftBtnClick")
    self.isChange = false
    self.filterRule = {}
    self:InitFilterLists()
    self:RefreshLeftBtnShowText()
    self:RefreshViewDesc()
  else
    _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_PetFiltering_C:OnLeftBtnClick")
    self:LoadAnimation(2)
    self.PopUp3:LoadAnimation(2)
  end
end

function UMG_PetFiltering_C:OnClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_PetFiltering_C:OnLeftBtnClick")
  self:LoadAnimation(2)
  self.PopUp3:LoadAnimation(2)
end

function UMG_PetFiltering_C:InitFilterLists()
  local departAllList = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.SKILL_FILTER_CONF):GetAllDatas()
  local skillSourceList = {}
  local departmentList = {}
  local skillTypeList = {}
  for i, v in pairs(departAllList) do
    if v.filter_type == _G.Enum.FilterRule.FIL_SKILL_SOURCE then
      table.insert(skillSourceList, v)
    elseif v.filter_type == _G.Enum.FilterRule.FIL_SKILLDAM_TYPE then
      table.insert(departmentList, v)
    elseif v.filter_type == _G.Enum.FilterRule.FIL_SKILL_TYPE then
      table.insert(skillTypeList, v)
    end
  end
  self.FilterList:InitGridView(skillSourceList)
  self.DepartmentList:InitGridView(departmentList)
  self.SkillTypeList:InitGridView(skillTypeList)
  for i = 1, self.FilterList:GetItemCount() do
    local item = self.FilterList:GetItemByIndex(i - 1)
    local num = 0
    local key1 = _G.Enum.FilterRule.FIL_SKILL_SOURCE
    for j, value in ipairs(item.conf.filter_enum_value) do
      local key2 = _G.Enum[item.conf.filter_enum_name][value]
      num = num + self.skillCountTab[key1][key2] or 0
      if self.filterRule[key1] and self.filterRule[key1][key2] then
        item:OnNotPlaySound()
        item:OnItemSelected(true)
        self.isChange = true
        break
      end
    end
    item:SetSkillNum(num)
  end
  for i = 1, self.DepartmentList:GetItemCount() do
    local item = self.DepartmentList:GetItemByIndex(i - 1)
    local num = 0
    local key1 = _G.Enum.FilterRule.FIL_SKILLDAM_TYPE
    for j, value in ipairs(item.conf.filter_enum_value) do
      local key2 = _G.Enum[item.conf.filter_enum_name][value]
      num = num + self.skillCountTab[key1][key2] or 0
      if self.filterRule[key1] and self.filterRule[key1][key2] then
        item:OnNotPlaySound()
        item:OnItemSelected(true)
        self.isChange = true
        break
      end
    end
    item:SetSkillNum(num)
  end
  for i = 1, self.SkillTypeList:GetItemCount() do
    local item = self.SkillTypeList:GetItemByIndex(i - 1)
    local num = 0
    local key1 = _G.Enum.FilterRule.FIL_SKILL_TYPE
    for j, value in ipairs(item.conf.filter_enum_value) do
      local key2 = _G.Enum[item.conf.filter_enum_name][value]
      num = num + self.skillCountTab[key1][key2] or 0
      if self.filterRule[key1] and self.filterRule[key1][key2] then
        item:OnNotPlaySound()
        item:OnItemSelected(true)
        self.isChange = true
        break
      end
    end
    item:SetSkillNum(num)
  end
end

function UMG_PetFiltering_C:OnFilterTypeSelect(filterType, values, bIsSelect)
  if not self.filterRule[filterType] then
    self.filterRule[filterType] = {}
  end
  for i, v in ipairs(values) do
    self.filterRule[filterType][v] = bIsSelect and bIsSelect or nil
  end
  if bIsSelect then
    self.isChange = true
  else
    self.isChange = false
    for i, v in pairs(self.filterRule) do
      if self:GetTableCount(v) > 0 then
        self.isChange = true
        break
      end
    end
  end
  self:RefreshLeftBtnShowText()
  self:RefreshViewDesc()
end

function UMG_PetFiltering_C:RefreshViewDesc()
  local tips = ""
  if self.isChange then
    tips = string.format(LuaText.skill_filter_tips_2, self:GetCurSkillNum())
  else
    tips = LuaText.skill_filter_tips_1
  end
  self.PopUp3:SetDescInfo(tips)
end

function UMG_PetFiltering_C:GetCurSkillNum()
  local num = 0
  if self.skillPool then
    for i, v in ipairs(self.skillPool) do
      if self:SkillFilter(v.id) then
        num = num + 1
      end
    end
  end
  return num
end

function UMG_PetFiltering_C:SkillFilter(skillId)
  if self.filterRule then
    if self.filterRule[_G.Enum.FilterRule.FIL_SKILL_SOURCE] and self:GetSingleTypeSelectNum(self.filterRule[_G.Enum.FilterRule.FIL_SKILL_SOURCE]) > 0 then
      local skillSourceList = _G.NRCModeManager:DoCmd(_G.PetUIModuleCmd.GetSkillSource, skillId, self.petBaseId)
      local haveType = false
      for i, v in ipairs(skillSourceList) do
        if self.filterRule[_G.Enum.FilterRule.FIL_SKILL_SOURCE][v] then
          haveType = true
          break
        end
      end
      if not haveType then
        return false
      end
    end
    local skillConf = _G.DataConfigManager:GetSkillConf(skillId)
    if skillConf then
      if self.filterRule[_G.Enum.FilterRule.FIL_SKILLDAM_TYPE] and self:GetSingleTypeSelectNum(self.filterRule[_G.Enum.FilterRule.FIL_SKILLDAM_TYPE]) > 0 and not self.filterRule[_G.Enum.FilterRule.FIL_SKILLDAM_TYPE][skillConf.skill_dam_type] then
        return false
      end
      if self.filterRule[_G.Enum.FilterRule.FIL_SKILL_TYPE] and self:GetSingleTypeSelectNum(self.filterRule[_G.Enum.FilterRule.FIL_SKILL_TYPE]) > 0 and not self.filterRule[_G.Enum.FilterRule.FIL_SKILL_TYPE][skillConf.Skill_Type] then
        return false
      end
    end
  end
  return true
end

function UMG_PetFiltering_C:GetSingleTypeSelectNum(list)
  local num = 0
  for i, v in pairs(list) do
    if true == v then
      num = num + 1
    end
  end
  return num
end

function UMG_PetFiltering_C:GetTableCount(table)
  local count = 0
  if table then
    for _, _ in pairs(table) do
      count = count + 1
    end
  end
  return count
end

function UMG_PetFiltering_C:TablesEqual(t1, t2, visited)
  visited = visited or {}
  if visited[t1] == t2 then
    return true
  end
  visited[t1] = t2
  if type(t1) ~= type(t2) then
    return false
  end
  if type(t1) ~= "table" then
    return t1 == t2
  end
  local count1, count2 = 0, 0
  for _ in pairs(t1) do
    count1 = count1 + 1
  end
  for _ in pairs(t2) do
    count2 = count2 + 1
  end
  if count1 ~= count2 then
    return false
  end
  for k, v1 in pairs(t1) do
    local v2 = t2[k]
    if not self:TablesEqual(v1, v2, visited) then
      return false
    end
  end
  return true
end

function UMG_PetFiltering_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_PetFiltering_C
