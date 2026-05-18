local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_Bag_PetHeadPicture_C = Base:Extend("UMG_Bag_PetHeadPicture_C")

function UMG_Bag_PetHeadPicture_C:OnConstruct()
  self.uiData = nil
end

function UMG_Bag_PetHeadPicture_C:OnDestruct()
end

function UMG_Bag_PetHeadPicture_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  self:SetData(self.uiData)
  self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.BloodPulse:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Bag_PetHeadPicture_C:ShowBloodPulse()
  local uiData = self.uiData
  local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(uiData[1].blood_id)
  self.BloodPulse:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.icon:SetPath(PetBloodConf.icon)
end

function UMG_Bag_PetHeadPicture_C:SetSelectQuality(quality)
end

function UMG_Bag_PetHeadPicture_C:SetData(_data)
  self.uiData = _data
  if _data then
    if 0 == self.uiData[2] then
      self.HeadIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#ffffffff"))
      self.BGColor:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.HeadIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("#AFAFAFFF"))
      self.BGColor:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.uiData[1].base_conf_id)
    if petBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      if modelConf then
        self.HeadIcon:SetIconPathAndMaterial(self.uiData[1].base_conf_id, self.uiData[1].mutation_type, self.uiData[1].glass_info)
        self.NumText:SetText(self.uiData[1].level)
      end
    end
  end
end

function UMG_Bag_PetHeadPicture_C:OnItemSelected(_bSelected)
  if true == _bSelected then
    if not self.CanOpenTips then
      _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.SetBagItemClickAble, "BagPopUp", false)
      local petdata = self.uiData
      self.Select:SetVisibility(UE4.ESlateVisibility.Visible)
      self:PlayAnimation(self.Select_In)
      if self.uiData.isEvolutionary then
        _G.NRCModuleManager:DoCmd(BagModuleCmd.SetEvolutionarySelectedItem, self.uiData)
        _G.NRCModuleManager:GetModule("BagModule"):DispatchEvent(BagModuleEvent.SetEvolutionarySelectedItem, petdata)
      else
        _G.NRCModuleManager:DoCmd(BagModuleCmd.SetPetSkillItemSelectedItem, self.uiData)
        _G.NRCModuleManager:GetModule("BagModule"):DispatchEvent(BagModuleEvent.SetChoosePetskillItem, petdata)
      end
    else
      self.CanOpenTips = false
      _G.NRCModeManager:DoCmd(PetUIModuleCmd.ShowChangePetConfirm, self.uiData[1])
    end
    self.CanOpenTips = true
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_Bag_PetHeadPicture_C:OnItemSelected")
  else
    self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:PlayAnimation(self.Select_Out)
    self.CanOpenTips = false
  end
end

function UMG_Bag_PetHeadPicture_C:OnDeactive()
end

function UMG_Bag_PetHeadPicture_C:OnAnimationFinished(Animation)
  if Animation == self.Select_In then
    _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.SetBagItemClickAble, "BagPopUp", true)
  end
  if Animation == self.Select_Out then
  end
end

function UMG_Bag_PetHeadPicture_C:ShowNightmare()
  self.HeadIcon:SetIconPathAndMaterial(self.uiData[1].base_conf_id, self.uiData[1].mutation_type, self.uiData[1].glass_info)
end

return UMG_Bag_PetHeadPicture_C
