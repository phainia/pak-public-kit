local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Information_Recording_DotItem_C = Base:Extend("UMG_Information_Recording_DotItem_C")

function UMG_Information_Recording_DotItem_C:OnConstruct()
  self.data = {
    key = -1,
    index = -1,
    roundIndex = -1,
    Selected = false
  }
end

function UMG_Information_Recording_DotItem_C:OnDestruct()
end

function UMG_Information_Recording_DotItem_C:OnItemUpdate(_data, datalist, index)
  _data.index = index
  local previousData = self.data
  local newData = {}
  table.copy(_data, newData)
  self:SetData(newData)
  if previousData.Selected ~= newData.Selected then
    if newData.Selected then
      self:PlayAnimation(self.Select)
    else
      self:PlayAnimation(self.Select_not)
    end
  end
  self:SetVisibility(UE.ESlateVisibility.Visible)
end

function UMG_Information_Recording_DotItem_C:SetData(newData)
  local previousData = self.data
  self.data = newData
end

function UMG_Information_Recording_DotItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    local data = self.data
    if data then
      tcall(data.OnSelectedCallbackOwner, data.OnSelectedCallback, data.key)
    end
  end
end

function UMG_Information_Recording_DotItem_C:OnDeactive()
end

return UMG_Information_Recording_DotItem_C
