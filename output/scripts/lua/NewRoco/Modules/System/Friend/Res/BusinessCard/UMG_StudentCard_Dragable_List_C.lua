local UMG_StudentCard_Dragable_List_C = _G.NRCPanelBase:Extend("UMG_StudentCard_Dragable_List_C")

function UMG_StudentCard_Dragable_List_C:OnConstruct()
end

function UMG_StudentCard_Dragable_List_C:OnDestruct()
end

function UMG_StudentCard_Dragable_List_C:OnActive()
  self.listInfo = {}
  for i = 1, 10 do
    local info = {
      name = "test" .. i,
      index = i,
      infoType = 3
    }
    table.insert(self.listInfo, info)
  end
  self.ListView:InitList(self.listInfo)
  Log.Debug("UMG_StudentCard_Dragable_List_C OnActive", #self.listInfo)
end

function UMG_StudentCard_Dragable_List_C:OnDeactive()
end

return UMG_StudentCard_Dragable_List_C
