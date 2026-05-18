local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MagnificentMagic_TabItem_C = Base:Extend("UMG_MagnificentMagic_TabItem_C")

function UMG_MagnificentMagic_TabItem_C:OnConstruct()
  self.suitsConf = nil
end

function UMG_MagnificentMagic_TabItem_C:OnDestruct()
end

function UMG_MagnificentMagic_TabItem_C:OnItemUpdate(_data, datalist, index)
  self.suitsConf = _G.DataConfigManager:GetFashionSuitsConf(_data)
  if self.suitsConf then
    self.Title:SetText(self.suitsConf.name)
    if self.suitsConf.petbase_id and #self.suitsConf.petbase_id > 0 then
      local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.suitsConf.petbase_id[1])
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      self.PetIcon:SetPath(modelConf.ui_icon)
    end
  else
    Log.Dump(_data, 4, "UMG_MagnificentMagic_TabItem_C:OnItemUpdate Error")
  end
end

function UMG_MagnificentMagic_TabItem_C:OnItemSelected(_bSelected)
  self:StopAllAnimations()
  if _bSelected then
    self:PlayAnimation(self.change1)
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_MagnificentMagic_TabItem_C:OnItemSelected")
    _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.OnMagicVideoSuitSelected, self.suitsConf.id)
  else
    self:PlayAnimation(self.change2)
  end
end

function UMG_MagnificentMagic_TabItem_C:OnDeactive()
end

return UMG_MagnificentMagic_TabItem_C
