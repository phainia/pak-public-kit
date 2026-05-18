local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PetUtils = reload("NewRoco.Utils.PetUtils")
local enum = reload("Data.Config.Enum")
local UMG_PetFightInfo_C = _G.NRCViewBase:Extend("UMG_PetFightInfo_C")

function UMG_PetFightInfo_C:Initialize(Initializer)
end

function UMG_PetFightInfo_C:OnConstruct()
  local uiItem = {}
  uiItem.propIcons = {
    [enum.AttributeType.AT_HPMAX] = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/GameInfo/Frames/ui_petinfo__icon_hp_png.ui_petinfo__icon_hp_png'",
    [enum.AttributeType.AT_PHYATK] = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/GameInfo/Frames/ui_petinfo_icon_attact_png.ui_petinfo_icon_attact_png'",
    [enum.AttributeType.AT_SPEATK] = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/GameInfo/Frames/ui_petinfo_icon_magic_png.ui_petinfo_icon_magic_png'",
    [enum.AttributeType.AT_PHYDEF] = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/GameInfo/Frames/ui_petinfo_icon_defence_png.ui_petinfo_icon_defence_png'",
    [enum.AttributeType.AT_SPEDEF] = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/GameInfo/Frames/ui_petinfo_icon_magicDF_png.ui_petinfo_icon_magicDF_png'",
    [enum.AttributeType.AT_SPEED] = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/GameInfo/Frames/ui_petinfo_icon_speed_png.ui_petinfo_icon_speed_png'"
  }
  local typeIcon1 = {
    root = self.icon2,
    icon = self.petTypeIcon2,
    up = self.imageIcon2Up,
    down = self.imageIcon2Down
  }
  local typeIcon2 = {
    root = self.icon1,
    icon = self.petTypeIcon1,
    up = self.imageIcon1Up,
    down = self.imageIcon1Down
  }
  uiItem.typeIcons = {typeIcon1, typeIcon2}
  self.uiItem = uiItem
end

function UMG_PetFightInfo_C:OnDestruct()
  table.clear(self.uiItem)
  self.uiItem = nil
  self.petTypeIcon1:ReleaseForce()
  self.petTypeIcon2:ReleaseForce()
end

function UMG_PetFightInfo_C:OnEnable()
end

function UMG_PetFightInfo_C:OnDisable()
end

function UMG_PetFightInfo_C:showIcon(_iconIdx, _prop, _isUp)
  local uiItem = self.uiItem
  local uiIconInfo = uiItem.typeIcons[_iconIdx or 0]
  if uiIconInfo then
    local iconPath = uiItem.propIcons[_prop]
    if iconPath then
      uiIconInfo.icon:SetPath(iconPath)
      self:setActive(uiIconInfo.icon, nil ~= iconPath)
      self:setActive(uiIconInfo.root, true)
      self:setActive(uiIconInfo.up, _isUp)
      self:setActive(uiIconInfo.down, not _isUp)
    else
      self:setActive(uiIconInfo.root, false)
    end
  end
end

function UMG_PetFightInfo_C:setActive(_uiItem, _isShow)
  if _uiItem then
    if _isShow then
      _uiItem:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      _uiItem:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  end
end

function UMG_PetFightInfo_C:updatePetInfo(_petData, _petBaseConf)
  if _petData and _petBaseConf then
    local curHp = _petData.additional_attr.addi_attr[2] or 0
    local maxHp = _G.DataConfigManager:GetAttrGlobalConfig("at_hp_maximum").num
    local curAttack = _petData.additional_attr.addi_attr[3] or 0
    local maxAttack = _G.DataConfigManager:GetAttrGlobalConfig("at_attack_maximum").num
    local curDefence = _petData.additional_attr.addi_attr[5] or 0
    local maxDefence = _G.DataConfigManager:GetAttrGlobalConfig("at_special_attack_maximum").num
    local curSpecialAttack = _petData.additional_attr.addi_attr[4] or 0
    local maxSpecialAttack = _G.DataConfigManager:GetAttrGlobalConfig("at_defense_maximium").num
    local curSpecialDefence = _petData.additional_attr.addi_attr[6] or 0
    local maxSpecialDefence = _G.DataConfigManager:GetAttrGlobalConfig("at_special_defense_maximum").num
    local curSpeed = _petData.additional_attr.addi_attr[7] or 0
    local maxSpeed = _G.DataConfigManager:GetAttrGlobalConfig("at_speed_maximum").num
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
    local natureIconInfo = {}
    local petNatureConf = _G.DataConfigManager:GetNatureConf(_petData.nature)
    self.textPetNature:SetText(petNatureConf and petNatureConf.name or "")
    if enum.AttributeType.AT_NONE < petNatureConf.positive_effect and petNatureConf.positive_effect < enum.AttributeType.AT_NULL then
      table.insert(natureIconInfo, {
        prop = petNatureConf.positive_effect,
        isUp = true
      })
    end
    if enum.AttributeType.AT_NONE < petNatureConf.negative_effect and petNatureConf.negative_effect < enum.AttributeType.AT_NULL then
      table.insert(natureIconInfo, {
        prop = petNatureConf.negative_effect,
        isUp = false
      })
    end
    local propCount = #natureIconInfo
    if 2 == propCount then
      self:showIcon(1, natureIconInfo[1].prop, natureIconInfo[1].isUp)
      self:showIcon(2, natureIconInfo[2].prop, natureIconInfo[2].isUp)
    elseif 1 == propCount then
      self:showIcon(1, 0)
      self:showIcon(2, natureIconInfo[1].prop, natureIconInfo[1].isUp)
    else
      self:showIcon(1, 0)
      self:showIcon(2, 0)
    end
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
    self.textPetNature:SetText("")
  end
end

return UMG_PetFightInfo_C
