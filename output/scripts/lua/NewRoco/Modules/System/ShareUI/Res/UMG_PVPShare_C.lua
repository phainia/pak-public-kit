local UMG_PVPShare_C = _G.NRCPanelBase:Extend("UMG_PVPShare_C")

function UMG_PVPShare_C:OnActive(data)
  self.data = data
  local ShareDataSnapshot = data.extraData
  self.tableIndex = ShareDataSnapshot.TableIndex
  local curSeasonData = ShareDataSnapshot.CurSeasonData
  self.TableDatas = ShareDataSnapshot.TableDatas
  local startNum = ShareDataSnapshot.rank_star
  self.PhotoSub:InitData(curSeasonData, self.tableIndex, self.TableDatas, startNum)
end

function UMG_PVPShare_C:OnDeactive()
end

function UMG_PVPShare_C:OnAddEventListener()
end

return UMG_PVPShare_C
