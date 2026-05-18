local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_FurnitureScreening_C = _G.NRCPanelBase:Extend("UMG_FurnitureScreening_C")

function UMG_FurnitureScreening_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
  self:OnAddEventListener()
end

function UMG_FurnitureScreening_C:GetBagModuleData()
  return self.module:GetData()
end

function UMG_FurnitureScreening_C:OnActive()
  local data = self:GetBagModuleData()
  local SortedList = data:SortItemListByLableType(data:GetCurItemType(), data.SortIndex)
  self.SortedList = SortedList
  local Data = NRCModuleManager:GetModule("HomeModule"):GetData()
  local InfoList = {}
  local BagModuleData = NRCModuleManager:GetModule("BagModule"):GetData()
  local FilterMap = BagModuleData and BagModuleData:GetFurnitureFilterTabMap() or {}
  BagModuleData:SetFurnitureFilterTabMap(FilterMap)
  self.FilterMap = {}
  for k, v in pairs(FilterMap) do
    self.FilterMap[k] = v
  end
  for i, info in ipairs(Data:GetFirstTabList()) do
    if info.tab_icon_build_1 or not BagModuleData:InFurnitureDecomposeMode() then
      table.insert(InfoList, {
        index = i,
        text = info.tab_name,
        tab = info,
        bDisableClickSelect = true,
        OnClick = FPartial(self.OnClickItem, self),
        bNeedInitSelect = true,
        InitSelected = FilterMap[info.id]
      })
    end
  end
  self.SortList:InitGridView(InfoList)
  self:SetCommonPopUpInfo()
  for i = 0, self.SortList:GetItemCount() - 1 do
    local Item = self.SortList:GetItemByIndex(i)
    if self.FilterMap[Item.data.tab.id] then
      Item:DoSelect()
    end
  end
end

function UMG_FurnitureScreening_C:OnDeactive()
end

function UMG_FurnitureScreening_C:OnAddEventListener()
end

function UMG_FurnitureScreening_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnReqReset
  CommonPopUpData.Btn_RightHandler = self.OnReqConfirm
  CommonPopUpData.ClosePanelHandler = self.OnReqClose
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp3:SetPanelInfo(CommonPopUpData)
end

function UMG_FurnitureScreening_C:OnClickItem(Data, bSelect)
  if not bSelect then
    return
  end
  if not self.FilterMap[Data.tab.id] then
    self.FilterMap[Data.tab.id] = true
    local index = Data.index
    local Item = self.SortList:GetItemByIndex(index - 1)
    Item:DoSelect()
  else
    self.FilterMap[Data.tab.id] = false
    local index = Data.index
    local Item = self.SortList:GetItemByIndex(index - 1)
    Item:DoUnSelect()
  end
end

function UMG_FurnitureScreening_C:OnReqReset()
  if not next(self.FilterMap) then
    return
  end
  for i = 0, self.SortList:GetItemCount() - 1 do
    local Item = self.SortList:GetItemByIndex(i)
    if Item and self.FilterMap[Item.data.tab.id] then
      Item:DoUnSelect()
    end
  end
  for k, v in pairs(self.FilterMap) do
    self.FilterMap[k] = nil
  end
end

function UMG_FurnitureScreening_C:OnReqConfirm()
  local Data = NRCModuleManager:GetModule("BagModule"):GetData()
  if Data and NRCModuleManager:GetModule("HomeModule"):GetData() then
    Data:SetFurnitureFilterTabMap(self.FilterMap)
    self:DispatchEvent(BagModuleEvent.UpdateFilter)
  end
  self:OnReqClose()
end

function UMG_FurnitureScreening_C:OnReqClose()
  if self.bPendingClose then
    return
  end
  self.bPendingClose = true
  _G.NRCAudioManager:PlaySound2DAuto(40008006, "UMG_FurnitureScreening_C:OnReqClose")
  self:LoadAnimation(2)
end

function UMG_FurnitureScreening_C:OnAnimationFinished(aim)
  if aim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_FurnitureScreening_C
