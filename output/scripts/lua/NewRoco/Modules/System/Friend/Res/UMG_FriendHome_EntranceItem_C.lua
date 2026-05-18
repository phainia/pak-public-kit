local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_FriendHome_EntranceItem_C = Base:Extend("UMG_FriendHome_EntranceItem_C")

function UMG_FriendHome_EntranceItem_C:OnConstruct()
end

function UMG_FriendHome_EntranceItem_C:OnDestruct()
end

function UMG_FriendHome_EntranceItem_C:OnActive()
end

function UMG_FriendHome_EntranceItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.NRCText_1:SetText(self.data)
end

function UMG_FriendHome_EntranceItem_C:OnItemSelected(_bSelected)
end

function UMG_FriendHome_EntranceItem_C:OnDeactive()
end

return UMG_FriendHome_EntranceItem_C
