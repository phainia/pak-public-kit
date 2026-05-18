local UMG_Pet_ConfirmationWizard_C = _G.NRCPanelBase:Extend("UMG_Pet_ConfirmationWizard_C")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local PetUtils = require("NewRoco.Utils.PetUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")

function UMG_Pet_ConfirmationWizard_C:OnActive(pet)
  self.name = pet.name
  self.pet = pet
  self:OnAddEventListener()
  self.petTypeIcons = {
    self.petTypeIcon1,
    self.petTypeIcon2
  }
  self.uiItem = {}
  self.uiItem.petTypeText = {
    {
      self.BG_5,
      self.Text_1
    },
    {
      self.BG_2,
      self.Text
    }
  }
  self.textPetName:SetText(pet.name)
  self:SetCatchHardLV(pet)
  self:SetWeigthAndStature(pet.weight, pet.height)
  self:updatePetNature(pet.nature)
  local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(pet.base_conf_id)
  self:updatePetTypeIcon(PetBaseConf.unit_type)
  self:SetSpecialSign(pet.mutation_type)
  self:UpdateBlood(pet)
end

function UMG_Pet_ConfirmationWizard_C:OnDeactive()
end

function UMG_Pet_ConfirmationWizard_C:OnAddEventListener()
  self:AddButtonListener(self.Btn2.btnLevelUp, self.OnBtnCancelClick)
  self:AddButtonListener(self.Btn5.btnLevelUp, self.OnBtnOkClick)
end

function UMG_Pet_ConfirmationWizard_C:OnBtnCancelClick()
  self:OnClose()
  NRCModuleManager:DoCmd(BattleUIModuleCmd.OpenCallNamePanel)
end

function UMG_Pet_ConfirmationWizard_C:OnBtnOkClick()
  local req = ProtoMessage:newZoneBattleFinalBattleP2SummonReq()
  req.name = self.name
  req.confirmed = 1
  req.pet = self.pet
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_FINAL_BATTLE_P2_SUMMON_REQ, req, self, self.OnFinalBattle2Rsp)
end

function UMG_Pet_ConfirmationWizard_C:OnFinalBattle2Rsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    _G.BattleEventCenter:Dispatch(BattleEvent.OnFinalBattleSummer, rsp)
    Log.Error("\233\128\137\230\139\169\230\136\144\229\138\159")
    self:OnClose()
  end
end

function UMG_Pet_ConfirmationWizard_C:SetCatchHardLV(petData)
  self.CatchHardLv:Clear()
  local BreakThroughStarsList = PetUtils.GetBreakThroughStarsList(petData)
  self.CatchHardLv:InitGridView(BreakThroughStarsList)
end

function UMG_Pet_ConfirmationWizard_C:SetWeigthAndStature(weight, height)
  local WeightData = weight * 0.001
  local num = self:GetPreciseDecimal(WeightData, 2)
  self.TextWeight:SetText(num)
  self.TextStature:SetText(string.format("%.2f", height * 0.01))
end

function UMG_Pet_ConfirmationWizard_C:updatePetNature(_nature)
  local petNatureConf = _G.DataConfigManager:GetNatureConf(_nature)
  if petNatureConf then
    self.textPetNature:SetText(petNatureConf.name or "")
  end
end

function UMG_Pet_ConfirmationWizard_C:updatePetTypeIcon(_dicTypes)
  for i, uiIcon in ipairs(self.petTypeIcons) do
    local typeBG = self.uiItem.petTypeText[i][1]
    local typeText = self.uiItem.petTypeText[i][2]
    uiIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
    typeBG:SetVisibility(UE4.ESlateVisibility.Collapsed)
    typeText:SetText("")
    local petType = _dicTypes[#_dicTypes - i + 1]
    if petType then
      local typeDic = _G.DataConfigManager:GetTypeDictionary(petType)
      if typeDic then
        uiIcon:SetPath(typeDic.type_icon)
        typeText:SetText(typeDic.short_name)
        uiIcon:SetVisibility(UE4.ESlateVisibility.Visible)
        typeBG:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  end
end

function UMG_Pet_ConfirmationWizard_C:SetSpecialSign(mutation_type)
  self.State_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
    if self:IsAnimationPlaying(self.New_in) then
      self.Heterochrome:SetRenderOpacity(0)
    end
    self.State_1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.State_1:SetActiveWidgetIndex(1)
  elseif PetMutationUtils.GetMutationValue(mutation_type, _G.Enum.MutationDiffType.MDT_GLASS) then
    self.State_1:SetVisibility(UE4.ESlateVisibility.Visible)
    if self.Dazzling and self:IsAnimationPlaying(self.New_in) then
      self.Dazzling:SetRenderOpacity(0)
    end
    self.State_1:SetActiveWidgetIndex(0)
  end
end

function UMG_Pet_ConfirmationWizard_C:GetPreciseDecimal(num, n)
  if type(num) ~= "number" then
    return num
  end
  n = n or 0
  n = math.floor(n)
  if n < 0 then
    n = 0
  end
  local decimal = 10 ^ n
  local temp = math.floor(num * decimal)
  return temp / decimal
end

function UMG_Pet_ConfirmationWizard_C:UpdateBlood(pet)
  local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(pet.blood_id)
  self.Text_2:SetText(PetBloodConf.blood_name)
  self.icon_1:SetPath(PetBloodConf.icon)
end

return UMG_Pet_ConfirmationWizard_C
