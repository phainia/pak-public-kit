local FurnitureList = Class("FurnitureList")

function FurnitureList:Ctor(HomeMain)
  self.HomeMain = HomeMain
  self.ListView = self.HomeMain.Furniture
  self.DecoListView = self.HomeMain.Furniture_Decoration
  self.TabLayer1 = self.HomeMain.TypeTabList
  self.TabLayer2 = self.HomeMain.TypeTabList_1
  self.FurnitureDataList = nil
  self.AvailableFurnitureDataList = nil
end

function FurnitureList:Release()
  self.HomeMain = nil
  if self.DelayRefreshId then
    DelayManager:CancelDelayById(self.DelayRefreshId)
    self.DelayRefreshId = nil
  end
end

function FurnitureList:InitTabLayer()
  local Data = self.HomeMain:GetHomeModuleData()
  local FirstTabList = Data:GetFirstTabList()
  local FirstTabData = {}
  for i, TabConf in ipairs(FirstTabList) do
    table.insert(FirstTabData, {
      TabConf = TabConf,
      OnClick = FPartial(self.ChangeTabLayer1, self, TabConf, i)
    })
  end
  self.TabLayer1:InitGridView(FirstTabData)
  if self.TabLayer1._selectedItem == nil then
    if #FirstTabData > 0 then
      self.TabLayer1:SelectItemByIndex(0)
    end
  else
    self:Refresh()
  end
end

function FurnitureList:ChangeTabLayer1(FirstTabConf, Layer1Index)
  self.CurTabLayer1 = Layer1Index
  if FirstTabConf then
    local bFirstTabChanged = self.TabLayer2.BelongToFirstTab ~= FirstTabConf
    self.TabLayer2.BelongToFirstTab = FirstTabConf
    local SecondTabData = {
      {
        TabConf = FirstTabConf,
        OnClick = FPartial(self.ChangeTabLayer2, self, FirstTabConf, 1)
      }
    }
    for i, tab in ipairs(FirstTabConf.sec_tab_array) do
      local TabConf = DataConfigManager:GetFurnitureClassificationConf(tab)
      table.insert(SecondTabData, {
        TabConf = TabConf,
        OnClick = FPartial(self.ChangeTabLayer2, self, TabConf, i + 1)
      })
    end
    self.TabLayer2:InitGridView(SecondTabData)
    if #SecondTabData > 0 and bFirstTabChanged then
      self.TabLayer2:SelectItemByIndex(0)
    end
    local angle = FirstTabConf.visual_angle
    if angle == Enum.HomeDiyVisualAngle.HDVA_HIGH then
      self.HomeMain:ToggleToGroundCamera()
    elseif angle == Enum.HomeDiyVisualAngle.HDVA_MIDDLE then
      self.HomeMain:ToggleToWallCamera()
    end
  end
end

function FurnitureList:ChangeTabLayer2(TabConf, Layer2Index)
  _G.NRCAudioManager:PlaySound2DAuto(41401006, "FurnitureList:ChangeTab")
  self.CurTabLayer2 = Layer2Index
  local Data = self.HomeMain:GetHomeModuleData()
  self.FurnitureDataList = Data:GetFurnitureListByTabId(TabConf.id)
  self:Refresh()
end

function FurnitureList:Refresh()
  if self.DelayRefreshId then
    DelayManager:CancelDelayById(self.DelayRefreshId)
    self.DelayRefreshId = nil
  end
  self.DelayRefreshId = DelayManager:DelayFrames(1, FPartial(self.InternalRefresh, self))
end

function FurnitureList:InternalRefresh()
  self.DelayRefreshId = nil
  if not self.HomeMain then
    return
  end
  self.AvailableFurnitureDataList = {}
  for i, v in ipairs(self.FurnitureDataList) do
    if v.BagItem and v.RemainingNum > 0 then
      table.insert(self.AvailableFurnitureDataList, v)
    end
  end
  self:InternalSort()
  local ListView = self:InFurnitureMode() and self.ListView or self.DecoListView
  ListView = ListView or self.ListView
  if self.ListView == ListView then
    self.DecoListView:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.ListView:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  ListView:ClearSelection()
  ListView:InitList(self.AvailableFurnitureDataList)
  if #self.AvailableFurnitureDataList > 0 then
    self.HomeMain.Empty:SetVisibility(UE.ESlateVisibility.Collapsed)
    ListView:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    ListView:NRCScrollToStart()
  else
    self.HomeMain.Empty:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    ListView:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function FurnitureList:InternalSort()
  local Item = self.AvailableFurnitureDataList[1]
  if not Item then
    return
  end
  local Sorter
  if Item.InteriorFinishConf then
    local function IsUsing(Data)
      local Room = HomeIndoorSandbox.Server.WorldData:GetRoomData(HomeIndoorSandbox.HomeEditServ.EditRoomId)
      
      if Room then
        local DecoData = Room:GetDecoDataById(Data.InteriorFinishConf.id)
        if DecoData then
          return true
        end
      end
      return false
    end
    
    function Sorter(a, b)
      local bUsingA = IsUsing(a)
      local bUsingB = IsUsing(b)
      if bUsingA ~= bUsingB then
        return bUsingA
      end
      return a.InteriorFinishConf.id < b.InteriorFinishConf.id
    end
  end
  if not Sorter then
    return
  end
  table.sort(self.AvailableFurnitureDataList, Sorter)
end

function FurnitureList:OnPcSelectFurnitureTabLeft()
  local ConfIndex = self.CurTabLayer1
  if 1 == ConfIndex then
    ConfIndex = self.TabLayer1:GetItemCount()
  else
    ConfIndex = ConfIndex - 1
  end
  HomeIndoorSandbox:LogDebug("[Tab] Layer1", ConfIndex - 1)
  self.TabLayer1:SelectItemByIndex(ConfIndex - 1)
end

function FurnitureList:OnPcSelectFurnitureTabRight()
  local ConfIndex = self.CurTabLayer1
  if ConfIndex == self.TabLayer1:GetItemCount() then
    ConfIndex = 1
  else
    ConfIndex = ConfIndex + 1
  end
  HomeIndoorSandbox:LogDebug("[Tab] Layer1", ConfIndex - 1)
  self.TabLayer1:SelectItemByIndex(ConfIndex - 1)
end

function FurnitureList:OnPcSelectFurnitureSecondTab()
  local ConfIndex = self.CurTabLayer2
  if ConfIndex == self.TabLayer2:GetItemCount() then
    ConfIndex = 1
  else
    ConfIndex = ConfIndex + 1
  end
  HomeIndoorSandbox:LogDebug("[Tab] Layer2", ConfIndex - 1)
  self.TabLayer2:SelectItemByIndex(ConfIndex - 1)
end

function FurnitureList:InFurnitureMode()
  local Item = self.AvailableFurnitureDataList[1]
  if not Item then
    return
  end
  return Item.FurnitureItemConf ~= nil
end

return FurnitureList
