local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ThisTag_Item_C = Base:Extend("UMG_ThisTag_Item_C")

function UMG_ThisTag_Item_C:OnConstruct()
end

function UMG_ThisTag_Item_C:OnDestruct()
end

function UMG_ThisTag_Item_C:OnItemUpdate(_data, datalist, index)
  self.FirstSelect = true
  self.data = _data
  self.index = index
  self:InitPanel()
  self:SetOnNewState()
end

function UMG_ThisTag_Item_C:CurrentUse(_IsUse)
  if _IsUse then
    self.Checked:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Checked:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ThisTag_Item_C:SetOnNewState()
  Log.Dump(self.data, 3, "UMG_ThisTag_Item1_C:SetOnNewState")
  if self.data and self.data.id then
    local id = self.data.id
    self.RedDot:SetupKey(173, id)
  end
end

function UMG_ThisTag_Item_C:SetOnNewStateRemove()
  if self.data and self.data.id and self.RedDot and self.RedDot:IsRed() then
    self.RedDot:EraseRedPoint()
  end
end

function UMG_ThisTag_Item_C:InitPanel()
  local LabelText = self.data.label_text
  self.Text_Label:SetText(LabelText)
  self.widget:SetVisibility(UE4.ESlateVisibility.Visible)
  if -1 == self.data.label_type then
    self.widget:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_ThisTag_Item_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.ParentView:ScrollToIndex(self.index - 3, false)
    _G.NRCModuleManager:DoCmd(FriendModuleCmd.SetSelectedLabel, self.data.id)
    self:SetOnNewStateRemove()
    self:PlayAnimation(self.Click)
  else
    self:PlayAnimation(self.UnClick)
  end
end

function UMG_ThisTag_Item_C:OnDeactive()
end

return UMG_ThisTag_Item_C
