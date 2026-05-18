local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local enum = reload("Data.Config.Enum")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_PetSkillChangeItem_C = Base:Extend("UMG_PetSkillChangeItem_C")

function UMG_PetSkillChangeItem_C:Initialize(Initializer)
  Log.Debug("UMG_PetSkillChangeItem_C:Initialize")
  self.isSelected = false
  _G.NRCModuleManager:GetModule("PetUIModule"):RegisterEvent(self, PetUIModuleEvent.RemoveSkillNewState, self.RemoveSkillNewState)
  self.ItemHeight = 100
  self.parentViewHeight = 314
end

function UMG_PetSkillChangeItem_C:Destruct()
  Log.Debug("UMG_PetSkillChangeItem_C:Destruct")
  _G.NRCModuleManager:GetModule("PetUIModule"):UnRegisterEvent(self, PetUIModuleEvent.RemoveSkillNewState, self.RemoveSkillNewState)
  UpdateManager:UnRegister(self)
end

function UMG_PetSkillChangeItem_C:OnConstruct()
  Log.Debug("UMG_PetSkillChangeItem_C:OnConstruct")
end

function UMG_PetSkillChangeItem_C:OnDestruct()
  Log.Debug("UMG_PetSkillChangeItem_C:OnDestruct")
end

function UMG_PetSkillChangeItem_C:OnEnable()
  Log.Debug("UMG_PetSkillChangeItem_C:OnEnable")
end

function UMG_PetSkillChangeItem_C:OnDisable()
end

function UMG_PetSkillChangeItem_C:OnRemoveEventListener()
end

function UMG_PetSkillChangeItem_C:OnItemUpdate(data, datalist, index)
  self.index = index
  Log.Debug("UMG_PetSkillChangeItem_C:OnItemUpdate")
  self._data = data
  self:updateItemInfo()
end

function UMG_PetSkillChangeItem_C:updateItemInfo()
  if self._data.skill_data then
    local skilldata = self._data.skill_data
    self.skillConfig = _G.DataConfigManager:GetSkillConf(skilldata.id)
    local skillConf = self.skillConfig
    self.SkillNameTxt:SetText(skillConf.name)
    self.SkillIcon:SetPath(skillConf.icon)
    self.NRCTextDes:SetText(skillConf.desc)
    self.SkillNengNum:SetText(skillConf.energy_cost[1])
    if skillConf.damage_type == enum.DamageType.DT_NONE then
      self.skillShuNumTxt:SetText("\226\148\128\226\148\128")
    else
      self.skillShuNumTxt:SetText(skillConf.dam_para[1])
    end
    local typeDic = _G.DataConfigManager:GetTypeDictionary(skillConf.skill_dam_type)
    if typeDic then
      self.SkillShuIcon:SetPath(typeDic.type_icon)
    end
    if skilldata.is_equipped and skilldata.pos <= 4 and skilldata.is_learned then
      if self._data.curskillId and self._data.curskillId == skilldata.id then
        self.NRCText_equiped:SetVisibility(UE4.ESlateVisibility.Hidden)
        self.NRCTextCur:SetVisibility(UE4.ESlateVisibility.Visible)
      else
        self.NRCText_equiped:SetVisibility(UE4.ESlateVisibility.Visible)
        self.NRCTextCur:SetVisibility(UE4.ESlateVisibility.Hidden)
      end
      self.CanvasZhuangbei:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.CanvasZhuangbei:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
    self:OnSetis_learned()
  end
  if self._data.changeSuccess == false then
    self.SkillDesPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasPanel_select:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.CanvasPanel_selectBg:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_PetSkillChangeItem_C:OnSetis_learned()
  local skilldata = self._data.skill_data
  if skilldata.is_learned == false then
    self.CanvasPanel_Lock:SetVisibility(UE4.ESlateVisibility.Visible)
    self.CanvasLock:SetVisibility(UE4.ESlateVisibility.Visible)
    if self._data.isHanbookSkill == true then
      local numTable = self:GetSunOrStar(skilldata.unlock_need_lv)
      self.Grade:InitGridView(numTable)
      self.SpecialhanbookSkill:SetVisibility(UE4.ESlateVisibility.Visible)
      self.SpecialNorSkill:SetVisibility(UE4.ESlateVisibility.Hidden)
      local conf = _G.DataConfigManager:GetPetbaseConf(skilldata.petbase_conf_id)
      if conf then
        local modelconf = _G.DataConfigManager:GetModelConf(conf.model_conf)
        if modelconf then
          self.skillShuicon_1:SetPath(modelconf.ui_icon)
        end
      end
    else
      self.lockLvTxt:SetText(skilldata.unlock_need_lv)
      self.SpecialhanbookSkill:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.SpecialNorSkill:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  else
    self.CanvasLock:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.CanvasPanel_Lock:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:SetOnNewState()
end

function UMG_PetSkillChangeItem_C:GetSunOrStar(num)
  local sun, temp1 = math.modf(num / 9)
  temp1 = num - sun * 9
  local Month, temp2 = math.modf(temp1 / 3)
  temp2 = temp1 - Month * 3
  local numtable = {}
  for i = 1, sun do
    table.insert(numtable, {iconType = 3})
  end
  for i = 1, Month do
    table.insert(numtable, {iconType = 2})
  end
  for i = 1, temp2 do
    table.insert(numtable, {iconType = 1})
  end
  return numtable
end

function UMG_PetSkillChangeItem_C:SetOnNewState()
  local gid = self._data.petgid
  local skilldata = self._data.skill_data
  local id = skilldata.id
  local state = NRCModuleManager:DoCmd(PetUIModuleCmd.GetSkillNew, gid, id)
  if skilldata.is_learned == true and state then
    self.NRCImage_new:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.NRCImage_new:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_PetSkillChangeItem_C:SetOnNewStateRemove()
  if self.SkillDesPanel.Visibility == UE4.ESlateVisibility.Visible then
    local gid = self._data.petgid
    local id = self._data.skill_data.id
    NRCModuleManager:DoCmd(PetUIModuleCmd.RemoveSkillNew, gid, id)
  end
end

function UMG_PetSkillChangeItem_C:RemoveSkillNewState(gid, skillid)
  if self.SkillDesPanel.Visibility == UE4.ESlateVisibility.Visible then
    local petgid = self._data.petgid
    local id = self._data.skill_data.id
    if petgid == gid and id == skillid then
      self.NRCImage_new:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  end
end

function UMG_PetSkillChangeItem_C:OnItemSelected(selected)
  self.isSelected = selected
  if selected and self._data.skill_data and self.SkillDesPanel.Visibility == UE4.ESlateVisibility.Collapsed then
    self.open = true
    self.expandNum = 0
    local size = self.SkillDesPanel.Slot:GetSize()
    size.y = 0
    self.SkillDesPanel.Slot:SetSize(size)
    self:VisibleOrHideSkillDes(true)
    self:PlayAnimation(self.select)
    self:SetOnNewStateRemove()
    _G.NRCAudioManager:PlaySound2DAuto(1213, "UMG_PetSkillChangeItem_C:OnItemSelectedOpen")
  else
    self.open = false
    self.expandNum = 0
    self:StopAllAnimations()
    if self.close then
      self:PlayAnimation(self.close)
    else
      self:VisibleOrHideSkillDes(false)
    end
    if selected then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1214, "UMG_PetSkillChangeItem_C:OnItemSelectedClose")
    end
  end
  UpdateManager:Register(self)
  if selected then
    self:SkillChange()
  end
end

function UMG_PetSkillChangeItem_C:VisibleOrHideSkillDes(visible)
  if visible then
    self.SkillDesPanel:SetVisibility(UE4.ESlateVisibility.Visible)
    self.CanvasPanel_select:SetVisibility(UE4.ESlateVisibility.Visible)
    self.CanvasPanel_selectBg:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.SkillDesPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasPanel_select:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.CanvasPanel_selectBg:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_PetSkillChangeItem_C:OnAnimationFinished(Animation)
  if Animation == self.close then
  elseif Animation == self.select then
    self:PlayAnimation(self.loop)
  end
end

function UMG_PetSkillChangeItem_C:OnTick(InDeltaTime)
  if self.open then
    self:Expand(InDeltaTime)
  else
    self:Indentation(InDeltaTime)
  end
end

function UMG_PetSkillChangeItem_C:Expand(InDeltaTime)
  if self.expandNum < 1 then
    self.expandNum = self.expandNum + 1
    self.timer = 0
    local OffsetEnd = self.ParentView:GetScrollOffsetOfEnd()
    self.parentViewHeight = self.ParentView:GetDesiredSize().y - OffsetEnd
    return
  end
  if 1 == self.expandNum then
    local size = self.VerticalBox_size:GetDesiredSize()
    self.maxSize = size
    self.expandNum = self.expandNum + 1
  end
  self.timer = self.timer + InDeltaTime
  local size = self.SkillDesPanel.Slot:GetSize()
  if self.timer >= self.animaTime then
    size.y = self.maxSize.y
    UpdateManager:UnRegister(self)
  else
    local localSizePro = self.openAndCloseCurve:GetFloatValue(self.timer)
    size.y = self.maxSize.y * (1 - localSizePro)
  end
  self.SkillDesPanel.Slot:SetSize(size)
  self:ExpandOffset()
end

function UMG_PetSkillChangeItem_C:Indentation(InDeltaTime)
  if self.expandNum < 1 then
    self.expandNum = self.expandNum + 1
    self.timer = 0
    return
  end
  local size = self.SkillDesPanel.Slot:GetSize()
  self.timer = self.timer + InDeltaTime
  if self.timer >= self.animaTime then
    size.y = 0
    UpdateManager:UnRegister(self)
    self:VisibleOrHideSkillDes(false)
  else
    local localSizePro = self.openAndCloseCurve:GetFloatValue(self.timer)
    size.y = self.maxSize.y * localSizePro
  end
  self.SkillDesPanel.Slot:SetSize(size)
end

function UMG_PetSkillChangeItem_C:SkillChangeBtnClick()
  self:SkillChange()
end

function UMG_PetSkillChangeItem_C:SkillChange()
  Log.Debug("UMG_PetSkillChangeItem_C:SkillChange")
  local changeData = {}
  changeData.skillData = self._data.skill_data
  changeData.skillConfig = self.skillConfig
  self._data.umg_petskillChange_c:OnSkillChange(changeData)
end

function UMG_PetSkillChangeItem_C:ExpandOffset()
  local scrollOffset = self.ParentView:GetScrollOffset()
  local height = 0
  local openItem
  for i = 1, self.index - 1 do
    local item = self.ParentView:GetItemByIndex(i - 1)
    local size = item:GetDesiredSize()
    if item.SkillDesPanel.Slot:GetSize().y > 1 and i < self.index then
      openItem = item
    end
    height = height + size.y
  end
  if scrollOffset > height then
  else
    local item = self.ParentView:GetItemByIndex(self.index - 1)
    local size = item:GetDesiredSize()
    height = height + size.y
    if height > self.parentViewHeight + scrollOffset then
      self.ParentView:SetScrollOffset(height - self.parentViewHeight)
    end
  end
end

function UMG_PetSkillChangeItem_C:IndentationOffset(InDeltaTime)
  local scrollOffset = self.ParentView:GetScrollOffset()
  local height = 0
  for i = 1, self.index - 1 do
    local item = self.ParentView:GetItemByIndex(i - 1)
    local size = item:GetDesiredSize()
    if not (item.SkillDesPanel.Slot:GetSize().y > 1) or i < self.index then
    end
    height = height + size.y
  end
  if scrollOffset > height then
    if self.movey == nil or 0 == self.movey then
      self.movey = scrollOffset - height
    end
    scrollOffset = scrollOffset - self.movey / 0.3 * InDeltaTime * 6
    if height > scrollOffset then
      scrollOffset = height
    end
    self.ParentView:SetScrollOffset(scrollOffset)
  else
    self.movey = 0
    height = self.ItemHeight * self.index
    if height > self.parentViewHeight + scrollOffset then
      self.ParentView:SetScrollOffset(height - self.parentViewHeight)
    end
    return true
  end
end

return UMG_PetSkillChangeItem_C
