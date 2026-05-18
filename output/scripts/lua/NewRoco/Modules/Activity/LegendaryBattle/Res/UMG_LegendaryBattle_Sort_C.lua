local UMG_LegendaryBattle_Sort_C = _G.NRCPanelBase:Extend("UMG_LegendaryBattle_Sort_C")

function UMG_LegendaryBattle_Sort_C:OnActive()
  local starTbl = {}
  local battleTbl = self.module.StarList
  self.startNum = 10 - #battleTbl + 1
  for i = self.startNum, 10 do
    table.insert(starTbl, {
      starNum = i,
      battleId = battleTbl[i]
    })
  end
  self.SortList:InitGridView(starTbl)
  self.SortList:SelectItemByIndex(self.startNum + self.module.curChooseStarNum - 2)
end

function UMG_LegendaryBattle_Sort_C:OnDeactive()
end

function UMG_LegendaryBattle_Sort_C:OnAddEventListener()
  self:AddButtonListener(self.Btn1.btnLevelUp, self.OnConfirmClick)
  self:AddButtonListener(self.Btn2.btnLevelUp, self.OnCancelClick)
end

function UMG_LegendaryBattle_Sort_C:OnRemoveListener()
end

function UMG_LegendaryBattle_Sort_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_LegendaryBattle_Sort_C:OnDestruct()
  self:OnRemoveListener()
end

function UMG_LegendaryBattle_Sort_C:OnConfirmClick()
  local selectNum = self.SortList._selectedItemIndex + self.startNum - 1
  self.module:OnSetStarNum(selectNum)
  self:OnClose()
end

function UMG_LegendaryBattle_Sort_C:OnCancelClick()
  self:OnClose()
end

return UMG_LegendaryBattle_Sort_C
