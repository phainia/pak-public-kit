local UMG_MainView_C = _G.NRCDraggablePanel:Extend("UMG_MainView_C")

function UMG_MainView_C:OnConstruct()
  _G.NRCDraggablePanel.OnConstruct(self)
  self.enableDrag = true
  self.isConstrainToViewport = false
  if self.TitleBar then
    self:SetDragArea(self.TitleBar)
  end
end

function UMG_MainView_C:OnDestruct()
end

function UMG_MainView_C:OnActive()
  _G.NRCDraggablePanel.OnActive(self)
  self:OnAddEventListener()
  self:InitUI()
  if self.In then
    self:PlayAnimation(self.In)
  end
end

function UMG_MainView_C:OnDeactive()
  self:OnRemoveEventListener()
  _G.NRCDraggablePanel.OnDeactive(self)
end

function UMG_MainView_C:InitUI()
  if self.TitleText then
    self.TitleText:SetText("NPC\231\188\150\232\190\145\229\153\168")
  end
  NRCModuleManager:DoCmd(PGCModuleCmd.LoadDataList, PGCModuleEnum.DataType.NPCType)
end

function UMG_MainView_C:OnAddEventListener()
  self:AddButtonListener(self.CloseButton, self.OnClickCloseButton)
  self:AddButtonListener(self.ModifyButton, self.OnClickModifyButton)
  self:AddButtonListener(self.RemoveButton, self.OnClickRemoveButton)
  self:AddButtonListener(self.AddButton, self.OnClickAddButton)
  self:AddButtonListener(self.InstanceButton, self.OnClickInstanceButton)
  self:AddButtonListener(self.TypeButton, self.OnClickTypeButton)
end

function UMG_MainView_C:OnRemoveEventListener()
  self:RemoveButtonListener(self.CloseButton, self.OnClickCloseButton)
  self:RemoveButtonListener(self.InstanceButton, self.OnClickInstanceButton)
  self:RemoveButtonListener(self.TypeButton, self.OnClickTypeButton)
  self:RemoveButtonListener(self.AddButton, self.OnClickAddButton)
  self:RemoveButtonListener(self.RemoveButton, self.OnClickRemoveButton)
  self:RemoveButtonListener(self.ModifyButton, self.OnClickModifyButton)
end

function UMG_MainView_C:OnClickCloseButton()
  NRCModuleManager:DoCmd(_G.PGCModuleCmd.CloseMainView)
end

function UMG_MainView_C:OnClickTypeButton()
  NRCModuleManager:DoCmd(_G.PGCModuleCmd.LoadDataList, PGCModuleEnum.DataType.NPCType)
end

function UMG_MainView_C:OnClickInstanceButton()
  NRCModuleManager:DoCmd(_G.PGCModuleCmd.LoadDataList, PGCModuleEnum.DataType.NPCInstance)
end

function UMG_MainView_C:OnClickAddButton()
  NRCModuleManager:DoCmd(PGCModuleCmd.AddDataItem)
end

function UMG_MainView_C:OnClickRemoveButton()
  NRCModuleManager:DoCmd(PGCModuleCmd.RemoveDataItem)
end

function UMG_MainView_C:OnClickModifyButton()
  NRCModuleManager:DoCmd(PGCModuleCmd.ModifyDataItem)
end

return UMG_MainView_C
