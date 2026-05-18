local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_RivalCamp_C = Base:Extend("UMG_RivalCamp_C")

function UMG_RivalCamp_C:OnConstruct()
end

function UMG_RivalCamp_C:OnDestruct()
end

function UMG_RivalCamp_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.index = index
  self:_InitItem()
end

function UMG_RivalCamp_C:OnItemSelected(_bSelected)
  if _bSelected then
    local infoData = {
      petBaseId = self.uiData.petBaseId,
      level = self.uiData.level,
      bIsEnemy = true,
      bShowHpText = true,
      bForceShowType = true
    }
    _G.NRCAudioManager:PlaySound2DAuto(40002003, "UMG_RivalCamp_C:OnItemSelected")
    _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.ShowChangePetConfirm3, infoData, nil, false, false, {isShowPetTips = true})
  else
  end
end

function UMG_RivalCamp_C:OnDeactive()
end

function UMG_RivalCamp_C:_InitItem()
  self.SelectedGrade:SetText(self.uiData.level)
  self.HeadIcon:SetIconPathAndMaterial(self.uiData.petBaseId)
end

return UMG_RivalCamp_C
