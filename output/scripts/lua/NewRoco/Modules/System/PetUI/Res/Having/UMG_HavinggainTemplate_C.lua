local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_HavinggainTemplate_C = Base:Extend("UMG_HavinggainTemplate_C")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")

function UMG_HavinggainTemplate_C:Initialize(Initializer)
  self.addListene = false
end

function UMG_HavinggainTemplate_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_HavinggainTemplate_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_HavinggainTemplate_C:OnItemUpdate(data, datalist, index)
  self.uidata = data
  self:ShowInfo()
end

function UMG_HavinggainTemplate_C:OnItemSelected(_bSelected)
end

function UMG_HavinggainTemplate_C:OnDeactive()
end

function UMG_HavinggainTemplate_C:OnAddEventListener()
  self.QuestionMarkBtn.OnClicked:Add(self, self.QuestionMarkBtnClick)
end

function UMG_HavinggainTemplate_C:OnRemoveEventListener()
end

function UMG_HavinggainTemplate_C:ShowInfo()
  self.skillConf = nil
  self:ShowInfoAttri()
  self:ShowInfoSkill()
  self:ShowColorQuality()
  if self.uidata.playAnima then
    self.CanvasPanel_anima:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self:PlayAnimation(self.Change)
  end
end

function UMG_HavinggainTemplate_C:ShowInfoAttri()
  local carryoneffect = self.uidata.carryoneffect
  if carryoneffect.sequence_desc == _G.Enum.EquipEffectType.EET_ATTR then
    local conf = self:GetAttriConf(carryoneffect.param1)
    self.GainWayDesc:SetText(conf.attribute_name)
    if 1 == conf.is_percent_attr then
      local num = self:FormatNum(carryoneffect.param2 / 100)
      self.SkillTitle:SetText("+" .. num .. "%")
    else
      self.SkillTitle:SetText("+" .. carryoneffect.param2)
    end
    self.QuestionMarkBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  if self.addListene == false then
    self:OnAddEventListener()
    self.addListene = true
  end
end

function UMG_HavinggainTemplate_C:GetAttriConf(attriType)
  local attritable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.ATTRIBUTE_CONF)
  local attriConfs = attritable:GetAllDatas()
  for i, conf in pairs(attriConfs) do
    local index = tonumber(conf.attribute)
    if index == attriType then
      return conf
    end
  end
end

function UMG_HavinggainTemplate_C:ShowInfoSkill()
  local carryoneffect = self.uidata.carryoneffect
  if carryoneffect.sequence_desc == _G.Enum.EquipEffectType.EET_PASSIVE_SKILL then
    local conf = _G.DataConfigManager:GetSkillConf(carryoneffect.param1)
    self.skillConf = conf
    self.GainWayDesc:SetText(LuaText.pet_carryon_skill_desc)
    self.SkillTitle:SetText(conf.name)
    self.QuestionMarkBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_HavinggainTemplate_C:ShowColorQuality()
  local conf = _G.DataConfigManager:GetBagItemConf(self.uidata.conf.id)
  local quality = conf.item_quality
  self.clolorimage = {
    self.White,
    self.Green,
    self.Blue,
    self.Purple,
    self.Orange
  }
  for i = 1, #self.clolorimage do
    if quality == i then
      self.clolorimage[i]:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.clolorimage[i]:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  end
end

function UMG_HavinggainTemplate_C:FormatNum(num)
  if num <= 0 then
    return 0
  else
    local t1, t2 = math.modf(num)
    if t2 > 0 then
      return num
    else
      return t1
    end
  end
end

function UMG_HavinggainTemplate_C:QuestionMarkBtnClick()
  if self.skillConf ~= nil then
    _G.NRCModeManager:DoCmd(BattleUIModuleCmd.OpenSkillTips, {
      skillData = self.skillConf
    })
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1060, "UMG_HavingFitTogether_C:BtnSwichClick2")
  end
end

return UMG_HavinggainTemplate_C
