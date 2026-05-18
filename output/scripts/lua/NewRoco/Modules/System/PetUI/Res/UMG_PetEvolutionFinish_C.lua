local UMG_PetEvolutionFinish_C = _G.NRCPanelBase:Extend("UMG_PetEvolutionFinish_C")

function UMG_PetEvolutionFinish_C:OnConstruct()
  self.uiData = {}
  self.uiItem = {}
  self.MaxCloseTime = 20
  self.uiItem.petTypeIcons = {
    self.petTypeIcon1,
    self.petTypeIcon2
  }
  self.petPropHp:SetTitle(LuaText.umg_petevolutionfinish_1)
  self.petPropAttack:SetTitle(LuaText.umg_petevolutionfinish_2)
  self.petPropDefence:SetTitle(LuaText.umg_petevolutionfinish_3)
  self.petPropSPAttack:SetTitle(LuaText.umg_petevolutionfinish_4)
  self.petPropSPDefence:SetTitle(LuaText.umg_petevolutionfinish_5)
  self.petPropSpeed:SetTitle(LuaText.umg_petevolutionfinish_6)
  Log.Debug("[UMG_PetEvolutionFinish_C:OnConstruct]")
end

function UMG_PetEvolutionFinish_C:OnDestruct()
  Log.Debug("[UMG_PetEvolutionFinish_C:OnDestruct]")
  UE4.UNRCAudioManager.Get():StopWwiseEventForActor(9013)
  local param = self.uiData.param
  if param and param.owner and param.callback then
    param.callback(param.owner)
  end
  table.clear(self.uiItem)
  self.uiData = nil
  self.uiItem = nil
  if self.uiCloseTimer then
    _G.TimerManager:RemoveTimer(self.uiCloseTimer)
    self.uiCloseTimer = nil
  end
end

function UMG_PetEvolutionFinish_C:OnActive(_param, ...)
  _G.NRCPanelBase.OnActive(self, _param, ...)
  self.uiData.param = _param
  self:OnAddEventListener()
  self:updatePanelInfo()
  if self.uiCloseTimer == nil then
    self.curTime = 0
    self:UpdateCloseInfo()
    self.uiCloseTimer = _G.TimerManager:CreateTimer(self, "UMG_PetEvolutionFinish_Close_Timer", 99, self.OnCloseTimerTick, nil, 1)
  end
end

function UMG_PetEvolutionFinish_C:OnDeactive(...)
  _G.NRCPanelBase.OnDeactive(self, ...)
end

function UMG_PetEvolutionFinish_C:OnAddEventListener()
  self:AddButtonListener(self.btnOK, self.OnBtnOKClick)
end

function UMG_PetEvolutionFinish_C:OnCloseTimerTick()
  self.curTime = self.curTime + 1
  self:UpdateCloseInfo()
  if self.curTime >= self.MaxCloseTime then
    Log.Debug("[UMG_PetEvolutionFinish_C:OnAddEventListener]")
    self:DoClose()
  end
end

function UMG_PetEvolutionFinish_C:UpdateCloseInfo()
  self.textCloseInfo:SetText(string.format(LuaText.umg_petevolutionfinish_7, self.MaxCloseTime - self.curTime or 0))
end

function UMG_PetEvolutionFinish_C:OnRemoveEventListener()
end

function UMG_PetEvolutionFinish_C:updatePanelInfo()
  local petBaseId = self.uiData.param.petbaseConfId
  if not petBaseId or petBaseId <= 0 then
    return
  end
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petBaseId)
  self.textPetName:SetText(string.format(LuaText.umg_petevolutionfinish_8, petBaseConf.name))
  self:updatePetTypeIcon(petBaseConf.unit_type)
  self:updatePetSpecialSkill(petBaseConf.pet_feature)
  self:updatePetPropInfo(petBaseConf)
end

function UMG_PetEvolutionFinish_C:updatePetTypeIcon(_dicTypes)
  for i, uiIcon in ipairs(self.uiItem.petTypeIcons) do
    uiIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
    local petType = _dicTypes[i]
    if petType then
      local typeDic = _G.DataConfigManager:GetTypeDictionary(petType)
      if typeDic then
        uiIcon:SetPath(typeDic.type_icon)
        uiIcon:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    end
  end
end

function UMG_PetEvolutionFinish_C:updatePetSpecialSkill(_skillId)
  local skillCfg = _G.DataConfigManager:GetSkillConf(_skillId)
  if skillCfg then
    self.specialSkillIicon:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.specialSkillIicon:SetPath(skillCfg.icon)
    self.textSpecialSkillName:SetText(skillCfg.name)
    self.textSpecialSkillDesc:SetText(skillCfg.desc)
    return
  end
  self:clearPetSpecialSkill()
end

function UMG_PetEvolutionFinish_C:clearPetSpecialSkill()
  self.specialSkillIicon:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.textSpecialSkillName:SetText("")
  self.textSpecialSkillDesc:SetText("")
end

function UMG_PetEvolutionFinish_C:updatePetPropInfo(_petBaseConf, _dstPetBaseConf)
  self.petPropHp:SetProp(_petBaseConf and _petBaseConf.hp_max_race, _dstPetBaseConf and _dstPetBaseConf.hp_max_race)
  self.petPropAttack:SetProp(_petBaseConf and _petBaseConf.phy_attack_race, _dstPetBaseConf and _dstPetBaseConf.phy_attack_race)
  self.petPropDefence:SetProp(_petBaseConf and _petBaseConf.phy_defence_race, _dstPetBaseConf and _dstPetBaseConf.phy_defence_race)
  self.petPropSPAttack:SetProp(_petBaseConf and _petBaseConf.spe_attack_race, _dstPetBaseConf and _dstPetBaseConf.spe_attack_race)
  self.petPropSPDefence:SetProp(_petBaseConf and _petBaseConf.spe_defence_race, _dstPetBaseConf and _dstPetBaseConf.spe_defence_race)
  self.petPropSpeed:SetProp(_petBaseConf and _petBaseConf.speed_race, _dstPetBaseConf and _dstPetBaseConf.speed_race)
end

function UMG_PetEvolutionFinish_C:OnBtnOKClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_PetEvolutionFinish_C:OnBtnOKClick")
  Log.Debug("[UMG_PetEvolutionFinish_C:OnBtnOKClick]")
  self:DoClose()
end

return UMG_PetEvolutionFinish_C
