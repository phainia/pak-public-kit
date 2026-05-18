local JsonUtils = require("Common.JsonUtils")
local UMG_LuaTableReflector_C = _G.NRCPanelBase:Extend("UMG_LuaTableReflector_C")

function UMG_LuaTableReflector_C:OnConstruct()
  self.currentPageIndex = 0
  self.isAddCacheDebugData = false
  self.DisplayArray = {}
  self:AddButtonListener(self.CloseButton, self.DoClose)
  self:AddButtonListener(self.ShowCallStack, self.ShowCallStackLayer)
  self:AddButtonListener(self.DumpButton, self.ShowDumpLayer)
  self:AddButtonListener(self.ConfirmDump, self.OnConfirmDump)
  self:AddButtonListener(self.LastPage, self.OnLastPage)
  self:AddButtonListener(self.DeletePage, self.OnDeleteCurrentPage)
  self:AddButtonListener(self.NextPage, self.OnNextPage)
  self.FileNameInput.OnTextChanged:Add(self, self.OnTextChanged)
end

function UMG_LuaTableReflector_C:OnDestruct()
  self:RemoveButtonListener(self.CloseButton)
  self:RemoveButtonListener(self.ShowCallStack)
  self:RemoveButtonListener(self.DumpButton)
  self:RemoveButtonListener(self.ConfirmDump)
  self:RemoveButtonListener(self.LastPage)
  self:RemoveButtonListener(self.DeletePage)
  self:RemoveButtonListener(self.NextPage)
  self.FileNameInput.OnTextChanged:Remove(self, self.OnTextChanged)
  table.clear(self.DisplayArray)
end

function UMG_LuaTableReflector_C:OnActive(Data)
  self:AddContent(Data)
end

function UMG_LuaTableReflector_C:ShowContent(index)
  local Content = self.DisplayArray[index]
  local Data = Content[1]
  local Name = Content[2]
  local StackTrace = Content[3]
  self.CallStack:SetText(StackTrace)
  self.CallStackLayer:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.RootItem:ClearChildren()
  self.RootItem:SetData(Name, Data)
  self.Name = Name
  self.Data = Data
  self.currentPageIndex = index
  self:UpdateShowPageIndex()
end

function UMG_LuaTableReflector_C:AddContent(DataList)
  local lFlag = false
  if #DataList > 1 then
    lFlag = true
  end
  for i = 1, #DataList do
    local Data = DataList[i]
    table.insert(self.DisplayArray, {
      Data[1],
      Data[2],
      Data[3],
      lFlag
    })
    if 1 == #self.DisplayArray then
      self:ShowContent(#self.DisplayArray)
    else
      self:UpdateShowPageIndex()
    end
  end
end

function UMG_LuaTableReflector_C:SetAddMode(modeFlag)
  self.isAddCacheDebugData = modeFlag
end

function UMG_LuaTableReflector_C:ShowCallStackLayer()
  if self.CallStackLayer:GetVisibility() == UE4.ESlateVisibility.Visible then
    self.CallStackLayer:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.CallStackLayer:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_LuaTableReflector_C:ShowDumpLayer()
  if self.DumpLayer:GetVisibility() == UE4.ESlateVisibility.Visible then
    self.DumpLayer:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.DumpLayer:SetVisibility(UE4.ESlateVisibility.Visible)
    self:SetupDumpPanel()
  end
end

function UMG_LuaTableReflector_C:SetupDumpPanel()
  self.FileNameInput:SetText(self.Name)
end

function UMG_LuaTableReflector_C:OnTextChanged()
  self.FilePath:SetText(string.format("Saved/%s.json", self.FileNameInput:GetText()))
end

function UMG_LuaTableReflector_C:OnConfirmDump()
  local SaveKey = self.FileNameInput:GetText()
  Log.Dump(self.Data, 9, SaveKey)
  JsonUtils.DumpSavedSortKey(SaveKey, self.Data)
  self.DumpLayer:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_LuaTableReflector_C:OnLastPage()
  if self.currentPageIndex <= 1 then
    self.currentPageIndex = #self.DisplayArray
  else
    self.currentPageIndex = self.currentPageIndex - 1
  end
  self:ShowContent(self.currentPageIndex)
end

function UMG_LuaTableReflector_C:OnDeleteCurrentPage()
  if #self.DisplayArray > 1 then
    table.remove(self.DisplayArray, self.currentPageIndex)
    self:OnLastPage()
  else
    table.remove(self.DisplayArray, self.currentPageIndex)
    self:DoClose()
  end
end

function UMG_LuaTableReflector_C:OnNextPage()
  if self.currentPageIndex >= #self.DisplayArray then
    self.currentPageIndex = 1
  else
    self.currentPageIndex = self.currentPageIndex + 1
  end
  self:ShowContent(self.currentPageIndex)
end

function UMG_LuaTableReflector_C:UpdateShowPageIndex()
  self.ShowPageIndex:SetText(string.format("%s / %s", self.currentPageIndex, #self.DisplayArray))
end

function UMG_LuaTableReflector_C:OnDeactive()
  self.Name = nil
  self.Data = nil
end

function UMG_LuaTableReflector_C:DoClose()
  local isClear = self.module:GetIsAddCachedDebugData()
  self.module:SetCachedDebugData(self.DisplayArray, isClear)
  _G.NRCPanelBase.DoClose(self)
end

return UMG_LuaTableReflector_C
