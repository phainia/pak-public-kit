local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PetUtils = reload("NewRoco.Utils.PetUtils")
local enum = reload("Data.Config.Enum")
local UMG_PetTalentInfo_C = _G.NRCViewBase:Extend("UMG_PetTalentInfo_C")

function UMG_PetTalentInfo_C:Initialize(Initializer)
end

function UMG_PetTalentInfo_C:OnConstruct()
  self:AddButtonListener(self.btnToOther, self.OnBtnToOtherClick)
end

function UMG_PetTalentInfo_C:OnDestruct()
end

function UMG_PetTalentInfo_C:OnEnable()
end

function UMG_PetTalentInfo_C:OnDisable()
end

function UMG_PetTalentInfo_C:updatePetInfo(_petData, _petBaseConf)
  if _petData then
    local curHp = _petData.attribute_info.hp.talent
    local maxHp = _G.DataConfigManager:GetAttrGlobalConfig("talent_hp_maximum").num
    local curAttack = _petData.attribute_info.attack.talent
    local maxAttack = _G.DataConfigManager:GetAttrGlobalConfig("talent_attack_maximum").num
    local curDefence = _petData.attribute_info.defense.talent
    local maxDefence = _G.DataConfigManager:GetAttrGlobalConfig("talent_special_attack_maximum").num
    local curSpecialAttack = _petData.attribute_info.special_attack.talent
    local maxSpecialAttack = _G.DataConfigManager:GetAttrGlobalConfig("talent_defense_maximium").num
    local curSpecialDefence = _petData.attribute_info.special_defense.talent
    local maxSpecialDefence = _G.DataConfigManager:GetAttrGlobalConfig("talent_special_defense_maximum").num
    local curSpeed = _petData.attribute_info.speed.talent
    local maxSpeed = _G.DataConfigManager:GetAttrGlobalConfig("talent_speed_maximum").num
    self.textHP:SetText(curHp)
    self.textAttackValue:SetText(curAttack)
    self.textDefence:SetText(curDefence)
    self.textSPAttack:SetText(curSpecialAttack)
    self.textSPDefence:SetText(curSpecialDefence)
    self.textSpeed:SetText(curSpeed)
    self.progressHP:SetPercent(curHp / maxHp)
    self.progressAttack:SetPercent(curAttack / maxAttack)
    self.progressDefence:SetPercent(curDefence / maxDefence)
    self.progressSPAttack:SetPercent(curSpecialAttack / maxSpecialAttack)
    self.progressSPDefence:SetPercent(curSpecialDefence / maxSpecialDefence)
    self.progressSpeed:SetPercent(curSpeed / maxSpeed)
  else
    self.textHP:SetText("")
    self.textAttackValue:SetText("")
    self.textDefence:SetText("")
    self.textSPAttack:SetText("")
    self.textSPDefence:SetText("")
    self.textSpeed:SetText("")
    self.progressHP:SetPercent(0)
    self.progressAttack:SetPercent(0)
    self.progressDefence:SetPercent(0)
    self.progressSPAttack:SetPercent(0)
    self.progressSPDefence:SetPercent(0)
    self.progressSpeed:SetPercent(0)
  end
end

function UMG_PetTalentInfo_C:OnBtnToOtherClick()
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_pettalentinfo_1)
end

return UMG_PetTalentInfo_C
