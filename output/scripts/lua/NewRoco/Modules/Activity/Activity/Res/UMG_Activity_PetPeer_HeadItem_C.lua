local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Activity_PetPeer_HeadItem_C = Base:Extend("UMG_Activity_PetPeer_HeadItem_C")

function UMG_Activity_PetPeer_HeadItem_C:OnConstruct()
  self.UIData = nil
  self.parentPanel = nil
end

function UMG_Activity_PetPeer_HeadItem_C:OnDestruct()
end

function UMG_Activity_PetPeer_HeadItem_C:OnItemUpdate(_data, datalist, index)
  self.UIData = _data.petData
  self.parentPanel = _data.parentPanel
  if self.UIData then
    self:SetSelectedState(0)
    self:SetIconPathAndMaterial(self.UIData.pet_base_id, self.UIData.mutation_type, self.UIData.glass_info, false)
  end
end

function UMG_Activity_PetPeer_HeadItem_C:SetSelectedState(state)
  self.Selected:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Selected:SetRenderOpacity(state)
end

function UMG_Activity_PetPeer_HeadItem_C:SetIconPathAndMaterial(PetBaseId, mutation_type, glass_info, useBigIcon)
  self.HeadIcon:SetIconPathAndMaterial(PetBaseId, mutation_type, glass_info, useBigIcon)
end

function UMG_Activity_PetPeer_HeadItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.Selected:SetRenderOpacity(1)
    self:StopAnimation(self.Cancel)
    self:PlayAnimation(self.Select)
    if self.parentPanel then
      self.parentPanel:OnItemSelected(self.UIData)
    end
  else
    self:StopAnimation(self.Select)
    self:PlayAnimation(self.Cancel)
  end
end

function UMG_Activity_PetPeer_HeadItem_C:OnTouchEnded(MyGeometry, InTouchEvent)
  Base.OnTouchEnded(self, MyGeometry, InTouchEvent)
  _G.NRCAudioManager:PlaySound2DAuto(40002006, "UMG_Activity_PetPeer_HeadItem_C:OnTouchEnded")
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_Activity_PetPeer_HeadItem_C:OnDeactive()
end

return UMG_Activity_PetPeer_HeadItem_C
