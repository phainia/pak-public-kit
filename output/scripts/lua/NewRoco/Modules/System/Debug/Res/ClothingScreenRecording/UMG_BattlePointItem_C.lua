local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BattlePointItem_C = Base:Extend("UMG_BattlePointItem_C")

function UMG_BattlePointItem_C:OnConstruct()
end

function UMG_BattlePointItem_C:OnDestruct()
end

function UMG_BattlePointItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.TText:SetText(_data.id)
end

function UMG_BattlePointItem_C:OnItemSelected(_bSelected)
  if _bSelected and self.data.Call and self.data.handler then
    self.data.handler(self.data.Call, self.data)
  end
end

function UMG_BattlePointItem_C:OnDeactive()
end

return UMG_BattlePointItem_C
