local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_QucikSelectionItem_C = Base:Extend("UMG_QucikSelectionItem_C")

function UMG_QucikSelectionItem_C:OnConstruct()
end

function UMG_QucikSelectionItem_C:OnDestruct()
end

function UMG_QucikSelectionItem_C:OnItemUpdate(_data, datalist, index)
  if _data.Talent == Enum.PetTalentRate.PTR_PERFECT then
    self.TText:SetText("\228\186\134\228\184\141\232\181\183\231\154\132\229\164\169\229\136\134")
  end
  if _data.Talent == Enum.PetTalentRate.PTR_AMAZING then
    self.TText:SetText("\231\155\184\229\189\147\229\165\189\231\154\132\229\164\169\229\136\134")
  end
  if _data.Talent == Enum.PetTalentRate.PTR_GOOD then
    self.TText:SetText("\232\191\152\228\184\141\233\148\153\231\154\132\229\164\169\229\136\134")
  end
  if _data.Talent == Enum.PetTalentRate.PTR_NORMAL then
    self.TText:SetText("\228\184\128\232\136\172\232\136\172\231\154\132\229\164\169\229\136\134")
  end
  self.bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor("E9E1CFFF"))
  self.NumText:SetText(_data.num)
  self.data = _data
  self.IsSelect = false
end

function UMG_QucikSelectionItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    if not self.IsSelect then
      self:PlayAnimation(self.Press)
      self.IsSelect = true
      self.NumText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
      self.TText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#272727FF"))
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401003, "UMG_PetDropDownListltem1_C:OnItemSelected")
    else
      self.IsSelect = false
      self.NumText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
      self.TText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#62605EFF"))
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401003, "UMG_PetDropDownListltem1_C:OnItemSelected")
      self:PlayAnimation(self.Cancel)
    end
    _G.NRCModuleManager:GetModule("PetUIModule"):DispatchEvent(PetUIModuleEvent.AddOrRemoveItemFromBatchList, self.data.Talent, self.IsSelect)
  end
end

function UMG_QucikSelectionItem_C:OnDeactive()
end

return UMG_QucikSelectionItem_C
