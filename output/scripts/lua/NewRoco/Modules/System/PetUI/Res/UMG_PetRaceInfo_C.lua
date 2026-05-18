local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PetUtils = reload("NewRoco.Utils.PetUtils")
local enum = reload("Data.Config.Enum")
local UMG_PetRaceInfo_C = _G.NRCViewBase:Extend("UMG_PetRaceInfo_C")

function UMG_PetRaceInfo_C:Initialize(Initializer)
end

function UMG_PetRaceInfo_C:OnConstruct()
  self:AddButtonListener(self.btnToOther, self.OnBtnToOtherClick)
end

function UMG_PetRaceInfo_C:OnDestruct()
end

function UMG_PetRaceInfo_C:OnEnable()
end

function UMG_PetRaceInfo_C:OnDisable()
end

function UMG_PetRaceInfo_C:updatePetInfo(_petData, _petBaseConf)
  if _petBaseConf then
    local curHp = _petBaseConf.hp_max_race
    local maxHp = _G.DataConfigManager:GetAttrGlobalConfig("race_hp_maximum").num
    local curAttack = _petBaseConf.phy_attack_race
    local maxAttack = _G.DataConfigManager:GetAttrGlobalConfig("race_attack_maximum").num
    local curDefence = _petBaseConf.phy_defence_race
    local maxDefence = _G.DataConfigManager:GetAttrGlobalConfig("race_special_attack_maximum").num
    local curSpecialAttack = _petBaseConf.spe_attack_race
    local maxSpecialAttack = _G.DataConfigManager:GetAttrGlobalConfig("race_defense_maximium").num
    local curSpecialDefence = _petBaseConf.spe_defence_race
    local maxSpecialDefence = _G.DataConfigManager:GetAttrGlobalConfig("race_special_defense_maximum").num
    local curSpeed = _petBaseConf.speed_race
    local maxSpeed = _G.DataConfigManager:GetAttrGlobalConfig("race_speed_maximum").num
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

function UMG_PetRaceInfo_C:OnBtnToOtherClick()
  self:DispatchEvent(PetUIModuleEvent.PET_UI_CHANG_TO_EVOLUTION)
end

return UMG_PetRaceInfo_C
