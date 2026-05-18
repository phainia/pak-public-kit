local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UIUtils = require("NewRoco.Modules.System.TipsModule.Utils.UIUtils")
local UMG_PetRelease_C = Base:Extend("UMG_PetRelease_C")

function UMG_PetRelease_C:OnConstruct()
  self.Selected:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_PetRelease_C:OnDestruct()
end

function UMG_PetRelease_C:OnActive()
end

function UMG_PetRelease_C:OnItemUpdate(_Petdata)
  self.PetList = _Petdata
  self:SetData()
end

function UMG_PetRelease_C:SetData()
  local petList = self.PetList
  if self.plus then
    self.plus:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  self.Selected:SetVisibility(UE4.ESlateVisibility.Hidden)
  if petList and petList.IsTeamPet == false then
    self.NumText:SetText(petList.IconListInfo)
    self.ColorfulHeadIcon:SetIconPathAndMaterial(petList.PetBaseId, petList.mutation_typ, petList.glass_info)
  elseif petList and petList.IsHasPet then
    self.NumText:SetText(petList.IconListInfo)
    self.ColorfulHeadIcon:SetIconPathAndMaterial(petList.PetBaseId, petList.mutation_typ, petList.glass_info)
  elseif self.plus then
    self.plus:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_PetRelease_C:SetSelect(_flag)
  self:StopAllAnimations()
  if _flag then
    self:PlayAnimation(self.change1)
    self.Selected:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self:PlayAnimation(self.change2)
    self.Selected:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_PetRelease_C:OnItemSelected(_bSelected)
  if _bSelected then
    local PetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.PetList.gid)
    _G.NRCModeManager:DoCmd(PetUIModuleCmd.ShowChangePetConfirm, PetData)
  end
end

function UMG_PetRelease_C:OnAnimationFinished(Animation)
  if Animation == self.change1 then
    Log.Trace("UMG_PetItemTemplate_C:OnAnimationFinished")
    self:PlayAnimation(self.select, 0, 9999)
  end
end

function UMG_PetRelease_C:OnDeactive()
end

return UMG_PetRelease_C
