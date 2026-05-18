local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_PetSumUp_C = _G.NRCViewBase:Extend("UMG_PetSumUp_C")

function UMG_PetSumUp_C:Initialize(Initializer)
end

function UMG_PetSumUp_C:OnConstruct()
  self:SetChildViews(self.UMG_PetRadarInfo)
  self.subPanels = {
    self.UMG_PetRadarInfo,
    self.NRCScrollViewSkill
  }
  self.uiData = {}
  self.uiItem = {}
  self.curSubPanelIndex = 0
  self.IsClick = false
  self:updateSubPanelVisible()
  self:ShowSubPanel(1)
  self:UpdateSumUpInfo()
  self.uiItem.genderIcons = {
    self.ImagePetGender1,
    self.ImagePetGender2
  }
  self.uiItem.petTypeIcons = {
    self.petTypeIcon1,
    self.petTypeIcon2
  }
  self:OnAddEventListener()
end

function UMG_PetSumUp_C:OnDestruct()
end

function UMG_PetSumUp_C:OnActive()
end

function UMG_PetSumUp_C:OnAddEventListener()
  self:AddButtonListener(self.BtnRechristen_1, self.OnBtnRechristen_1)
  self:AddButtonListener(self.Btn, self.OnBtn)
  self:AddButtonListener(self.Btn_1, self.OnBtn_1)
  self:AddButtonListener(self.NRCButton_61, self.OnNRCButton_61)
  self:RegisterEvent(self, PetUIModuleEvent.PetRename, self.UpdatePetName)
end

function UMG_PetSumUp_C:UpdateSumUpInfo()
  self.UMG_PetRadarInfo:SetImage(false)
  self:SetSwitchTo(self.IsClick)
end

function UMG_PetSumUp_C:PanelChanage()
  self.curSubPanelIndex = 0
  self.IsClick = false
  self:updateSubPanelVisible()
  self:ShowSubPanel(1)
  self:UpdateSumUpInfo()
end

function UMG_PetSumUp_C:OnSelectPetChange(_petData)
  self.uiData.BeForePetData = self.uiData.petData or _petData
  self.uiData.petData = _petData
  if self.uiData.BeForePetData.gid ~= self.uiData.petData.gid then
    self:SetPetNewSkillInfo(self.uiData.BeForePetData)
  end
  if _petData then
    self.uiData.petBaseConf = _G.DataConfigManager:GetPetbaseConf(_petData.base_conf_id)
    local BallId = _petData.ball_id
    if 0 == BallId then
      BallId = 100002
    end
    local CurIconPath = PetUtils.iconBallPath[BallId]
    self.CurIcon:SetPath(CurIconPath)
  else
    self.uiData.petBaseConf = nil
  end
  self:SetSumInfo()
  self.UMG_PetRadarInfo:updatePetInfo(self.uiData.petData, self.uiData.petBaseConf)
  self:ShowPetAllSkill()
end

function UMG_PetSumUp_C:ShowPetAllSkill()
  local data = self:GetEquipSkillAllDatas(self.uiData.petData)
  self.NRCScrollViewSkill:InitList(data)
end

function UMG_PetSumUp_C:GetEquipSkillAllDatas(_petData)
  local petEquipSkills = {}
  if _petData then
    for i, skillData in ipairs(_petData.skill.skill_data) do
      if skillData.is_equipped and skillData.pos > 0 and skillData.pos <= 4 then
        table.insert(petEquipSkills, {
          petData = _petData,
          skillData = skillData,
          isinteRaction = false
        })
      end
    end
  end
  return petEquipSkills
end

function UMG_PetSumUp_C:SetSwitchTo(_IsClick)
  if false == _IsClick then
    self.SwitchTo:SetActiveWidgetIndex(1)
    self.SwitchTo1:SetActiveWidgetIndex(0)
  else
    self.SwitchTo:SetActiveWidgetIndex(0)
    self.SwitchTo1:SetActiveWidgetIndex(1)
  end
end

function UMG_PetSumUp_C:SetSumInfo()
  local petData = self.uiData.petData
  local petBaseConf = self.uiData.petBaseConf
  self.textPetName:SetText(petData.name)
  self.textPetLevel:SetText("Lv." .. petData.level)
  self:updatePetGender(petData.gender)
  self:updatePetTypeIcon(petBaseConf.unit_type)
end

function UMG_PetSumUp_C:updatePetGender(_gender)
  for gender, genderIcon in ipairs(self.uiItem.genderIcons) do
    if _gender == gender then
      genderIcon:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      genderIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  end
end

function UMG_PetSumUp_C:updatePetTypeIcon(_dicTypes)
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

function UMG_PetSumUp_C:updateSubPanelVisible()
  for panelIndex, subPanel in pairs(self.subPanels) do
    if subPanel then
      if panelIndex == self.curSubPanelIndex then
        subPanel:SetVisibility(UE4.ESlateVisibility.Visible)
      else
        subPanel:SetVisibility(UE4.ESlateVisibility.Hidden)
      end
    end
  end
end

function UMG_PetSumUp_C:OnPanelStateChange(_isShow)
  if _isShow then
  end
  if _isShow then
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    if self.uiData then
      self:SetPetNewSkillInfo(self.uiData.petData)
    end
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_PetSumUp_C:ShowSubPanel(_index, _subIndex)
  if _index > 0 and _index <= #self.subPanels and self.curSubPanelIndex ~= _index then
    self:SetPetNewSkillInfo(self.uiData.petData)
    self:ChangeSubPanelState(self.curSubPanelIndex, false)
    self.curSubPanelIndex = _index
    self:ChangeSubPanelState(self.curSubPanelIndex, true)
  end
end

function UMG_PetSumUp_C:SetPetNewSkillInfo(_PetData)
  local PetData = _PetData
  if PetData and 2 == self.curSubPanelIndex then
    PetUtils.UpdatePetNewSkill(PetData)
  end
end

function UMG_PetSumUp_C:SetPetSumUpPetNewSkill()
  self:SetPetNewSkillInfo()
end

function UMG_PetSumUp_C:ChangeSubPanelState(_index, _isShow)
  if _index then
    local subPanel = self.subPanels[_index]
    if subPanel then
      if subPanel.OnPanelStateChange then
        tcall(subPanel, subPanel.OnPanelStateChange, _isShow)
      end
      if _isShow then
        subPanel:SetVisibility(UE4.ESlateVisibility.Visible)
      else
        subPanel:SetVisibility(UE4.ESlateVisibility.Hidden)
      end
    end
  end
end

function UMG_PetSumUp_C:OnBtn()
  self.IsClick = false
  self:SetSwitchTo(self.IsClick)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1005, "UMG_PetLeftPanel_C:OnBtnCloseSubPanelClick")
  self:ShowSubPanel(1)
end

function UMG_PetSumUp_C:OnBtn_1()
  self.IsClick = true
  self:SetSwitchTo(self.IsClick)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1005, "UMG_PetLeftPanel_C:OnBtnCloseSubPanelClick")
  self:ShowSubPanel(2)
end

function UMG_PetSumUp_C:UpdatePetName(refreshInfo)
  self.uiData.petData = refreshInfo.ret_info.goods_change_info.changes[1].pet_data
  local petRename = self.uiData.petData.name
  self.textPetName:SetText(petRename)
end

function UMG_PetSumUp_C:setPetInfoMainCtrl(_petInfoMainCtrl)
  self.petInfoMainCtrl = _petInfoMainCtrl
end

function UMG_PetSumUp_C:OnNRCButton_61()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_PetBaseInfo_C:OnBtnBtnRechristenClick")
  NRCModuleManager:DoCmd(PetUIModuleCmd.OpenRechristenPanel, self.uiData)
end

function UMG_PetSumUp_C:OnBtnRechristen_1()
  _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenPetTips, self.uiData, _G.Enum.GoodsType.GT_PET)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1002, "UMG_PetBaseInfo_C:OnBtnBtnRechristenClick")
end

function UMG_PetSumUp_C:OnDeactive()
end

return UMG_PetSumUp_C
