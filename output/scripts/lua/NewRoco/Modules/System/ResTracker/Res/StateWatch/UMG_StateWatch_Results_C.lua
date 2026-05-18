local UMG_StateWatch_Results_C = _G.NRCPanelBase:Extend("UMG_StateWatch_Results_C")

function UMG_StateWatch_Results_C:OnActive()
end

function UMG_StateWatch_Results_C:OnDeactive()
end

function UMG_StateWatch_Results_C:OnAddEventListener()
end

function UMG_StateWatch_Results_C:BindData(_data, _data1)
  local Item = _data
  local Item1 = _data1
  self.ResultList:InitList(Item)
  self.ResultList_1:InitList(Item1)
end

return UMG_StateWatch_Results_C
