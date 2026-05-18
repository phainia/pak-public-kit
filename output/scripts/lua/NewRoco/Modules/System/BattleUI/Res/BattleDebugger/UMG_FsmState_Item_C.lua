local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_FsmState_Item_C = Base:Extend("UMG_FsmState_Item_C")

function UMG_FsmState_Item_C:OnConstruct()
end

function UMG_FsmState_Item_C:OnDestruct()
end

function UMG_FsmState_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetPanelInfo()
  self:SetFsmListInfo()
end

function UMG_FsmState_Item_C:SetPanelInfo()
  local data = self.data
  self.FsmName:SetText(data.State:GetName())
end

function UMG_FsmState_Item_C:SetFsmListInfo()
  local data = self.data
  local activeActions = data.Action
  self.FsmActionList:InitGridView(activeActions)
end

function UMG_FsmState_Item_C:OnItemSelected(_bSelected)
end

function UMG_FsmState_Item_C:OnDeactive()
end

return UMG_FsmState_Item_C
