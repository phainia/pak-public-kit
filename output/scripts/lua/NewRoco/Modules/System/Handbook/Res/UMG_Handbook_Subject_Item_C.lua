local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Handbook_Subject_Item_C = Base:Extend("UMG_Handbook_Subject_Item_C")

function UMG_Handbook_Subject_Item_C:OnConstruct()
end

function UMG_Handbook_Subject_Item_C:OnDestruct()
end

function UMG_Handbook_Subject_Item_C:OnItemUpdate(_data, datalist, index)
  local showSubstrate = _data.topic_type ~= _G.Enum.PetHandbookTopic.PHT_CONFIRM_FORM_NUMBER and _data.topic_type ~= _G.Enum.PetHandbookTopic.PHT_EVO_TIMES
  self.Description:SetText(_data.topic_desc)
  self.Quantity:SetText(_data.finish_cnt)
  local node_num = _data.node_num
  local topic_node = _data.topic_node
  local nodeListData = {}
  for i, value in ipairs(topic_node) do
    table.insert(nodeListData, {
      num = value,
      showStar = i <= node_num
    })
  end
  self.List:InitGridView(nodeListData)
end

function UMG_Handbook_Subject_Item_C:OnItemSelected(_bSelected)
end

function UMG_Handbook_Subject_Item_C:OnDeactive()
end

return UMG_Handbook_Subject_Item_C
