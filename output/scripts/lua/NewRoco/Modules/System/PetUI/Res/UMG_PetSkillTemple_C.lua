local Enum = reload("Data.Config.Enum")
local UMG_PetSkillTemple_C = _G.NRCViewBase:Extend("UMG_PetSkillTemple_C")

function UMG_PetSkillTemple_C:Initialize(Initializer)
end

function UMG_PetSkillTemple_C:Construct()
  NRCViewBase.Construct(self)
  self.selectState = false
end

function UMG_PetSkillTemple_C:Destruct()
  self.skillData = nil
  self.skillConfig = nil
  self.callbackFunc = nil
  self.callbackCaller = nil
  self.skillIcon:ReleaseForce()
  self.propIcon:ReleaseForce()
  NRCViewBase.Destruct(self)
end

function UMG_PetSkillTemple_C:OnConstruct()
  self.selectState = false
end

function UMG_PetSkillTemple_C:OnDestruct()
  self.skillData = nil
  self.skillConfig = nil
  self.callbackFunc = nil
  self.callbackCaller = nil
end

function UMG_PetSkillTemple_C:OnEnable()
end

function UMG_PetSkillTemple_C:OnDisable()
end

function UMG_PetSkillTemple_C:SetClickCallback(_caller, _callback)
  self.callbackCaller = _caller
  self.callbackFunc = _callback
end

function UMG_PetSkillTemple_C:SetSkillData(_petSkillData, _skillIndex)
  self.skillIndex = _skillIndex
  self.skillData = _petSkillData
  if self.skillData then
    self.skillConfig = _G.DataConfigManager:GetSkillConf(self.skillData.id)
  else
    self.skillConfig = nil
  end
  self:UpdateSkillInfo()
end

function UMG_PetSkillTemple_C:getSkillId()
  if self.skillData then
    return self.skillData.id
  end
  return 0
end

function UMG_PetSkillTemple_C:UpdateSkillInfo()
  if self.skillData and self.skillData.is_learned and self.skillConfig then
    self.imageEmpty:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.panelSkillIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    self.skillIcon:SetPath(self.skillConfig.icon)
    self.textSkillName:SetText(self.skillConfig.name)
    if self.skillConfig.energy_cost[1] and self.skillConfig.energy_cost[1] > 0 then
      self.Panel_Ultimate:SetVisibility(UE4.ESlateVisibility.Visible)
      self.textSkillUltimate:SetText(self.skillConfig.energy_cost[1])
    else
      self.Panel_Ultimate:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
    local dam_para = self.skillConfig.dam_para[1]
    if dam_para and dam_para > 0 then
      self.textPropValue:SetText(dam_para)
    else
      self.textPropValue:SetText("\226\128\148")
    end
    local typeDic = _G.DataConfigManager:GetTypeDictionary(self.skillConfig.skill_dam_type)
    if typeDic then
      self.propIcon:SetPath(typeDic.type_icon)
      self.propIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.propIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  else
    self.textPropValue:SetText("")
    self.textSkillName:SetText("")
    self.Panel_Ultimate:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.imageEmpty:SetVisibility(UE4.ESlateVisibility.Visible)
    self.panelSkillIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_PetSkillTemple_C:SetSelectState(_select)
  if self.selectState == _select then
    return
  end
  local ani = self.Select
  if self:IsAnimationPlaying(ani) then
    self:StopAnimation(ani)
  end
  if _select then
    self:PlayAnimation(ani)
  else
    self:PlayChangeAnimation()
  end
  self.selectState = _select
end

function UMG_PetSkillTemple_C:PlayChangeAnimation()
  local ani = self.Change
  if self:IsAnimationPlaying(ani) then
    self:StopAnimation(ani)
  end
  self:PlayAnimation(ani)
end

function UMG_PetSkillTemple_C:OnTouchEnded(_myGeometry, _inTouchEvent)
  if self.callbackCaller and self.callbackFunc then
    tcall(self.callbackCaller, self.callbackFunc, self.skillData, self.skillIndex or -1)
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_PetSkillTemple_C:OnAnimationFinished(Animation)
  if Animation == self.Change and self.selectState and not self:IsAnimationPlaying(self.Select) then
    self:PlayAnimation(self.Select)
  end
end

return UMG_PetSkillTemple_C
