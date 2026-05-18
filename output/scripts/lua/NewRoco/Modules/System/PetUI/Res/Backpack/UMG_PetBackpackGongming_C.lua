local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_PetBackpackGongming_C = Base:Extend("UMG_PetBackpackGongming_C")

function UMG_PetBackpackGongming_C:OnConstruct()
end

function UMG_PetBackpackGongming_C:OnDestruct()
end

function UMG_PetBackpackGongming_C:OnItemUpdate(_data, datalist, index)
  if _data.activedNum then
    self.Text:SetText(_data.activedNum)
    self.ShiNeng:SetPath(_data.typeCfg.synchron_petbag_icon)
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PetBackpackGongming_C:OnItemSelected(_bSelected)
  if _bSelected then
  end
end

function UMG_PetBackpackGongming_C:OnOpenResonanceUI()
  local teamPet = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  local petInfos = {}
  for i, petData in ipairs(teamPet) do
    table.insert(petInfos, PetUtils.PetInfoCreate(petData.gid))
  end
  local petTeam = {pet_infos = petInfos}
  if nil == petTeam or petTeam.pet_infos == nil or 0 == #petTeam.pet_infos then
    local msg = _G.DataConfigManager:GetPetGlobalConfig("pet_no_synchron").str
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, msg)
    return
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1290, "UMG_PetTeam_C:OnOpenResonanceUI")
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenPetTeamResonancePanel, petTeam)
end

function UMG_PetBackpackGongming_C:OnDeactive()
end

return UMG_PetBackpackGongming_C
