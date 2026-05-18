local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Common_ListItem_Pet_C = Base:Extend("UMG_Common_ListItem_Pet_C")

function UMG_Common_ListItem_Pet_C:OnConstruct()
end

function UMG_Common_ListItem_Pet_C:OnDestruct()
  if self.Module then
    self.Module:UnRegisterEvent(self, PetUIModuleEvent.PetTeamWarehouseItemSelected, self.OnPetTeamWarehouseItemSelected)
    self.Module:UnRegisterEvent(self, PetUIModuleEvent.PetTeamFastFormationChanged, self.OnPetTeamFastFormationChanged)
  end
end

function UMG_Common_ListItem_Pet_C:RefreshItem()
  self:OnItemUpdate(self.uiData, false)
end

function UMG_Common_ListItem_Pet_C:OnItemUpdate(_data, datalist, index)
  self.Module = _G.NRCModuleManager:GetModule("PetUIModule")
  self.Module:UnRegisterEvent(self, PetUIModuleEvent.PetTeamWarehouseItemSelected, self.OnPetTeamWarehouseItemSelected)
  self.Module:UnRegisterEvent(self, PetUIModuleEvent.PetTeamFastFormationChanged, self.OnPetTeamFastFormationChanged)
  self.uiData = _data
  self.data = _data
  local iconNum = _data.itemNum
  if _data.isHasPet then
    if iconNum then
      self.Text_Quantity:SetText(iconNum)
    end
    self.pet:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if _data.PetData.gid then
      local petInfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(_data.PetData.gid)
      self.pet:SetIconPathAndMaterial(petInfo.base_conf_id, petInfo.mutation_type, petInfo.glass_info)
    else
      self.pet:SetIconPathAndMaterial(_data.PetData.base_conf_id)
    end
    if _data.PetData.is_trial_pet then
      self.TryOut:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.TryOut:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.Text_Quantity:SetText(_data.PetData.level)
  else
    if _data.isLockUp then
      self.LockUp:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.LockUp:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.TryOut:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Text_Quantity:SetText("--")
  end
  if 0 == self.data.Mode then
    self.number:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Module:RegisterEvent(self, PetUIModuleEvent.PetTeamWarehouseItemSelected, self.OnPetTeamWarehouseItemSelected)
  elseif 1 == self.data.Mode then
    self.number:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Module:RegisterEvent(self, PetUIModuleEvent.PetTeamFastFormationChanged, self.OnPetTeamFastFormationChanged)
  end
end

function UMG_Common_ListItem_Pet_C:OnPetTeamWarehouseItemChanged(_PetData)
end

function UMG_Common_ListItem_Pet_C:OnPetTeamWarehouseItemSelected(_PetData)
  if _PetData and self.data and self.data.PetData and self.data.PetData.gid == _PetData.gid then
    if not self.isInTeam then
      self:PlayAnimation(self.In)
    else
      self:PlayAnimation(self.Select)
    end
    self.isInTeam = true
  else
    if self.isInTeam then
      self:PlayAnimation(self.Out)
    end
    self.isInTeam = false
  end
end

function UMG_Common_ListItem_Pet_C:OnPetTeamFastFormationChanged(newTeamInfoDic)
  local data = self.data
  if data and data.PetData then
    if newTeamInfoDic and newTeamInfoDic[data.PetData.gid] then
      self.Text_number:SetText(newTeamInfoDic[data.PetData.gid])
      if not self.isInTeam then
        self:PlayAnimation(self.In)
      else
        self:PlayAnimation(self.Select)
      end
      self.isInTeam = true
    else
      if self.isInTeam then
        self:PlayAnimation(self.Out)
      end
      self.isInTeam = false
    end
  end
end

function UMG_Common_ListItem_Pet_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_Common_ListItem_Pet_C:OnItemSelected(_bSelected)
  if self.uiData.IsTravel then
    return
  end
  if _bSelected then
    if 0 == self.uiData.Mode then
      self.Module:DispatchEvent(PetUIModuleEvent.PetTeamWarehouseItemSelected, self.uiData.PetData)
    elseif 1 == self.uiData.Mode then
      self.Module:DispatchEvent(PetUIModuleEvent.PetTeamFastFormationSelected, self.uiData.PetData)
    end
  end
end

function UMG_Common_ListItem_Pet_C:OnDeactive()
  self.uiData = nil
end

return UMG_Common_ListItem_Pet_C
